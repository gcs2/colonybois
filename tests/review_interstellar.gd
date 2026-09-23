extends SceneTree
## Engine-only renders. Never moves the OS pointer or reads another application.
const Session = preload("res://scripts/expedition_session.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var view := SubViewport.new()
	view.size = Vector2i(1920,1080)
	view.size_2d_override = Vector2i(1600,900)
	view.size_2d_override_stretch = true
	view.own_world_3d = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	var campaign := Session.new()
	campaign.field.change_flight_mode("orbit")
	for id: String in ["morrow","s1p0","s2p0"]:
		if id != "morrow":
			campaign.field.change_flight_mode("orbit")
			campaign.begin_travel(id)
			for i: int in range(24):
				if not campaign.traveling(): break
				campaign.tick()
		var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
		scene.campaign = campaign
		view.add_child(scene)
		scene.set_process(false); scene.set_physics_process(false)
		scene.audio.muted = true
		scene._toggle_sector_map()
		scene.sector_map.select_system("s1" if id == "morrow" else campaign.sector.state.flagship.system)
		await process_frame
		await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png("res://artifacts/travel_%s_chart.png" % id)
		scene.sector_map.hide()
		scene._change_flight_mode("surface")
		scene.distance = 65
		scene._update_camera(1)
		scene._update_visuals()
		scene._refresh_ui()
		await process_frame
		await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png("res://artifacts/travel_%s_surface.png" % id)
		scene.free()
	view.free()
	quit()
