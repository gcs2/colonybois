extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
const Geography = preload("res://scripts/planet_geography.gd")
const DEFAULT_OUT := "res://artifacts/visual-critic-surface-pass/mining"
var output_dir: String = DEFAULT_OUT
var capture_size := Vector2i(1920, 1080)
var capture_label: String = "1080p"
var capture_pitch: float = 0.43
var camera_only: bool = false

func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--output-dir="):
			output_dir = argument.trim_prefix("--output-dir=")
		elif argument.begins_with("--pitch="):
			capture_pitch = clampf(argument.trim_prefix("--pitch=").to_float(), 0.2, 1.3)
		elif argument == "--camera-only":
			camera_only = true
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
	for i: int in range(5): await process_frame
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
	var capture_definition: Dictionary = game.field.definition()
	var capture_up: Vector3 = Geography.surface_runtime(capture_definition).advance(Geography.surface_direction(capture_definition,0,12),620,0)
	game.field.state.surface_direction = [capture_up.x,capture_up.y,capture_up.z]
	var capture_position: Vector2 = Geography.surface_local_position(capture_definition,capture_up)
	game.field.state.surface_position = [capture_position.x,3.0,capture_position.y]
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = game
	scene.set_process(false)
	scene.set_physics_process(false)
	view.add_child(scene)
	await process_frame
	for frozen_node: Node in scene.find_children("*", "", true, false):
		frozen_node.set_process(false)
		frozen_node.set_physics_process(false)
	print("Scene ready; child processing frozen for screenshot fixture.")
	scene.audio.muted = true
	scene.save_path = output_dir + "/isolated-save.fw"
	var desired_ship_position: Vector3 = scene._target_position("vein") + Vector3(-4,0,6)
	scene._set_surface_up(Geography.surface_direction(scene.world_definition,desired_ship_position.x,desired_ship_position.z))
	print("Camera and HUD fixture positioned without rebuilding geography.")
	scene.ship.position.y = scene.terrain_height(scene.ship.position.x,scene.ship.position.z)+3.0
	scene.camera_distance_target = 38
	scene.distance = 38
	scene.yaw = 0.12
	scene.pitch = capture_pitch
	scene.selected = "vein"
	scene._select_tool("mine")
	scene._update_camera(1)
	scene._update_visuals()
	scene._refresh_ui()
	var mining_range: float = scene.ship.position.distance_to(scene._target_position("vein"))
	assert(game.mining_reason(mining_range).is_empty(), "Capture setup must be in valid mining range")
	scene._start_first_landing_welcome()
	assert(scene.objective.text == "Explore freely. Your surveys are secure.", "First landing presents its brief welcome")
	await _save_frame(view,"first-landing-welcome-"+capture_label)
	scene._dismiss_first_landing_welcome()
	assert(scene.objective.text.is_empty(), "First landing welcome clears on interaction")
	await _save_frame(view,"surface-mining-before-"+capture_label)
	if camera_only:
		print("Camera-only reference capture complete; gameplay evidence is not implied.")
		quit()
		return

	var weapons_tab: Button = scene.hud.category_buttons["Weapons"]
	view.notify_mouse_entered()
	var hover_motion := InputEventMouseMotion.new()
	hover_motion.position = weapons_tab.get_global_transform_with_canvas() * (weapons_tab.size * 0.5)
	view.push_input(hover_motion,true)
	for _frame: int in range(5): await process_frame
	assert(scene.hud.category_tooltip_overlay.visible and scene.hud.category_tooltip_heading.text == "Weapons", "Synthetic GUI hover opens the real category tooltip")
	assert(scene.hud.category_buttons["Main tools"].button_pressed and scene.hud.category_tab_cards["Weapons"].hovered, "Hover preserves selected Main tools and lights Weapons")
	assert(scene.hud.category_tooltip_panel.size == Vector2(300,64) and not scene.hud.category_tooltip_panel.get_global_rect().intersects(scene.hud.grid_backing.get_global_rect()), "The fixed tooltip remains compact and leaves the inventory grid visible")
	await _save_frame(view,"hud-tab-hover-"+capture_label)
	var communications_tab: Button = scene.hud.communications_button
	hover_motion = InputEventMouseMotion.new()
	hover_motion.position = communications_tab.get_global_transform_with_canvas() * (communications_tab.size * 0.5)
	view.push_input(hover_motion,true)
	for _frame: int in range(5): await process_frame
	assert(scene.hud.category_tooltip_heading.text == "Communications" and scene.hud.category_tooltip_panel.position.x + scene.hud.category_tooltip_panel.size.x <= communications_tab.position.x, "Edge category tooltip flips left and stays inside the HUD")
	await _save_frame(view,"hud-tab-comms-hover-"+capture_label)
	var leave_motion := InputEventMouseMotion.new()
	leave_motion.position = Vector2(800,400)
	view.push_input(leave_motion,true)
	for _frame: int in range(5): await process_frame

	scene.held = true
	scene._operate(3.0)
	assert(game.field.state.ore_remaining == Field.MINERAL_DEPOSIT_UNITS-1, "A completed cutter cycle depletes one visible crystal")
	assert(game.commerce.quantity("glass") == 1, "The cut crystal enters real cargo")
	assert(scene.status.text == "Glass +1 · cargo 1/%d" % game.commerce.capacity(), "Reward toast reports the actual cargo occupancy")
	scene._update_visuals()
	scene._refresh_ui()
	assert(scene.hud.action_state.text == "3 OF 4 LEFT", "Seam reports remaining inventory after mining")
	assert(scene.hud.explanation.text == "Next: +1 Resonant glass", "Seam reports the next useful yield")
	await _save_frame(view,"surface-mining-after-"+capture_label)
	for _cycle: int in range(Field.MINERAL_DEPOSIT_UNITS-1):
		scene.held = true
		scene.latched = false
		scene._operate(3.0)
		scene._update_visuals()
		scene._refresh_ui()
	assert(game.field.state.ore_remaining == 0, "Four completed cycles exhaust the deposit")
	assert(scene.hud.action_state.text == "DEPLETED", "Exhaustion is called out in the seam card")
	assert(scene.hud.explanation.text == "No crystals remain.", "Exhausted seam explains why mining stops")
	await _save_frame(view,"surface-mining-depleted-"+capture_label)
	print("Mining, yield, depleted state, welcome and tab-hover captures passed; performance is not measured.")
	quit()
