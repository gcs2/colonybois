extends RefCounted
## Six ecological slots per tier; bounded populations, no individual creature simulation.
const Geography = preload("res://scripts/planet_geography.gd")
const SurfaceLayout = preload("res://scripts/surface_region_layout.gd")
const Validation = preload("res://scripts/surface_combat.gd")
const SLOTS := ["small","medium","large","herbivore_a","herbivore_b","predator"]
const HOLD := 12
const RANGE := 13.0
static var catalog: Dictionary = {}
var state: Dictionary = {"worlds":{},"cargo":{},"catalogued":[],"completed":[]}
static func data() -> Dictionary:
	if catalog.is_empty(): catalog = JSON.parse_string(FileAccess.get_file_as_string("res://data/biosphere.json")).species
	return catalog
static func empty_layer() -> Dictionary:
	return {"small":"","medium":"","large":"","herbivore_a":"","herbivore_b":"","predator":""}
static func native_species(planet: String) -> Array:
	var origin: String = ["morrow","s1p0","s2p0"][["temperate","frozen","arid"].find(Geography.definition(planet).archetype)]
	return data().keys().filter(func(id: String) -> bool: return data()[id].home == origin)
static func fresh(planet: String) -> Dictionary:
	var layer: Dictionary = empty_layer()
	var stock: Dictionary = {}
	for id: String in native_species(planet):
		var role: String = data()[id].role
		var slot: String = ("herbivore_a" if layer.herbivore_a.is_empty() else "herbivore_b") if role == "herbivore" else role
		layer[slot] = id; stock[id] = 4
	return {"layers":[layer,empty_layer(),empty_layer()],"stock":stock,"sites":{},"stress":0,"recovery":0}
func world(planet: String) -> Dictionary: return state.worlds.get(planet,fresh(planet))
func site(planet: String, id: String) -> Vector3:
	var at: Array = world(planet).sites.get(id,[])
	return Vector3(at[0],at[1],at[2]) if at.size() == 3 else position(planet,id)
func species(planet: String) -> Array:
	var found: Array = []
	for layer: Dictionary in world(planet).layers:
		for id: String in layer.values():
			if not id.is_empty(): found.append(id)
	return found
func used() -> int:
	var count: int = 0
	for amount: int in state.cargo.values(): count += amount
	return count
func plant_tier(planet: String) -> int:
	var count: int = 0
	for layer: Dictionary in world(planet).layers:
		if layer.small.is_empty() or layer.medium.is_empty() or layer.large.is_empty(): break
		count += 1
	return count
func complete_tier(planet: String) -> int:
	var count: int = 0
	for layer: Dictionary in world(planet).layers:
		if layer.values().has(""): break
		count += 1
	return count
static func position(planet: String, id: String) -> Vector3:
	var index: int = data().keys().find(id)
	if planet == "morrow":
		var region_index: int = 0
		if id in ["ribbon_bush","pocket_manta"]: region_index = 1
		elif id in ["hollow_crown","button_strider","veil_maw"]: region_index = 2
		var habitats: Array[Dictionary] = SurfaceLayout.regions(Geography.definition(planet))
		var habitat: Dictionary = habitats[region_index]
		var angle: float = float(index)*2.399963
		var radius: float = 20.0+float(index%3)*5.0 if region_index == 0 else float(habitat.radius)*0.48
		var flat: Vector2 = habitat.center+Vector2(cos(angle),sin(angle))*radius
		return Vector3(flat.x,Geography.surface_height(Geography.definition(planet),flat.x,flat.y)+1.5,flat.y)
	var angle: float = index*2.399963
	var radius: float = 18.0+float(index%3)*5
	var flat := Vector2(cos(angle),sin(angle))*radius
	return Vector3(flat.x,Geography.surface_height(Geography.definition(planet),flat.x,flat.y)+1.5,flat.y)
func access(game: RefCounted, at: Vector3, point: Vector3) -> String:
	if game.traveling() or game.field.state.flight_mode != "surface": return "Enter the atmosphere first."
	if not at.is_finite() or not point.is_finite(): return "Position unavailable."
	if at.distance_to(point) > RANGE: return "Approach within 13 m."
	return ""
func reason(game: RefCounted, id: String, action: String, at: Vector3, point: Vector3 = Vector3.ZERO) -> String:
	if not data().has(id): return "Unknown specimen."
	var planet: String = game.field.state.planet_id
	var blocked: String = access(game,at,point if action == "release" else site(planet,id))
	if not blocked.is_empty(): return blocked
	if action in ["scan","collect"]:
		if id not in species(planet): return "Species is absent on this world."
		if action == "scan": return "Already catalogued." if id in state.catalogued else ""
		if id not in state.catalogued: return "Scan this species first."
		if used() >= HOLD: return "Specimen hold is full (12)."
		if int(world(planet).stock.get(id,0)) <= 0: return "Local population recovering."
	elif action == "release":
		if int(state.cargo.get(id,0)) <= 0: return "No specimen aboard."
		if Vector2(point.x,point.z).length() > Geography.surface_travel_radius(planet): return "Choose a site inside the explorable surface region."
		if absf(point.y-Geography.surface_height(game.field.definition(),point.x,point.z)-1.5) > 0.1: return "Choose a surface habitat."
		if id in species(planet): return "Species already established here."
		if release_slot(game,id).is_empty(): return "Needs a climate tier with a matching slot and an established food supply."
	else: return "Unknown specimen action."
	return "Need 5 energy." if game.field.state.energy < 5 else ""
func release_slot(game: RefCounted, id: String) -> Array:
	var planet: String = game.field.state.planet_id
	var layers: Array = world(planet).layers
	var tier: int = game.climate.score(game.climate.world(planet))
	for i: int in range(tier):
		var layer: Dictionary = layers[i]
		if i > 0 and layers[i-1].values().has(""): break
		var role: String = data()[id].role
		if role in ["small","medium","large"]:
			if layer[role].is_empty(): return [i,role]
		elif not layer.small.is_empty() and not layer.medium.is_empty() and not layer.large.is_empty():
			if role == "herbivore":
				for slot: String in ["herbivore_a","herbivore_b"]:
					if layer[slot].is_empty(): return [i,slot]
			elif layer.predator.is_empty() and not layer.herbivore_a.is_empty() and not layer.herbivore_b.is_empty(): return [i,"predator"]
	return []
func act(game: RefCounted, id: String, action: String, at: Vector3, point: Vector3 = Vector3.ZERO) -> String:
	var blocked: String = reason(game,id,action,at,point)
	if not blocked.is_empty(): return blocked
	var planet: String = game.field.state.planet_id
	if action == "scan":
		state.catalogued.append(id)
	else:
		game.field.state.energy -= 5
		var local: Dictionary = world(planet)
		if action == "collect":
			local.stock[id] -= 1; state.cargo[id] = int(state.cargo.get(id,0))+1
		else:
			var slot: Array = release_slot(game,id)
			state.cargo[id] -= 1
			if state.cargo[id] == 0: state.cargo.erase(id)
			local.layers[slot[0]][slot[1]] = id; local.stock[id] = 1
			local.sites[id] = [point.x,point.y,point.z]
		state.worlds[planet] = local
	game.diplomacy.record(game,"ecology",("Catalogued " if action == "scan" else "Collected " if action == "collect" else "Introduced ")+str(data()[id].name)+" at "+str(game.field.definition().name)+".","",{"planet":planet,"species":id,"action":action})
	if action == "release":
		var completed: int = complete_tier(planet)
		var key: String = planet+":"+str(completed)
		if completed > 1 and key not in state.completed:
			state.completed.append(key)
			game.field.note("ecosystem:"+key,"Ecosystem T%d established on %s." % [completed,game.field.definition().name])
	game.climate.bind(game)
	game.commerce.update_badges(game)
	return ""
func tick(game: RefCounted) -> void:
	for planet: String in state.worlds:
		var local: Dictionary = state.worlds[planet]
		local.recovery += 1
		if local.recovery >= 60:
			local.recovery = 0
			for id: String in local.stock: local.stock[id] = mini(4,local.stock[id]+1)
		var tier: int = game.climate.score(game.climate.world(planet))
		var endangered: bool = false
		for i: int in range(tier,3): endangered = endangered or not local.layers[i].values().all(func(id: String) -> bool: return id.is_empty())
		local.stress = local.stress+1 if endangered else 0
		if local.stress >= 30:
			for i: int in range(tier,3):
				for id: String in local.layers[i].values(): local.stock.erase(id); local.sites.erase(id)
				local.layers[i] = empty_layer()
			local.stress = 0
			game.diplomacy.record(game,"ecology","Habitat loss on "+str(Geography.definition(planet).name)+"; unsupported species disappeared.","",{"planet":planet,"climate_tier":tier},0,"",planet)
			game.climate.bind(game)
func restore(source: Variant) -> Error:
	if not source is Dictionary or not source.has_all(["worlds","cargo","catalogued","completed"]): return ERR_INVALID_DATA
	if not source.worlds is Dictionary or source.worlds.size() > 6144 or not source.cargo is Dictionary or not source.catalogued is Array or not source.completed is Array: return ERR_INVALID_DATA
	var count: int = 0
	for id: Variant in source.cargo:
		if not id is String or not data().has(id) or not Validation.number(source.cargo[id],1,HOLD,true): return ERR_INVALID_DATA
		count += source.cargo[id]
	if count > HOLD or source.catalogued.size() > 18 or source.completed.size() > 12288: return ERR_INVALID_DATA
	var seen: Array = []
	for id: Variant in source.catalogued:
		if not id is String or not data().has(id) or id in seen: return ERR_INVALID_DATA
		seen.append(id)
	for id: String in source.cargo:
		if id not in source.catalogued: return ERR_INVALID_DATA
	seen.clear()
	for key: Variant in source.completed:
		if not key is String or key in seen: return ERR_INVALID_DATA
		var parts: PackedStringArray = key.split(":")
		if parts.size() != 2 or Geography.definition(parts[0]).is_empty() or parts[1] not in ["2","3"]: return ERR_INVALID_DATA
		seen.append(key)
	for planet: Variant in source.worlds:
		if not planet is String or Geography.definition(planet).is_empty(): return ERR_INVALID_DATA
		var local: Variant = source.worlds[planet]
		if not local is Dictionary or not local.has_all(["layers","stock","sites","stress","recovery"]) or not local.layers is Array or local.layers.size() != 3 or not local.stock is Dictionary or not local.sites is Dictionary: return ERR_INVALID_DATA
		if not Validation.number(local.stress,0,29,true) or not Validation.number(local.recovery,0,59,true): return ERR_INVALID_DATA
		seen.clear()
		var previous_complete: bool = true
		for layer: Variant in local.layers:
			if not layer is Dictionary or layer.size() != 6 or not layer.has_all(SLOTS): return ERR_INVALID_DATA
			for slot: String in SLOTS:
				var id: Variant = layer[slot]
				if not id is String: return ERR_INVALID_DATA
				if id.is_empty(): continue
				if not data().has(id) or id in seen or data()[id].role != ("herbivore" if slot.begins_with("herbivore") else slot): return ERR_INVALID_DATA
				seen.append(id)
			if not previous_complete and not layer.values().all(func(id: String) -> bool: return id.is_empty()): return ERR_INVALID_DATA
			if not layer.herbivore_a.is_empty() or not layer.herbivore_b.is_empty() or not layer.predator.is_empty():
				if layer.small.is_empty() or layer.medium.is_empty() or layer.large.is_empty(): return ERR_INVALID_DATA
			if not layer.predator.is_empty() and (layer.herbivore_a.is_empty() or layer.herbivore_b.is_empty()): return ERR_INVALID_DATA
			previous_complete = not layer.values().has("")
		if local.stock.size() != seen.size(): return ERR_INVALID_DATA
		for id: Variant in local.stock:
			if not id is String or id not in seen or not Validation.number(local.stock[id],0,4,true): return ERR_INVALID_DATA
		for id: Variant in local.sites:
			if not id is String or id not in seen or not local.sites[id] is Array or local.sites[id].size() != 3: return ERR_INVALID_DATA
			for axis: int in range(3):
				var value: Variant = local.sites[id][axis]
				var bound: float = 100.0 if axis == 1 else Geography.surface_travel_radius(str(planet))
				if not Validation.number(value,-bound,bound): return ERR_INVALID_DATA
			if Vector2(local.sites[id][0],local.sites[id][2]).length() > Geography.surface_travel_radius(str(planet)): return ERR_INVALID_DATA
	state = source.duplicate(true)
	return OK
