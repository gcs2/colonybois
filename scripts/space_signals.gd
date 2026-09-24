extends RefCounted
## Finite authored encounter lifecycle. One authoritative clock, paid acts, durable outcomes.
const Field = preload("res://scripts/encounter_state.gd")
const Check = preload("res://scripts/surface_combat.gd")
static var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/space_signals.json"))
const RANGE := 12.0
const SCAN_ENERGY := 8
var state: Dictionary = {"encounters":{}}
static func position(id: String) -> Vector3:
	var at: Array = catalog[id].position
	return Vector3(at[0],at[1],at[2])
func local_ids(game: RefCounted) -> Array:
	return state.encounters.keys().filter(func(id: String) -> bool: return catalog[id].planet == game.field.state.planet_id)
func open_ids() -> Array:
	return state.encounters.keys().filter(func(id: String) -> bool: return state.encounters[id].status in ["offered","active","decision"])
func completed() -> int:
	return state.encounters.values().filter(func(item: Dictionary) -> bool: return item.status == "resolved").size()
func discover(game: RefCounted) -> void:
	if game.traveling() or game.field.state.flight_mode != "orbit" or game.field.state.survey_ticks < game.field.definition().survey_seconds: return
	for id: String in catalog:
		if catalog[id].planet != game.field.state.planet_id or state.encounters.has(id): continue
		state.encounters[id] = {"status":"offered","choice":"","deadline":0,"progress":0,"channeling":false,"discovered_at":int(game.field.state.time),"accepted_at":0,"resolved_at":0}
		game.diplomacy.contact(game,catalog[id].faction)
		game.diplomacy.record(game,"encounter","Signal located: "+str(catalog[id].title)+".",catalog[id].faction,{"encounter":id,"status":"offered"},0,"signal:"+id,catalog[id].planet)
		game.field.note("signal_"+id,"New orbital signal · "+str(catalog[id].title)+". Click the contact or open Communications.")
func reason(game: RefCounted, id: String, action: String, at: Vector3) -> String:
	if not catalog.has(id) or not state.encounters.has(id): return "Discover this signal through an orbital survey."
	var item: Dictionary = state.encounters[id]; var spec: Dictionary = catalog[id]
	if item.status not in ["offered","active","decision"]: return "This encounter has ended."
	if action == "abandon": return "" if item.status == "active" and spec.kind == "convoy" else "No escort commitment to abandon."
	if action == "decline": return "Withdraw from your escort commitment instead." if spec.kind == "convoy" and item.status == "active" else ""
	if not spec.choices.has(action): return "Unknown encounter action."
	if game.traveling(): return "Finish the journey first."
	if action in ["publish","license"]:
		return "Scan the registry first." if item.status != "decision" else ""
	if spec.planet != game.field.state.planet_id or game.field.state.flight_mode != "orbit": return "Return to this signal's orbit."
	if action == "defend": return "Escort commitment already active." if item.status != "offered" else ""
	if not at.is_finite() or at.distance_to(position(id)) > RANGE: return "Approach within 12 m."
	if action == "passage": return "Requires 60 Marks." if game.field.marks < 60 else ""
	if action == "inspect":
		if item.status == "decision": return "Registry already scanned."
		if item.channeling: return "Scan already in progress."
		return "Requires 8 energy." if game.field.state.energy < SCAN_ENERGY else ""
	return "Unknown encounter action."
func act(game: RefCounted, id: String, action: String, at: Vector3) -> String:
	var blocked: String = reason(game,id,action,at)
	if not blocked.is_empty(): return blocked
	var item: Dictionary = state.encounters[id]
	if action in ["decline","abandon"]:
		finish(game,id,"failed" if action == "abandon" else "declined"); return ""
	if action in ["passage","publish","license"]:
		finish(game,id,action); return ""
	item.status = "active"; item.choice = action
	if item.accepted_at == 0: item.accepted_at = int(game.field.state.time)
	if action == "defend": item.deadline = int(game.field.state.time)+int(catalog[id].seconds)
	else:
		game.field.state.energy -= SCAN_ENERGY
		item.channeling = true; item.progress = 0
	game.diplomacy.record(game,"encounter","Committed to "+("cover the convoy's departure." if action == "defend" else "a close-range registry scan."),catalog[id].faction,{"encounter":id,"action":action,"deadline":item.deadline,"energy":SCAN_ENERGY if action == "inspect" else 0},game.diplomacy.state.keys.get("signal:"+id,0),"",catalog[id].planet)
	return ""
func cancel_scan() -> void:
	for item: Dictionary in state.encounters.values():
		if item.channeling: item.channeling = false; item.progress = 0
func tick(game: RefCounted) -> void:
	discover(game)
	for id: String in state.encounters:
		var item: Dictionary = state.encounters[id]; var spec: Dictionary = catalog[id]
		if item.status != "active": continue
		if spec.kind == "convoy":
			var world: Dictionary = game.field.state if game.field.state.planet_id == spec.planet else game.worlds.get(spec.planet,{})
			if world.get("guardian_disabled",false): finish(game,id,"defend")
			elif game.field.state.time >= item.deadline: finish(game,id,"failed")
		elif item.channeling:
			var coords: Array = game.field.state.position
			var ship := Vector3(coords[0],coords[1],coords[2])
			if game.traveling() or game.field.state.planet_id != spec.planet or game.field.state.flight_mode != "orbit" or ship.distance_to(position(id)) > RANGE:
				item.channeling = false; item.progress = 0; continue
			item.progress += 1
			if item.progress >= spec.seconds:
				item.channeling = false; item.status = "decision"
				game.diplomacy.record(game,"encounter","The registry reveals competing ownership seals. Choose who receives the evidence.",spec.faction,{"encounter":id,"status":"decision"},game.diplomacy.state.keys.get("signal:"+id,0),"signal_scan:"+id,spec.planet)
				game.field.note("signal_ready_"+id,"Registry scan complete · publish the claims or sell exclusive evidence through Signals.")
func finish(game: RefCounted, id: String, result: String) -> void:
	var item: Dictionary = state.encounters[id]
	if item.status not in ["offered","active","decision"]: return
	var spec: Dictionary = catalog[id]; var outcome: Dictionary = spec.outcomes[result]
	item.status = result if result in ["failed","declined"] else "resolved"
	item.choice = result; item.channeling = false; item.deadline = 0; item.resolved_at = int(game.field.state.time)
	game.field.marks += outcome.marks
	for faction_id: String in outcome.relations:
		game.diplomacy.contact(game,faction_id)
		var faction: Dictionary = game.sector.faction_by_id(faction_id)
		faction.relation = clampi(int(faction.relation)+int(outcome.relations[faction_id]),-100,100)
		faction.embargo = int(faction.relation) < -15
		faction.reason = str(spec.title)+" · "+str(outcome.summary)+" (%+d)." % outcome.relations[faction_id]
	game.fleet.reconcile(game)
	game.diplomacy.record(game,"encounter",outcome.summary,spec.faction,{"encounter":id,"choice":result,"status":item.status,"marks_delta":outcome.marks,"relations":outcome.relations},game.diplomacy.state.keys.get("signal:"+id,0),"signal_end:"+id,spec.planet)
	game.field.note("signal_end_"+id,str(spec.title)+(" · resolved" if item.status == "resolved" else " · commitment failed" if item.status == "failed" else " · declined"))
	game.commerce.update_badges(game)
func restore(value: Variant, now: int, events: RefCounted) -> Error:
	if not value is Dictionary or not value.has("encounters") or not value.encounters is Dictionary or value.encounters.size() > catalog.size(): return ERR_INVALID_DATA
	for id: Variant in value.encounters:
		if not id is String or not catalog.has(id): return ERR_INVALID_DATA
		var item: Variant = value.encounters[id]; var spec: Dictionary = catalog[id]
		if not item is Dictionary or not item.has_all(["status","choice","deadline","progress","channeling","discovered_at","accepted_at","resolved_at"]): return ERR_INVALID_DATA
		if not item.status is String or item.status not in ["offered","active","decision","resolved","failed","declined"] or not item.choice is String or not item.channeling is bool: return ERR_INVALID_DATA
		for key: String in ["discovered_at","accepted_at","resolved_at"]:
			if not Check.number(item[key],0,now,true): return ERR_INVALID_DATA
		if not Check.number(item.deadline,0,now+int(spec.seconds),true) or not Check.number(item.progress,0,6,true): return ERR_INVALID_DATA
		if not events.state.keys.has("signal:"+id): return ERR_INVALID_DATA
		if item.status == "offered":
			if item.choice != "" or item.accepted_at != 0 or item.progress != 0: return ERR_INVALID_DATA
		elif item.status == "active":
			if item.choice != ("defend" if spec.kind == "convoy" else "inspect") or item.accepted_at < item.discovered_at: return ERR_INVALID_DATA
			if spec.kind == "convoy" and (item.deadline <= now or item.deadline != item.accepted_at+int(spec.seconds)): return ERR_INVALID_DATA
		elif item.status == "decision":
			if spec.kind != "registry" or item.choice != "inspect" or item.progress != spec.seconds: return ERR_INVALID_DATA
		else:
			if not spec.outcomes.has(item.choice) or item.resolved_at < item.discovered_at or not events.state.keys.has("signal_end:"+id): return ERR_INVALID_DATA
			if item.status in ["failed","declined"] and item.choice != item.status: return ERR_INVALID_DATA
			if item.status == "resolved" and item.choice in ["failed","declined"]: return ERR_INVALID_DATA
		if item.status not in ["resolved","failed","declined"] and item.resolved_at != 0: return ERR_INVALID_DATA
		if not (spec.kind == "convoy" and item.status == "active") and item.deadline != 0: return ERR_INVALID_DATA
		if item.channeling and (spec.kind != "registry" or item.status != "active" or item.progress >= spec.seconds): return ERR_INVALID_DATA
		if spec.kind == "convoy" and item.progress != 0: return ERR_INVALID_DATA
	state = value.duplicate(true)
	return OK
