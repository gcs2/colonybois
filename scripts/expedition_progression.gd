extends RefCounted
## Recognition from durable outcomes. No points for opening UI or repeating the same deed.
const Geography = preload("res://scripts/planet_geography.gd")
const Climate = preload("res://scripts/planet_climate.gd")
static var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/progression.json"))
var state: Dictionary = {"climate_highs":{},"pinned":"","queue":[]}

static func points(tiers: Dictionary) -> int:
	var total: int = 0
	for tier: int in tiers.values():
		for i: int in range(tier): total += int(catalog.tier_points[i])
	return total
static func rank(tiers: Dictionary) -> int:
	var score: int = points(tiers); var result: int = 0
	for threshold: int in catalog.rank_points:
		if score >= threshold: result += 1
	return result
static func title(tiers: Dictionary) -> String:
	var level: int = rank(tiers)
	return "Captain" if level == 0 else str(catalog.rank_names[level-1])
func climate_completed(planet: String, tier: int) -> void:
	var native: int = Climate.score(Climate.fresh(planet))
	if tier > native: state.climate_highs[planet] = maxi(tier,int(state.climate_highs.get(planet,native)))
func progress(game: RefCounted, badge: String) -> int:
	match badge:
		"captain": return game.signals.completed()
		"diplomat", "trader":
			var count: int = 0
			for faction: Dictionary in game.sector.state.factions:
				if game.diplomacy.state.keys.has("pact:"+str(faction.id)+(":alliance" if badge == "diplomat" else ":trade")): count += 1
			return count
		"colonist":
			var count: int = 0
			for outpost: Dictionary in game.colonies.state.outposts.values():
				if outpost.online_recorded: count += 1
			return count
		"surveyor":
			var count: int = 1 if game.field.state.survey_ticks >= game.field.definition().survey_seconds else 0
			for id: String in game.worlds:
				if game.worlds[id].survey_ticks >= Geography.definition(id).survey_seconds: count += 1
			return count
		"naturalist": return game.biosphere.state.catalogued.size()
		"zoologist": return game.biosphere.state.completed.size()
		"terraformer":
			var count: int = 0
			for id: String in state.climate_highs: count += int(state.climate_highs[id])-Climate.score(Climate.fresh(id))
			return count
	return 0
func award(game: RefCounted, id: String, tier: int) -> void:
	var key: String = "badge:"+id+":"+str(tier)
	state.queue.append({"kind":"badge","id":id,"tier":tier})
	game.diplomacy.record(game,"progression","%s %d earned." % [game.commerce.catalog.badges[id].name,tier],"",{"badge":id,"tier":tier,"points":catalog.tier_points[tier-1]},0,key)
func promotion(game: RefCounted, level: int) -> void:
	state.queue.append({"kind":"rank","id":"","tier":level})
	game.diplomacy.record(game,"progression","Promoted to "+str(catalog.rank_names[level-1])+".","",{"rank":level,"points":points(game.commerce.state.badges)},0,"rank:"+str(level))
func restore(value: Variant, badges: Dictionary) -> Error:
	if not value is Dictionary or not value.has_all(["climate_highs","pinned","queue"]): return ERR_INVALID_DATA
	if not value.climate_highs is Dictionary or value.climate_highs.size() > 23 or not value.pinned is String or (not value.pinned.is_empty() and not badges.has(value.pinned)): return ERR_INVALID_DATA
	for id: Variant in value.climate_highs:
		if not id is String or id == "morrow" or Geography.definition(id).is_empty(): return ERR_INVALID_DATA
		var tier: Variant = value.climate_highs[id]
		if not tier is int or tier > 3 or tier <= Climate.score(Climate.fresh(id)): return ERR_INVALID_DATA
	if not value.queue is Array or value.queue.size() > badges.size()*5+10: return ERR_INVALID_DATA
	var seen: Array = []
	for item: Variant in value.queue:
		if not item is Dictionary or not item.has_all(["kind","id","tier"]) or not item.kind is String or not item.id is String or not item.tier is int: return ERR_INVALID_DATA
		if item.kind == "badge":
			if not badges.has(item.id) or item.tier < 1 or item.tier > badges[item.id]: return ERR_INVALID_DATA
		elif item.kind == "rank":
			if item.id != "" or item.tier < 1 or item.tier > rank(badges): return ERR_INVALID_DATA
		else: return ERR_INVALID_DATA
		var key: String = item.kind+":"+item.id+":"+str(item.tier)
		if key in seen: return ERR_INVALID_DATA
		seen.append(key)
	state = value.duplicate(true)
	return OK
