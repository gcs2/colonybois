extends RefCounted
## Allied loans remain ships with damage and history, not a temporary damage bonus.
const Combat = preload("res://scripts/surface_combat.gd")
const Geography = preload("res://scripts/planet_geography.gd")
const Field = preload("res://scripts/encounter_state.gd")
const REPLACEMENT_COST := 120
const REPLACEMENT_DELAY := 60
var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/allied_fleet.json"))
var state: Dictionary = {"ships":{},"assist":true,"context":"","last_step":-1}
var flashes: Array = [] # Render-only beam events, never authoritative projectiles.

func capacity(game: RefCounted) -> int:
	# Scenario bridge until reference master ranks are implemented. Peaceful paths qualify.
	return mini(3,maxi(int(game.commerce.state.badges.explorer),maxi(int(game.commerce.state.badges.merchant),int(game.commerce.state.badges.defender))))
func active_ids() -> Array:
	var result: Array = []
	for id: String in state.ships:
		if state.ships[id].status == "active": result.append(id)
	return result
func active(game: RefCounted) -> Array:
	return [] if game.traveling() else active_ids()
func positions(game: RefCounted) -> Array:
	var result: Array = []
	for id: String in active(game): result.append(Combat.position(state.ships[id].at))
	return result
func allied(game: RefCounted, id: String) -> bool:
	return id+":alliance" in game.sector.state.agreements and not game.sector.faction_by_id(id).get("embargo",false)
func reason(game: RefCounted, id: String, action: String, at: Vector3 = Vector3.ZERO) -> String:
	if game.traveling(): return "Wait until the jump ends."
	if not at.is_finite(): return "Ship position unavailable."
	if not catalog.has(id): return "Unknown fleet partner."
	var ship: Dictionary = state.ships.get(id,{})
	if action == "dismiss": return "" if ship.get("status") == "active" else "No escort assigned."
	if action == "repair":
		if ship.get("status") != "active": return "No escort assigned."
		if ship.hull >= catalog[id].hull: return "Hull is sound."
		var dock: String = "orbit_tender" if game.field.state.flight_mode == "orbit" else "basin_port"
		var blocked: String = game.commerce.access(game,dock,at)
		if not blocked.is_empty(): return blocked
		return "Not enough Marks for repairs." if game.field.marks < repair_cost(id) else ""
	if action != "recruit": return "Unknown fleet order."
	if not allied(game,id): return "Requires an active alliance and open relations."
	if game.field.state.flight_mode != "orbit" or game.owner_of(game.field.state.planet_id) != id: return "Request a ship while orbiting in your ally's territory."
	if ship.get("status") == "active": return "This ally already has a ship in your fleet."
	if active_ids().size() >= capacity(game): return "No fleet slot available. Earn another Explorer, Merchant or Defender tier."
	if ship.get("status") == "lost":
		if game.field.state.time < ship.available: return "Replacement preparing · %d s." % (ship.available-game.field.state.time)
		if game.field.marks < REPLACEMENT_COST: return "Replacement contribution requires 120 Marks."
	return ""
func repair_cost(id: String) -> int:
	return ceili((float(catalog[id].hull)-float(state.ships[id].hull))*0.8)
func command(game: RefCounted, id: String, action: String, at: Vector3 = Vector3.ZERO) -> String:
	var blocked: String = reason(game,id,action,at)
	if not blocked.is_empty(): return blocked
	var cost: int = 0
	if action == "recruit":
		if not state.ships.has(id): state.ships[id] = {"hull":float(catalog[id].hull),"status":"returned","at":[0.0,8.0,35.0],"ready":0,"available":0,"losses":0,"sortie":0}
		var ship: Dictionary = state.ships[id]
		if ship.status == "lost":
			cost = REPLACEMENT_COST; ship.hull = float(catalog[id].hull)
		ship.status = "active"; ship.sortie += 1
		ship.at = Combat.packed(at)
		ship.ready = int(game.field.state.time)+3
		state.context = "" # Spawn into the new local formation on the next combat tick.
	elif action == "dismiss": state.ships[id].status = "returned"
	elif action == "repair":
		cost = repair_cost(id); state.ships[id].hull = float(catalog[id].hull)
	game.field.marks -= cost
	game.diplomacy.record(game,"fleet",str(catalog[id].name)+" · "+action+".",id,{"action":action,"marks_delta":-cost,"hull":state.ships[id].hull,"sortie":state.ships[id].sortie})
	return ""
func reconcile(game: RefCounted) -> void:
	for id: String in active_ids():
		if allied(game,id): continue
		state.ships[id].status = "returned"
		game.diplomacy.record(game,"fleet",str(catalog[id].name)+" recalled: alliance or access ended.",id,{"action":"recall","hull":state.ships[id].hull})
func set_assist(game: RefCounted, enabled: bool) -> void:
	if enabled == state.assist: return
	state.assist = enabled
	game.diplomacy.record(game,"fleet","Escorts will "+("assist your selected attack." if enabled else "hold fire and follow."),"",{"assist":enabled})
func formation(game: RefCounted, ship: Vector3, index: int) -> Vector3:
	var offset: Vector3 = [Vector3(-7,1,6),Vector3(7,1,6),Vector3(0,3,11)][index]
	var at: Vector3 = ship+offset
	if game.field.state.flight_mode == "surface":
		var flat := Vector2(at.x,at.z).limit_length(38)
		at.x = flat.x; at.z = flat.y
		at.y = maxf(at.y,Geography.surface_height(game.field.definition(),at.x,at.z)+4)
	else:
		var center := Vector3(-14,-8,-14)
		if at.distance_to(center) < 20: at = center+(at-center).normalized()*20
	return at
func prepare(game: RefCounted, ship: Vector3) -> void:
	if game.traveling() or not ship.is_finite(): return
	reconcile(game)
	var context: String = game.field.state.planet_id+":"+game.field.state.flight_mode
	if state.last_step == game.field.state.time and state.context == context: return
	state.last_step = int(game.field.state.time)
	flashes.clear()
	var index: int = 0
	for id: String in active_ids():
		var unit: Dictionary = state.ships[id]
		var destination: Vector3 = formation(game,ship,index)
		var from: Vector3 = Combat.position(unit.at)
		var at: Vector3 = destination if state.context != context else from.move_toward(destination,18)
		if game.field.state.flight_mode == "surface": at.y = maxf(at.y,Geography.surface_height(game.field.definition(),at.x,at.z)+4)
		else:
			var center := Vector3(-14,-8,-14)
			if at.distance_to(center) < 20: at = center+(at-center).normalized()*20
		unit.at = Combat.packed(at)
		index += 1
	state.context = context
func hit_volume(game: RefCounted, point: Vector3, radius: float, damage: float) -> void:
	for id: String in active(game):
		var unit: Dictionary = state.ships[id]
		if Combat.position(unit.at).distance_to(point) > radius: continue
		unit.hull = maxf(0,float(unit.hull)-damage)
		if unit.hull > 0: continue
		unit.status = "lost"; unit.losses += 1; unit.available = int(game.field.state.time)+REPLACEMENT_DELAY
		var f: Dictionary = game.sector.faction_by_id(id)
		f.relation = maxi(-100,int(f.relation)-7); f.embargo = int(f.relation) < -15
		f.reason = "Our escort was lost under your command (−7)."
		game.diplomacy.record(game,"fleet",str(catalog[id].name)+" lost in combat. Relations −7.",id,{"action":"lost","losses":unit.losses,"relation":f.relation},0,"escort_loss:"+id+":"+str(unit.losses))
	reconcile(game)
func orbit_hits(game: RefCounted, old_shots: int, old_pulse: int) -> void:
	if game.traveling() or game.field.state.flight_mode != "orbit": return
	var field: RefCounted = game.field
	if field.state.guardian_shots > old_shots:
		hit_volume(game,Combat.position(field.state.guardian_aim),maxf(0.5,float(field.enemy_profile().radius)),float(field.enemy_profile().damage))
	if field.has_wreck() and old_pulse == 5 and field.state.threat_clock == 0:
		hit_volume(game,Field.WRECK_POSITION,Field.HAZARD_RADIUS,18)
func assist(game: RefCounted, target: String, engaged: bool, ship: Vector3) -> void:
	if not engaged or not state.assist or game.traveling(): return
	var orbital: bool = game.field.state.flight_mode == "orbit"
	for id: String in active_ids():
		var unit: Dictionary = state.ships[id]
		if unit.ready > game.field.state.time: continue
		var at: Vector3 = Combat.position(unit.at)
		if at.distance_to(ship) > 36: continue
		var endpoint: Vector3
		if orbital and target == "raid":
			if not game.conflict.local(game): return
			endpoint = Combat.position(game.conflict.state.raid.at)
		elif orbital:
			if target != "guardian" or not game.field.has_guardian() or game.field.state.guardian_disabled: return
			endpoint = game.field.guardian_position()
		else:
			if not game.territory.active_enemy(game,game.field.state.planet_id): return
			var local: Dictionary = game.combat.world(game.field.state.planet_id)
			if not local.units.has(target) or local.units[target].hull <= 0: return
			endpoint = Combat.position(local.units[target].at)
		if at.distance_to(endpoint) > 32: continue
		unit.ready = int(game.field.state.time)+int(catalog[id].cycle)
		flashes.append({"id":id,"origin":Combat.packed(at),"end":Combat.packed(endpoint)})
		if orbital and target == "raid":
			game.conflict.damage(game,float(catalog[id].damage)*game.field.damage_multiplier())
		elif orbital:
			game.field.damage_guardian(float(catalog[id].damage)*game.field.damage_multiplier())
			if game.field.state.guardian_disabled:
				game.diplomacy.record(game,"combat",game.field.enemy_profile().name+" neutralized with allied support.",id,{"planet":game.field.state.planet_id},0,"defeat:"+game.field.state.planet_id)
				game.commerce.update_badges(game)
		else:
			game.combat.state.worlds[game.field.state.planet_id] = game.combat.world(game.field.state.planet_id)
			game.combat._damage(game,game.field.state.planet_id,target,float(catalog[id].damage)*game.field.damage_multiplier())
func restore(value: Variant, time: int, sector: RefCounted) -> Error:
	if not value is Dictionary or not value.has_all(["ships","assist","context","last_step"]): return ERR_INVALID_DATA
	if not value.ships is Dictionary or value.ships.size() > 3 or not value.assist is bool or not value.context is String: return ERR_INVALID_DATA
	if not Combat.number(value.last_step,-1,time,true): return ERR_INVALID_DATA
	if not value.context.is_empty():
		var parts: PackedStringArray = value.context.split(":")
		if parts.size() != 2 or Geography.definition(parts[0]).is_empty() or parts[1] not in ["orbit","surface"]: return ERR_INVALID_DATA
	for id: Variant in value.ships:
		if not id is String or not catalog.has(id): return ERR_INVALID_DATA
		var unit: Variant = value.ships[id]
		if not unit is Dictionary or not unit.has_all(["hull","status","at","ready","available","losses","sortie"]): return ERR_INVALID_DATA
		if unit.status not in ["active","returned","lost"] or not Combat.number(unit.hull,0,catalog[id].hull) or not Combat.vector_valid(unit.at): return ERR_INVALID_DATA
		if (unit.hull == 0) != (unit.status == "lost"): return ERR_INVALID_DATA
		if not Combat.number(unit.ready,0,time+3,true) or not Combat.number(unit.available,0,time+REPLACEMENT_DELAY,true): return ERR_INVALID_DATA
		if not Combat.number(unit.losses,0,100000,true) or not Combat.number(unit.sortie,1,1000000,true) or unit.losses > unit.sortie: return ERR_INVALID_DATA
		if unit.status == "active" and (id+":alliance" not in sector.state.agreements or sector.faction_by_id(id).get("embargo",false)): return ERR_INVALID_DATA
	state = value.duplicate(true)
	return OK
