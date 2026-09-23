extends SceneTree
## Engine-only 1080p panel review; no external application or pointer control.
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
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = Session.new()
	view.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false)
	scene.audio.muted = true
	scene.campaign.commerce.export_alloy(scene.campaign,"basin_port",scene.model.service_position("basin_port"),4)
	scene.selected_service = "basin_port"
	scene.distance = 65
	scene._update_camera(1); scene._update_visuals(); scene._refresh_ui()
	for panel: String in ["market","upgrades","cargo","badges"]:
		scene.dock_page = panel
		scene._show_popup("service" if panel in ["market","upgrades"] else panel)
		await process_frame
		await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png("res://artifacts/commerce_%s.png" % panel)
	scene.free(); view.free(); quit()
