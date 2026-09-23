extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game := Session.new()
	game.commerce.state.badges.explorer = 3
	for id: String in game.fleet.catalog:
		game.diplomacy.contact(game,id); game.sector.faction_by_id(id).relation = 60
		game.diplomacy.act(game,id,"alliance")
		for system: Dictionary in game.sector.state.systems:
			if system.owner != id: continue
			game.field.state = Field.fresh(system.id+"p0"); game.field.bind_account(game.sector.state)
			game.field.change_flight_mode("orbit"); game.configure_flagship(); break
		game.fleet.command(game,id,"recruit",Vector3(0,8,35))
	game.field.state = Field.fresh("s1p0"); game.field.bind_account(game.sector.state)
	game.field.change_flight_mode("orbit"); game.configure_flagship()
	game.field.marks = 420; game.fleet.state.ships.consortium.hull = 37.0
	for i: int in range(3): game.tick()
	var view := SubViewport.new()
	view.size_2d_override = Vector2i(1600,900); view.size_2d_override_stretch = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS; root.add_child(view)
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = game; view.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	scene.ship.position = game.field.guardian_position()+Vector3(0,2,14)
	scene.distance = 68; scene.camera_distance_target = 68; scene.yaw = 0.3; scene.pitch = 0.6
	for i: int in range(4): game.tick(); game.fleet.prepare(game,scene.ship.position)
	game.fleet.assist(game,"guardian",true,scene.ship.position)
	scene.fleet_visual.refresh(game,0.01,false)
	scene._update_camera(1); scene._update_visuals(); scene._refresh_ui()
	for dimensions: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		view.size = dimensions
		for page: String in ["orbit","roster","contact"]:
			if page == "orbit": scene._close_popup()
			elif page == "roster": scene._show_popup("fleet")
			else:
				scene.contacted_faction = "consortium"; scene.contact_page = "fleet"; scene._show_popup("contact")
			scene._refresh_ui()
			for i: int in range(8): await process_frame
			await RenderingServer.frame_post_draw
			view.get_texture().get_image().save_png("res://artifacts/fleet_%s_%d.png" % [page,dimensions.y])
	scene.free(); view.free(); quit()
