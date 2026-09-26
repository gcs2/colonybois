extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
const Geography = preload("res://scripts/planet_geography.gd")
const OUT = "res://artifacts/visual-critic-surface-pass/mining"

func _initialize() -> void:
	call_deferred("_run")

func _save_frame(view: SubViewport, name: String) -> void:
	for i: int in range(3): await process_frame
	await RenderingServer.frame_post_draw
	var image: Image = view.get_texture().get_image()
	var err: Error = image.save_png(OUT + "/" + name + ".png")
	assert(err == OK, "Could not save " + name)
	print("Saved " + name)

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var resolution := Vector2i(1920,1080)
	root.size = resolution
	var view := SubViewport.new()
	view.size = resolution
	view.size_2d_override = Vector2i(1600,900)
	view.size_2d_override_stretch = true
	view.own_world_3d = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)

	var game := Session.new()
	game.field.state = Field.fresh("morrow")
	game.field.state.landings = 1
	game.field.change_flight_mode("surface")
	game.field.act("scan","vein",4)
	game.configure_flagship()
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = game
	scene.process_mode = Node.PROCESS_MODE_DISABLED
	view.add_child(scene)
	await process_frame
	scene.audio.muted = true
	scene.save_path = OUT + "/isolated-save.fw"
	var desired_ship_position: Vector3 = scene._target_position("vein") + Vector3(-4,0,6)
	scene._set_surface_up(Geography.surface_direction(scene.world_definition,desired_ship_position.x,desired_ship_position.z))
	scene._refresh_surface_geography()
	scene.ship.position.y = scene.terrain_height(scene.ship.position.x,scene.ship.position.z)+3.0
	scene.camera_distance_target = 38
	scene.distance = 38
	scene.yaw = 0.12
	scene.pitch = 0.43
	scene.selected = "vein"
	scene._select_tool("mine")
	scene._update_camera(1)
	scene._update_visuals()
	scene._refresh_ui()
	var mining_range: float = scene.ship.position.distance_to(scene._target_position("vein"))
	assert(game.mining_reason(mining_range).is_empty(), "Capture setup must be in valid mining range")
	await _save_frame(view,"surface-mining-before-1080")

	scene.held = true
	scene._operate(3.0)
	assert(game.field.state.ore_remaining == Field.MINERAL_DEPOSIT_UNITS-1, "A completed cutter cycle depletes one visible crystal")
	assert(game.commerce.quantity("glass") == 1, "The cut crystal enters real cargo")
	scene._update_visuals()
	scene._refresh_ui()
	await _save_frame(view,"surface-mining-after-1080")
	print("Mining capture assertions passed; Silent-mode performance is not measured.")
	quit()
