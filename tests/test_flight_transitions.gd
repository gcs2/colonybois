extends SceneTree
var failures: int = 0
var checks: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+label)
func run() -> void:
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	scene.camera_distance_target = 105
	scene._zoom_camera(1)
	check(scene.zoom_ascent,"Crossing the zoom boundary starts ascent without an extra wheel detent")
	scene.distance = 105
	scene._change_flight_mode("orbit")
	check(scene.distance == 105,"Transition does not snap camera distance")
	scene.camera_distance_target = 48
	scene._zoom_camera(-1)
	check(scene.landing and scene.navigating,"Inward zoom starts a real landing approach")
	scene._zoom_camera(1)
	check(not scene.landing and not scene.navigating,"Outward zoom cancels entry")
	scene.hud.altitude_requested.emit(-1)
	check(scene.landing,"Mouse descent button commands atmospheric approach")
	scene._refresh_ui()
	check(scene.hud.action_state.text == "DESCENDING" and scene.use_button.text == "Cancel","Target card explains descent and exposes cancellation")
	scene._update_visuals()
	check(scene.orbit.landing_marker.visible and scene.orbit.landing_marker.get_parent() == scene.orbit.planet,"Landing target ring inherits planet rotation")
	check(scene.flight_readout.text.begins_with("ORBIT") and not "Y " in scene.flight_readout.text,"Orbital readout does not present a scene Y coordinate as altitude")
	scene._stop()
	scene._update_visuals()
	check(not scene.orbit.landing_marker.visible,"Cancelling descent removes the landing target ring")
	Input.action_press("flight_descend")
	for i: int in range(30): scene._physics_process(1.0/60)
	Input.action_release("flight_descend")
	check(scene.landing and scene.navigating,"Holding descent does not repeatedly cancel or restart approach")
	Input.action_press("flight_left"); scene._physics_process(1.0/60); Input.action_release("flight_left")
	check(not scene.landing,"Manual steering overrides landing")
	scene._stop()
	scene.ship.position = Vector3(-60,-8,-14)
	scene._begin_landing()
	check(scene.landing_waypoints.size() > 1,"Far-side entry receives a route around the globe")
	var collided: bool = false
	for i: int in range(2000):
		if scene.model.state.flight_mode == "surface": break
		scene._physics_process(1.0/60)
		if scene.model.state.flight_mode == "orbit" and scene.ship.position.distance_to(scene.orbit.planet.position) < 21: collided = true
	check(scene.model.state.flight_mode == "surface" and not collided,"Far-side entry reaches the surface without becoming stuck against the planet")
	check(scene.model.state.landings == 1,"A completed multi-waypoint approach records one landing")
	scene.ship.position.y = scene.terrain_height(scene.ship.position.x,scene.ship.position.z)+10
	scene._refresh_ui()
	check(scene.flight_readout.text.begins_with("ALT 10 m"),"Surface altitude measures clearance above local terrain")
	scene._change_flight_mode("orbit")
	scene.arrival_fade = 0
	scene.landing = true; scene.landing_waypoints.clear()
	scene.destination = scene.ship.position+Vector3(0,0,3)
	scene._update_flight_effects(0)
	check(is_zero_approx(scene.transition_veil.color.a),"Final approach remains visible three units before arrival")
	scene.destination = scene.ship.position+Vector3(0,0,0.66)
	scene._update_flight_effects(0)
	check(scene.transition_veil.color.a > 0.95 and scene.wreck_label.modulate.a < 0.05,"World locators disappear with the world at the reference-frame swap")
	scene._cancel_orders(); scene._update_flight_effects(0)
	check(is_zero_approx(scene.transition_veil.color.a) and scene.wreck_label.modulate.a == 1,"Cancellation immediately restores world and locator opacity")
	scene.audio.muted = false
	scene.audio.guide("missing_test_recording","No machine voice should speak this.")
	check(not scene.audio.voice.playing,"Absent guide recordings remain caption-only")
	scene.free()
	print("Flight transition assertions: ",checks,"; failures: ",failures)
	quit(0 if failures == 0 else 1)
