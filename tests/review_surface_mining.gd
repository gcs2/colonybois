extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
const Geography = preload("res://scripts/planet_geography.gd")
const DEFAULT_OUT := "res://artifacts/visual-critic-surface-pass/mining"
var output_dir: String = DEFAULT_OUT
var capture_size := Vector2i(1920, 1080)
var capture_label: String = "1080p"

func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--output-dir="):
			output_dir = argument.trim_prefix("--output-dir=")
		elif argument.begins_with("--resolution="):
			var resolution_spec: String = argument.trim_prefix("--resolution=")
			var dimensions: PackedStringArray = resolution_spec.split("x", false)
			if dimensions.size() != 2:
				push_error("Use --resolution=1920x1080 or another 16:9 size.")
				quit(2)
				return
			var width: int = dimensions[0].to_int()
			var height: int = dimensions[1].to_int()
			if width < 1280 or height < 720 or width * 9 != height * 16:
				push_error("Capture resolution must be at least 1280x720 and 16:9.")
				quit(2)
				return
			capture_size = Vector2i(width, height)
			capture_label = "%dp" % height
	call_deferred("_run")

func _save_frame(view: SubViewport, name: String) -> void:
	for i: int in range(3): await process_frame
	await RenderingServer.frame_post_draw
	var image: Image = view.get_texture().get_image()
	var err: Error = image.save_png(output_dir + "/" + name + ".png")
	assert(err == OK, "Could not save " + name)
	print("Saved " + name)

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var resolution: Vector2i = capture_size
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
	scene.save_path = output_dir + "/isolated-save.fw"
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
	await _save_frame(view,"surface-mining-before-"+capture_label)

	scene.held = true
	scene._operate(3.0)
	assert(game.field.state.ore_remaining == Field.MINERAL_DEPOSIT_UNITS-1, "A completed cutter cycle depletes one visible crystal")
	assert(game.commerce.quantity("glass") == 1, "The cut crystal enters real cargo")
	scene._update_visuals()
	scene._refresh_ui()
	assert(scene.subject.text == "RESONANT SEAM" and scene.hud.action_state.text == "3 OF 4 LEFT", "The target card separates seam identity from its truthful remaining count")
	assert(is_equal_approx(scene.hud.context_card.size.x,252.0) and is_equal_approx(scene.hud.context_card.size.y,66.0), "The compact tethered target card uses the reviewed footprint")
	assert(scene.hud.action_state.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT, "The remaining count aligns within the target card")
	assert(scene.explanation.text == "+1 Resonant glass secured", "The card keeps successful tool feedback clear beneath the remaining count")
	assert(scene.status.text == "+1 Resonant glass · cargo 1/8" and scene.status.size == Vector2(212,40) and scene.status_backing.size == Vector2(264,40), "The full reward and cargo count stay in a compact one-line toast")
	assert(scene.status.get_theme_font_size("font_size") == 13 and scene.status.get_minimum_size().x <= scene.status.size.x, "The compact reward toast remains readable without clipping its complete text")
	await _save_frame(view,"surface-mining-after-"+capture_label)
	print("Mining capture assertions passed; Silent-mode performance is not measured.")
	quit()
