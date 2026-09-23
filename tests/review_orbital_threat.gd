extends SceneTree
## Isolated rendered inspection of the charted orbital threat; never reads a player save.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	scene.set_physics_process(false)
	scene.audio.muted = true
	scene.model.state.survey_ticks = 12
	scene._change_flight_mode("orbit")
	scene.ship.position = Vector3(18,8,32)
	scene.model.state.hull = 82
	scene.model.state.threat_clock = 3
	scene.camera_distance_target = 58
	scene.distance = 58
	scene._update_camera(1)
	scene._refresh_ui()
	scene._update_visuals()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/orbital_threat_approach.png")
	scene.model.state.shroud_unlocked = true
	scene.model.state.shroud_on = true
	scene._refresh_ui()
	scene._update_visuals()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/orbital_threat_shroud.png")
	root.size = Vector2i(1280,720)
	scene._update_camera(1)
	scene._refresh_ui()
	scene._update_visuals()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/orbital_threat_720.png")
	scene.queue_free()
	quit()
