extends SceneTree
## Actual imported mesh, native renderer; no composited concept art.
func _initialize() -> void: call_deferred("run")
func capture(view: SubViewport, file: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	view.get_texture().get_image().save_png("res://artifacts/scout_"+file+".png")
func run() -> void:
	var view := SubViewport.new()
	view.size = Vector2i(1920,1080); view.own_world_3d = true
	view.size_2d_override = Vector2i(1600,900); view.size_2d_override_stretch = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS; root.add_child(view)
	var stage := Node3D.new(); view.add_child(stage)
	var env := WorldEnvironment.new(); env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("151e2a")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("8191b7")
	env.environment.ambient_light_energy = 0.55; stage.add_child(env)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-40,-35,0); light.light_color = Color("fff1d7"); light.light_energy = 1.6; stage.add_child(light)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(25,135,0); fill.light_color = Color("acc6e1"); fill.light_energy = 0.6; stage.add_child(fill)
	var ship: Node3D = load("res://assets/encounter/scout.glb").instantiate(); stage.add_child(ship)
	var camera := Camera3D.new(); stage.add_child(camera); camera.current = true
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL; camera.size = 9.5
	var angles: Dictionary = {"front":Vector3(6,5,-8),"rear":Vector3(-6,4,8),"top":Vector3(0,10,0.01),"side":Vector3(10,0,0),"belly":Vector3(4,-5,-7)}
	for id: String in angles:
		camera.position = angles[id]; camera.look_at(Vector3.ZERO); await capture(view,id)
	stage.free()
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); view.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	for mode: String in ["surface","orbit"]:
		if mode == "orbit": scene._change_flight_mode("orbit")
		scene.ship.rotation.y = -0.6
		for gap: float in [14,29,95]:
			scene.distance = gap; scene.camera_distance_target = gap; scene.yaw = 0.3; scene.pitch = 0.65
			scene.velocity = Vector3(0,1,-12); scene._update_camera(1)
			scene._update_visuals(); scene._update_flight_effects(1); scene._refresh_ui()
			for i: int in range(12): await process_frame
			await capture(view,"%s_%d" % [mode,int(gap)])
	scene.free(); view.free(); quit()
