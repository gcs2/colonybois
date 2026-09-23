extends Control
## Composed ship instruments. Emits intentions; never mutates simulation state.
signal action_requested(action: String)
signal tool_requested(tool: String)
signal altitude_requested(direction: float)
signal ui_cue(cue: String)
const Art = preload("res://scripts/flight_interface.gd")
const Navigation = preload("res://scripts/flight_navigation.gd")
const Equipment = preload("res://scripts/equipment_catalog.gd")
var IDS: Array[String] = Equipment.ids()
var GROUPS: Dictionary = Equipment.groups()
var navigation := Navigation.new()
var toolbar: Array[Button] = []
var category_buttons: Dictionary = {}
var active_group: String = "Survey"
var orbital_mode: bool = false
var selected_tool: String = "scan"
var tool_title: Label
var tool_spec: Label
var quick_cargo: Button
var location_label: Label
var stats: Label
var objective: Label
var subject: Label
var explanation: Label
var flight_readout: Label
var energy_bar: ProgressBar
var hull_bar: ProgressBar
var hull_label: Label
var energy_label: Label
var danger_label: Label
var guardian_warning: Label
var weapon_button: Button
var progress_bar: ProgressBar
var departure_button: Button
var use_button: Button
var paused_badge: Label
var action_state: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()

func label_at(text: String, rect: Rect2, font_size: int = 16, tint: Color = Art.PAPER) -> Label:
	var label := Label.new()
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",tint)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

func button_at(text: String, rect: Rect2, action: String, tint: Color = Art.NAV, icon: String = "") -> Button:
	var button := Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.add_theme_font_size_override("font_size",16)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.focus_mode = Control.FOCUS_NONE
	Art.instrument(button,icon,tint)
	button.pressed.connect(func() -> void: action_requested.emit(action))
	button.mouse_entered.connect(func() -> void: ui_cue.emit("ui_hover"))
	add_child(button)
	return button

func _build() -> void:
	# Neutral readability backing until the reference-led art kit is reviewed.
	# The rejected cockpit illustration is deliberately not a production asset.
	for rect: Rect2 in [Rect2(26,626,398,225),Rect2(480,748,567,103),Rect2(1135,677,425,174)]:
		var backing := ColorRect.new()
		backing.position = rect.position
		backing.size = rect.size
		backing.color = Color(0.025,0.05,0.065,0.82)
		backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(backing)
	stats = label_at("",Rect2(1010,31,550,25),16,Art.GOLD)
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	# Navigation and nearby communication share one physical location.
	location_label = label_at("MORROW",Rect2(38,581,350,29),18)
	label_at("LOCAL CHART",Rect2(40,612,230,18),11,Art.MUTED)
	navigation.position = Vector2(70,643)
	navigation.size = Vector2(192,192)
	add_child(navigation)
	button_at("Planet map",Rect2(287,722,130,36),"atlas",Art.NAV).tooltip_text = "View Morrow, survey coverage and landing site [M]"
	button_at("Communicate",Rect2(287,765,130,36),"contact",Art.COMMS).tooltip_text = "Open local trade and service communications"
	button_at("−",Rect2(292,807,46,34),"zoom_out",Art.NAV).tooltip_text = "Pull back · at surface limit, ascend to orbit"
	button_at("+",Rect2(352,807,46,34),"zoom_in",Art.NAV).tooltip_text = "Move camera closer"
	# Ship and palette are adjacent, with selected equipment above its slots.
	tool_title = label_at("",Rect2(514,720,370,26),18)
	tool_spec = label_at("",Rect2(514,763,430,20),12,Art.MUTED)
	var group_index: int = 0
	for group: String in GROUPS:
		var button: Button = button_at(group,Rect2(514+group_index*127,694,120,31),"category:"+group,Equipment.tint(GROUPS[group][0]))
		category_buttons[group] = button
		group_index += 1
	for i: int in range(IDS.size()):
		var button: Button = button_at("",Rect2(524,789,64,55),"tool:"+IDS[i],Equipment.tint(IDS[i]),IDS[i])
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.add_theme_constant_override("icon_max_width",42)
		button.tooltip_text = Equipment.hint(IDS[i])
		var shortcut := Label.new()
		shortcut.text = str(i+1)
		shortcut.position = Vector2(7,3)
		shortcut.add_theme_font_size_override("font_size",11)
		shortcut.modulate = Art.MUTED
		shortcut.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(shortcut)
		toolbar.append(button)
	weapon_button = button_at("Weapon",Rect2(524,789,192,55),"weapon",Art.CARGO,"lance")
	weapon_button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	weapon_button.add_theme_constant_override("icon_max_width",41)
	weapon_button.tooltip_text = "Select arc lance, then click an enemy · 10 energy per shot · no ammunition"
	weapon_button.visible = false
	quick_cargo = button_at("Inventory",Rect2(1305,812,160,32),"cargo",Art.CARGO,"cargo")
	quick_cargo.tooltip_text = "Open inventory: specimens and usable energy packs [I]"
	label_at("SCOUT  /  SHIP CONDITION",Rect2(1155,683,240,23),13,Art.GOLD)
	flight_readout = label_at("",Rect2(1155,708,355,21),13)
	hull_label = label_at("",Rect2(1155,731,178,17),11,Art.CARGO)
	energy_label = label_at("",Rect2(1350,731,195,17),11,Art.GOLD)
	hull_bar = ProgressBar.new()
	hull_bar.position = Vector2(1155,753)
	hull_bar.size = Vector2(173,10)
	hull_bar.max_value = 100
	hull_bar.show_percentage = false
	hull_bar.tooltip_text = "Hull condition · clear hazards and use field repair"
	Art.meter(hull_bar,Art.CARGO)
	hull_bar.add_theme_font_size_override("font_size",1)
	add_child(hull_bar)
	hull_bar.size.y = 10
	energy_bar = ProgressBar.new()
	energy_bar.position = Vector2(1350,753)
	energy_bar.size = Vector2(195,10)
	energy_bar.show_percentage = false
	energy_bar.tooltip_text = "Energy · use a pack in Inventory or buy a recharge through local services"
	Art.meter(energy_bar,Art.GOLD)
	energy_bar.add_theme_font_size_override("font_size",1)
	add_child(energy_bar)
	energy_bar.size.y = 10
	button_at("Equipment",Rect2(1148,775,124,33),"systems",Art.GOLD,"systems")
	var rise: Button = button_at("↑",Rect2(1422,775,38,33),"",Art.NAV)
	rise.tooltip_text = "Hold to ascend · Home / Numpad 9"
	rise.button_down.connect(func() -> void: altitude_requested.emit(1))
	rise.button_up.connect(func() -> void: altitude_requested.emit(0))
	var lower: Button = button_at("↓",Rect2(1465,775,38,33),"",Art.NAV)
	lower.tooltip_text = "Descend · in orbit, approach the planet · End / Numpad 3"
	lower.button_down.connect(func() -> void: altitude_requested.emit(-1))
	lower.button_up.connect(func() -> void: altitude_requested.emit(0))
	button_at("■",Rect2(1508,775,38,33),"stop",Art.NAV).tooltip_text = "Stop · Numpad 5"
	departure_button = button_at("Leave atmosphere",Rect2(1148,812,156,32),"departure",Art.NAV)
	departure_button.add_theme_font_size_override("font_size",12)
	danger_label = label_at("",Rect2(940,582,590,34),18,Art.CARGO)
	danger_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	guardian_warning = label_at("",Rect2(940,552,590,27),16,Art.CARGO)
	guardian_warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	# Target feedback stays compact and readable below the world, beside tools.
	subject = label_at("",Rect2(528,622,386,26),17)
	action_state = label_at("",Rect2(530,655,104,19),11,Art.GOLD)
	explanation = label_at("",Rect2(640,653,263,38),12,Art.MUTED)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	use_button = button_at("Use",Rect2(917,638,90,38),"use",Equipment.tint(IDS[0]))
	progress_bar = ProgressBar.new()
	progress_bar.position = Vector2(530,687)
	progress_bar.size = Vector2(477,3)
	progress_bar.max_value = 1
	progress_bar.show_percentage = false
	Art.meter(progress_bar,Equipment.tint(IDS[0]))
	progress_bar.add_theme_font_size_override("font_size",1)
	add_child(progress_bar)
	progress_bar.size.y = 4
	label_at("FLIGHT ASSIST  /  NAVLINK",Rect2(36,40,440,18),11,Art.GOLD)
	objective = label_at("",Rect2(36,64,420,56),14)
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	paused_badge = label_at("",Rect2(650,25,300,24),15,Art.GOLD)
	paused_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_requested.connect(_internal_action)
	select_tool("scan")

func _internal_action(action: String) -> void:
	if action.begins_with("category:"): show_group(action.trim_prefix("category:"))
	elif action.begins_with("tool:"): tool_requested.emit(action.trim_prefix("tool:"))

func show_group(group: String) -> void:
	if not GROUPS.has(group): return
	active_group = group
	var slot: int = 0
	for i: int in range(IDS.size()):
		toolbar[i].visible = not orbital_mode and IDS[i] in GROUPS[group]
		if toolbar[i].visible:
			toolbar[i].position.x = 524+slot*76
			slot += 1
	for key: String in category_buttons:
		Art.instrument(category_buttons[key],"",Art.NAV,key == group)

func select_tool(id: String) -> void:
	if not Equipment.has_tool(id): return
	selected_tool = id
	for group: String in GROUPS:
		if id in GROUPS[group]: show_group(group); break
	for i: int in range(IDS.size()):
		Art.instrument(toolbar[i],IDS[i],Equipment.tint(IDS[i]),IDS[i] == id)
		toolbar[i].add_theme_constant_override("icon_max_width",42)
	tool_title.text = Equipment.title(id)
	tool_spec.text = Equipment.summary(id)

func set_orbital_mode(enabled: bool) -> void:
	orbital_mode = enabled
	for button: Button in category_buttons.values(): button.visible = not enabled
	weapon_button.visible = enabled
	if enabled:
		for button: Button in toolbar: button.visible = false
		tool_title.text = "Orbital tools"
		tool_spec.text = "Select a tool, then click its target"
	else: select_tool(selected_tool)
