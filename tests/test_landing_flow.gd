extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	root.add_child(scene)
	scene.save_path = "res://artifacts/landing-flow-test.json"
	scene.set_process(false); scene.set_physics_process(false)
	scene.audio.muted = true
	scene._change_flight_mode("orbit")
	scene.ship.position = Vector3(-60,-8,-14)
	scene._begin_landing()
	var frames: int = 0
	var minimum_speed: float = INF
	var slow_frames: int = 0
	var collided: bool = false
	while scene.model.state.flight_mode == "orbit" and frames < 2400:
		scene._physics_process(1.0/60)
		frames += 1
		if frames > 60 and not scene.landing_waypoints.is_empty():
			minimum_speed = minf(minimum_speed,scene.velocity.length())
			if scene.velocity.length() < 8: slow_frames += 1
		if scene.model.state.flight_mode == "orbit" and scene.ship.position.distance_to(scene.orbit.planet.position) <= 21.01: collided = true
	print("Landing flow: ",frames/60.0," seconds; intermediate minimum speed ",minimum_speed,"; slow frames ",slow_frames,"; collision ",collided,"; completed ",scene.model.state.flight_mode == "surface")
	var passed: bool = not collided and scene.model.state.flight_mode == "surface" and slow_frames == 0 and frames < 480
	# Cover different hemispheres and integration rates; no collision-clamp contacts.
	for hz: int in [30,60,120]:
		for angle: int in range(0,360,45):
			scene._change_flight_mode("orbit")
			scene.ship.position = scene.orbit.planet.position+Vector3(cos(deg_to_rad(angle))*55,12,sin(deg_to_rad(angle))*55)
			scene._begin_landing()
			var touched: bool = false
			for frame: int in range(hz*20):
				if scene.model.state.flight_mode == "surface": break
				scene._physics_process(1.0/hz)
				if scene.model.state.flight_mode == "orbit" and scene.ship.position.distance_to(scene.orbit.planet.position) <= 21.01: touched = true
			if touched or scene.model.state.flight_mode != "surface":
				passed = false; printerr("Landing failed at ",angle," degrees / ",hz," Hz")
	print("Landing route sweep: 24 hemisphere/rate cases; passed ",passed)
	scene.free()
	quit(0 if passed else 1)
