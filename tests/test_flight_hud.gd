extends SceneTree
## Command integration through HUD controls, not an assertion of native-input/art approval.
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1; printerr("FAIL: "+message)
func click_chart(chart: Control, at: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = at
	chart._gui_input(event)
func press(scene: Node, key: Key, shift: bool = false, ctrl: bool = false) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.pressed = true
	event.shift_pressed = shift
	event.ctrl_pressed = ctrl
	scene._unhandled_input(event)
func chart_test_height(x: float, z: float) -> float:
	var at := Vector2(x,z)
	if at.distance_to(Vector2(-34,22)) < 9 or at.distance_to(Vector2(160,-100)) < 9: return -5.0
	return 1.0+8.0*exp(-at.distance_to(Vector2(10,-18))/34.0)

func test_surface_chart_sampling() -> void:
	var chart: Control = load("res://scripts/flight_navigation.gd").new()
	root.add_child(chart)
	chart.size = Vector2(220,160)
	chart.set_terrain(Callable(self,"chart_test_height"))
	check(chart.terrain != null and chart.water_area > 3 and chart.water_center.distance_to(Vector2(-34,22)) < 3.0,"Surface chart derives a recognizable water contact from sampled terrain")
	var surface_map: Image = chart.terrain.get_image()
	var pond_pixel := Vector2i(roundi(((-34.0+62.5)/125.0)*95.0),roundi(((22.0+62.5)/125.0)*95.0))
	var water_color: Color = surface_map.get_pixel(pond_pixel.x,pond_pixel.y)
	var land_color: Color = surface_map.get_pixel(48,48)
	check(absf(water_color.r-land_color.r)+absf(water_color.g-land_color.g)+absf(water_color.b-land_color.b) > 0.35,"Sampled water and surrounding relief use clearly distinct map colors")
	var darkest: float = 1.0
	var brightest: float = 0.0
	for y: int in range(surface_map.get_height()):
		for x: int in range(surface_map.get_width()):
			var value: float = surface_map.get_pixel(x,y).get_luminance()
			darkest = minf(darkest,value)
			brightest = maxf(brightest,value)
	check(brightest-darkest > 0.35,"Terrain chart preserves strong sampled relief contrast")
	var ruler_px: float = chart._scale_width_pixels(chart.chart_rect())
	check(is_equal_approx(ruler_px,chart.chart_rect().size.x*0.4),"The 50 m ruler matches the 125 m chart extent")
	chart.recenter_surface(Vector2(160,-100))
	check(chart.surface_center == Vector2(160,-100) and chart.water_area > 3 and chart.water_center.distance_to(Vector2(160,-100)) < 3.0,"Water identification follows sampled terrain when the chart recenters")
	chart.ship_at = chart.surface_center
	chart.points["relay"] = Vector2(162,-98)
	check(chart.project(chart.ship_at).distance_to(chart.chart_rect().get_center()) < 0.01 and chart.unproject(chart.project(chart.points.relay)).distance_to(chart.points.relay) < 0.01,"Ship and known-contact markers remain anchored in world coordinates")
	chart.free()

func run() -> void:
	test_surface_chart_sampling()
	if OS.get_cmdline_user_args().has("chart-only"):
		print("Surface chart assertions: ",checks,"; failures: ",failures)
		quit(0 if failures == 0 else 1)
		return
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	scene.set_physics_process(false)
	scene.audio.muted = true
	var hud: Control = scene.hud
	check(hud.navigation.size.x >= 200 and hud.navigation.size.y >= 160 and hud.navigation.tooltip_text.contains("50 m"),"Surface chart expands its terrain aperture while keeping the 50 m scale")
	check(hud.chart_heading.visible and hud.chart_heading.position.y >= hud.navigation.position.y + hud.navigation.size.y - 6,"Surface chart keeps its name below the map field")
	check(hud.chart_backing.get_script() == load("res://scripts/flight_instrument_frame.gd") and hud.chart_backing.size.x <= 230 and not hud.nav_pod.visible,"Surface chart uses one fitted Field Instruments frame without a blank altitude bay")
	check(hud.navigation_backing.get_script() == load("res://scripts/flight_instrument_frame.gd") and hud.navigation_backing.visible and hud.navigation_backing.size.x <= 40 and hud.navigation_backing.size.y <= 90,"Local navigation uses a narrow angular Field Instruments tab strip")
	check(hud.navigation_menu_button.visible and hud.departure_button.visible and hud.navigation_actions.all(func(button: Button) -> bool: return not button.visible) and not hud.sector_button.visible and not hud.system_button.visible,"Surface keeps two navigation controls visible and tucks secondary actions away")
	check(hud.departure_button.get_theme_font_size("font_size") == 1 and not hud.departure_button.tooltip_text.is_empty(),"The ascent tab stays icon-only and keeps its named hover tooltip")
	hud.navigation_menu_button.pressed.emit()
	check(hud.navigation_popup_backing.visible and hud.navigation_actions.all(func(button: Button) -> bool: return button.visible and not button.tooltip_text.is_empty()) and hud.sector_button.visible and hud.system_button.visible,"Navigation tab opens all named map, contact and zoom controls")
	hud.navigation_menu_button.pressed.emit()
	check(not hud.navigation_popup_backing.visible and hud.navigation_actions.all(func(button: Button) -> bool: return not button.visible),"Navigation menu closes back to the two-control strip")
	check(hud.empty_slot_backings.size() == 12 and hud.empty_slot_backings[0].position.y < hud.empty_slot_backings[6].position.y,"Inventory grid retains all six columns and both carried-item rows")
	check(scene.status_backing.position.y + scene.status_backing.size.y < hud.objective.position.y,"Upper-left discovery notice clears the objective text")
	check(hud.treasury_backing.position.x > 1370 and hud.stats.text.ends_with("Marks"),"Marks remain legible in the upper-right instrument")
	check(hud.altitude_backing.size.x <= 80 and hud.altitude_backing.size.y <= 20 and hud.flight_readout.size.x <= 72 and hud.altitude_backing.position.x >= hud.console_pod.position.x+100,"ALT stays a compact secondary readout within the existing right-side housing")
	check(hud.toolbar.all(func(button: Button) -> bool: return button.focus_mode == Control.FOCUS_ALL and button.get_theme_stylebox("focus") is StyleBoxFlat),"Flight HUD tool actions can receive keyboard focus with a visible Field Instruments focus edge")
	var encounter_action: Button = scene._button("Focus check",scene._close_popup,scene.popup_body)
	check(encounter_action.focus_mode == Control.FOCUS_ALL and encounter_action.get_theme_stylebox("focus") is StyleBoxFlat,"Flight encounter actions can receive the same visible keyboard focus")
	check(not hud.tool_title.visible and not hud.tool_spec.visible,"Persistent text above tool icons is removed; identity and costs belong in hover help")
	check(hud.item_buttons.values().all(func(button: Button) -> bool: return not button.tooltip_text.is_empty()) and hud.category_buttons.values().all(func(button: Button) -> bool: return not button.tooltip_text.is_empty()) and hud.navigation_actions.all(func(button: Button) -> bool: return not button.tooltip_text.is_empty()),"Every tool, category and navigation icon has named hover help")
	var icon_style: StyleBox = hud.toolbar[0].get_theme_stylebox("normal")
	check(icon_style is StyleBoxFlat and icon_style.corner_radius_top_left == 0 and not icon_style is StyleBoxTexture,"Icon controls do not use rounded decorative wells or metallic border textures")
	scene._activate_selected()
	var state: Dictionary = scene.model.state.duplicate(true)
	var subject: String = scene.selected
	press(scene,KEY_TAB)
	check(hud.active_group == "Environment" and scene.selected == subject and scene.approach_subject,"Tab browses palettes without cycling targets or cancelling the active order")
	press(scene,KEY_TAB,true)
	check(hud.active_group == "Main tools" and scene.tool == "scan" and scene.model.state == state,"Shift-Tab reverses browsing without spending or selecting")
	var bar_position: Vector2 = hud.energy_bar.position
	hud.collapse_button.pressed.emit()
	check(not hud.palette_expanded and not hud.toolbar[0].visible and hud.energy_bar.visible and hud.energy_bar.position == bar_position,"Collapse hides items while keeping ship condition fixed")
	press(scene,KEY_2)
	check(scene.tool == "scan" and scene.approach_subject,"Collapsed item shortcuts cannot accidentally select invisible tools")
	hud.category_buttons.Environment.pressed.emit()
	check(hud.palette_expanded and hud.toolbar[2].visible and hud.slot_labels.heat_ray.text == "1" and hud.slot_labels.warm.text == "Ctrl+3" and hud.slot_labels.seed.text == "Ctrl+4","Opening a category labels its own visible slots")
	press(scene,KEY_0)
	press(scene,KEY_5,false,true)
	check(scene.tool == "scan" and scene.approach_subject,"Empty first- and second-row slots do nothing")
	hud.category_buttons.Environment.pressed.emit()
	check(scene.tool == "scan" and scene.approach_subject,"Browsing a category preserves active tool and approach")
	check(scene.model.state == state and not scene._inspection_open(),"Palette browsing neither mutates nor pauses the simulation")
	hud.toolbar[2].pressed.emit()
	check(scene.tool == "warm" and not scene.approach_subject,"Equipping a new tool cancels the previous operation")
	check(scene.model.state == state,"Equipping consumes no energy or cargo")
	scene._select_tool("scan")
	hud.category_buttons.Environment.pressed.emit()
	press(scene,KEY_3,false,true)
	check(scene.tool == "warm" and hud.selected_tool == "warm" and scene.model.state == state,"Second-row Ctrl+3 selects the same thermal tool as clicking its icon")
	scene._show_popup("systems")
	scene._equip_from_panel("collect")
	check(scene.tool == "collect" and not scene.popup.visible,"Selecting installed equipment from inspection returns to flight and actually equips it")
	scene._select_tool("scan")
	scene._refresh_ui()
	click_chart(hud.navigation,hud.navigation.project(hud.navigation.points.relay))
	check(scene.selected == "relay" and scene.approach_subject,"Chart contact click issues the real approach/tool command")
	for i: int in range(600):
		scene._physics_process(1.0/60)
		scene._operate(1.0/60)
	scene._refresh_ui()
	check("relay" in scene.model.state.scanned and hud.action_state.text == "COMPLETE","Completed chart scan records discovery and shows completion")
	check(scene.progress_bar.value == 1,"Completion leaves a filled confirmation meter briefly")
	scene._update_camera(1)
	scene._pick(scene.camera.unproject_position(scene._target_position("pod")))
	check(scene.selected == "pod" and (scene.approach_subject or scene.held),"A new subject click after completion starts the next survey without an extra cancel click")
	scene._stop()
	click_chart(hud.navigation,hud.navigation.project(Vector2(-24,22)))
	check(scene.navigating and scene.destination.x < -23 and scene.destination.z > 21,"Open chart click navigates to the corresponding terrain coordinate")
	scene._stop()
	scene._refresh_ui()
	check(hud.action_state.text == "CANCELLED" and not scene.navigating,"Cancel is a distinct, truthful order state")
	scene._toggle_pause()
	click_chart(hud.navigation,hud.navigation.project(Vector2(20,20)))
	check(not scene.navigating,"Chart commands are rejected during pause even before the next HUD refresh")
	scene._toggle_pause()
	scene._show_popup("cargo")
	click_chart(hud.navigation,hud.navigation.project(Vector2(20,20)))
	check(not scene.navigating,"Inspection also blocks chart navigation")
	scene.popup.hide()
	scene.model.state.scanned.append("bed")
	scene.model.state.energy = 10
	scene.selected = "bed"
	scene._select_tool("warm")
	scene._refresh_ui()
	check(hud.action_state.text == "UNAVAILABLE" and "25 required" in scene.explanation.text,"Shortage appears before committing an operation")
	scene.use_button.pressed.emit()
	check(not scene.held and not scene.model.state.warm and scene.model.state.energy == 10,"Insufficient-energy use cannot execute or consume resources")
	scene.model.state.scanned.append("pod")
	scene.model.state.samples = 2
	scene.selected = "pod"
	scene._select_tool("collect")
	scene._refresh_ui()
	scene.use_button.pressed.emit()
	check("full" in scene.explanation.text and scene.model.state.native_stock == 3,"Full cargo rejects collection without losing native stock")
	check("Cargo: 2 / 2" in hud.quick_cargo.tooltip_text,"Quick cargo reflects actual onboard capacity")
	scene._change_flight_mode("orbit")
	scene._refresh_ui()
	check(hud.flight_readout.visible and hud.flight_readout.size.x <= 168 and hud.flight_readout.size.y <= hud.altitude_backing.size.y,"Orbital ALT remains compact inside its dedicated instrument strip")
	check(scene.use_button.disabled and scene.toolbar.all(func(b: Button) -> bool: return b.disabled),"Surface equipment is unavailable in orbit")
	hud.category_buttons.Environment.pressed.emit()
	var orbit_tool: String = scene.tool
	press(scene,KEY_1)
	check(scene.tool == orbit_tool and "atmosphere" in hud.toolbar[2].tooltip_text,"Wrong-view equipment explains why it is unavailable and cannot be selected")
	hud.category_buttons.Weapons.pressed.emit()
	click_chart(hud.navigation,hud.navigation.project(hud.navigation.planet_at))
	check(not hud.navigation.visible and not hud.chart_backing.visible and not hud.chart_heading.visible and not hud.navigation_menu_button.visible and not scene.landing,"Local terrain chart and its surface-only tab are absent and cannot accept commands in orbit")
	hud.departure_button.pressed.emit()
	check(scene.landing and scene.navigating and scene.model.state.flight_mode == "orbit","Return-to-planet control issues landing approach without an orbital local chart or teleportation")
	check(scene.energy_bar.size.y <= 12,"Energy instrument does not overlap equipment controls")
	scene._stop()
	var before_select: Dictionary = scene.model.state.duplicate(true)
	hud.weapon_button.pressed.emit()
	check(scene.weapon_selected and not scene.attack_order and scene.model.state == before_select,"Selecting a weapon does not attack, move or consume energy")
	scene.weapon_selected = false
	press(scene,KEY_1)
	check(scene.weapon_selected and not scene.attack_order and scene.model.state == before_select,"Weapon keyboard selection follows the visible slot and does not fire")
	scene._command_target("guardian")
	check(scene.attack_order,"Clicking a target with the selected weapon issues combat")
	scene._stop()
	var escape := InputEventKey.new()
	escape.physical_keycode = KEY_ESCAPE
	escape.pressed = true
	scene._unhandled_input(escape)
	check(scene.popup.visible and scene.popup_kind == "menu" and scene.menu_shade.visible,"Escape opens a modal game menu")
	var category: String = hud.active_group
	press(scene,KEY_TAB)
	hud.category_buttons.Inventory.pressed.emit()
	hud.item_buttons.pack.pressed.emit()
	check(hud.active_group == category and scene.model.state == before_select,"Fresh modal guards block palette and item commands before another render")
	var at: Vector3 = scene.ship.position
	scene._physics_process(1)
	check(scene.ship.position == at and scene._inspection_open(),"Game menu pauses flight")
	var slot := InputEventKey.new()
	slot.physical_keycode = KEY_5; slot.pressed = true
	scene.weapon_selected = false
	scene._unhandled_input(slot)
	check(not scene.weapon_selected,"Gameplay hotkeys cannot act behind the menu")
	scene._menu_page("audio")
	scene._unhandled_input(escape)
	check(scene.popup_kind == "menu" and scene.popup.visible,"Escape from menu settings returns to the menu")
	scene._unhandled_input(escape)
	check(not scene.popup.visible and not scene.menu_shade.visible and not scene.paused,"Escape closes menu and restores unpaused state")
	scene._toggle_pause()
	scene._unhandled_input(escape); scene._unhandled_input(escape)
	check(scene.paused,"Closing the menu preserves a prior explicit pause")
	scene._toggle_pause()
	scene.model.state.energy = 20
	scene.model.state.energy_packs = 1
	scene._show_popup("cargo")
	var pack: Button
	for child: Node in scene.popup_body.get_children():
		if child is Button and child.text.begins_with("Energy pack ×"): pack = child
	check(pack != null and not pack.disabled,"Inventory exposes the real usable pack item")
	pack.pressed.emit()
	check(scene.model.state.energy == 70 and scene.model.state.energy_packs == 0 and scene.popup_kind == "cargo" and scene.popup.visible,"Inventory item consumes exactly one pack and refreshes the inventory")
	scene.popup.hide()
	scene.model.state.energy_packs = 2
	scene.model.state.energy = 10
	scene.model.state.pack_ready_at = scene.model.state.time
	hud.category_buttons.Inventory.pressed.emit()
	scene._refresh_ui()
	check(hud.count_labels.pack.text == "× 2" and not hud.item_buttons.pack.disabled,"Quick inventory shows the actual owned stack")
	var selected_item: String = hud.selected_tool
	press(scene,KEY_1)
	hud.item_buttons.pack.pressed.emit()
	check(scene.model.state.energy == 60 and scene.model.state.energy_packs == 1,"Keyboard then repeated click consumes only one pack during cooldown")
	check(hud.selected_tool == selected_item and not scene.attack_order,"Self-use preserves the equipped weapon and never creates a target order")
	scene._refresh_ui()
	check(hud.item_buttons.pack.disabled and "8s" in hud.count_labels.pack.text and "Ready in 8 s" in hud.item_buttons.pack.tooltip_text,"Remaining count and cooldown belong to the inventory item")
	scene._toggle_pause()
	var before_pause: Dictionary = scene.model.state.duplicate(true)
	hud.category_buttons.Weapons.pressed.emit()
	press(scene,KEY_1)
	check(scene.model.state == before_pause and hud.active_group == "Inventory","Explicit pause blocks both palette browsing and item use")
	scene._toggle_pause()
	var utility_buttons: int = 0
	for child: Node in hud.get_children():
		if child is Button and child.text in ["Save","Load","Audio","Controls","Menu","Recharge","SHROUD ON"]: utility_buttons += 1
	check(utility_buttons == 0,"Flight HUD contains no utility footer or direct recharge/shroud button")
	scene.free()
	print("Flight HUD assertions: ",checks,"; failures: ",failures)
	quit(0 if failures == 0 else 1)
