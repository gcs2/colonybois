extends RefCounted
## Original alien colony records; surface combat owns every building/guard hit point.
const C = preload("res://scripts/surface_combat.gd")
const Catalog = preload("res://scripts/territory_catalog.gd")
static var catalog: Dictionary = Catalog.catalog
var state: Dictionary = {"worlds":{},"captured":[],"ruined":[],"eliminated":[]}
static func fresh() -> Dictionary: return {"phase":"held","refused":false,"resolved_at":0,"stock":8}
func world(id: String) -> Dictionary: return state.worlds.get(id,fresh())
func eliminated(id: String) -> bool: return id in state.eliminated
func active_enemy(game: RefCounted, id: String) -> bool:
	return not catalog.has(id) or (world(id).phase == "held" and game.conflict.at_war(catalog[id].owner))
func attack_reason(game: RefCounted, id: String) -> String:
	if not catalog.has(id): return ""
	var phase: String = world(id).phase
	if phase == "surrendered": return "Colony surrendered. Click its hall to review the terms."
	if phase in ["annexed","ruined"]: return "This colony is no longer a hostile target."
	return "Declare war through Communications before attacking this colony." if not game.conflict.at_war(catalog[id].owner) else ""
func port_reason(game: RefCounted, id: String) -> String:
	if catalog.has(id) and world(id).phase == "ruined" and not game.sector.state.colonies.has(id): return "Colony port destroyed. Rebuild with a carried colony kit before using services."
	return ""
func pressure(game: RefCounted, id: String) -> float:
	var units: Dictionary = game.combat.world(id).units
	var value: float = 0
	for part: String in ["civic","housing","industry"]: value += float(C.profiles(id)[part].hull)-float(units[part].hull)
	return value
func assess(game: RefCounted, id: String) -> void:
	if not catalog.has(id) or world(id).phase in ["annexed","ruined"]: return
	state.worlds[id] = world(id)
	var record: Dictionary = state.worlds[id]
	if game.combat.world(id).units.civic.hull <= 0:
		record.phase = "ruined"; record.resolved_at = int(game.field.state.time); record.stock = 0
		state.ruined.append(id); game.sector.state.planets[id].owner = ""
		game.commerce.state.markets.erase(id)
		for faction: Dictionary in game.sector.state.factions:
			if not faction.get("contacted",false): continue
			var loss: int = 25 if faction.id == "commune" else 15
			faction.relation = maxi(-100,int(faction.relation)-loss); faction.embargo = faction.relation < -15
			faction.reason = "Destruction of "+str(catalog[id].name)+" (−%d)." % loss
		game.fleet.reconcile(game)
		game.diplomacy.record(game,"war",str(catalog[id].name)+" destroyed. Infrastructure and stock lost; the world is unclaimed.",catalog[id].owner,{"planet":id,"outcome":"ruined"},0,"territory_end:"+id,id)
		game.field.note("ruined_"+id,str(catalog[id].name)+" destroyed · no services or production remain")
		reconcile_system(game,id); check_elimination(game,catalog[id].owner)
	elif record.phase == "held" and not record.refused and pressure(game,id) >= 160:
		record.phase = "surrendered"
		game.diplomacy.record(game,"war",str(catalog[id].name)+" offers surrender. Cease fire to preserve its remaining works.",catalog[id].owner,{"planet":id,"hall_hull":game.combat.world(id).units.civic.hull},0,"surrender:"+id,id)
		game.field.note("surrender_"+id,str(catalog[id].name)+" surrendered · click the civic hall")
	if record.phase != "held":
		for unit: Dictionary in game.combat.state.worlds[id].units.values(): unit.fire_at = 0
func reason(game: RefCounted, id: String, action: String, at: Vector3) -> String:
	if not catalog.has(id) or world(id).phase != "surrendered": return "Obtain the colony's surrender first."
	if game.traveling() or game.field.state.planet_id != id or game.field.state.flight_mode != "surface": return "Return to this colony's surface."
	if not at.is_finite() or at.distance_to(C.home(id,"civic")) > 30: return "Approach the civic hall within 30 m."
	if not game.conflict.at_war(catalog[id].owner): return "Peace prevents seizure. The previous owner retains this colony."
	if not game.combat.world(id).shots.is_empty(): return "Wait for committed ordnance to land before settling terms."
	if action == "refuse": return ""
	if action != "annex": return "Unknown surrender term."
	if game.sector.state.colonies.size()+game.sector.state.settlements.size() >= 3: return "Three colony sites are already committed. This scenario cannot administer another."
	return ""
func command(game: RefCounted, id: String, action: String, at: Vector3) -> String:
	var blocked: String = reason(game,id,action,at)
	if not blocked.is_empty(): return blocked
	var record: Dictionary = state.worlds[id]
	if action == "refuse":
		record.phase = "held"; record.refused = true
		game.diplomacy.record(game,"war","Rejected "+str(catalog[id].name)+"'s surrender. Further fire risks destruction.",catalog[id].owner,{"planet":id},game.diplomacy.state.keys.get("surrender:"+id,0),"",id)
		return ""
	record.phase = "annexed"; record.resolved_at = int(game.field.state.time); state.captured.append(id)
	var local: Dictionary = game.combat.world(id)
	game.sector._create_colony(id,true)
	var colony: Dictionary = game.sector.state.colonies[id]
	# Inherit the surviving structures and finite goods, not a free new landing kit.
	colony.materials = 20.0; colony.supplies = 20.0
	if local.units.housing.hull <= 0:
		for key: String in colony.cells.keys():
			if colony.cells[key].type == "habitat": colony.cells.erase(key)
	if local.units.industry.hull <= 0:
		for key: String in colony.cells.keys():
			if colony.cells[key].type == "industry": colony.cells.erase(key)
	game.sector.refresh_colony(id)
	var goods: String = catalog[id].goods
	var stock: Dictionary = {"alloy":0,"water":0,"glass":0}; stock[goods] = record.stock
	game.colonies.state.outposts[id] = {"site":[-6.0,-18.0],"module":goods if local.units.industry.hull > 0 else "","stock":stock,"status":"Captured works · damage retained","online_recorded":true}
	record.stock = 0
	game.conflict.state.sites[id] = {"integrity":clampi(int(100*float(local.units.civic.hull)/240),1,100),"battery":false,"ammo":0}
	var f: Dictionary = game.sector.faction_by_id(catalog[id].owner); f.relation = maxi(-100,int(f.relation)-15); f.embargo = true; f.reason = "You annexed "+str(catalog[id].name)+" (−15)."
	game.diplomacy.record(game,"war",str(catalog[id].name)+" annexed; surviving industry and goods transferred, damage retained.",catalog[id].owner,{"planet":id,"outcome":"annexed","goods":stock,"port_integrity":game.conflict.site(id).integrity},game.diplomacy.state.keys.get("surrender:"+id,0),"territory_end:"+id,id)
	game.field.note("annexed_"+id,str(catalog[id].name)+" annexed · administration and services transferred")
	reconcile_system(game,id); check_elimination(game,catalog[id].owner); game.commerce.update_badges(game)
	return ""
func reconcile_system(game: RefCounted, id: String) -> void:
	var system: Dictionary = game.sector.system_by_id(game.system_of(id)); var owners: Array = []
	for pid: String in system.planets:
		var owner: String = game.sector.state.planets[pid].owner
		if not owner.is_empty() and owner not in owners: owners.append(owner)
	system.owner = str(owners[0]) if owners.size() == 1 and owners[0] != "player" else ""
	system["contested"] = owners.size() > 1
func check_elimination(game: RefCounted, id: String) -> void:
	if eliminated(id): return
	for planet: Dictionary in game.sector.state.planets.values():
		if planet.owner == id: return
	state.eliminated.append(id)
	var n: Dictionary = game.conflict.nation(id); n.war = false; n.warning = 0; n.next_raid = 0; game.conflict.state.nations[id] = n
	if not game.conflict.state.raid.is_empty() and game.conflict.state.raid.faction == id: game.conflict.finish(game,"withdrawn")
	for pact: String in ["trade","non_aggression","alliance"]: game.sector.state.agreements.erase(id+":"+pact)
	game.fleet.reconcile(game)
	game.diplomacy.record(game,"war",str(game.sector.faction_by_id(id).name)+" lost its final territorial holding. This is not evidence of species extinction.",id,{"outcome":"no_territory"},0,"eliminated:"+id)
func tick(game: RefCounted) -> void:
	# One fixed-clock unit of export stock per two colony days, held in the real colony.
	if int(game.field.state.time)%60 != 0: return
	for id: String in catalog:
		if world(id).phase != "held" or game.conflict.at_war(catalog[id].owner): continue
		if game.combat.world(id).units.industry.hull <= 0: continue
		state.worlds[id] = world(id); state.worlds[id].stock = mini(16,int(state.worlds[id].stock)+1)
func restore(value: Variant, now: int, sector: RefCounted, combat: RefCounted, colonies: RefCounted, history: RefCounted) -> Error:
	if not value is Dictionary or not value.has_all(["worlds","captured","ruined","eliminated"]) or not value.worlds is Dictionary or value.worlds.size() > catalog.size(): return ERR_INVALID_DATA
	for key: String in ["captured","ruined","eliminated"]:
		if not value[key] is Array or value[key].size() > (3 if key == "eliminated" else catalog.size()): return ERR_INVALID_DATA
		var seen: Array = []
		for id: Variant in value[key]:
			if not id is String or id in seen or not (id in ["directorate","consortium","commune"] if key == "eliminated" else catalog.has(id)): return ERR_INVALID_DATA
			seen.append(id)
	for id: Variant in value.worlds:
		if not id is String or not catalog.has(id): return ERR_INVALID_DATA
		var record: Variant = value.worlds[id]
		if not record is Dictionary or not record.has_all(["phase","refused","resolved_at","stock"]) or not record.refused is bool: return ERR_INVALID_DATA
		if record.phase not in ["held","surrendered","annexed","ruined"] or not C.number(record.stock,0,16,true) or not C.number(record.resolved_at,0,now,true): return ERR_INVALID_DATA
		var units: Dictionary = combat.world(id).units
		if record.phase in ["annexed","ruined"]:
			if not history.state.keys.has("territory_end:"+id) or record.stock != 0: return ERR_INVALID_DATA
			if record.phase == "annexed" and (id not in value.captured or not colonies.state.outposts.has(id) or sector.state.planets[id].owner != "player" or units.civic.hull <= 0): return ERR_INVALID_DATA
			if record.phase == "ruined" and (id not in value.ruined or units.civic.hull != 0 or sector.state.planets[id].owner not in ["","player"]): return ERR_INVALID_DATA
		else:
			if sector.state.planets[id].owner != catalog[id].owner or units.civic.hull <= 0 or record.resolved_at != 0: return ERR_INVALID_DATA
			var damage: float = 0
			for part: String in ["civic","housing","industry"]: damage += float(C.profiles(id)[part].hull)-float(units[part].hull)
			if record.phase == "surrendered" and (record.refused or damage < 160 or not history.state.keys.has("surrender:"+id)): return ERR_INVALID_DATA
	for id: String in catalog:
		if not value.worlds.has(id) and (sector.state.planets[id].owner != catalog[id].owner or combat.world(id).units.civic.hull != 240): return ERR_INVALID_DATA
	for id: String in value.captured:
		if not value.worlds.has(id) or value.worlds[id].phase != "annexed" or id in value.ruined: return ERR_INVALID_DATA
	for id: String in value.ruined:
		if not value.worlds.has(id) or value.worlds[id].phase != "ruined": return ERR_INVALID_DATA
	for id: String in value.eliminated:
		if not history.state.keys.has("eliminated:"+id): return ERR_INVALID_DATA
		for p: Dictionary in sector.state.planets.values():
			if p.owner == id: return ERR_INVALID_DATA
	state = value.duplicate(true); return OK
