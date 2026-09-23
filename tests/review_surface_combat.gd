extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
const Combat = preload("res://scripts/surface_combat.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var view := SubViewport.new()
	view.size_2d_override = Vector2i(1600,900); view.size_2d_override_stretch = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS; root.add_child(view)
	var game := Session.new()
	game.field.state = Field.fresh("s1p0"); game.field.bind_account(game.sector.state); game.configure_flagship()
	game.field.marks = 600; game.commerce.state.badges.explorer = 2; game.commerce.state.badges.merchant = 2
	for id: String in ["seeker","ground_bomb"]: game.commerce.buy_upgrade(game,"basin_port",Field.service_position("basin_port"),id)
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = game; view.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	scene.ship.position = Combat.home("s1p0","watcher")+Vector3(0,5,13)
	scene.surface_selected = "sentry_a"; scene.surface_weapon = "ground_bomb"; scene.hud.select_tool("ground_bomb")
	scene.distance = 62; scene.camera_distance_target = 62; scene.yaw = 0.4; scene.pitch = 0.8
	game.combat.step(game,scene.ship.position)
	game.combat.fire(game,"ground_bomb","",Vector3(23,0,-21),scene.ship.position)
	var initial: Dictionary = game.snapshot()
	scene._update_camera(1); scene._refresh_ui()
	for dimensions: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		game.restore_snapshot(initial)
		view.size = dimensions
		for phase: String in ["approach","impact"]:
			if phase == "impact": game.tick(); game.tick()
			scene.surface_combat_visual.refresh(game,"sentry_a",0.35,0.1,false)
			scene._refresh_ui(); scene._update_visuals()
			for i: int in range(8): await process_frame
			await RenderingServer.frame_post_draw
			view.get_texture().get_image().save_png("res://artifacts/surface_combat_%s_%d.png" % [phase,dimensions.y])
	scene.free(); view.free(); quit()
