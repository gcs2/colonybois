extends RefCounted
## Persistent combat records; visual nodes never own damage or projectile outcomes.
const Geography = preload("res://scripts/planet_geography.gd")
static var catalog: Dictionary = {}
var state: Dictionary = {"worlds":{},"ready":0,"fired":0}
var impacts: Array = [] # Cosmetic notifications, deliberately excluded from saves.
static func data() -> Dictionary:
	if catalog.is_empty(): catalog = JSON.parse_string(FileAccess.get_file_as_string("res://data/surface_combat.json"))
	return catalog
static func profiles(planet: String) -> Dictionary: return data().worlds.get(planet,{})
static func position(values: Array) -> Vector3: return Vector3(values[0],values[1],values[2])
static func packed(at: Vector3) -> Array: return [at.x,at.y,at.z]
static func home(planet: String, id: String) -> Vector3:
	var unit: Dictionary = profiles(planet)[id]
	return Vector3(unit.at[0],Geography.surface_height(Geography.definition(planet),unit.at[0],unit.at[1])+(11 if unit.kind == "air" else 2.0),unit.at[1])
static func fresh(planet: String) -> Dictionary:
	var result: Dictionary = {"units":{},"shots":[]}
	for id: String in profiles(planet):
		result.units[id] = {"hull":float(profiles(planet)[id].hull),"at":packed(home(planet,id)),"ready":0,"fire_at":0,"aim":[0.0,0.0,0.0],"salvaged":false}
	return result
func world(planet: String) -> Dictionary: return state.worlds.get(planet,fresh(planet))
func cleared() -> int:
	var count: int = 0
	for planet: String in state.worlds:
		for unit: Dictionary in state.worlds[planet].units.values():
			if unit.hull == 0: count += 1
	return count
static func installed(field: RefCounted, weapon: String) -> bool:
	if not data().weapons.has(weapon): return false
	var required: String = data().weapons[weapon].upgrade
	return required.is_empty() or required in field.installed_upgrades
func reason(game: RefCounted, weapon: String, target: String, point: Vector3, at: Vector3) -> String:
	if game.traveling() or game.field.state.flight_mode != "surface": return "Enter the atmosphere to use this weapon."
	if not installed(game.field,weapon): return "Purchase this weapon at a dock."
	if not at.is_finite() or not point.is_finite(): return "Invalid targeting coordinates."
	var spec: Dictionary = data().weapons[weapon]
	var planet: String = game.field.state.planet_id
	var local: Dictionary = world(planet)
	if weapon != "ground_bomb":
		if not local.units.has(target) or local.units[target].hull <= 0: return "Select a live hostile target."
		if weapon == "seeker" and profiles(planet)[target].kind != "air": return "Missiles require a flying target."
		point = position(local.units[target].at)
	else:
		if Vector2(point.x,point.z).length() > 38: return "Aim within the surface flight area."
		point.y = Geography.surface_height(game.field.definition(),point.x,point.z)
	if at.distance_to(point) > float(spec.range): return "Approach within weapon range."
	if game.field.state.time < state.ready: return "Weapon cooling down."
	if game.field.state.energy < float(spec.energy): return "Need %d energy." % spec.energy
	return ""
func fire(game: RefCounted, weapon: String, target: String, point: Vector3, at: Vector3) -> String:
	var blocked: String = reason(game,weapon,target,point,at)
	if not blocked.is_empty(): return blocked
	var planet: String = game.field.state.planet_id
	var local: Dictionary = world(planet)
	state.worlds[planet] = local
	var spec: Dictionary = data().weapons[weapon]
	game.field.state.energy -= float(spec.energy)
	state.ready = int(game.field.state.time)+int(spec.cooldown)
	state.fired += 1
	if weapon == "surface_laser":
		impacts.append({"planet":planet,"time":game.field.state.time,"at":local.units[target].at.duplicate(),"radius":1.4})
		_damage(game,planet,target,float(spec.damage))
	else:
		if weapon == "ground_bomb": point.y = Geography.surface_height(game.field.definition(),point.x,point.z)
		else: point = position(local.units[target].at)
		local.shots.append({"weapon":weapon,"target":target,"origin":packed(at),"point":packed(point),"launch":int(game.field.state.time),"impact":int(game.field.state.time)+int(spec.delay)})
	return ""
func _damage(game: RefCounted, planet: String, target: String, amount: float) -> void:
	var unit: Dictionary = state.worlds[planet].units[target]
	if unit.hull <= 0: return
	unit.hull = maxf(0,float(unit.hull)-amount)
	if unit.hull > 0: return
	unit.fire_at = 0
	if profiles(planet)[target].kind == "air":
		var at: Vector3 = position(unit.at)
		unit.at[1] = Geography.surface_height(Geography.definition(planet),at.x,at.z)+1.0
	game.diplomacy.record(game,"combat",profiles(planet)[target].name+" neutralized on "+Geography.definition(planet).name+".","",{"planet":planet,"surface_target":target},0,"surface_defeat:"+planet+":"+target)
	game.commerce.update_badges(game)
func resolve(game: RefCounted) -> void:
	# Player projectiles finish on the shared clock even after departure; hidden AI never attacks the ship.
	impacts = impacts.filter(func(event: Dictionary) -> bool: return event.time >= game.field.state.time-1)
	for planet: String in state.worlds:
		var local: Dictionary = state.worlds[planet]
		for shot: Dictionary in local.shots:
			if shot.impact > game.field.state.time: continue
			var spec: Dictionary = data().weapons[shot.weapon]
			impacts.append({"planet":planet,"time":game.field.state.time,"at":local.units[shot.target].at.duplicate() if shot.weapon == "seeker" else shot.point.duplicate(),"radius":2.5 if shot.weapon == "seeker" else spec.radius})
			if shot.weapon == "seeker": _damage(game,planet,shot.target,float(spec.damage))
			else:
				for id: String in local.units:
					var at: Vector3 = position(local.units[id].at)
					if profiles(planet)[id].kind == "ground" and Vector2(at.x,at.z).distance_to(Vector2(shot.point[0],shot.point[2])) <= float(spec.radius): _damage(game,planet,id,float(spec.damage))
		local.shots = local.shots.filter(func(shot: Dictionary) -> bool: return shot.impact > game.field.state.time)
		if planet != game.field.state.planet_id or game.field.state.flight_mode != "surface" or game.traveling():
			for unit: Dictionary in local.units.values(): unit.fire_at = 0
func step(game: RefCounted, ship: Vector3) -> String:
	var planet: String = game.field.state.planet_id
	if game.traveling() or game.field.state.flight_mode != "surface" or profiles(planet).is_empty() or not ship.is_finite(): return ""
	var local: Dictionary = world(planet)
	state.worlds[planet] = local
	var event: String = ""
	for id: String in local.units:
		var unit: Dictionary = local.units[id]
		if unit.hull <= 0: continue
		var spec: Dictionary = profiles(planet)[id]
		var at: Vector3 = position(unit.at)
		var target: Vector3 = ship
		for escort: Vector3 in game.fleet.positions(game):
			if escort.distance_to(at) < target.distance_to(at): target = escort
		var intruding: bool = home(planet,id).distance_to(ship) < 32
		if spec.kind == "air":
			var destination: Vector3 = home(planet,id)
			if intruding: destination = ship+Vector3(0,4,0)
			at = at.move_toward(destination,4)
			at = home(planet,id)+(at-home(planet,id)).limit_length(18)
			at.y = maxf(at.y,Geography.surface_height(game.field.definition(),at.x,at.z)+6)
			unit.at = packed(at)
		if unit.fire_at > 0:
			if unit.fire_at > game.field.state.time: continue
			unit.fire_at = 0; unit.ready = int(game.field.state.time)+4
			game.fleet.hit_volume(game,position(unit.aim),float(spec.radius),float(spec.damage))
			if ship.distance_to(position(unit.aim)) <= float(spec.radius):
				game.field.state.hull = maxf(0,float(game.field.state.hull)-float(spec.damage)); event = "hit"
				if game.field.state.hull <= 0:
					game.field._emergency_tow()
					for other: Dictionary in local.units.values(): other.fire_at = 0
					return "tow"
			elif event != "hit": event = "miss"
		elif intruding and at.distance_to(ship) <= float(spec.range) and game.field.state.time >= unit.ready:
			unit.aim = packed(target); unit.fire_at = int(game.field.state.time)+int(spec.windup)
			if event.is_empty(): event = "aim"
	return event
func salvage(game: RefCounted, target: String, at: Vector3) -> String:
	if game.traveling() or game.field.state.flight_mode != "surface": return "Approach the surface wreck."
	var planet: String = game.field.state.planet_id
	var local: Dictionary = world(planet)
	if not local.units.has(target) or local.units[target].hull > 0: return "Neutralize this target first."
	var unit: Dictionary = local.units[target]
	if unit.salvaged: return "Cargo already recovered."
	if not at.is_finite() or at.distance_to(position(unit.at)) > 9: return "Approach the wreck within 9 m."
	if game.commerce.used_space(game) >= game.commerce.capacity(): return "Cargo hold is full."
	game.commerce.add_cargo(profiles(planet)[target].goods,1,planet)
	unit.salvaged = true
	game.diplomacy.record(game,"combat","Recovered cargo from "+str(profiles(planet)[target].name)+".","",{"planet":planet,"surface_target":target,"quantity":1})
	return ""
static func number(value: Variant, low: float, high: float, integral: bool = false) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value >= low and value <= high and (not integral or value == floorf(value))
static func vector_valid(value: Variant) -> bool:
	if not value is Array or value.size() != 3: return false
	for axis: Variant in value:
		if not number(axis,-100,100): return false
	return true
func restore(source: Variant, time: int, upgrades: Array) -> Error:
	if not source is Dictionary or not source.has_all(["worlds","ready","fired"]) or not source.worlds is Dictionary: return ERR_INVALID_DATA
	if not number(source.ready,0,time+4,true) or not number(source.fired,0,1e9,true) or source.worlds.size() > data().worlds.size(): return ERR_INVALID_DATA
	for planet: Variant in source.worlds:
		if not planet is String or not data().worlds.has(planet): return ERR_INVALID_DATA
		var local: Variant = source.worlds[planet]
		if not local is Dictionary or not local.get("units") is Dictionary or not local.get("shots") is Array or local.shots.size() > 2: return ERR_INVALID_DATA
		if local.units.size() != profiles(planet).size(): return ERR_INVALID_DATA
		for id: String in profiles(planet):
			var unit: Variant = local.units.get(id)
			if not unit is Dictionary or not unit.has_all(["hull","at","ready","fire_at","aim","salvaged"]): return ERR_INVALID_DATA
			if not number(unit.hull,0,profiles(planet)[id].hull) or not number(unit.ready,0,time+4,true) or not number(unit.fire_at,0,time+3,true): return ERR_INVALID_DATA
			if not vector_valid(unit.at) or not vector_valid(unit.aim) or not unit.salvaged is bool: return ERR_INVALID_DATA
			if position(unit.at).distance_to(home(planet,id)) > (30.0 if unit.hull == 0 else 18.01): return ERR_INVALID_DATA
			if profiles(planet)[id].kind == "ground" and position(unit.at).distance_to(home(planet,id)) > 0.01: return ERR_INVALID_DATA
			if (unit.salvaged or unit.fire_at > 0) and (unit.hull > 0 if unit.salvaged else unit.hull <= 0): return ERR_INVALID_DATA
		for shot: Variant in local.shots:
			if not shot is Dictionary or not shot.has_all(["weapon","target","origin","point","launch","impact"]): return ERR_INVALID_DATA
			if shot.weapon not in ["seeker","ground_bomb"] or not shot.target is String or not vector_valid(shot.origin) or not vector_valid(shot.point): return ERR_INVALID_DATA
			if data().weapons[shot.weapon].upgrade not in upgrades: return ERR_INVALID_DATA
			if not number(shot.launch,0,time,true) or not number(shot.impact,time+1,time+2,true) or shot.impact != shot.launch+2: return ERR_INVALID_DATA
			if shot.weapon == "seeker" and (not local.units.has(shot.target) or profiles(planet)[shot.target].kind != "air"): return ERR_INVALID_DATA
			if shot.weapon == "ground_bomb" and Vector2(shot.point[0],shot.point[2]).length() > 38: return ERR_INVALID_DATA
	state = source.duplicate(true)
	return OK
