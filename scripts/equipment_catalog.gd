extends RefCounted
## Authored tool contract shared by commands, HUD and effects. State stays in the model.
const PATH := "res://data/equipment.json"
const HANDLERS := ["scan", "collect", "warm", "seed", "mine"]
const TARGETS := ["pod", "grazer", "bed", "relay", "vein"]
static var _entries: Dictionary = {}

static func validate(document: Variant) -> PackedStringArray:
	var errors := PackedStringArray()
	if not document is Dictionary or document.get("version") != 1 or not document.get("tools") is Array:
		return PackedStringArray(["Expected equipment version 1 and a tools array."])
	var seen: Array[String] = []
	for entry: Variant in document.tools:
		if not entry is Dictionary:
			errors.append("Tool must be an object.")
			continue
		var valid: bool = true
		for key: String in ["id", "name", "category", "description", "constraint", "target_error", "icon", "color", "effect_color", "acquisition"]:
			if not entry.get(key) is String or entry.get(key, "").is_empty():
				errors.append("Missing text field: "+key)
				valid = false
		for key: String in ["reach", "seconds", "energy", "samples"]:
			var value: Variant = entry.get(key)
			if (not value is float and not value is int) or not is_finite(float(value)) or float(value) < 0:
				errors.append("Invalid numeric field: "+key)
				valid = false
		if not entry.get("targets") is Array or not entry.get("requires_scan") is bool:
			errors.append("Expected targets array and requires_scan boolean.")
			valid = false
		if not valid: continue
		if entry.id in seen or entry.id not in HANDLERS: errors.append("Duplicate or unsupported handler: "+entry.id)
		seen.append(entry.id)
		if entry.reach <= 0 or entry.seconds <= 0: errors.append("Reach and cycle must be positive: "+entry.id)
		if entry.samples != floor(entry.samples): errors.append("Sample cost must be a whole number: "+entry.id)
		if entry.targets.is_empty(): errors.append("Tool needs a target: "+entry.id)
		for target: Variant in entry.targets:
			if target not in TARGETS: errors.append("Unsupported target for "+entry.id)
		if not entry.icon.begins_with("res://assets/ui/flight/") or not ResourceLoader.exists(entry.icon, "Texture2D"):
			errors.append("Missing tool icon: "+entry.id)
		if not Color.html_is_valid(entry.color) or not Color.html_is_valid(entry.effect_color): errors.append("Invalid tool color: "+entry.id)
	# Current handlers and keyboard slots are intentionally bounded. A new handler needs code and tests.
	if seen.size() != HANDLERS.size(): errors.append("Catalog must define every supported tool exactly once.")
	return errors

static func _ensure_loaded() -> void:
	if not _entries.is_empty(): return
	var document: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	var errors: PackedStringArray = validate(document)
	if not errors.is_empty():
		push_error("Invalid equipment catalog: "+"; ".join(errors))
		return
	for entry: Dictionary in document.tools: _entries[entry.id] = entry.duplicate(true)

static func has_tool(id: String) -> bool:
	_ensure_loaded()
	return _entries.has(id)

static func definition(id: String) -> Dictionary:
	_ensure_loaded()
	return _entries.get(id, {}).duplicate(true)

static func ids() -> Array[String]:
	_ensure_loaded()
	var result: Array[String] = []
	result.assign(_entries.keys())
	return result

static func groups() -> Dictionary:
	_ensure_loaded()
	var result: Dictionary = {}
	for id: String in _entries:
		var category: String = _entries[id].category
		if not result.has(category): result[category] = []
		result[category].append(id)
	return result

static func value(id: String, key: String) -> Variant:
	_ensure_loaded()
	# Only scalar access; callers must use definition() for mutable collections.
	var result: Variant = _entries.get(id, {}).get(key)
	return result.duplicate(true) if result is Array or result is Dictionary else result

static func title(id: String) -> String: return str(value(id, "name"))
static func reach(id: String) -> float: return float(value(id, "reach"))
static func seconds(id: String) -> float: return float(value(id, "seconds"))
static func energy(id: String) -> float: return float(value(id, "energy"))
static func samples(id: String) -> int: return int(value(id, "samples"))
static func tint(id: String) -> Color: return Color.html(value(id, "color"))
static func effect_tint(id: String) -> Color: return Color.html(value(id, "effect_color"))

static func colors() -> Array[Color]:
	var result: Array[Color] = []
	for id: String in ids(): result.append(tint(id))
	return result

static func amount(number: float) -> String:
	return str(int(number)) if number == floor(number) else String.num(number,2)

static func summary(id: String) -> String:
	var cost: String = "%s energy" % amount(energy(id)) if energy(id) > 0 else "no energy cost"
	if samples(id) > 0: cost += " · %d specimen" % samples(id)
	return "%s m reach · %s" % [amount(reach(id)), cost]

static func hint(id: String) -> String:
	return "%s %s. %s" % [value(id,"description"), summary(id), value(id,"constraint")]
