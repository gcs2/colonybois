extends RefCounted
## Timed ship equipment on the authoritative field clock, not scene timers.
static var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/ship_support.json"))
static func fresh() -> Dictionary:
	return {"shield":{"until":0,"ready":0,"uses":0},"rally_call":{"until":0,"ready":0,"uses":0}}
static func active(field: RefCounted, id: String) -> bool:
	return id in field.installed_upgrades and field.state.support[id].until > field.state.time
static func reason(field: RefCounted, id: String) -> String:
	if not catalog.has(id): return "Unknown support tool."
	if id not in field.installed_upgrades: return "Purchase this equipment at a dock."
	if active(field,id): return "%s active · %d s remaining." % [catalog[id].name,field.state.support[id].until-field.state.time]
	if field.state.support[id].ready > field.state.time: return "Cooling down · %d s." % (field.state.support[id].ready-field.state.time)
	if field.state.energy < catalog[id].energy: return "Requires %d energy." % catalog[id].energy
	return ""
static func use(field: RefCounted, id: String) -> String:
	var blocked: String = reason(field,id)
	if not blocked.is_empty(): return blocked
	var entry: Dictionary = field.state.support[id]
	field.state.energy -= catalog[id].energy
	entry.until = int(field.state.time)+int(catalog[id].duration)
	entry.ready = int(field.state.time)+int(catalog[id].cooldown)
	entry.uses += 1
	return ""
static func validate(value: Variant, now: int, owned: Array) -> bool:
	if not value is Dictionary or value.size() != catalog.size(): return false
	for id: String in catalog:
		var entry: Variant = value.get(id)
		if not entry is Dictionary or entry.size() != 3 or not entry.has_all(["until","ready","uses"]): return false
		for key: String in ["until","ready","uses"]:
			if not (entry[key] is int or entry[key] is float) or not is_finite(float(entry[key])) or entry[key] < 0 or entry[key] != floorf(entry[key]): return false
		if entry.uses > 1000000000 or entry.until > now+catalog[id].duration or entry.ready > now+catalog[id].cooldown: return false
		if entry.uses == 0:
			if entry.until != 0 or entry.ready != 0: return false
		else:
			if id not in owned or entry.ready < catalog[id].cooldown: return false
			if entry.until > 0 and entry.ready-entry.until != catalog[id].cooldown-catalog[id].duration: return false
	return true
