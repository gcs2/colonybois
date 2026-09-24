extends RefCounted
## Ship cargo, finite planetary markets and earned shop eligibility. No scene state.
const Geography = preload("res://scripts/planet_geography.gd")
const Field = preload("res://scripts/encounter_state.gd")
const Recognition = preload("res://scripts/expedition_progression.gd")
var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/space_commerce.json"))
var state: Dictionary = {"cargo":[],"markets":{},"flows":[],"badges":{"explorer":0,"merchant":0,"defender":0},"upgrades":[]}

func _init() -> void:
	catalog.badges.merge(Recognition.catalog.badges.duplicate(true))
	for id: String in catalog.badges:
		if not state.badges.has(id): state.badges[id] = 0

func capacity() -> int:
	return 16 if "hold" in state.upgrades else 8

func drive_range() -> int:
	for tier: int in range(4,0,-1):
		if ("drive" if tier == 1 else "drive_%d" % tier) in state.upgrades: return [3,5,8,12,20][tier]
	return 3

func used_space(game: RefCounted) -> int:
	return quantity()+game.colonies.reserved_space()

func tick_markets(game: RefCounted) -> void:
	# Bounded aggregate production/consumption; opening a view never replenishes stock.
	if int(game.sector.state.tick)%4 != 0: return
	for planet: String in state.markets:
		if not game.territory.port_reason(game,planet).is_empty(): continue
		var limits: Dictionary = initial_market(planet)
		var climate: String = Geography.definition(planet).archetype
		for item: String in catalog.goods:
			var offer: Dictionary = state.markets[planet][item]
			offer.demand = mini(limits[item].demand,int(offer.demand)+1)
			if float(catalog.goods[item].factors[climate]) < 1.0: offer.stock = mini(limits[item].stock,int(offer.stock)+1)

func quantity(item: String = "") -> int:
	var total: int = 0
	for lot: Dictionary in state.cargo:
		if item.is_empty() or lot.item == item: total += lot.quantity
	return total

func market(planet: String) -> Dictionary:
	# Quotes do not create or replenish stock. Both docks share the same market.
	if state.markets.has(planet): return state.markets[planet]
	return initial_market(planet)

func price(planet: String, item: String, buying: bool, game: RefCounted = null) -> int:
	var good: Dictionary = catalog.goods[item]
	var treaty: float = 1.0
	if game != null:
		var owner: String = game.owner_of(planet)
		if not owner.is_empty() and owner+":trade" in game.sector.state.agreements: treaty = 0.9 if buying else 1.1
	return maxi(1,int(ceil(float(good.base)*float(good.factors[Geography.definition(planet).archetype])*(1.2 if buying else 0.8)*treaty)))

func access(game: RefCounted, port: String, at: Vector3) -> String:
	var destroyed: String = game.territory.port_reason(game,game.field.state.planet_id)
	if not destroyed.is_empty(): return destroyed
	var port_damage: String = game.conflict.port_reason(game.field.state.planet_id)
	if not port_damage.is_empty(): return port_damage
	if game.traveling(): return "Complete the journey first."
	var providers: Dictionary = game.field.local_services()
	if not providers.has(port) or providers[port].mode != game.field.state.flight_mode: return "No dock in reach."
	if at.distance_to(Field.service_position(port)) > float(providers[port].reach): return "Approach the dock to trade."
	var owner: String = game.owner_of(game.field.state.planet_id)
	if not owner.is_empty() and game.sector.faction_by_id(owner).get("embargo",false): return "Trade suspended by embargo."
	return ""

func reason(game: RefCounted, port: String, at: Vector3, item: String, amount: int, buying: bool) -> String:
	var blocked: String = access(game,port,at)
	if not blocked.is_empty(): return blocked
	if not catalog.goods.has(item) or amount <= 0: return "Select a valid commodity and quantity."
	var planet: String = game.field.state.planet_id
	var offer: Dictionary = market(planet)[item]
	if buying:
		if used_space(game)+amount > capacity(): return "Cargo hold is full."
		if amount > offer.stock: return "Insufficient local stock."
		if game.field.marks < price(planet,item,true,game)*amount: return "Insufficient Marks."
	else:
		if quantity(item) < amount: return "Not enough aboard."
		if offer.demand < amount: return "Local demand is exhausted."
	return ""

func add_cargo(item: String, amount: int, origin: String) -> void:
	for lot: Dictionary in state.cargo:
		if lot.item == item and lot.origin == origin:
			lot.quantity += amount
			return
	state.cargo.append({"item":item,"quantity":amount,"origin":origin})

func transact(game: RefCounted, port: String, at: Vector3, item: String, amount: int, buying: bool) -> String:
	var blocked: String = reason(game,port,at,item,amount,buying)
	if not blocked.is_empty(): return blocked
	var planet: String = game.field.state.planet_id
	var offer: Dictionary = market(planet)
	state.markets[planet] = offer
	var total: int = price(planet,item,buying,game)*amount
	if buying:
		offer[item].stock -= amount
		game.field.marks -= total
		add_cargo(item,amount,planet)
	else:
		offer[item].demand -= amount
		game.field.marks += total
		var remaining: int = amount
		for lot: Dictionary in state.cargo:
			if lot.item != item or remaining == 0: continue
			var taken: int = mini(remaining,lot.quantity)
			remaining -= taken
			lot.quantity -= taken
			var flow: String = lot.origin+">"+planet+":"+item
			if lot.origin != planet and flow not in state.flows: state.flows.append(flow)
		state.cargo = state.cargo.filter(func(lot: Dictionary) -> bool: return lot.quantity > 0)
	game.field.note("commerce_%d" % game.field.state.history.size(),"%s %d %s at %s for %d Marks." % ["Bought" if buying else "Sold",amount,catalog.goods[item].name,Geography.definition(planet).name,total])
	var owner: String = game.owner_of(planet)
	var agreement_cause: int = game.diplomacy.state.keys.get("pact:"+owner+":trade",0) if owner+":trade" in game.sector.state.agreements else 0
	game.diplomacy.record(game,"trade","%s %d %s for %d Marks." % ["Bought" if buying else "Sold",amount,catalog.goods[item].name,total],owner,{"item":item,"quantity":amount,"buying":buying,"total":total},agreement_cause)
	update_badges(game)
	return ""

func export_reason(game: RefCounted, port: String, at: Vector3, amount: int = 1) -> String:
	var blocked: String = access(game,port,at)
	if not blocked.is_empty(): return blocked
	if game.field.state.planet_id != "morrow": return "Home colony exports are loaded at Morrow."
	if amount <= 0: return "Choose a positive quantity."
	if used_space(game)+amount > capacity(): return "Cargo hold is full."
	if game.sector.state.colonies.s0p0.materials < 80+amount*4: return "Keep 80 construction materials in reserve."
	return ""

func export_alloy(game: RefCounted, port: String, at: Vector3, amount: int = 1) -> String:
	var blocked: String = export_reason(game,port,at,amount)
	if not blocked.is_empty(): return blocked
	game.sector.state.colonies.s0p0.materials -= 4*amount
	add_cargo("alloy",amount,"morrow")
	return ""

func progress(game: RefCounted, badge: String) -> int:
	if Recognition.catalog.badges.has(badge): return game.recognition.progress(game,badge)
	if badge == "merchant": return state.flows.size()
	if badge == "defender":
		var cleared: int = 1 if game.field.has_guardian() and game.field.state.guardian_disabled else 0
		for id: String in game.worlds:
			if not Field.Encounters.profile(id).is_empty() and game.worlds[id].guardian_disabled: cleared += 1
		return cleared+game.combat.cleared()+game.conflict.state.defended.size()
	var count: int = 0
	for system: Dictionary in game.sector.state.systems:
		if system.visited: count += 1
	return count

func update_badges(game: RefCounted) -> void:
	var previous_rank: int = Recognition.rank(state.badges)
	for id: String in catalog.badges:
		var level: int = 0
		for threshold: float in catalog.badges[id].levels:
			if progress(game,id) >= threshold: level += 1
		if level > int(state.badges[id]):
			for earned: int in range(int(state.badges[id])+1,level+1): game.recognition.award(game,id,earned)
			state.badges[id] = level
			game.field.note("badge_%s_%d" % [id,level],"%s %d earned · open Badges for progress and shop requirements." % [catalog.badges[id].name,level])
	for earned: int in range(previous_rank+1,Recognition.rank(state.badges)+1): game.recognition.promotion(game,earned)

func eligible(id: String) -> bool:
	if not catalog.upgrades.has(id): return false
	var prior: String = catalog.upgrades[id].get("prior", "")
	if not prior.is_empty() and prior not in state.upgrades: return false
	if catalog.upgrades[id].has("rank") and Recognition.rank(state.badges) >= int(catalog.upgrades[id].rank): return true
	for badge: String in catalog.upgrades[id].requires:
		if int(state.badges[badge]) >= int(catalog.upgrades[id].requires[badge]): return true
	return false

func upgrade_reason(game: RefCounted, port: String, at: Vector3, id: String) -> String:
	var blocked: String = access(game,port,at)
	if not blocked.is_empty(): return blocked
	if not catalog.upgrades.has(id): return "Unknown upgrade."
	if id in state.upgrades: return "Installed."
	var prior: String = catalog.upgrades[id].get("prior", "")
	if not prior.is_empty() and prior not in state.upgrades: return "Install %s first." % catalog.upgrades[prior].name
	if not eligible(id): return "Earn either of the listed badge tiers first."
	if game.field.marks < float(catalog.upgrades[id].price): return "Insufficient Marks."
	return ""

func buy_upgrade(game: RefCounted, port: String, at: Vector3, id: String) -> String:
	var blocked: String = upgrade_reason(game,port,at,id)
	if not blocked.is_empty(): return blocked
	game.field.marks -= float(catalog.upgrades[id].price)
	state.upgrades.append(id)
	game.field.installed_upgrades = state.upgrades
	if id.begins_with("drive"): game.Galaxy.reveal(game.sector,game.sector.state.flagship.system,maxf(5,drive_range()))
	game.field.note("upgrade_"+id,"Installed "+str(catalog.upgrades[id].name)+".")
	game.diplomacy.record(game,"equipment","Installed "+str(catalog.upgrades[id].name)+".","",{"upgrade":id,"price":catalog.upgrades[id].price})
	return ""

func restore(source: Variant, legacy: bool = true) -> Error:
	if not source is Dictionary or not source.has_all(["cargo","markets","flows","badges","upgrades"]): return ERR_INVALID_DATA
	if not source.cargo is Array or not source.markets is Dictionary or not source.flows is Array or not source.badges is Dictionary or not source.upgrades is Array: return ERR_INVALID_DATA
	source = source.duplicate(true)
	if legacy and not source.badges.has("defender") and source.badges.has_all(["explorer","merchant"]): source.badges["defender"] = 0
	if legacy:
		for id: String in Recognition.catalog.badges:
			if not source.badges.has(id): source.badges[id] = 0
	if source.upgrades.size() > catalog.upgrades.size() or source.badges.size() != catalog.badges.size() or source.cargo.size() > 16 or source.markets.size() > 6144 or source.flows.size() > 131072: return ERR_INVALID_DATA
	var seen: Array = []
	for id: Variant in source.upgrades:
		if not id is String or not catalog.upgrades.has(id) or id in seen: return ERR_INVALID_DATA
		var prior: String = catalog.upgrades[id].get("prior", "")
		if not prior.is_empty() and prior not in source.upgrades: return ERR_INVALID_DATA
		seen.append(id)
	for id: String in catalog.badges:
		if not source.badges.get(id) is int or source.badges[id] < 0 or source.badges[id] > 5: return ERR_INVALID_DATA
	var count: int = 0
	seen.clear()
	for lot: Variant in source.cargo:
		if not lot is Dictionary or not lot.has_all(["item","origin","quantity"]): return ERR_INVALID_DATA
		if not lot.item is String or not catalog.goods.has(lot.item) or not lot.origin is String or Geography.definition(lot.origin).is_empty(): return ERR_INVALID_DATA
		if not lot.quantity is int or lot.quantity <= 0 or lot.quantity > 16 or lot.item+":"+lot.origin in seen: return ERR_INVALID_DATA
		seen.append(lot.item+":"+lot.origin)
		count += lot.quantity
	if count > (16 if "hold" in source.upgrades else 8): return ERR_INVALID_DATA
	for planet: Variant in source.markets:
		if not planet is String or Geography.definition(planet).is_empty() or not source.markets[planet] is Dictionary or source.markets[planet].size() != catalog.goods.size(): return ERR_INVALID_DATA
		var initial: Dictionary = initial_market(planet)
		for item: String in catalog.goods:
			var offer: Variant = source.markets[planet].get(item)
			if not offer is Dictionary or not offer.has_all(["stock","demand"]): return ERR_INVALID_DATA
			for key: String in ["stock","demand"]:
				if not offer[key] is int or offer[key] < 0 or offer[key] > initial[item][key]: return ERR_INVALID_DATA
	seen.clear()
	for flow: Variant in source.flows:
		if not flow is String or flow in seen: return ERR_INVALID_DATA
		var parts: PackedStringArray = flow.split(":")
		if parts.size() != 2 or not catalog.goods.has(parts[1]): return ERR_INVALID_DATA
		var endpoints: PackedStringArray = parts[0].split(">")
		if endpoints.size() != 2 or endpoints[0] == endpoints[1] or Geography.definition(endpoints[0]).is_empty() or Geography.definition(endpoints[1]).is_empty(): return ERR_INVALID_DATA
		seen.append(flow)
	state = source.duplicate(true)
	return OK

func initial_market(planet: String) -> Dictionary:
	# Detached initial market bounds for save validation.
	var result: Dictionary = {}
	var climate: String = Geography.definition(planet).archetype
	for item: String in catalog.goods:
		var factor: float = catalog.goods[item].factors[climate]
		result[item] = {"stock":12 if factor < 1 else 4,"demand":16 if factor > 1 else 8}
	return result
