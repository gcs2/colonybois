extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var view := SubViewport.new()
	view.size = Vector2i(1920,1080); view.size_2d_override = Vector2i(1600,900)
	view.size_2d_override_stretch = true; view.own_world_3d = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS; root.add_child(view)
	for id: String in ["s1p0","s2p0"]:
		var game := Session.new()
		game.field.state = Field.fresh(id); game.field.bind_account(game.sector.state)
		game.field.change_flight_mode("orbit"); game.configure_flagship()
		game.field.state.survey_ticks = 12
		var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
		scene.campaign = game; view.add_child(scene)
		scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
		scene.ship.position = Field.GUARDIAN_HOME+Vector3(0,0,8)
		scene.orbital_target = "guardian"
		scene.distance = 48; scene.camera_distance_target = 48
		scene.yaw = 0.3; scene.pitch = 0.65
		for i: int in range(3): game.field.tick(); game.field.guardian_step(scene.ship.position)
		scene._update_camera(1); scene._update_visuals(); scene._refresh_ui()
		await process_frame; await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png("res://artifacts/orbit_warning_%s.png" % id)
		scene.orbit.aim_marker.hide()
		scene.distance = 25; scene.camera_distance_target = 25
		scene.ship.position = Field.GUARDIAN_HOME+Vector3(0,-1,0)
		scene.ship.hide()
		for child: Node in scene.get_children():
			if child is CanvasLayer: child.hide()
		scene._update_camera(1)
		await process_frame; await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png("res://artifacts/orbit_vessel_%s.png" % id)
		scene.free()
	view.free(); quit()
