extends SceneTree
## GUI-event review only: the mouse motion is synthetic and never moves the OS cursor.
const CategoryHint = preload("res://scripts/flight_category_hint.gd")
const DEFAULT_OUTPUT := "res://artifacts/tooltip-review"
const EXPECTED_CATEGORY_HINT := "Weapons · Browse tools [Tab]"
var capture_size := Vector2i(1920, 1080)
var output_dir: String = DEFAULT_OUTPUT

func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--resolution="):
			var parts: PackedStringArray = argument.trim_prefix("--resolution=").split("x", false)
			if parts.size() != 2:
				push_error("Use --resolution=1920x1080 or another 16:9 size.")
				quit(2)
				return
			capture_size = Vector2i(parts[0].to_int(), parts[1].to_int())
			if capture_size.x < 1280 or capture_size.y < 720 or capture_size.x * 9 != capture_size.y * 16:
				push_error("Capture resolution must be at least 1280x720 and 16:9.")
				quit(2)
				return
		elif argument.begins_with("--output-dir="):
			output_dir = argument.trim_prefix("--output-dir=")
	call_deferred("_run")

func _save_frame(view: SubViewport, name: String) -> void:
	for _frame: int in range(2): await process_frame
	var image: Image = view.get_texture().get_image()
	var path: String = output_dir.path_join(name + ".png")
	var error: Error = image.save_png(path)
	assert(error == OK, "Could not save " + path)
	print("Saved ", path)

func _run() -> void:
	var absolute_output: String = ProjectSettings.globalize_path(output_dir)
	DirAccess.make_dir_recursive_absolute(absolute_output)
	var label: String = "%dx%d" % [capture_size.x, capture_size.y]
	root.size = capture_size
	var view := SubViewport.new()
	view.size = capture_size
	view.size_2d_override = Vector2i(1600, 900)
	view.size_2d_override_stretch = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	view.gui_embed_subwindows = true
	root.add_child(view)
	var hud: Control = load("res://scripts/flight_hud.gd").new()
	view.add_child(hud)
	await process_frame
	hud.refresh_items(load("res://scripts/encounter_state.gd").new(), false)
	await process_frame

	var category: Button = hud.category_buttons["Weapons"] as Button
	var category_hint: CategoryHint = hud.category_hint as CategoryHint
	assert(category_hint != null, "Flight HUD exposes its compact category hint")
	var motion := InputEventMouseMotion.new()
	motion.position = category.get_global_transform_with_canvas() * (category.size * 0.5)
	view.notify_mouse_entered()
	view.push_input(motion, true)
	await create_timer(0.8).timeout
	assert(category_hint.visible, "Synthetic GUI mouse motion presents the category hint")
	assert(category_hint.hint_text == EXPECTED_CATEGORY_HINT, "Category hint names Weapons and its Tab shortcut")
	var hint_label: Label = category_hint.text_label as Label
	assert(hint_label.is_visible_in_tree() and hint_label.text == EXPECTED_CATEGORY_HINT, "Named hint text is visibly drawn in the SubViewport")
	assert(category_hint.size.x >= 220.0 and category_hint.size.x <= 300.0 and hint_label.get_theme_font_size("font_size") == 12 and hint_label.autowrap_mode == TextServer.AUTOWRAP_OFF, "Hint uses the compact one-line size and type target")
	assert(category_hint.position.x >= 0.0 and category_hint.position.x + category_hint.size.x <= 1600.0, "Category hint is horizontally clamped within the HUD")
	var panel_top: float = category.position.y + 20.0
	assert(is_equal_approx(category_hint.position.y, panel_top - 60.0), "Category hint sits above the tab row at the target offset")
	var hint_rect: Rect2 = category_hint.get_global_rect()
	var tab_controls: Array[Control] = []
	for tab: Control in hud.category_buttons.values():
		tab_controls.append(tab)
	tab_controls.append(hud.communications_button)
	for tab: Control in tab_controls:
		assert(not hint_rect.intersects(tab.get_global_rect()), "Category hint does not overlap the tab row at " + label)
	assert(not hint_rect.intersects(hud.grid_backing.get_global_rect()), "Category hint does not overlap the item grid at " + label)
	print("Custom Weapons category hint text is visible after synthetic Godot GUI mouse motion; OS cursor was not moved.")
	await _save_frame(view, "weapons-category-hint-" + label)

	# Begin before the first category and use a viewport Tab key event to traverse into it.
	var first_category: Button = hud.category_buttons["Main tools"] as Button
	var motion_away := InputEventMouseMotion.new()
	motion_away.position = Vector2(20, 20)
	view.push_input(motion_away, true)
	first_category.grab_focus()
	await process_frame
	var tab_event := InputEventKey.new()
	tab_event.keycode = KEY_TAB
	tab_event.physical_keycode = KEY_TAB
	tab_event.pressed = true
	view.push_input(tab_event, true)
	await process_frame
	await process_frame
	var focus_owner: Control = view.gui_get_focus_owner()
	var focused_group: String = ""
	for group: String in hud.category_buttons:
		if hud.category_buttons[group] == focus_owner:
			focused_group = group
			break
	assert(not focused_group.is_empty() and focused_group != "Main tools", "Tab GUI event advances focus from Main tools to another category tab")
	var focus_art: Control = hud.category_tab_cards[focused_group] as Control
	assert(bool(focus_art.get("focused")), "Keyboard focus activates the visible category focus cue")
	print("Tab GUI event focused ", focused_group, "; its category card focus cue is active.")
	var focus_tag: String = focused_group.to_lower().replace(" ", "-")
	await _save_frame(view, focus_tag + "-keyboard-focus-" + label)
	print("Tooltip and focus GUI-event review passed at ", label, ". This is not native OS pointer or keyboard evidence.")
	quit()
