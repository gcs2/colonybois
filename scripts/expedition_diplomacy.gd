extends RefCounted
## Validated personal diplomacy, persistent decisions and explicit agreement effects.
const Geography = preload("res://scripts/planet_geography.gd")
var profiles: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/diplomacy.json"))
var state: Dictionary = {"gifts":[],"licenses":{},"events":[],"keys":{},"next_id":1}
const ACTIONS := ["trade","non_aggression","alliance","gift","chart","reconcile","cancel_trade","cancel_non_aggression","cancel_alliance"]

func record(game: RefCounted, kind: String, summary: String, faction_id: String = "", outcome: Dictionary = {}, cause: int = 0, key: String = "", event_location: String = "") -> int:
	if not key.is_empty() and state.keys.has(key): return state.keys[key]
	var actor: Dictionary = {}
	if profiles.has(faction_id):
		var f: Dictionary = game.sector.faction_by_id(faction_id)
		actor = {"id":faction_id,"name":f.name,"government":f.government,"philosophy":f.philosophy,"speaker":profiles[faction_id].speaker,"species":profiles[faction_id].species}
	var id: int = state.next_id
	state.next_id += 1
	state.events.append({"id":id,"time":int(game.field.state.time),"kind":kind,"location":game.field.state.planet_id if event_location.is_empty() else event_location,"summary":summary,"actor":actor,"outcome":outcome.duplicate(true),"cause":cause})
	if not key.is_empty(): state.keys[key] = id
	return id

func contact(game: RefCounted, id: String) -> void:
	if not profiles.has(id): return
	var faction: Dictionary = game.sector.faction_by_id(id)
	var known: bool = faction.get("contacted",false)
	faction.contacted = true
	if not known:
		record(game,"contact","First contact with "+str(faction.name)+".",id,{"relation":faction.relation},0,"contact:"+id)
		game.field.note("contact_"+id,"Incoming transmission · "+str(faction.name)+". Open communications.")

func greeting(game: RefCounted, id: String) -> String:
	var faction: Dictionary = game.sector.faction_by_id(id)
	return profiles[id].hostile if faction.get("embargo",false) else profiles[id].friendly if faction.relation >= 40 else profiles[id].greeting

func unread() -> Array:
	var result: Array = []
	for id: String in profiles:
		if state.keys.has("contact:"+id) and not state.keys.has("read:"+id): result.append(id)
	return result

func acknowledge(id: String) -> void:
	if state.keys.has("contact:"+id): state.keys["read:"+id] = state.keys["contact:"+id]

func reason(game: RefCounted, id: String, action: String) -> String:
	if game.traveling(): return "Wait until the jump ends."
	if not profiles.has(id) or not game.sector.faction_by_id(id).get("contacted",false): return "Make first contact in their territory."
	if action not in ACTIONS: return "Unknown diplomatic action."
	var f: Dictionary = game.sector.faction_by_id(id)
	if action.begins_with("cancel_"):
		return "" if id+":"+action.trim_prefix("cancel_") in game.sector.state.agreements else "No such agreement is active."
	if action == "gift":
		if id in state.gifts: return "Your goodwill grant has already been accepted."
		return "Requires 120 Marks." if game.field.marks < 120 else ""
	if action == "chart":
		if state.licenses.has(game.field.state.planet_id): return "This chart already has an exclusive license."
		if game.sector.system_by_id(game.sector.state.flagship.system).owner == id: return "They already chart their own territory."
		if game.field.state.survey_ticks < game.field.definition().survey_seconds: return "Complete this world's orbital survey first."
		return "Resolve the embargo before licensing a chart." if f.get("embargo",false) else ""
	if action == "reconcile":
		if int(f.relation) >= 0: return "Relations do not require reconciliation."
		return "Requires 80 Marks." if game.field.marks < 80 else ""
	var thresholds: Dictionary = {"trade":0,"non_aggression":15,"alliance":40}
	if id+":"+action in game.sector.state.agreements: return "Agreement active."
	if f.get("embargo",false): return "Resolve the embargo first."
	if f.relation < thresholds[action]: return "Requires %d relations; currently %d." % [thresholds[action],f.relation]
	return ""

func act(game: RefCounted, id: String, action: String) -> String:
	var blocked: String = reason(game,id,action)
	if not blocked.is_empty(): return blocked
	var f: Dictionary = game.sector.faction_by_id(id)
	var old_relation: int = f.relation
	var old_money: float = game.field.marks
	var cause: int = state.keys.get("contact:"+id,0)
	var outcome: Dictionary = {"action":action}
	if action == "gift":
		game.field.marks -= 120
		state.gifts.append(id)
		f.relation = mini(100,int(f.relation)+15)
		f.reason = "Your one-time goodwill grant repaired local infrastructure (+15)."
	elif action == "chart":
		state.licenses[game.field.state.planet_id] = id
		game.field.marks += 25
		f.relation = mini(100,int(f.relation)+8)
		f.reason = "You licensed an exclusive orbital survey to us (+8)."
		outcome.planet = game.field.state.planet_id
	elif action.begins_with("cancel_"):
		var pact: String = action.trim_prefix("cancel_")
		game.sector.state.agreements.erase(id+":"+pact)
		f.relation = maxi(-100,int(f.relation)-20)
		f.reason = "You withdrew from our %s agreement (-20)." % pact.replace("_"," ")
		cause = state.keys.get("pact:"+id+":"+pact,cause)
	else:
		blocked = game.sector.command("diplomacy",{"faction":id,"pact":action})
		if not blocked.is_empty(): return blocked
		if action == "alliance":
			var charts: Array = []
			for system: Dictionary in game.sector.state.systems:
				if system.owner != id: continue
				for neighbor: String in system.links:
					if neighbor not in charts: charts.append(neighbor)
					for frontier: String in game.sector.system_by_id(neighbor).links:
						if frontier not in charts: charts.append(frontier)
			for known: String in charts: game.sector.system_by_id(known)["charted"] = true
			outcome.charts = charts
	f.embargo = int(f.relation) < -15
	game.fleet.reconcile(game)
	outcome.relation_before = old_relation
	outcome.relation_after = int(f.relation)
	outcome.marks_delta = game.field.marks-old_money
	outcome.embargo = f.embargo
	var summary: String = "%s · %s. Relations %d → %d; treasury %+d Marks." % [f.name,action.replace("_"," "),old_relation,f.relation,outcome.marks_delta]
	var event_id: int = record(game,"diplomacy",summary,id,outcome,cause)
	if action in ["trade","non_aggression","alliance"]: state.keys["pact:"+id+":"+action] = event_id
	game.field.note("diplomacy_%d" % event_id,summary)
	return ""

func restore(value: Variant) -> Error:
	if not value is Dictionary or not value.has_all(["gifts","licenses","events","keys","next_id"]): return ERR_INVALID_DATA
	if not value.gifts is Array or not value.licenses is Dictionary or not value.events is Array or not value.keys is Dictionary or not value.next_id is int: return ERR_INVALID_DATA
	if value.gifts.size() > 3 or value.licenses.size() > 24 or value.events.size() > 16384 or value.keys.size() > 16384 or value.next_id != value.events.size()+1: return ERR_INVALID_DATA
	var seen: Array = []
	for id: Variant in value.gifts:
		if not id is String or not profiles.has(id) or id in seen: return ERR_INVALID_DATA
		seen.append(id)
	for planet: Variant in value.licenses:
		if not planet is String or Geography.definition(planet).is_empty() or not value.licenses[planet] is String or not profiles.has(value.licenses[planet]): return ERR_INVALID_DATA
	var expected: int = 1
	var last_time: int = 0
	for event: Variant in value.events:
		if not event is Dictionary or not event.has_all(["id","time","kind","location","summary","actor","outcome","cause"]): return ERR_INVALID_DATA
		if not event.id is int or event.id != expected or not event.time is int or event.time < last_time: return ERR_INVALID_DATA
		if not event.kind is String or not event.summary is String or not event.location is String or Geography.definition(event.location).is_empty(): return ERR_INVALID_DATA
		if not event.actor is Dictionary or not event.outcome is Dictionary or not event.cause is int or event.cause < 0 or event.cause >= event.id: return ERR_INVALID_DATA
		expected += 1; last_time = event.time
	for key: Variant in value.keys:
		if not key is String or not value.keys[key] is int or value.keys[key] <= 0 or value.keys[key] >= value.next_id: return ERR_INVALID_DATA
	state = value.duplicate(true)
	return OK
