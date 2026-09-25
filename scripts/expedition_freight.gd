extends RefCounted
## Scheduled physical consignments. Scene objects never own freight or income.
const Geography = preload("res://scripts/planet_geography.gd")
const CHARTER := 80
const CAPACITY := 4
const DAYS_PER_LINK := 2
var state: Dictionary = {"routes":{}}

func market_access(game: RefCounted, destination: String) -> String:
	if not game.territory.port_reason(game,destination).is_empty(): return "Destination colony destroyed."
	if not game.conflict.port_reason(destination).is_empty(): return "Destination port disabled by raid damage."
	var owner: String = game.owner_of(destination)
	if owner.is_empty(): return ""
	var faction: Dictionary = game.sector.faction_by_id(owner)
	if faction.get("embargo",false): return "Destination market is embargoed."
	if owner+":trade" not in game.sector.state.agreements: return "Automatic foreign sales require a trade agreement."
	return ""

func quote(game: RefCounted, source: String, destination: String, item: String, reserve: int) -> Dictionary:
	var result: Dictionary = {"reason":"","path":[],"days":0,"fee":0,"charter":0 if state.routes.has(source) else CHARTER,"gross":0,"net":0}
	if not game.colonies.state.outposts.has(source) or not game.sector.state.colonies.has(source): result.reason = "Choose an operational outpost."
	elif Geography.definition(destination).is_empty() or destination == source: result.reason = "Choose another market."
	elif not game.sector.system_by_id(game.system_of(destination)).visited: result.reason = "Visit the destination system first."
	elif not game.commerce.catalog.goods.has(item) or reserve not in [0,4,8]: result.reason = "Choose a commodity and warehouse reserve."
	elif state.routes.has(source) and (state.routes[source].phase != "waiting" or state.routes[source].cargo > 0): result.reason = "Return and unload the freighter before changing its contract."
	if not result.reason.is_empty(): return result
	result.path = game.sector.route_between(game.system_of(source),game.system_of(destination),true)
	var links: int = maxi(1,result.path.size()-1)
	result.days = links*DAYS_PER_LINK
	result.fee = links*4
	var is_supply: bool = game.colonies.state.outposts.has(destination) and game.sector.state.colonies.has(destination)
	if is_supply:
		result.gross = 0
		result.net = -result.fee
		result.reason = market_access(game,destination)
		if result.reason.is_empty():
			var dest_wh: Dictionary = game.colonies.state.outposts[destination].stock
			var dest_stored: int = 0
			for amount: int in dest_wh.values(): dest_stored += amount
			if dest_stored >= game.colonies.STORAGE:
				result.reason = "Destination warehouse has no storage capacity."
	else:
		result.gross = game.commerce.price(destination,item,false,game)*CAPACITY
		result.net = result.gross-result.fee
		result.reason = market_access(game,destination)
	if result.path.is_empty(): result.reason = "No charted, accessible freight route."
	elif links > 5: result.reason = "Beyond this carrier's five-link range."
	elif game.field.marks < result.charter: result.reason = "Chartering a carrier costs 80 Marks."
	return result

func carrier_system(route: Dictionary) -> String:
	if route.path.is_empty(): return ""
	if route.path.size() == 1: return route.path[0]
	var links: int = maxi(1, route.path.size() - 1)
	var elapsed: int = route.duration - route.remaining
	var hop: int = mini(links - 1, elapsed / DAYS_PER_LINK)
	if elapsed % DAYS_PER_LINK > 0:
		return route.path[mini(route.path.size() - 1, hop + 1)]
	return route.path[hop]

func system_threat(game: RefCounted, sys_id: String) -> Dictionary:
	var system: Dictionary = game.sector.system_by_id(sys_id)
	if system.is_empty(): return {}
	if system.get("piracy", false) or not str(system.get("threat", "")).is_empty():
		return {
			"system": sys_id,
			"faction": system.get("threat_faction", system.get("owner", "raiders")),
			"at_war": false,
			"risk": str(system.get("threat", "pirate_raider"))
		}
	var owner: String = system.get("owner", "")
	if owner.is_empty() or owner == "player": return {}
	var at_war: bool = game.conflict.at_war(owner)
	var faction: Dictionary = game.sector.faction_by_id(owner)
	var relation: int = int(faction.get("relation", 0))
	var is_hostile: bool = at_war or relation < 0 or faction.get("hostile", false)
	if not is_hostile: return {}
	var risk: String = "privateer" if at_war else ("hostile_patrol" if relation < -20 else "raider")
	return {
		"system": sys_id,
		"faction": owner,
		"at_war": at_war,
		"risk": risk
	}

func route_threat(game: RefCounted, route: Dictionary) -> Dictionary:
	if route.path.is_empty(): return {}
	var current_sys: String = carrier_system(route)
	var direct_threat: Dictionary = system_threat(game, current_sys)
	if not direct_threat.is_empty():
		return direct_threat
	for sys_id: String in route.path:
		var system: Dictionary = game.sector.system_by_id(sys_id)
		var owner: String = system.get("owner", "")
		if not owner.is_empty() and game.conflict.at_war(owner):
			return system_threat(game, sys_id)
	return {}

func configure(game: RefCounted, source: String, destination: String, item: String, reserve: int) -> String:
	var offer: Dictionary = quote(game,source,destination,item,reserve)
	if not offer.reason.is_empty(): return offer.reason
	var previous: Dictionary = state.routes.get(source,{})
	game.field.marks -= offer.charter
	state.routes[source] = {"destination":destination,"item":item,"reserve":reserve,"paused":false,"phase":"waiting","cargo":0,"remaining":0,"duration":0,"path":[],"status":"Waiting for warehouse surplus", "delivered":previous.get("delivered",0),"receipts":previous.get("receipts",0),"fees":previous.get("fees",0),"trips":previous.get("trips",0),"incident":{},"incident_count":previous.get("incident_count",0),"incidents_this_trip":0}
	var is_supply: bool = game.colonies.state.outposts.has(destination) and game.sector.state.colonies.has(destination)
	var event_text: String = "%s freight contract: supply %s to %s." % [Geography.definition(source).name,game.commerce.catalog.goods[item].name,Geography.definition(destination).name] if is_supply else "%s freight contract: %s to %s." % [Geography.definition(source).name,game.commerce.catalog.goods[item].name,Geography.definition(destination).name]
	game.diplomacy.record(game,"colonies" if is_supply else "trade",event_text,"",{"source":source,"destination":destination,"item":item,"reserve":reserve,"charter":offer.charter,"supply":is_supply})
	return ""

func pause(game: RefCounted, source: String) -> String:
	if not state.routes.has(source): return "No carrier assigned."
	var route: Dictionary = state.routes[source]
	route.paused = not route.paused
	game.diplomacy.record(game,"trade",("Paused" if route.paused else "Resumed")+" departures from "+Geography.definition(source).name+".","",{"source":source,"paused":route.paused})
	return ""

func recall(game: RefCounted, source: String) -> String:
	if not state.routes.has(source) or state.routes[source].phase != "outbound": return "Only an outbound carrier can be recalled."
	var route: Dictionary = state.routes[source]
	route.phase = "returning"; route.remaining = route.duration-route.remaining; route.paused = true
	route.path.reverse()
	route.status = "Returning with unsold cargo"
	game.diplomacy.record(game,"trade","Recalled freight to "+Geography.definition(source).name+"; departures paused.","",{"source":source,"cargo":route.cargo})
	return ""

func path_open(game: RefCounted, path: Array) -> bool:
	# Recheck the booked itinerary; do not silently teleport onto a cheaper detour.
	for id: String in path:
		var owner: String = game.sector.system_by_id(id).owner
		if not owner.is_empty() and game.sector.faction_by_id(owner).get("embargo",false) and owner+":non_aggression" not in game.sector.state.agreements: return false
	return true

func _status(game: RefCounted, source: String, message: String) -> void:
	var route: Dictionary = state.routes[source]
	if route.status == message: return
	route.status = message
	if message.begins_with("Blocked"):
		game.diplomacy.record(game,"trade",Geography.definition(source).name+" freight: "+message,"",{"source":source,"cargo":route.cargo})

func _money(game: RefCounted, source: String, receipt: int, fee: int) -> void:
	game.field.marks += receipt-fee
	var ledger: Dictionary = game.sector.state.ledger
	if ledger != null:
		ledger.exports += receipt; ledger.upkeep += fee
		ledger.closing = game.field.marks; ledger.net = game.field.marks-ledger.opening
	var colony: Dictionary = game.sector.state.colonies.get(source, {})
	if not colony.is_empty():
		if not colony.has("ledger"): colony.ledger = {"tax":0.0,"crime_loss":0.0,"upkeep":0.0,"exports":0.0}
		colony.ledger.exports += receipt; colony.ledger.upkeep += fee; colony.income += receipt-fee

func tick(game: RefCounted) -> void:
	for source: String in state.routes:
		var route: Dictionary = state.routes[source]
		var warehouse: Dictionary = game.colonies.state.outposts[source].stock
		if not game.conflict.port_reason(source).is_empty(): _status(game,source,"Blocked · source port disabled; cargo retained"); continue
		if route.phase != "waiting":
			if not route.incident.is_empty() and not route.incident.get("resolved", false):
				_status(game, source, "Intercepted · %s in %s; cargo held aboard" % [route.incident.risk.replace("_", " ").capitalize(), game.sector.system_by_id(route.incident.system).name])
				continue
			var threat: Dictionary = route_threat(game, route)
			if not threat.is_empty() and route.incidents_this_trip < 1:
				route.incidents_this_trip += 1
				route.incident_count += 1
				var inc_id: String = "inc_%s_%d" % [source, int(game.field.state.time)]
				route.incident = {
					"id": inc_id,
					"carrier": source,
					"system": threat.system,
					"faction": threat.faction,
					"risk": threat.risk,
					"cargo": route.cargo,
					"item": route.item,
					"time": int(game.field.state.time),
					"route": [route.path.front(), route.path.back()],
					"phase": route.phase,
					"resolved": false
				}
				var summary: String = "%s carrier intercepted in %s by %s; %d %s held aboard." % [
					Geography.definition(source).name,
					game.sector.system_by_id(threat.system).name,
					threat.risk.replace("_", " "),
					route.cargo,
					game.commerce.catalog.goods[route.item].name
				]
				_status(game, source, "Intercepted · %s in %s; cargo held aboard" % [threat.risk.replace("_", " ").capitalize(), game.sector.system_by_id(threat.system).name])
				game.diplomacy.record(game, "trade", summary, threat.faction, {
					"carrier": source,
					"cargo": route.cargo,
					"item": route.item,
					"system": threat.system,
					"risk": threat.risk,
					"incident_id": inc_id
				}, 0, "incident:" + inc_id, source)
				game.field.note("incident_" + inc_id, summary)
				continue
			if not path_open(game,route.path): _status(game,source,"Blocked · transit border closed; cargo retained"); continue
			route.remaining = maxi(0,route.remaining-1)
			if route.remaining > 0:
				route.status = "%s · %d days" % ["Outbound" if route.phase == "outbound" else "Returning",route.remaining]
				continue
			if route.phase == "outbound":
				var blocked: String = market_access(game,route.destination)
				var is_supply: bool = game.colonies.state.outposts.has(route.destination) and game.sector.state.colonies.has(route.destination)
				if is_supply:
					var delivered: int = 0
					if blocked.is_empty():
						var dest_wh: Dictionary = game.colonies.state.outposts[route.destination].stock
						var dest_stored: int = 0
						for amount: int in dest_wh.values(): dest_stored += amount
						var space: int = maxi(0,game.colonies.STORAGE-dest_stored)
						delivered = mini(route.cargo,space)
						dest_wh[route.item] += delivered
						route.cargo -= delivered
						route.delivered += delivered
					var owner: String = game.owner_of(route.destination)
					game.diplomacy.record(game,"colonies","Freighter delivered %d %s to %s warehouse; %d units returning." % [delivered,game.commerce.catalog.goods[route.item].name,Geography.definition(route.destination).name,route.cargo],owner,{"source":source,"destination":route.destination,"item":route.item,"delivered":delivered,"cargo":route.cargo,"reason":blocked,"supply":true})
				else:
					var sold: int = 0
					var receipts: int = 0
					if blocked.is_empty():
						var market: Dictionary = game.commerce.market(route.destination)
						sold = mini(route.cargo,market[route.item].demand)
						market[route.item].demand -= sold
						game.commerce.state.markets[route.destination] = market
						receipts = sold*game.commerce.price(route.destination,route.item,false,game)
						route.cargo -= sold; route.delivered += sold; route.receipts += receipts
						_money(game,source,receipts,0)
						var flow: String = source+">"+route.destination+":"+route.item
						if sold > 0 and flow not in game.commerce.state.flows: game.commerce.state.flows.append(flow)
						game.commerce.update_badges(game)
					var owner: String = game.owner_of(route.destination)
					var cause: int = game.diplomacy.state.keys.get("pact:"+owner+":trade",0) if sold > 0 and owner+":trade" in game.sector.state.agreements else 0
					game.diplomacy.record(game,"trade","Freighter sold %d %s at %s for %d Marks; %d units returning." % [sold,game.commerce.catalog.goods[route.item].name,Geography.definition(route.destination).name,receipts,route.cargo],owner,{"source":source,"destination":route.destination,"item":route.item,"sold":sold,"receipts":receipts,"unsold":route.cargo,"reason":blocked},cause)
				route.phase = "returning"; route.remaining = route.duration; route.path.reverse()
				route.status = "Returning · %d days" % route.remaining
				continue
			else:
				route.phase = "waiting"; route.path = []; route.duration = 0; route.incident = {}; route.incidents_this_trip = 0
		if route.cargo > 0:
			var stored: int = 0
			for amount: int in warehouse.values(): stored += amount
			var unloaded: int = mini(route.cargo,game.colonies.STORAGE-stored)
			warehouse[route.item] += unloaded; route.cargo -= unloaded
			if route.cargo > 0: _status(game,source,"Blocked · warehouse full; returned cargo stays aboard"); continue
		if route.paused: route.status = "Departures paused"; continue
		if warehouse[route.item] < CAPACITY+route.reserve: route.status = "Waiting for %d units above reserve %d" % [CAPACITY,route.reserve]; continue
		var offer: Dictionary = quote(game,source,route.destination,route.item,route.reserve)
		if not offer.reason.is_empty(): _status(game,source,"Blocked · "+offer.reason); continue
		var is_supply: bool = game.colonies.state.outposts.has(route.destination) and game.sector.state.colonies.has(route.destination)
		if not is_supply and game.commerce.market(route.destination)[route.item].demand < CAPACITY: route.status = "Waiting for destination demand"; continue
		if game.field.marks < offer.fee: route.status = "Waiting for %d transport Marks" % offer.fee; continue
		warehouse[route.item] -= CAPACITY
		route.cargo = CAPACITY; route.phase = "outbound"; route.path = offer.path
		route.remaining = offer.days; route.duration = offer.days
		route.trips += 1; route.fees += offer.fee
		_money(game,source,0,offer.fee)
		route.status = "Outbound · %d days" % route.remaining

func restore(value: Variant, sector: RefCounted, colonies: RefCounted) -> Error:
	if not value is Dictionary or not value.get("routes") is Dictionary or value.routes.size() > 2: return ERR_INVALID_DATA
	for source: Variant in value.routes:
		if not source is String or not colonies.state.outposts.has(source) or not sector.state.colonies.has(source): return ERR_INVALID_DATA
		var route: Variant = value.routes[source]
		if not route is Dictionary or not route.has_all(["destination","item","reserve","paused","phase","cargo","remaining","duration","path","status","delivered","receipts","fees","trips"]): return ERR_INVALID_DATA
		if not route.destination is String or Geography.definition(route.destination).is_empty() or route.destination == source or route.item not in ["alloy","water","glass"] or not route.paused is bool or not route.status is String or route.phase not in ["waiting","outbound","returning"]: return ERR_INVALID_DATA
		for key: String in ["reserve","cargo","remaining","duration","delivered","receipts","fees","trips"]:
			if not route[key] is int or route[key] < 0: return ERR_INVALID_DATA
		if route.reserve not in [0,4,8] or route.cargo > CAPACITY or route.remaining > route.duration or route.duration > 10: return ERR_INVALID_DATA
		if not route.path is Array or route.path.size() > 6: return ERR_INVALID_DATA
		var incident: Variant = route.get("incident", {})
		if not incident is Dictionary: return ERR_INVALID_DATA
		if not incident.is_empty():
			if not incident.has_all(["id","carrier","system","faction","risk","cargo","item","time","route","phase","resolved"]): return ERR_INVALID_DATA
			if not incident.id is String or not incident.carrier is String or not incident.system is String or not incident.faction is String or not incident.risk is String: return ERR_INVALID_DATA
			if not incident.cargo is int or incident.cargo < 0 or incident.cargo > CAPACITY: return ERR_INVALID_DATA
			if incident.item not in ["alloy","water","glass"] or not incident.time is int or not incident.route is Array or not incident.resolved is bool: return ERR_INVALID_DATA
			if incident.phase not in ["outbound","returning"] or incident.carrier != source: return ERR_INVALID_DATA
		var incident_count: Variant = route.get("incident_count", 0)
		if not incident_count is int or incident_count < 0: return ERR_INVALID_DATA
		var incidents_this_trip: Variant = route.get("incidents_this_trip", 0)
		if not incidents_this_trip is int or incidents_this_trip < 0: return ERR_INVALID_DATA
		if route.phase == "waiting":
			if route.remaining != 0 or route.duration != 0 or not route.path.is_empty(): return ERR_INVALID_DATA
		else:
			if route.path.is_empty() or (route.remaining == 0 and route.phase == "outbound") or route.duration != maxi(1,route.path.size()-1)*DAYS_PER_LINK: return ERR_INVALID_DATA
			var from: String = source.get_slice("p",0)
			var to: String = "s0" if route.destination == "morrow" else route.destination.get_slice("p",0)
			if route.path.front() != (from if route.phase == "outbound" else to) or route.path.back() != (to if route.phase == "outbound" else from): return ERR_INVALID_DATA
			var seen: Array = []
			for node: Variant in route.path:
				if not node is String or sector.system_by_id(node).is_empty() or node in seen: return ERR_INVALID_DATA
				if not seen.is_empty() and node not in sector.system_by_id(seen.back()).links: return ERR_INVALID_DATA
				seen.append(node)
	state = value.duplicate(true)
	for source: String in state.routes:
		var r: Dictionary = state.routes[source]
		if not r.has("incident"): r.incident = {}
		if not r.has("incident_count"): r.incident_count = 0
		if not r.has("incidents_this_trip"): r.incidents_this_trip = 0
	return OK
