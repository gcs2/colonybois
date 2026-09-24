extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
const Climate = preload("res://scripts/planet_climate.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game := Session.new()
	game.field.state = Field.fresh("s1p0"); game.field.bind_account(game.sector.state)
	game.field.change_flight_mode("orbit"); game.configure_flagship(); game.climate.bind(game)
	game.field.marks = 2000; game.commerce.state.badges.explorer = 2
	for id: String in ["heat_ray","cloud_accumulator"]: game.commerce.buy_upgrade(game,"orbit_tender",Field.service_position("orbit_tender"),id)
	game.field.state.survey_ticks = game.field.definition().survey_seconds
	var view := SubViewport.new(); view.size_2d_override = Vector2i(1600,900); view.size_2d_override_stretch = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS; root.add_child(view)
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); scene.campaign = game
	view.add_child(scene); scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	scene.save_path = "res://artifacts/climate_review.fw"
	scene._select_climate("heat_ray")
	var original: Dictionary = game.snapshot()
	for dimensions: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		view.size = dimensions; game.restore_snapshot(original); scene.model = game.field
		for phase: String in ["native_orbit","changed_orbit","changed_map","changed_surface","shop"]:
			if phase == "native_orbit":
				scene._close_popup(); scene.planet_map.hide(); scene._apply_flight_mode(); scene._restore_ship(); scene._select_climate("heat_ray")
			if phase == "changed_orbit":
				for tool: String in ["heat_ray","heat_ray","heat_ray","cloud_accumulator"]:
					game.climate.start(game,tool,scene.ship.position)
					for i: int in range(8): game.tick()
			if phase == "changed_map": scene._toggle_planet_map()
			if phase == "changed_surface":
				scene.planet_map.hide(); scene._change_flight_mode("surface"); scene.ship.position = Vector3(0,12,12)
				scene.yaw = 0.5; scene.pitch = 0.75; scene.distance = 85; scene.camera_distance_target = 85; scene._select_climate("heat_ray")
			if phase == "shop":
				scene.ship.position = Field.service_position("basin_port"); scene.selected_service = "basin_port"; scene.dock_page = "climate"; scene._show_popup("service")
			scene._update_camera(1); scene._refresh_ui(); scene._update_visuals()
			for i: int in range(8): await process_frame
			await RenderingServer.frame_post_draw
			view.get_texture().get_image().save_png("res://artifacts/climate_%s_%d.png" % [phase,dimensions.y])
	scene.free(); view.free(); quit()
