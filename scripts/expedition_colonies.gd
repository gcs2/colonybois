extends RefCounted
## Paid ship-carried colony kits and aggregate export outposts; no citizen agents.
const Geography = preload("res://scripts/planet_geography.gd")
const Settlement = preload("res://scripts/settlement_projects.gd")
const KIT_SPACE := 4
const STORAGE := 16
var state: Dictionary = {"kit_source":"","outposts":{}}

func reserved_space() -> int:
	return KIT_SPACE if not str(state.kit_source).is_empty() else 0

static func strategic_id(id: String) -> String:
	return "s0p0" if id == "morrow" else id

func buy_reason(game: RefCounted, port: String, at: Vector3) -> String:
	var blocked: String = game.commerce.access(game,port,at)
	if not blocked.is_empty(): return blocked
	if reserved_space() > 0: return "A colony kit is already aboard."
	if game.sector.state.colonies.size()+game.sector.state.settlements.size() >= 3: return "Three colony sites are already committed."
	var id: String = strategic_id(game.field.state.planet_id)
	if not game.sector.state.colonies.has(id): return "Load a colony kit at one of your established colonies."
	if game.commerce.quantity()+KIT_SPACE > game.commerce.capacity(): return "Reserve four cargo spaces for the kit."
	var source: Dictionary = game.sector.state.colonies[id]
	if game.field.marks < Settlement.MARKS or source.materials < Settlement.MATERIALS or source.supplies < Settlement.SUPPLIES: return "Requires 300 Marks, 100 colony materials and 80 colony supplies."
	return ""

func buy_kit(game: RefCounted, port: String, at: Vector3) -> String:
	var blocked: String = buy_reason(game,port,at)
	if not blocked.is_empty(): return blocked
	var id: String = strategic_id(game.field.state.planet_id)
	game.field.marks -= Settlement.MARKS
	game.sector.state.colonies[id].materials -= Settlement.MATERIALS
	game.sector.state.colonies[id].supplies -= Settlement.SUPPLIES
	state.kit_source = id
	game.diplomacy.record(game,"colonies","Loaded a colony kit: 300 Marks, 100 materials and 80 supplies committed.","",{"source":id,"cargo_space":KIT_SPACE})
	return ""

func deployment_reason(game: RefCounted) -> String:
	if game.traveling(): return "Finish the jump first."
	if reserved_space() == 0: return "Load a colony kit at a home dock first."
	if game.field.state.flight_mode != "surface": return "Enter the atmosphere before deploying."
	if game.field.state.survey_ticks < game.field.definition().survey_seconds: return "Complete an orbital survey before choosing a site."
	var id: String = strategic_id(game.field.state.planet_id)
	if not str(game.sector.state.planets[id].owner).is_empty() or game.sector.state.settlements.has(id): return "This world is already claimed or under construction."
	if game.sector.state.colonies.size()+game.sector.state.settlements.size() >= 3: return "Three colony sites are already committed."
	return ""

static func site_reason(planet: String, at: Vector2) -> String:
	if not is_finite(at.x) or not is_finite(at.y) or at.length() > 27: return "Choose a site inside the surveyed basin."
	# Preserve the visible wetland, wild pods, relay, mineral patch and service approach.
	for exclusion: Vector3 in [Vector3(-23,0,12),Vector3(-7,4,9),Vector3(9,-13,9),Vector3(8,-4,9),Vector3(0,12,9)]:
		if at.distance_to(Vector2(exclusion.x,exclusion.y)) < exclusion.z: return "Leave clearance around the water, native life, relics and landing approach."
	var definition: Dictionary = Geography.definition(planet)
	var low: float = INF
	var high: float = -INF
	for offset: Vector2 in [Vector2.ZERO,Vector2(-4,-4),Vector2(4,-4),Vector2(-4,4),Vector2(4,4)]:
		var h: float = Geography.surface_height(definition,at.x+offset.x,at.y+offset.y)
		low = minf(low,h); high = maxf(high,h)
	if high-low > 1.6: return "Terrain is too steep for the landing hub."
	return ""

func deploy(game: RefCounted, at: Vector2, ship: Vector3) -> String:
	var blocked: String = deployment_reason(game)
	if not blocked.is_empty(): return blocked
	blocked = site_reason(game.field.state.planet_id,at)
	if not blocked.is_empty(): return blocked
	var ground := Vector3(at.x,Geography.surface_height(game.field.definition(),at.x,at.y),at.y)
	if ground.distance_to(ship) > 12: return "Fly within 12 metres of the site to unload."
	var id: String = strategic_id(game.field.state.planet_id)
	game.sector.state.settlements[id] = {"source":state.kit_source,"remaining":Settlement.DAYS,"duration":Settlement.DAYS,"delivered":true}
	state.outposts[id] = {"site":[at.x,at.y],"module":"","stock":{"alloy":0,"water":0,"glass":0},"status":"Landing cargo","online_recorded":false}
	state.kit_source = ""
	game.diplomacy.record(game,"colonies","Deployed a colony kit. Hub construction takes 18 colony days.","",{"planet":id,"site":[at.x,at.y],"duration":Settlement.DAYS})
	game.field.note("colony_landing","Colony cargo landed · hub construction underway.")
	return ""

func phase(game: RefCounted, id: String) -> int:
	if game.sector.state.colonies.has(id): return 3
	if not game.sector.state.settlements.has(id): return -1
	var remaining: int = game.sector.state.settlements[id].remaining
	return 0 if remaining > 12 else 1 if remaining > 6 else 2

func install_reason(game: RefCounted, id: String, item: String) -> String:
	if not state.outposts.has(id) or not game.sector.state.colonies.has(id): return "Complete hub construction first."
	if item not in ["alloy","water","glass"]: return "Unknown export facility."
	if state.outposts[id].module == item: return "This facility is already installed."
	var colony: Dictionary = game.sector.state.colonies[id]
	if game.field.marks < 60 or colony.materials < 20 or colony.supplies < 10: return "Installation needs 60 Marks, 20 local materials and 10 local supplies."
	return ""

func install(game: RefCounted, id: String, item: String) -> String:
	var blocked: String = install_reason(game,id,item)
	if not blocked.is_empty(): return blocked
	game.field.marks -= 60
	game.sector.state.colonies[id].materials -= 20
	game.sector.state.colonies[id].supplies -= 10
	state.outposts[id].module = item
	state.outposts[id].status = "Export facility commissioned"
	game.diplomacy.record(game,"colonies","Commissioned "+str(game.commerce.catalog.goods[item].name)+" production.","",{"planet":id,"item":item,"cost":60})
	return ""

static func yield_for(planet: String, item: String, game: RefCounted = null) -> int:
	var climate: String = Geography.definition(planet).archetype
	var output: int = 2 if (climate == "frozen" and item in ["water","alloy"]) or (climate == "arid" and item == "glass") else 1
	if game != null and game.climate.state.worlds.has(planet):
		var tier: int = mini(game.climate.score(game.climate.world(planet)),game.biosphere.complete_tier(planet))
		return 0 if tier == 0 else output+maxi(0,tier-1)
	return output

func tick(game: RefCounted) -> void:
	for id: String in state.outposts:
		var outpost: Dictionary = state.outposts[id]
		if not game.sector.state.colonies.has(id):
			outpost.status = Settlement.phase(game.sector.state.settlements[id])
			continue
		if not outpost.online_recorded:
			outpost.online_recorded = true
			game.diplomacy.record(game,"colonies","Landing hub operational on "+str(game.sector.state.planets[id].name)+".","",{"planet":id},0,"hub:"+id)
		if not game.conflict.port_reason(id).is_empty(): outpost.status = "Port disabled · repair through Colony defense"; continue
		var item: String = outpost.module
		if item.is_empty(): outpost.status = "Hub ready · choose an export facility"; continue
		var count: int = 0
		for amount: int in outpost.stock.values(): count += amount
		var output: int = yield_for(id,item,game)
		if output == 0: outpost.status = "Production suspended · T0 climate"; continue
		var colony: Dictionary = game.sector.state.colonies[id]
		var upkeep: float = 2.0 if Geography.definition(id).archetype == "frozen" else 1.0
		if game.climate.state.worlds.has(id): upkeep *= float(game.climate.effects(id).power_factor)
		if count+output > STORAGE: outpost.status = "Warehouse full · collect cargo"; continue
		if game.field.marks < upkeep or colony.supplies < 0.5: outpost.status = "Paused · needs operating Marks and local supplies"; continue
		outpost.status = "Producing %d %s / 2 colony days" % [output,game.commerce.catalog.goods[item].name]
		if int(game.sector.state.tick)%2 != 0: continue
		game.field.marks -= upkeep
		colony.supplies -= 0.5
		outpost.stock[item] += output
		game.sector.state.ledger.upkeep += upkeep
		colony.ledger.upkeep += upkeep
		colony.income -= upkeep
		game.sector.state.ledger.closing = game.field.marks
		game.sector.state.ledger.net = game.field.marks-game.sector.state.ledger.opening

func collect_reason(game: RefCounted, port: String, at: Vector3, item: String, amount: int) -> String:
	var blocked: String = game.commerce.access(game,port,at)
	if not blocked.is_empty(): return blocked
	var id: String = strategic_id(game.field.state.planet_id)
	if not state.outposts.has(id) or not state.outposts[id].stock.has(item) or amount <= 0: return "No such cargo at this outpost."
	if state.outposts[id].stock[item] < amount: return "Insufficient warehouse stock."
	if game.commerce.used_space(game)+amount > game.commerce.capacity(): return "Insufficient cargo space."
	return ""

func collect(game: RefCounted, port: String, at: Vector3, item: String, amount: int) -> String:
	var blocked: String = collect_reason(game,port,at,item,amount)
	if not blocked.is_empty(): return blocked
	var id: String = strategic_id(game.field.state.planet_id)
	state.outposts[id].stock[item] -= amount
	game.commerce.add_cargo(item,amount,game.field.state.planet_id)
	return ""

func restore(value: Variant, sector: RefCounted, commerce: RefCounted) -> Error:
	if not value is Dictionary or not value.has_all(["kit_source","outposts"]) or not value.kit_source is String or not value.outposts is Dictionary or value.outposts.size() > 2: return ERR_INVALID_DATA
	if not value.kit_source.is_empty() and (not sector.state.colonies.has(value.kit_source) or commerce.quantity()+KIT_SPACE > commerce.capacity()): return ERR_INVALID_DATA
	for id: Variant in value.outposts:
		if not id is String or id not in ["s1p0","s2p0"] or (not sector.state.colonies.has(id) and not sector.state.settlements.has(id)): return ERR_INVALID_DATA
		var outpost: Variant = value.outposts[id]
		if not outpost is Dictionary or not outpost.has_all(["site","module","stock","status","online_recorded"]): return ERR_INVALID_DATA
		if not outpost.site is Array or outpost.site.size() != 2 or not outpost.module is String or outpost.module not in ["","alloy","water","glass"] or not outpost.status is String or not outpost.online_recorded is bool: return ERR_INVALID_DATA
		for n: Variant in outpost.site:
			if not (n is int or n is float) or not is_finite(float(n)): return ERR_INVALID_DATA
		if not site_reason(id,Vector2(outpost.site[0],outpost.site[1])).is_empty(): return ERR_INVALID_DATA
		if not outpost.stock is Dictionary or outpost.stock.size() != 3: return ERR_INVALID_DATA
		var total: int = 0
		for item: String in ["alloy","water","glass"]:
			if not outpost.stock.get(item) is int or outpost.stock[item] < 0 or outpost.stock[item] > STORAGE: return ERR_INVALID_DATA
			total += outpost.stock[item]
		if total > STORAGE: return ERR_INVALID_DATA
	state = value.duplicate(true)
	return OK
