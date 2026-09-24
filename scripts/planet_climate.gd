extends RefCounted
## Two global axes, paid tool pulses and shared-clock drift. No scene owns climate.
const Geography = preload("res://scripts/planet_geography.gd")
const Validation = preload("res://scripts/surface_combat.gd")
const DURATION := 8
const HOLD := 6
static var catalog: Dictionary = {}
var ecosystem: RefCounted
var state: Dictionary = {"worlds":{},"charges":{"heat_charge":0,"cool_charge":0,"atmosphere_charge":0,"vacuum_charge":0},"stock":{}}
static func data() -> Dictionary:
	if catalog.is_empty(): catalog = JSON.parse_string(FileAccess.get_file_as_string("res://data/planet_climate.json"))
	return catalog
static func baseline(planet: String) -> Vector2:
	var values: Array = data().baselines[Geography.definition(planet).archetype]
	return Vector2(values[0],values[1])
static func fresh(planet: String) -> Dictionary:
	var base: Vector2 = baseline(planet)
	return {"temperature":base.x,"atmosphere":base.y,"disturbed":false,"drift_clock":0,"project":{}}
func world(planet: String) -> Dictionary: return state.worlds.get(planet,fresh(planet))
static func score(values: Dictionary) -> int:
	var radius: float = Vector2(values.temperature-50,values.atmosphere-50).length()
	return 3 if radius <= 14 else 2 if radius <= 27 else 1 if radius <= 40 else 0
func effects(planet: String) -> Dictionary:
	var local: Dictionary = world(planet)
	var severity: float = Vector2(local.temperature-50,local.atmosphere-50).length()
	var base: float = baseline(planet).distance_to(Vector2(50,50))
	var ecological: int = mini(score(local),ecosystem.complete_tier(planet)) if ecosystem != null else score(local)
	return {"tier":score(local),"ecological_tier":ecological,"population_cap":40 if ecological == 0 else ecological*120,"power_factor":clampf((50+severity)/(50+base),0.5,2.5),"suitability_delta":(base-severity)/100}
func units() -> int:
	var result: int = 0
	for amount: int in state.charges.values(): result += amount
	return result
func stock(planet: String, port: String, tool: String) -> int:
	return int(state.stock.get(planet+":"+port,{}).get(tool,2))
func buy_reason(game: RefCounted, port: String, at: Vector3, tool: String) -> String:
	if not data().tools.has(tool) or not data().tools[tool].charge: return "Unknown terraforming supply."
	if not at.is_finite(): return "Ship position unavailable."
	var blocked: String = game.commerce.access(game,port,at)
	if not blocked.is_empty(): return blocked
	if maxi(game.commerce.state.badges.explorer,game.commerce.state.badges.merchant) < 1: return "Requires Explorer 1 or Merchant 1."
	if units() >= HOLD: return "Terraforming locker is full (6)."
	if stock(game.field.state.planet_id,port,tool) <= 0: return "This dock has no units left."
	return "Not enough Marks." if game.field.marks < data().tools[tool].price else ""
func buy(game: RefCounted, port: String, at: Vector3, tool: String) -> String:
	var blocked: String = buy_reason(game,port,at,tool)
	if not blocked.is_empty(): return blocked
	var key: String = game.field.state.planet_id+":"+port
	if not state.stock.has(key): state.stock[key] = {}
	state.stock[key][tool] = stock(game.field.state.planet_id,port,tool)-1
	state.charges[tool] += 1; game.field.marks -= data().tools[tool].price
	game.diplomacy.record(game,"terraforming","Loaded "+str(data().tools[tool].name)+".","",{"item":tool,"marks_delta":-int(data().tools[tool].price)})
	return ""
func available(field: RefCounted, tool: String) -> String:
	var spec: Dictionary = data().tools[tool]
	if spec.charge: return "No unit aboard. Buy one at a dock." if state.charges[tool] == 0 else ""
	return "Purchase this tool at a dock." if tool not in field.installed_upgrades else ""
func reason(game: RefCounted, tool: String, at: Vector3) -> String:
	if game.traveling(): return "Finish the jump first."
	if not data().tools.has(tool): return "Unknown climate tool."
	var blocked: String = available(game.field,tool)
	if not blocked.is_empty(): return blocked
	var planet: String = game.field.state.planet_id
	if planet == game.field.state.homeworld_id: return "Homeworld climate is protected."
	if game.field.state.survey_ticks < game.field.definition().survey_seconds: return "Complete an orbital survey first."
	if not at.is_finite(): return "Ship position unavailable."
	if game.field.state.flight_mode == "orbit" and at.distance_to(Vector3(-14,-8,-14)) > 95: return "Approach within 95 m of the planet."
	var local: Dictionary = world(planet)
	if not local.project.is_empty(): return "A climate pulse is already settling on this world."
	var spec: Dictionary = data().tools[tool]
	if (spec.delta > 0 and local[spec.axis] >= 100) or (spec.delta < 0 and local[spec.axis] <= 0): return "This climate axis is at its limit."
	if game.field.state.energy < spec.energy: return "Need %d energy." % spec.energy
	return ""
func start(game: RefCounted, tool: String, at: Vector3) -> String:
	var blocked: String = reason(game,tool,at)
	if not blocked.is_empty(): return blocked
	var planet: String = game.field.state.planet_id
	var local: Dictionary = world(planet)
	var spec: Dictionary = data().tools[tool]
	game.field.state.energy -= spec.energy
	if spec.charge: state.charges[tool] -= 1
	local.project = {"tool":tool,"from":float(local[spec.axis]),"to":clampf(float(local[spec.axis])+float(spec.delta),0,100),"remaining":DURATION}
	state.worlds[planet] = local
	if not game.biosphere.state.worlds.has(planet): game.biosphere.state.worlds[planet] = game.biosphere.world(planet)
	game.diplomacy.record(game,"terraforming","Deployed "+str(spec.name)+" at "+str(game.field.definition().name)+".","",{"planet":planet,"tool":tool,"energy":spec.energy,"consumed":spec.charge})
	return ""
func tick(game: RefCounted) -> void:
	for planet: String in state.worlds:
		var local: Dictionary = state.worlds[planet]
		if not local.project.is_empty():
			var project: Dictionary = local.project
			var spec: Dictionary = data().tools[project.tool]
			project.remaining -= 1
			local[spec.axis] = lerpf(project.from,project.to,1.0-float(project.remaining)/DURATION)
			local.drift_clock = 0
			if project.remaining == 0:
				game.recognition.climate_completed(planet,score(local))
				game.diplomacy.record(game,"terraforming","Climate pulse settled on "+str(Geography.definition(planet).name)+".","",{"planet":planet,"temperature":local.temperature,"atmosphere":local.atmosphere,"tier":score(local)},0,"",planet)
				local.project = {}
		else:
			local.drift_clock += 1
			if local.drift_clock >= 30:
				local.drift_clock = 0
				var native: Vector2 = baseline(planet)
				var next: Dictionary = local.duplicate(true)
				next.temperature = move_toward(local.temperature,native.x,1.0)
				next.atmosphere = move_toward(local.atmosphere,native.y,1.0)
				var floor_tier: int = mini(score(local),game.biosphere.plant_tier(planet))
				if score(next) >= floor_tier:
					local.temperature = next.temperature; local.atmosphere = next.atmosphere
		if not local.disturbed and Vector2(local.temperature,local.atmosphere).distance_to(baseline(planet)) >= 9.99:
			local.disturbed = true
			var owner: String = game.sector.state.planets[planet].owner
			for faction: Dictionary in game.sector.state.factions:
				if not faction.get("contacted",false): continue
				var penalty: int = 20 if faction.id == owner else 8 if faction.id == "commune" else 0
				if penalty == 0: continue
				faction.relation = maxi(-100,int(faction.relation)-penalty); faction.embargo = int(faction.relation) < -15
				faction.reason = "Your terraforming altered "+str(Geography.definition(planet).name)+"'s native climate (−%d)." % penalty
				game.diplomacy.record(game,"diplomacy",faction.reason,faction.id,{"planet":planet,"relation_delta":-penalty},0,"climate_objection:"+planet+":"+str(faction.id),planet)
		game.sector.climate_effects[planet] = effects(planet)
		if game.sector.state.colonies.has(planet): game.sector.refresh_colony(planet)
func bind(game: RefCounted) -> void:
	ecosystem = game.biosphere
	game.field.planetary = self
	game.sector.climate_effects.clear()
	for planet: String in state.worlds:
		game.sector.climate_effects[planet] = effects(planet)
		if game.sector.state.colonies.has(planet): game.sector.refresh_colony(planet)
func restore(source: Variant, upgrades: Array) -> Error:
	if not source is Dictionary or not source.has_all(["worlds","charges","stock"]): return ERR_INVALID_DATA
	if not source.worlds is Dictionary or source.worlds.size() > 23 or not source.charges is Dictionary or source.charges.size() != 4 or not source.stock is Dictionary or source.stock.size() > 48: return ERR_INVALID_DATA
	var count: int = 0
	for id: String in state.charges:
		if not source.charges.has(id) or not source.charges[id] is int or source.charges[id] < 0 or source.charges[id] > HOLD: return ERR_INVALID_DATA
		count += source.charges[id]
	if count > HOLD: return ERR_INVALID_DATA
	for key: Variant in source.stock:
		if not key is String or not source.stock[key] is Dictionary or source.stock[key].size() > 4: return ERR_INVALID_DATA
		var parts: PackedStringArray = key.split(":")
		if parts.size() != 2 or Geography.definition(parts[0]).is_empty() or parts[1] not in ["basin_port","orbit_tender"]: return ERR_INVALID_DATA
		for tool: Variant in source.stock[key]:
			if not tool is String or not state.charges.has(tool) or not Validation.number(source.stock[key][tool],0,2,true): return ERR_INVALID_DATA
	for planet: Variant in source.worlds:
		if not planet is String or planet == "morrow" or Geography.definition(planet).is_empty(): return ERR_INVALID_DATA
		var local: Variant = source.worlds[planet]
		if not local is Dictionary or not local.has_all(["temperature","atmosphere","disturbed","drift_clock","project"]): return ERR_INVALID_DATA
		if not Validation.number(local.temperature,0,100) or not Validation.number(local.atmosphere,0,100) or not local.disturbed is bool or not Validation.number(local.drift_clock,0,29,true) or not local.project is Dictionary: return ERR_INVALID_DATA
		if local.project.is_empty(): continue
		var p: Dictionary = local.project
		if not p.has_all(["tool","from","to","remaining"]) or not p.tool is String or not data().tools.has(p.tool): return ERR_INVALID_DATA
		var spec: Dictionary = data().tools[p.tool]
		if not spec.charge and p.tool not in upgrades: return ERR_INVALID_DATA
		if not Validation.number(p.from,0,100) or not Validation.number(p.to,0,100) or not Validation.number(p.remaining,1,DURATION,true): return ERR_INVALID_DATA
		if not is_equal_approx(p.to,clampf(float(p.from)+spec.delta,0,100)): return ERR_INVALID_DATA
		if not is_equal_approx(local[spec.axis],lerpf(p.from,p.to,1.0-float(p.remaining)/DURATION)): return ERR_INVALID_DATA
	state = source.duplicate(true)
	return OK
