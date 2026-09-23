extends SceneTree
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1; printerr("FAIL: "+message)
func wheel(scene: Node, out: bool, altitude: bool = false) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_WHEEL_DOWN if out else MOUSE_BUTTON_WHEEL_UP
	event.pressed = true
	event.ctrl_pressed = altitude
	scene._unhandled_input(event)
func run() -> void:
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	scene.set_physics_process(false)
	scene.audio.muted = true
	var before: Vector3 = scene.ship.position
	var time: int = scene.model.state.time
	wheel(scene,true)
	check(scene.camera_distance_target > 55 and scene.altitude_order == -1,"Ordinary wheel changes camera scale, not altitude")
	check(scene.ship.position == before and scene.model.state.time == time,"Changing camera does not move or tick the ship")
	wheel(scene,false,true)
	check(scene.altitude_order > before.y,"Ctrl-wheel retains explicit ascent control")
	scene._cancel_orders()
	scene.camera_distance_target = scene.SURFACE_ZOOM_MAX
	wheel(scene,true)
	check(scene.zoom_ascent and scene.altitude_order == 63 and scene.model.state.flight_mode == "surface","Scrolling beyond surface overview begins actual ascent")
	wheel(scene,false)
	check(not scene.zoom_ascent and scene.altitude_order == -1,"Scrolling back in cancels camera-requested ascent")
	scene._command_target("relay")
	scene.hud.altitude_requested.emit(1)
	check(not scene.approach_subject and not scene.navigating and scene.vertical_button == 1,"Mouse altitude control overrides an approach order")
	scene.hud.altitude_requested.emit(0)
	scene.camera_distance_target = scene.SURFACE_ZOOM_MAX
	wheel(scene,true)
	Input.action_press("flight_left")
	scene._physics_process(1.0/60)
	Input.action_release("flight_left")
	check(not scene.zoom_ascent and scene.altitude_order == -1,"Manual steering cancels camera-requested ascent")
	scene._stop()
	scene.camera_distance_target = scene.SURFACE_ZOOM_MAX
	wheel(scene,true)
	for i: int in range(400): scene._physics_process(1.0/60)
	check(scene.model.state.flight_mode == "orbit","Zoom ascent reaches the orbital reference frame")
	check(scene.model.state.time == time and scene.model.state.history.size() == 1,"Zoom transition neither duplicates economy nor loses its milestone")
	for i: int in range(30): wheel(scene,true)
	scene._update_camera(1)
	check(scene.distance == 320 and scene.camera.far >= 600,"Orbital overview supports a substantially wider camera")
	check(scene.camera.position.distance_to(scene.orbit.planet.position) > 20,"Wide camera remains outside planet geometry")
	var zoom: float = scene.camera_distance_target
	scene._show_popup("cargo")
	wheel(scene,false)
	check(scene.camera_distance_target == zoom,"Inspection blocks world-camera scroll")
	scene.popup.hide()
	var effects: Node3D = scene.effects
	var particle_count: int = 0
	for emitter: CPUParticles3D in effects.all_emitters(): particle_count += emitter.amount
	check(particle_count == 184 and particle_count <= effects.MAX_PARTICLES,"All cosmetic particles fit the explicit budget")
	effects.update(1,16,false,true,0,"scan",false,Vector3.ZERO,0)
	check(effects.exhaust.all(func(jet: CPUParticles3D) -> bool: return jet.emitting),"Movement drives both engine emitters")
	check(not effects.dust.visible,"No atmospheric dust in orbit")
	effects.update(1,16,true,true,0,"scan",true,Vector3.ZERO,0.5)
	check(effects.all_emitters().all(func(p: CPUParticles3D) -> bool: return not p.visible and not p.emitting),"Inspection/pause hides and stops every particle emitter")
	check(not effects.sweep.visible and not effects.tool_active,"Pause also removes the active tool sweep")
	scene._change_flight_mode("surface")
	scene._select_tool("scan")
	scene.ship.position = scene._target_position("relay")+Vector3(0,3,3)
	scene._command_target("relay")
	scene._operate(0.5)
	scene._update_flight_effects(0.5)
	check(effects.tool_active and effects.tool_particles.emitting,"A validated operation drives actual tool particles")
	scene._stop()
	check(not effects.tool_active and not effects.tool_particles.visible,"Cancel clears the tool effect immediately")
	var saved: Dictionary = scene.model.state.duplicate(true)
	for i: int in range(10):
		effects.update(1,12,false,false,0,"collect",true,Vector3.ONE,0.4)
		effects.reset()
	check(scene.model.state == saved,"Effects cannot mutate gameplay or rewards")
	check(effects.all_emitters().size() == 5,"Repeated operations reuse the same bounded emitters")
	scene.free()
	print("Flight presentation assertions: ",checks,"; failures: ",failures)
	quit(0 if failures == 0 else 1)
