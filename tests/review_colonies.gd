extends SceneTree
## In-engine construction and administration review at 1080p.
const Session = preload("res://scripts/expedition_session.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game := Session.new()
	game.field.marks = 900
	game.colonies.buy_kit(game,"basin_port",game.field.service_position("basin_port"))
	game.field.change_flight_mode("orbit")
	game.begin_travel("s1p0")
	while game.traveling(): game.tick()
	game.field.start_survey()
	for i: int in range(12): game.tick()
	game.field.change_flight_mode("surface")
	var view := SubViewport.new()
	view.size = Vector2i(1920,1080)
	view.size_2d_override = Vector2i(1600,900)
	view.size_2d_override_stretch = true
	view.own_world_3d = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = game
	view.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false)
	scene.audio.muted = true
	scene.distance = 42
	scene.ship.position = Vector3(-6,8,-18)
	game.colonies.deploy(game,Vector2(-6,-18),scene.ship.position)
	for phase: int in range(4):
		while game.colonies.phase(game,"s1p0") < phase: game.tick()
		if phase == 3: game.colonies.install(game,"s1p0","water")
		scene._update_camera(1); scene._update_visuals(); scene._refresh_ui()
		await process_frame
		await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png("res://artifacts/colony_stage_%d.png" % phase)
	for panel: String in ["colonies","warehouse"]:
		if panel == "warehouse":
			scene.selected_service = "basin_port"
			scene.ship.position = game.field.service_position("basin_port")
			scene.dock_page = "warehouse"
		scene._show_popup("service" if panel == "warehouse" else panel)
		await process_frame
		await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png("res://artifacts/colony_%s.png" % panel)
	scene.free(); view.free(); quit()
