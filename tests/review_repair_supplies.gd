extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var view := SubViewport.new()
	view.size_2d_override = Vector2i(1600,900); view.size_2d_override_stretch = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS; root.add_child(view)
	var game := Session.new()
	game.field.marks = 600; game.commerce.state.badges.explorer = 2
	var dock: Vector3 = game.field.service_position("basin_port")
	game.purchase_service("basin_port",dock,"repair_pack")
	game.purchase_service("basin_port",dock,"mega_repair_pack")
	game.field.state.hull = 25.0; game.field.state.energy = 42.0
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = game; view.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	scene.ship.position = dock; scene.selected_service = "basin_port"
	scene._update_camera(1); scene._refresh_ui()
	for dimensions: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		view.size = dimensions
		for panel: String in ["service","cargo","palette"]:
			scene.dock_page = "energy"
			if panel == "palette": scene._close_popup(); scene._hud_action("category:Inventory"); scene._refresh_ui()
			else: scene._show_popup(panel)
			for i: int in range(8): await process_frame
			await RenderingServer.frame_post_draw
			view.get_texture().get_image().save_png("res://artifacts/repair_%s_%d.png" % [panel,dimensions.y])
	scene.free(); view.free(); quit()
