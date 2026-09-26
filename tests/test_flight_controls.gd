extends SceneTree
const Controls = preload("res://scripts/flight_controls.gd")
const Settings = preload("res://scripts/flight_input_settings.gd")
var checks: int = 0
var failures: int = 0

func _initialize() -> void: call_deferred("run")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1; printerr("FAIL: "+message)

func run() -> void:
	var test_path := "user://flight_controls_test.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(test_path))
	var settings := Settings.new(test_path)
	settings.install()
	for key: int in [KEY_W,KEY_UP,KEY_KP_8]:
		check(Controls.has_key("flight_forward",key),"Forward keeps WASD, arrow and numpad alternatives")
	for binding: Array in [["flight_left",[KEY_A,KEY_LEFT,KEY_KP_4]],["flight_back",[KEY_S,KEY_DOWN,KEY_KP_2]],["flight_right",[KEY_D,KEY_RIGHT,KEY_KP_6]]]:
		for key: int in binding[1]: check(Controls.has_key(binding[0],key),"Arrow/numpad and WASD alternatives remain mapped for %s" % binding[0])
	check(settings.validate_key("flight_left",KEY_ESCAPE) != "","Escape cannot be assigned")
	check(settings.validate_key("flight_left",0) != "","A keyless event cannot be assigned")
	check(settings.validate_key("flight_left",KEY_I) != "","A menu shortcut cannot be assigned")
	check(settings.validate_key("flight_left",KEY_UP) != "","An active key cannot conflict with another action")
	check(settings.assign_key("flight_left",KEY_Z,false).is_empty(),"A supplemental key can be assigned")
	check(Controls.has_key("flight_left",KEY_LEFT) and Controls.has_key("flight_left",KEY_KP_4),"Adding a key preserves left-hand controls")
	check(settings.assign_key("flight_right",KEY_Z,false) != "","Custom keys cannot conflict")
	check(settings.save_settings() == OK,"Custom keys save to user settings")
	var restored := Settings.new(test_path)
	restored.install()
	check(restored.custom_keys.get("flight_left",0) == KEY_Z and Controls.has_key("flight_left",KEY_Z),"Saved custom key loads into its flight action")
	check(restored.reset() == OK and not Controls.has_key("flight_left",KEY_Z),"Reset removes custom key and restores defaults")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(test_path))
	print("Flight controls assertions: ",checks,"; failures: ",failures)
	quit(0 if failures == 0 else 1)
