extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game := Session.new(); game.field.state = Field.fresh("s2p0"); game.field.bind_account(game.sector.state)
	game.field.change_flight_mode("orbit"); game.sector.system_by_id("s2").visited = true; game.configure_flagship(); game.climate.bind(game)
	game.field.state.survey_ticks = game.field.definition().survey_seconds
	var view := SubViewport.new(); view.size_2d_override = Vector2i(1600,900); view.size_2d_override_stretch = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS; root.add_child(view)
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); scene.campaign = game; view.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true; scene.save_path = "res://artifacts/system_review.fw"
	var original: Dictionary = game.snapshot()
	for dimensions: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		view.size = dimensions; game.restore_snapshot(original); scene.model = game.field; scene._open_system_view("s2")
		for phase: String in ["overview","selected","transit","sector","sector_route"]:
			# Capture fixtures keep focus-loss pause separate from the actual travel state.
			scene.paused = false; scene._refresh_ui()
			if phase == "selected": scene.system_map.select_planet("s2p1")
			if phase == "transit":
				scene._launch_journey("s2p1"); game.tick(); game.tick(); game.tick(); scene.system_map.refresh()
			if phase in ["sector","sector_route"] and not scene.sector_map.visible: scene._toggle_sector_map()
			if phase == "sector_route":
				var current_id: String = game.sector.state.flagship.system
				for star: Dictionary in game.sector.state.systems:
					if star.id == current_id or not game.sector.is_revealed(star.id): continue
					var planet_id: String = Session.local_id(star.planets[0])
					if game.quote(planet_id).reason.is_empty():
						scene.sector_map.select_system(star.id)
						break
			scene._refresh_ui()
			for i: int in range(10):
				scene.paused = false; scene._refresh_ui(); await process_frame
			await RenderingServer.frame_post_draw
			view.get_texture().get_image().save_png("res://artifacts/system_%s_%d.png" % [phase,dimensions.y])
	scene.free(); view.free(); quit()
