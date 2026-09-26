extends RefCounted
## Supplemental flight bindings live in user settings, separately from expedition saves.
const Controls = preload("res://scripts/flight_controls.gd")
const SETTINGS_PATH := "user://flight_input_settings.cfg"
const RESERVED_KEYS: Array[int] = [KEY_ESCAPE,KEY_F,KEY_G,KEY_I,KEY_J,KEY_K,KEY_M,KEY_TAB,KEY_Y,KEY_SPACE,KEY_F5,KEY_F9,
	KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6,KEY_7,KEY_8,KEY_9]
var settings_path: String = SETTINGS_PATH
var custom_keys: Dictionary = {}

func _init(path: String = SETTINGS_PATH) -> void:
	settings_path = path

func install() -> void:
	Controls.install()
	load_settings()
	for action: String in custom_keys:
		var key := int(custom_keys[action])
		if not Controls.has_key(action,key): InputMap.action_add_event(action,Controls.key_event(key))

func load_settings() -> void:
	custom_keys.clear()
	var config := ConfigFile.new()
	if config.load(settings_path) != OK: return
	var stored: Variant = config.get_value("flight_keys","custom",{})
	if not stored is Dictionary: return
	for action: Variant in stored:
		var key := int(stored[action])
		if action is String and action in Controls.BINDINGS and validate_key(action,key).is_empty():
			if not _conflicts_with_custom(action,key): custom_keys[action] = key

func save_settings() -> Error:
	var config := ConfigFile.new()
	config.set_value("flight_keys","custom",custom_keys)
	return config.save(settings_path)

func validate_key(action: String, key: int) -> String:
	if action not in Controls.BINDINGS: return "Unknown flight action."
	if key <= 0: return "Choose a physical keyboard key."
	if key in RESERVED_KEYS: return "That key is reserved for an existing shortcut."
	if _has_default_key(action,key) or int(custom_keys.get(action,0)) == key: return "That key is already bound to this action."
	for other: String in Controls.BINDINGS:
		if other != action and _has_default_key(other,key): return "That key already controls %s." % _action_name(other)
	if _conflicts_with_custom(action,key): return "That key is already assigned to another flight action."
	return ""

func assign_key(action: String, key: int, persist: bool = true) -> String:
	var error := validate_key(action,key)
	if not error.is_empty(): return error
	if _conflicts_with_custom(action,key): return "That key is already assigned to another flight action."
	var previous_key: int = int(custom_keys.get(action,0))
	if previous_key > 0 and Controls.has_key(action,previous_key): InputMap.action_erase_event(action,Controls.key_event(previous_key))
	custom_keys[action] = key
	InputMap.action_add_event(action,Controls.key_event(key))
	if persist and save_settings() != OK:
		if previous_key > 0: custom_keys[action] = previous_key
		else: custom_keys.erase(action)
		InputMap.action_erase_event(action,Controls.key_event(key))
		if previous_key > 0: InputMap.action_add_event(action,Controls.key_event(previous_key))
		return "Could not save flight controls."
	return ""

func reset(persist: bool = true) -> Error:
	var previous: Dictionary = custom_keys.duplicate(true)
	for action: String in custom_keys:
		var key := int(custom_keys[action])
		if Controls.has_key(action,key): InputMap.action_erase_event(action,Controls.key_event(key))
	custom_keys.clear()
	if persist:
		var result := save_settings()
		if result != OK:
			custom_keys = previous
			for action: String in custom_keys:
				InputMap.action_add_event(action,Controls.key_event(int(custom_keys[action])))
		return result
	return OK

func binding_text(action: String) -> String:
	var names: PackedStringArray = []
	for key: int in Controls.BINDINGS[action]: names.append(OS.get_keycode_string(key))
	if custom_keys.has(action): names.append("Custom: "+OS.get_keycode_string(int(custom_keys[action])))
	return ", ".join(names)

func _conflicts_with_custom(action: String, key: int) -> bool:
	for other: String in custom_keys:
		if other != action and int(custom_keys[other]) == key: return true
	return false

func _has_default_key(action: String, key: int) -> bool:
	for default_key: int in Controls.BINDINGS[action]:
		if default_key == key: return true
	return false

func _action_name(action: String) -> String:
	return {"flight_forward":"Forward","flight_back":"Back","flight_left":"Left","flight_right":"Right",
		"flight_rise":"Ascend","flight_descend":"Descend","flight_brake":"Brake"}.get(action,action)
