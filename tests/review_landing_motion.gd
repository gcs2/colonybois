extends SceneTree
## Real physics/camera sequence with synthetic descent command and isolated saves.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1280,720)
	root.content_scale_size = Vector2i(1600,900)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.gui_disable_input = true
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	root.add_child(scene)
	scene.save_path = "res://artifacts/landing-motion.json"
	scene.set_process(false); scene.set_physics_process(false)
	scene.set_process_input(false); scene.set_process_unhandled_input(false)
	scene.audio.muted = true
	scene._change_flight_mode("orbit")
	scene.ship.position = Vector3(-60,-8,-14)
	scene.camera_distance_target = 105; scene.distance = 105
	scene._update_camera(1)
	scene._begin_landing()
	DirAccess.make_dir_recursive_absolute("res://artifacts/landing-motion")
	var trace := FileAccess.open("res://artifacts/landing-motion/trace.csv",FileAccess.WRITE)
	trace.store_line("frame,seconds,mode,speed,planet_clearance")
	for frame: int in range(480):
		scene.orbit.advance(1.0/60)
		scene._physics_process(1.0/60)
		scene._update_camera(1.0/60)
		scene._update_visuals(); scene._refresh_ui(); scene._update_flight_effects(1.0/60)
		await process_frame
		if frame % 6 == 0:
			trace.store_line("%d,%.3f,%s,%.3f,%.3f" % [frame,frame/60.0,scene.model.state.flight_mode,scene.velocity.length(),scene.ship.position.distance_to(scene.orbit.planet.position)-21])
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://artifacts/landing-motion/frame-%03d.png" % (frame/6))
	trace.close()
	print("Captured eight-second landing motion sequence at 10 sampled frames per second")
	quit()
