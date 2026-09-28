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
	check(absf(water_color.r-land_color.r)+absf(water_color.g-land_color.g)+absf(water_color.b-land_color.b) > 0.15,"Sampled water and surrounding relief use clearly distinct map colors")
	var darkest: float = 1.0
	var brightest: float = 0.0
	for y: int in range(surface_map.get_height()):
		for x: int in range(surface_map.get_width()):
			var value: float = surface_map.get_pixel(x,y).get_luminance()
			darkest = minf(darkest,value)
			brightest = maxf(brightest,value)
	check(brightest-darkest > 0.2,"Terrain chart preserves visible relief contrast within the dark instrument palette")
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
	check(hud.navigation.size.x >= 180 and hud.navigation.size.y >= 140 and hud.navigation.tooltip_text.contains("50 m"),"Surface chart keeps a legible terrain aperture and the 50 m scale")
	check(hud.chart_heading.visible and hud.chart_heading.position.y >= hud.navigation.position.y + hud.navigation.size.y - 6,"Surface chart keeps its name below the map field")
	check(hud.chart_backing is TextureRect and hud.chart_backing.texture is AtlasTexture and hud.chart_backing.size == Vector2(250,190) and not hud.nav_pod.visible,"Surface chart uses the approved proportioned housing without a blank altitude bay")
	check(hud.navigation_backing.get_script() == load("res://scripts/flight_instrument_frame.gd") and not hud.navigation_backing.visible,"Surface navigation leaves the chart aperture free of a side rail")
	check(hud.navigation_menu_button.visible and hud.departure_button.visible and hud.navigation_actions.all(func(button: Button) -> bool: return not button.visible) and not hud.sector_button.visible and not hud.system_button.visible,"Surface keeps two navigation controls visible and tucks secondary actions away")
	check(hud.departure_button.get_theme_font_size("font_size") == 1 and not hud.departure_button.tooltip_text.is_empty(),"The ascent tab stays icon-only and keeps its named hover tooltip")
	hud.navigation_menu_button.pressed.emit()
	check(hud.navigation_popup_backing.visible and hud.navigation_actions.all(func(button: Button) -> bool: return button.visible and not button.tooltip_text.is_empty()) and hud.sector_button.visible and hud.system_button.visible,"Navigation tab opens all named map, contact and zoom controls")
	hud.navigation_menu_button.pressed.emit()
	check(not hud.navigation_popup_backing.visible and hud.navigation_actions.all(func(button: Button) -> bool: return not button.visible),"Navigation menu closes back to the two-control strip")
	check(hud.empty_slot_backings.size() == 12 and hud.empty_slot_backings[0].position.y < hud.empty_slot_backings[6].position.y,"Inventory grid retains all six columns and both carried-item rows")
	check(hud.item_buttons.values().all(func(button: Button) -> bool: return button.get_theme_constant("icon_max_width") >= 48),"Equipment pictograms use most of each square inventory slot")
	var painted_tool_ids: Array[String] = ["heat_ray","cool_ray","cloud_accumulator","cloud_vacuum","lance","seeker","ground_bomb","shield","rally_call"]
	check(painted_tool_ids.all(func(id: String) -> bool: return hud.item_buttons[id].icon is AtlasTexture) and hud.item_buttons.scan.icon is Texture2D and not hud.item_buttons.scan.icon is AtlasTexture,"Only exact painted-atlas tool matches use object art; unmatched scanner keeps its own pictogram")
	check(hud.navigation.size == Vector2(207,150) and not hud.navigation_backing.visible and hud.navigation_menu_button.position.x >= hud.navigation.position.x + hud.navigation.size.x - 6,"Surface chart keeps its scale while navigation tabs sit on the housing's side protrusions")
	check(scene.status_plate.position.y + scene.status_plate.size.y < hud.objective.position.y,"Upper-left discovery notice clears the objective text")
	check(hud.treasury_backing.position.x > 1420 and hud.treasury_backing.position.x + hud.treasury_backing.size.x > 1550 and hud.stats.text.ends_with("Marks"),"Marks remain legible at the upper-right edge")
	check(scene.recognition_button.position.x + scene.recognition_button.size.x < hud.treasury_backing.position.x,"Recognition remains accessible beside, rather than over, the upper-right Marks plate")
	var saved_landings: int = scene.model.state.landings
	scene.model.state.landings = maxi(1,saved_landings)
	scene._refresh_ui()
	check(not hud.objective.visible and hud.objective.text.is_empty(),"Idle surface exploration leaves the notification corner clear")
	scene.model.state.landings = saved_landings
	scene._refresh_ui()
	check(not hud.altitude_backing.visible and hud.flight_readout.size.x <= hud.CONSOLE_NATIVE_WIDTH-16 and hud.flight_readout.position.x == hud.console_pod.position.x+8 and hud.flight_readout.position.y >= hud.console_pod.position.y,"ALT sits in the right console header instead of a detached inset")
	check(hud.toolbar.all(func(button: Button) -> bool: return button.focus_mode == Control.FOCUS_ALL and button.get_theme_stylebox("focus") is StyleBoxFlat),"Flight HUD tool actions can receive keyboard focus with a visible Field Instruments focus edge")
	var encounter_action: Button = scene._button("Focus check",scene._close_popup,scene.popup_body)
	check(encounter_action.focus_mode == Control.FOCUS_ALL and encounter_action.get_theme_stylebox("focus") is StyleBoxFlat,"Flight encounter actions can receive the same visible keyboard focus")
	check(not hud.tool_title.visible and not hud.tool_spec.visible,"Persistent text above tool icons is removed; identity and costs belong in hover help")
	var named_hover_help: bool = hud.item_buttons.values().all(func(button: Button) -> bool: return not button.tooltip_text.is_empty()) and hud.navigation_actions.all(func(button: Button) -> bool: return not button.tooltip_text.is_empty())
	hud._show_category_hint(hud.category_buttons["Main tools"],"Main tools")
	named_hover_help = named_hover_help and hud.category_hint.visible and hud.category_hint.hint_text == "Main tools · Browse tools [Tab]"
	hud._show_category_hint(hud.communications_button,"Communications")
	named_hover_help = named_hover_help and hud.category_hint.visible and hud.category_hint.hint_text == "Communications · Contact and trade [Y]"
	hud._hide_category_hint()
	check(named_hover_help,"Tools and navigation use named tooltips; category tabs show their named contextual hover hint")
	var category_tabs_fit: bool = hud.category_buttons.size() == 4 and hud.category_tab_cards.size() == 4 and hud.communications_button != null and hud.category_hint != null
	var tab_order: Array[String] = ["Main tools","Inventory","Weapons","Environment"]
	for index: int in range(tab_order.size()):
		var key: String = tab_order[index]
		var button: Button = hud.category_buttons[key]
		var card: Control = hud.category_tab_cards[key]
		category_tabs_fit = category_tabs_fit and card.get_parent() == hud and card.position == button.position and card.size == Vector2(hud.TAB_CARD_WIDTH,hud.TAB_CARD_HEIGHT) and button.size == Vector2(hud.TAB_CARD_WIDTH,hud.TAB_CARD_HEIGHT) and button.focus_mode == Control.FOCUS_ALL and button.get_theme_stylebox("normal") is StyleBoxEmpty
		if index > 0:
			var prior: Button = hud.category_buttons[tab_order[index-1]]
			category_tabs_fit = category_tabs_fit and is_equal_approx(button.position.x-prior.position.x,prior.size.x+hud.TAB_CARD_GAP)
	var last_category: Button = hud.category_buttons["Environment"]
	category_tabs_fit = category_tabs_fit and is_equal_approx(hud.communications_button.position.x-last_category.position.x,last_category.size.x+hud.TAB_CARD_GAP) and hud.communications_button.size == last_category.size
	category_tabs_fit = category_tabs_fit and hud.GROUPS.size() == 4 and hud.category_buttons["Main tools"].button_pressed and not hud.communications_button.toggle_mode
	category_tabs_fit = category_tabs_fit and hud.TAB_GROUP_ORDER == tab_order
	check(category_tabs_fit,"Five raised category cards use the approved display order, centered hit areas, even gaps, focus and named help")
	var inventory_housing_fits: bool = is_equal_approx(hud.grid_backing.position.x+hud.grid_backing.size.x,hud.console_pod.position.x) and is_equal_approx(hud.console_pod.position.x+hud.console_pod.size.x,hud.palette_backing.position.x+hud.palette_backing.size.x)
	inventory_housing_fits = inventory_housing_fits and hud.console_pod.scale == Vector2.ONE and hud.console_pod.size.x == hud.CONSOLE_NATIVE_WIDTH and hud.grid_backing.size.x == hud.PALETTE_GRID_WIDTH+8 and hud.item_buttons.values().all(func(button: Button) -> bool: return is_equal_approx(button.size.x,hud.PALETTE_SLOT_WIDTH))
	inventory_housing_fits = inventory_housing_fits and hud.grid_backing.size.y == hud.PALETTE_GRID_HEIGHT and hud.item_buttons.values().all(func(button: Button) -> bool: return button.size.y == hud.PALETTE_SLOT_HEIGHT)
	check(inventory_housing_fits,"Wider real item cells and the narrowed status segment meet flush inside a shared right-aligned housing")
	var expected_tabs_x: float = hud.inventory_grid_origin.x+(hud.PALETTE_GRID_WIDTH-(5.0*hud.TAB_CARD_WIDTH+4.0*hud.TAB_CARD_GAP))*0.5
	var tabs_attached: bool = is_equal_approx(hud.category_buttons["Main tools"].position.x,expected_tabs_x)
	tabs_attached = tabs_attached and hud.category_buttons["Main tools"].position.y+20 == hud.palette_backing.position.y and hud.grid_backing.position.y == hud.inventory_grid_origin.y-4.0 and hud.palette_backing.size.y == hud.PALETTE_PANEL_HEIGHT and hud.category_tab_cards["Main tools"].accent == hud.Art.GOLD
	check(tabs_attached,"Wider notched tabs rise across the console edge, with the larger two-row grid below")
	var console_controls_fit: bool = hud.collapse_button.position.y == hud.console_pod.position.y+32 and hud.page_previous.position.y == hud.collapse_button.position.y and hud.page_label.position.y == hud.collapse_button.position.y and hud.page_next.position.y == hud.collapse_button.position.y
	console_controls_fit = console_controls_fit and hud.page_next.position.x+hud.page_next.size.x <= hud.console_pod.position.x+hud.console_pod.size.x*hud.console_pod.scale.x and hud.collapse_button.position.x+hud.collapse_button.size.x < hud.page_previous.position.x and hud.page_previous.position.x+hud.page_previous.size.x < hud.page_label.position.x and hud.page_label.position.x+hud.page_label.size.x < hud.page_next.position.x
	check(console_controls_fit,"Collapse and page controls fit the console header row without reducing the five category cards")
	var icon_style: StyleBox = hud.toolbar[0].get_theme_stylebox("normal")
	check(icon_style is StyleBoxFlat and icon_style.corner_radius_top_left == 0 and not icon_style is StyleBoxTexture,"Icon controls do not use rounded decorative wells or metallic border textures")
	scene._activate_selected()
	var state: Dictionary = scene.model.state.duplicate(true)
	var subject: String = scene.selected
	press(scene,KEY_TAB)
	check(hud.active_group == "Inventory" and scene.selected == subject and scene.approach_subject,"Tab browses palettes in visual order without cycling targets or cancelling the active order")
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
	var orbital_readout_is_compact: bool = hud.flight_readout.visible and hud.flight_readout.size.x <= hud.CONSOLE_NATIVE_WIDTH-16 and hud.flight_readout.size.y <= 20 and not hud.altitude_backing.visible and hud.flight_readout.position.x == hud.console_pod.position.x+8
	check(orbital_readout_is_compact,"Orbital ALT remains compact in the right console header")
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
	var emitted_actions: Array[String] = []
	hud.action_requested.connect(func(action: String) -> void: emitted_actions.append(action))
	hud.communications_button.pressed.emit()
	check(emitted_actions.size() == 1 and emitted_actions[0] == "contact","Communications card dispatches the existing contact action")
	scene.free()
	print("Flight HUD assertions: ",checks,"; failures: ",failures)
	quit(0 if failures == 0 else 1)
