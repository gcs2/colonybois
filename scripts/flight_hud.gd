extends Control
## Composed ship instruments. Emits intentions; never mutates simulation state.
signal action_requested(action: String)
signal tool_requested(tool: String)
signal altitude_requested(direction: float)
signal ui_cue(cue: String)
const Art = preload("res://scripts/flight_interface.gd")
const Navigation = preload("res://scripts/flight_navigation.gd")
const IDS: Array[String] = ["scan","collect","warm","seed"]
const GROUPS := {"Survey":["scan"],"Cargo":["collect"],"Environment":["warm","seed"]}
var navigation := Navigation.new()
var toolbar: Array[Button] = []
var category_buttons: Dictionary = {}
var active_group: String = "Survey"
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
var progress_bar: ProgressBar
var pause_button: Button
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

func housing(rect: Rect2) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	var skin := StyleBoxTexture.new()
	skin.texture = preload("res://assets/ui/flight/housing.svg")
	for side: int in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]: skin.set_texture_margin(side,28)
	panel.add_theme_stylebox_override("panel",skin)
	add_child(panel)
	return panel

func button_at(text: String, rect: Rect2, action: String, tint: Color = Art.NAV, icon: String = "") -> Button:
	var button := Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.add_theme_font_size_override("font_size",14)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.focus_mode = Control.FOCUS_NONE
	Art.instrument(button,icon,tint)
	button.pressed.connect(func() -> void: action_requested.emit(action))
	button.mouse_entered.connect(func() -> void: ui_cue.emit("ui_hover"))
	add_child(button)
	return button

func _build() -> void:
	# A shallow rail carries secondary features; no large menu across the sky.
	housing(Rect2(-12,858,1624,57))
	stats = label_at("",Rect2(30,871,620,22),14,Art.GOLD)
	button_at("Chronicle",Rect2(850,866,127,30),"journal",Art.NAV,"log")
	button_at("Controls",Rect2(983,866,102,30),"controls")
	button_at("Audio",Rect2(1091,866,85,30),"audio")
	pause_button = button_at("Pause",Rect2(1182,866,90,30),"pause",Art.GOLD)
	button_at("Save",Rect2(1278,866,78,30),"save")
	button_at("Load",Rect2(1362,866,78,30),"load")
	button_at("Menu",Rect2(1446,866,124,30),"menu")
	# Navigation and nearby communication share one physical location.
	housing(Rect2(20,605,342,248))
	location_label = label_at("MORROW",Rect2(42,620,230,27),18)
	label_at("LOCAL CHART",Rect2(42,649,230,18),11,Art.MUTED)
	navigation.position = Vector2(40,674)
	navigation.size = Vector2(197,158)
	add_child(navigation)
	button_at("Atlas",Rect2(250,678,91,45),"atlas",Art.NAV)
	button_at("Contact",Rect2(250,730,91,45),"contact",Art.COMMS)
	label_at("M  /  GLOBE",Rect2(251,791,89,18),11,Art.MUTED)
	# Ship and palette are adjacent, with selected equipment above its slots.
	housing(Rect2(938,655,642,198))
	tool_title = label_at("",Rect2(961,669,320,27),18)
	tool_spec = label_at("",Rect2(961,696,320,20),12,Art.MUTED)
	var group_index: int = 0
	for group: String in GROUPS:
		var button: Button = button_at(group,Rect2(959+group_index*102,725,98,31),"category:"+group,Art.TOOL_COLORS[group_index])
		category_buttons[group] = button
		group_index += 1
	for i: int in range(IDS.size()):
		var button: Button = button_at("",Rect2(963,766,70,69),"tool:"+IDS[i],Art.TOOL_COLORS[i],IDS[i])
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.add_theme_constant_override("icon_max_width",42)
		button.tooltip_text = Art.TOOL_HINTS[IDS[i]]
		var shortcut := Label.new()
		shortcut.text = str(i+1)
		shortcut.position = Vector2(7,3)
		shortcut.add_theme_font_size_override("font_size",11)
		shortcut.modulate = Art.MUTED
		shortcut.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(shortcut)
		toolbar.append(button)
	quick_cargo = button_at("0 / 2",Rect2(1138,777,126,46),"cargo",Art.CARGO,"cargo")
	quick_cargo.tooltip_text = "Onboard sample cradles · full inventory [I]"
	label_at("EXPEDITION SHIP",Rect2(1296,670,250,24),13,Art.GOLD)
	flight_readout = label_at("",Rect2(1296,700,250,40),13)
	energy_bar = ProgressBar.new()
	energy_bar.position = Vector2(1296,744)
	energy_bar.size = Vector2(258,10)
	energy_bar.show_percentage = false
	energy_bar.tooltip_text = "Reactor energy · inspection [K]"
	Art.meter(energy_bar,Art.GOLD)
	energy_bar.add_theme_font_size_override("font_size",1)
	add_child(energy_bar)
	energy_bar.size.y = 10
	button_at("Equipment",Rect2(1296,765,125,33),"systems",Art.GOLD,"systems")
	var rise: Button = button_at("↑",Rect2(1427,765,39,33),"",Art.NAV)
	rise.tooltip_text = "Hold to ascend · Home / Numpad 9"
	rise.button_down.connect(func() -> void: altitude_requested.emit(1))
	rise.button_up.connect(func() -> void: altitude_requested.emit(0))
	var lower: Button = button_at("↓",Rect2(1471,765,39,33),"",Art.NAV)
	lower.tooltip_text = "Hold to descend · End / Numpad 3"
	lower.button_down.connect(func() -> void: altitude_requested.emit(-1))
	lower.button_up.connect(func() -> void: altitude_requested.emit(0))
	button_at("■",Rect2(1515,765,39,33),"stop",Art.NAV).tooltip_text = "Stop · Escape / Numpad 5"
	departure_button = button_at("Leave atmosphere",Rect2(1296,805,258,32),"departure",Art.NAV)
	# Target feedback stays compact and readable below the world, beside tools.
	housing(Rect2(384,750,533,103))
	subject = label_at("",Rect2(406,762,380,25),17)
	action_state = label_at("",Rect2(407,792,100,18),11,Art.GOLD)
	explanation = label_at("",Rect2(511,791,276,38),12,Art.MUTED)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	use_button = button_at("Use",Rect2(803,775,91,43),"use",Art.TOOL_COLORS[0])
	progress_bar = ProgressBar.new()
	progress_bar.position = Vector2(407,835)
	progress_bar.size = Vector2(487,4)
	progress_bar.max_value = 1
	progress_bar.show_percentage = false
	Art.meter(progress_bar,Art.TOOL_COLORS[0])
	progress_bar.add_theme_font_size_override("font_size",1)
	add_child(progress_bar)
	progress_bar.size.y = 4
	housing(Rect2(24,24,355,91))
	label_at("FLIGHT ASSIST",Rect2(44,37,300,17),11,Art.GOLD)
	objective = label_at("",Rect2(44,61,310,43),14)
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
		toolbar[i].visible = IDS[i] in GROUPS[group]
		if toolbar[i].visible:
			toolbar[i].position.x = 963+slot*80
			slot += 1
	for key: String in category_buttons:
		Art.instrument(category_buttons[key],"",Art.NAV,key == group)

func select_tool(id: String) -> void:
	selected_tool = id
	for group: String in GROUPS:
		if id in GROUPS[group]: show_group(group); break
	for i: int in range(IDS.size()):
		Art.instrument(toolbar[i],IDS[i],Art.TOOL_COLORS[i],IDS[i] == id)
		toolbar[i].add_theme_constant_override("icon_max_width",42)
	tool_title.text = Art.TOOL_NAMES[id]
	tool_spec.text = {"scan":"13 m reach  ·  no energy cost","collect":"13 m reach  ·  2 sample cradles","warm":"13 m reach  ·  25 energy","seed":"13 m reach  ·  1 specimen"}[id]
