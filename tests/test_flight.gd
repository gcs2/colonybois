extends SceneTree
const Model = preload("res://scripts/encounter_state.gd")
const Controls = preload("res://scripts/flight_controls.gd")
var checks: int = 0
var failures: int = 0

func _initialize() -> void: call_deferred("run")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1; printerr("FAIL: "+message)

func run() -> void:
	Controls.install()
	for key: int in [KEY_W,KEY_UP,KEY_KP_8]:
		var event := InputEventKey.new()
		event.physical_keycode = key
		check(InputMap.event_is_action(event,"flight_forward"),"Forward accepts WASD, arrows and numpad: %s" % key)
	for key: int in [KEY_HOME,KEY_PAGEUP,KEY_KP_9,KEY_KP_ADD]:
		var event := InputEventKey.new()
		event.physical_keycode = key
		check(InputMap.event_is_action(event,"flight_rise"),"Right-hand altitude binding: %s" % key)
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	scene.set_physics_process(false)
	scene.model = Model.new()
	scene.save_path = "res://artifacts/flight_ui_test.json"
	scene._restore_ship()
	scene._apply_flight_mode()
	scene._update_camera(1)
	var start: Vector3 = scene.ship.position
	Input.action_press("flight_rise")
	for i: int in range(90): scene._physics_process(1.0/60)
	Input.action_release("flight_rise")
	check(scene.ship.position.y > start.y+14,"Manual vertical flight exceeds old 14 m ceiling")
	scene._cancel_orders()
	scene.ship.position = Vector3(0,5,18)
	scene._update_camera(1)
	scene._pick(scene.camera.unproject_position(scene._target_position("relay")))
	check(scene.selected == "relay" and scene.approach_subject,"A target click issues an approach and tool order")
	for i: int in range(600):
		scene._physics_process(1.0/60)
		scene._operate(1.0/60)
	check("relay" in scene.model.state.scanned,"Click alone completes approach and survey without F")
	check(not scene.model.state.seeded and not scene.model.state.warm,"Spaceflight introduction requires no planting")
	scene._navigate(Vector3(-20,8,12))
	for i: int in range(180): scene._physics_process(1.0/60)
	check(scene.ship.position.x < -10,"Point-and-click flight moves the actual ship")
	var stop: Vector3 = scene.ship.position
	scene._cancel_orders()
	for i: int in range(30): scene._physics_process(1.0/60)
	check(scene.ship.position.distance_to(stop) < 0.01,"Brake cancels autopilot and residual velocity")
	var surface_state: Dictionary = scene.model.state.duplicate(true)
	scene._departure()
	check(scene.model.state.flight_mode == "surface","Depart command begins ascent, not an instant teleport")
	for i: int in range(360): scene._physics_process(1.0/60)
	check(scene.model.state.flight_mode == "orbit" and scene.orbit.visible and not scene.surface_root.visible,"Crossing atmospheric ceiling reaches orbital flight")
	check(scene.model.state.scanned == surface_state.scanned and scene.model.state.native_stock == surface_state.native_stock,"Departure preserves surface discoveries and resources")
	check(scene.model.state.time == surface_state.time,"Switching views does not run duplicate simulation ticks")
	scene._save()
	var restored := Model.new()
	check(restored.load_from(scene.save_path) == OK and restored.state.flight_mode == "orbit","Orbital location survives save/load")
	scene._begin_landing()
	for i: int in range(360): scene._physics_process(1.0/60)
	check(scene.model.state.flight_mode == "surface" and scene.surface_root.visible and not scene.orbit.visible,"Orbital approach returns to the same surface")
	check(scene.model.state.landings == 1 and "relay" in scene.model.state.scanned,"Landing preserves survey and records one return")
	check(scene.surface_environment.environment != null and scene.orbit.environment.environment == null,"Return restores the surface environment exclusively")
	scene._navigate(Vector3(20,7,20))
	scene._toggle_pause()
	var frozen: Vector3 = scene.ship.position
	scene._physics_process(1)
	check(scene.ship.position == frozen and not scene.navigating,"Pause stops movement and cancels queued orders")
	scene._toggle_pause()
	scene._show_popup("controls")
	check(scene.popup.visible and scene.popup_body.get_child_count() >= 3,"Controls help is accessible from the HUD")
	scene.popup.visible = false
	# Migration is exercised with a complete original snapshot, not a made-up stub.
	var old: Dictionary = Model.fresh()
	old.version = 1
	old.erase("flight_mode")
	old.erase("landings")
	old.marks = 54
	var legacy_path: String = "res://artifacts/flight_legacy.json"
	var file := FileAccess.open(legacy_path,FileAccess.WRITE)
	file.store_string(JSON.stringify(old))
	file.close()
	check(restored.load_from(legacy_path) == OK and restored.state.marks == 54 and restored.state.flight_mode == "surface","Version 1 saves migrate without losing earned currency")
	old.version = 2
	old.flight_mode = "invalid"
	old.landings = 0
	file = FileAccess.open(legacy_path,FileAccess.WRITE)
	file.store_string(JSON.stringify(old))
	file.close()
	var before: Dictionary = restored.state.duplicate(true)
	check(restored.load_from(legacy_path) == ERR_INVALID_DATA and restored.state == before,"Invalid flight location cannot replace current progress")
	scene.free()
	print("Flight assertions: ",checks,"; failures: ",failures)
	quit(0 if failures == 0 else 1)
