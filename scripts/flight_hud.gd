extends Control
## Composed ship instruments. Emits intentions; never mutates simulation state.
signal action_requested(action: String)
signal tool_requested(tool: String)
signal altitude_requested(direction: float)
signal ui_cue(cue: String)
const Art = preload("res://scripts/flight_interface.gd")
const Navigation = preload("res://scripts/flight_navigation.gd")
const InstrumentFrame = preload("res://scripts/flight_instrument_frame.gd")
const Equipment = preload("res://scripts/equipment_catalog.gd")
const CargoIcon = preload("res://scripts/flight_cargo_icon.gd")
const Palette = preload("res://scripts/flight_palette.gd")
const NavPod = preload("res://scripts/flight_nav_pod.gd")
const ConsolePod = preload("res://scripts/flight_console_pod.gd")
const MARK_ICON = preload("res://assets/ui/mark-symbol.svg")
const PALETTE_ORIGIN := Vector2(1034, 690)
const PALETTE_COLUMNS := Palette.COLUMNS
const PALETTE_PAGE_CAPACITY := Palette.PAGE_SIZE
const PALETTE_SLOT_WIDTH := 60.0
const PALETTE_COLUMN_GAP := 6.0
const PALETTE_COLUMN_STRIDE := PALETTE_SLOT_WIDTH + PALETTE_COLUMN_GAP
const PALETTE_GRID_WIDTH := PALETTE_COLUMNS * PALETTE_COLUMN_STRIDE - PALETTE_COLUMN_GAP
const CONSOLE_NATIVE_WIDTH := 184.0
const CONSOLE_VISIBLE_WIDTH := 144.0
const CONSOLE_RIGHT_EDGE := 1592.0
const ASSEMBLY_RAISE := 27.0

class TabCardArtwork extends Control:
	var accent: Color = Color("8cc9d0")
	var selected: bool = false
	var hovered: bool = false
	var depressed: bool = false
	var focused: bool = false
	var disabled: bool = false

	func _draw() -> void:
		var w: float = size.x
		var h: float = size.y
		if w < 24.0 or h < 20.0: return
		var sink: float = 1.0 if depressed and not disabled else 0.0
		var face := PackedVector2Array([
			Vector2(0,6+sink), Vector2(6,sink), Vector2(w-6,sink), Vector2(w,6+sink),
			Vector2(w,h-6+sink), Vector2(w-6,h+sink), Vector2(6,h+sink), Vector2(0,h-6+sink)
		])
		var shadow := PackedVector2Array()
		for point: Vector2 in face: shadow.append(point+Vector2(0,2))
		draw_colored_polygon(shadow,Color(0,0,0,0.5))
		var fill := Color("1a2222")
		if selected: fill = Color("202a29")
		if hovered: fill = fill.lightened(0.12)
		if depressed: fill = fill.darkened(0.13)
		if disabled: fill = Color("232b29")
		draw_colored_polygon(face,fill)
		var outline := Color("64706d")
		if hovered: outline = Color("a4aea5")
		if selected: outline = accent.darkened(0.2)
		if disabled: outline = Color("48514f")
		var closed_face := face.duplicate()
		closed_face.append(face[0])
		draw_polyline(closed_face,outline,1.0,true)
		if selected and not disabled:
			draw_line(Vector2(8,2+sink),Vector2(w-8,2+sink),Color(accent.r,accent.g,accent.b,0.16),4.0,true)
			draw_line(Vector2(8,2+sink),Vector2(w-8,2+sink),accent,2.0,true)
		elif selected:
			draw_line(Vector2(8,2+sink),Vector2(w-8,2+sink),Color("596361"),1.0,true)
		else:
			var top_edge := Color("9aa49d")
			top_edge.a = 0.5 if not disabled else 0.22
			draw_line(Vector2(8,2+sink),Vector2(w-8,2+sink),top_edge,1.0,true)
		if focused and not disabled:
			var focus_edge := Color("f3c567")
			focus_edge.a = 0.9
			draw_polyline(closed_face,focus_edge,1.5,true)
		var fastener: Color = Color("101615") if not disabled else Color("1b2221")
		var glint := Color("a0aaa2")
		glint.a = 0.72 if not disabled else 0.35
		for point: Vector2 in [Vector2(6,7+sink),Vector2(w-6,7+sink),Vector2(6,h-7+sink),Vector2(w-6,h-7+sink)]:
			draw_circle(point,1.5,fastener)
			draw_circle(point-Vector2(0.45,0.5),0.55,glint)

class InventorySelectionCue extends Control:
	func _draw() -> void:
		if size.x < 16.0 or size.y < 16.0: return
		var tint := Color("d2b474")
		var inset: float = 3.0
		var leg: float = 8.0
		var x2: float = size.x-inset
		var y2: float = size.y-inset
		for segment: PackedVector2Array in [
			PackedVector2Array([Vector2(inset,inset),Vector2(inset+leg,inset)]),
			PackedVector2Array([Vector2(inset,inset),Vector2(inset,inset+leg)]),
			PackedVector2Array([Vector2(x2-leg,inset),Vector2(x2,inset)]),
			PackedVector2Array([Vector2(x2,inset),Vector2(x2,inset+leg)]),
			PackedVector2Array([Vector2(inset,y2-leg),Vector2(inset,y2)]),
			PackedVector2Array([Vector2(inset,y2),Vector2(inset+leg,y2)]),
			PackedVector2Array([Vector2(x2-leg,y2),Vector2(x2,y2)]),
			PackedVector2Array([Vector2(x2,y2-leg),Vector2(x2,y2)])
		]:
			draw_line(segment[0],segment[1],tint,1.5,true)

var nav_pod: Control
var console_pod: Control
var IDS: Array[String] = Equipment.ids()
var GROUPS: Dictionary = Palette.GROUPS.duplicate(true)
var navigation := Navigation.new()
var sector_button: Button
var system_button: Button
var chart_heading: Label
var chart_backing: Control
var navigation_backing: Control
var navigation_popup_backing: Control
var navigation_menu_button: Button
var navigation_menu_open: bool = false
var navigation_actions: Array[Button] = []
var toolbar: Array[Button] = []
var support_badges: Dictionary = {}
var category_buttons: Dictionary = {}
var category_tab_cards: Dictionary = {}
var communications_button: Button
var communications_card: TabCardArtwork
var active_group: String = "Main tools"
var palette_expanded: bool = true
var palette_locked: bool = false
var item_buttons: Dictionary = {}
var slot_labels: Dictionary = {}
var count_labels: Dictionary = {}
var palette_backing: Control
var grid_backing: Panel
var empty_slot_backings: Array[Panel] = []
var collapse_button: Button
var palette_page: int = 0
var page_previous: Button
var page_next: Button
var page_label: Label
var campaign_inventory_ids: Array[String] = []
var campaign_item_buttons: Dictionary = {}
var campaign_count_labels: Dictionary = {}
var campaign_owned_counts: Dictionary = {}
var orbital_mode: bool = false
var inventory_grid_origin: Vector2 = PALETTE_ORIGIN
var selected_tool: String = "scan"
var tool_title: Label
var tool_spec: Label
var quick_cargo: Button
var location_label: Label
var stats: Label
var treasury_readout: String = ""
var treasury_backing: Control
var treasury_icon: TextureRect
var mode_label: Label
var altitude_backing: ColorRect
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
var equipment_button: Button
var rise_button: Button
var lower_button: Button
var brake_button: Button
var context_card: ColorRect
var scout_label: Label

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

func _style_inventory_slot(button: Button, selected: bool = false) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("11191b")
	normal.border_color = Color("425055")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(0)
	normal.content_margin_left = 2
	normal.content_margin_right = 2
	normal.content_margin_top = 2
	normal.content_margin_bottom = 2
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("263235")
	hover.border_color = Color("819197")
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("1b2628")
	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color("141b1d")
	disabled.border_color = Color("303b3f")
	if selected:
		normal.bg_color = Color("202b2d")
		normal.border_color = Color("697a77")
		hover.bg_color = Color("293639")
		hover.border_color = Color("819b96")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("icon_disabled_color", Color("667579"))
	var cue := button.get_node_or_null("InventorySelectionCue") as Control
	if cue == null:
		cue = InventorySelectionCue.new()
		cue.name = "InventorySelectionCue"
		cue.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		cue.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cue.z_index = 10
		button.add_child(cue)
	cue.visible = selected
	cue.queue_redraw()

func _format_marks(value: int) -> String:
	var digits: String = str(value)
	var formatted: String = ""
	for i: int in range(digits.length()):
		if i > 0 and (digits.length() - i) % 3 == 0:
			formatted += ","
		formatted += digits[i]
	return formatted

func button_at(text: String, rect: Rect2, action: String, tint: Color = Art.NAV, icon: String = "") -> Button:
	var button := Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.add_theme_font_size_override("font_size",16)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.focus_mode = Control.FOCUS_ALL
	Art.instrument(button,icon,tint)
	Art.focus_cue(button)
	button.pressed.connect(func() -> void: action_requested.emit(action))
	button.mouse_entered.connect(func() -> void: ui_cue.emit("ui_hover"))
	add_child(button)
	return button

func symbol_at(icon: String, rect: Rect2, action: String, title: String, tint: Color = Art.NAV) -> Button:
	var button: Button = button_at("",rect,action,tint,icon)
	Art.symbol(button,icon,tint)
	button.tooltip_text = title
	return button

func _attach_tab_card(button: Button, tint: Color) -> TabCardArtwork:
	var artwork := TabCardArtwork.new()
	artwork.accent = tint
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var parent: Control = button.get_parent() as Control
	artwork.position = button.position
	artwork.size = button.size
	parent.add_child(artwork)
	parent.move_child(artwork,button.get_index())
	for state: String in ["normal","hover","pressed","disabled","focus"]:
		button.add_theme_stylebox_override(state,StyleBoxEmpty.new())
	button.add_theme_constant_override("icon_max_width",28)
	button.mouse_entered.connect(func() -> void: artwork.hovered = true; artwork.queue_redraw())
	button.mouse_exited.connect(func() -> void: artwork.hovered = false; artwork.queue_redraw())
	button.button_down.connect(func() -> void: artwork.depressed = true; artwork.queue_redraw())
	button.button_up.connect(func() -> void: artwork.depressed = false; artwork.queue_redraw())
	button.focus_entered.connect(func() -> void: artwork.focused = true; artwork.queue_redraw())
	button.focus_exited.connect(func() -> void: artwork.focused = false; artwork.queue_redraw())
	return artwork

func _set_tab_appearance(button: Button, artwork: TabCardArtwork, tint: Color, selected: bool) -> void:
	button.button_pressed = selected if button.toggle_mode else false
	button.disabled = palette_locked
	button.add_theme_color_override("icon_normal_color",tint.lightened(0.12))
	button.add_theme_color_override("icon_hover_color",tint.lightened(0.32))
	button.add_theme_color_override("icon_pressed_color",tint.lightened(0.08))
	button.add_theme_color_override("icon_disabled_color",Color("687370"))
	# The active edge is warm gold while the icon keeps its category color.
	artwork.accent = Art.GOLD if selected else tint
	artwork.selected = selected
	artwork.disabled = palette_locked
	artwork.queue_redraw()

func _build() -> void:
	nav_pod = NavPod.new()
	nav_pod.position = Vector2(26, 680)
	nav_pod.size = Vector2(250, 190)
	add_child(nav_pod)

	chart_backing = InstrumentFrame.new()
	chart_backing.position = Vector2(26, 680)
	chart_backing.size = Vector2(250, 190)
	chart_backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chart_backing.hide()
	add_child(chart_backing)

	palette_backing = InstrumentFrame.new()
	palette_backing.position = PALETTE_ORIGIN - Vector2(8, 8)
	palette_backing.size = Vector2(150, 68)
	palette_backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(palette_backing)

	# One recessed charcoal tray keeps the two-row item matrix visually related
	# to the condition console. Empty cells are capacity only, never fake items.
	grid_backing = Panel.new()
	grid_backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var grid_style := StyleBoxFlat.new()
	grid_style.bg_color = Color("101618")
	grid_style.border_color = Color("454943")
	grid_style.set_border_width_all(1)
	grid_style.set_corner_radius_all(0)
	grid_backing.add_theme_stylebox_override("panel", grid_style)
	add_child(grid_backing)
	for slot: int in range(PALETTE_PAGE_CAPACITY):
		var empty_slot := Panel.new()
		empty_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var empty_style := StyleBoxFlat.new()
		empty_style.bg_color = Color("141b1d")
		empty_style.border_color = Color("253238")
		empty_style.set_border_width_all(1)
		empty_style.set_corner_radius_all(0)
		empty_slot.add_theme_stylebox_override("panel", empty_style)
		empty_slot_backings.append(empty_slot)
		add_child(empty_slot)

	console_pod = ConsolePod.new()
	console_pod.position = Vector2(1402, 690)
	console_pod.size = Vector2(184, 117)
	add_child(console_pod)
	altitude_backing = ColorRect.new()
	altitude_backing.position = Vector2(1508, 666)
	altitude_backing.size = Vector2(78, 24)
	# Keep the former inset node hidden; ALT now shares the console header.
	altitude_backing.color = Color("1c2426")
	altitude_backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	altitude_backing.hide()
	add_child(altitude_backing)

	navigation_backing = InstrumentFrame.new()
	navigation_backing.position = Vector2(281, 680)
	navigation_backing.size = Vector2(108, 190)
	navigation_backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(navigation_backing)

	# The only Marks balance stays in a high-contrast upper-right Field Instruments plate.
	treasury_backing = InstrumentFrame.new()
	# The recognition control occupies the extreme upper-right corner; keep this
	# Marks plate beside it with a visible gap instead of drawing under that button.
	treasury_backing.position = Vector2(1380, 18)
	treasury_backing.size = Vector2(144, 40)
	treasury_backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(treasury_backing)
	treasury_icon = TextureRect.new()
	treasury_icon.position = Vector2(1391, 27)
	treasury_icon.size = Vector2(20, 20)
	treasury_icon.texture = MARK_ICON
	treasury_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	treasury_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	treasury_icon.modulate = Color("a98427")
	treasury_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(treasury_icon)
	stats = label_at("", Rect2(1417, 23, 98, 28), 13, Color("1c2426"))
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	stats.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stats.clip_text = true

	# Top-left clean location header matching Field Instruments
	location_label = label_at("MORROW", Rect2(36, 28, 400, 28), 20, Color("1c2426"))
	mode_label = label_at("SURFACE", Rect2(36, 53, 140, 18), 11, Color("58646b"))
	chart_heading = label_at("LOCAL SURFACE CHART", Rect2(36, 663, 218, 18), 10, Color("1c2426"))
	chart_heading.visible = false

	# Local navigation chart mounted cleanly inside the dial of nav_pod
	navigation.position = Vector2(20, 700)
	navigation.size = Vector2(160, 160)
	add_child(navigation)
	navigation_popup_backing = InstrumentFrame.new()
	navigation_popup_backing.position = Vector2(47, 690)
	navigation_popup_backing.size = Vector2(108, 144)
	navigation_popup_backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	navigation_popup_backing.hide()
	add_child(navigation_popup_backing)

	# Compact navigation controls
	sector_button = symbol_at("systems", Rect2(285, 686, 48, 42), "sector", "Galaxy · select a star and orbital destination [G]", Art.GOLD)
	system_button = symbol_at("system_view", Rect2(337, 686, 48, 42), "system_view", "System view · nearby planets [J]", Art.NAV)
	navigation_actions.append(symbol_at("planet_map", Rect2(285, 732, 48, 42), "atlas", "Planet map", Art.NAV))
	navigation_actions[-1].tooltip_text = "Planet map · Morrow, survey coverage and landing site [M]"
	navigation_actions.append(symbol_at("communicator", Rect2(337, 732, 48, 42), "contact", "Communicate", Art.COMMS))
	navigation_actions[-1].tooltip_text = "Communicate · local trade and ship services [Y]"
	navigation_actions.append(symbol_at("zoom_out", Rect2(285, 778, 48, 42), "zoom_out", "Zoom out", Art.NAV))
	navigation_actions[-1].tooltip_text = "Zoom out · at surface limit, ascend to orbit"
	navigation_actions.append(symbol_at("zoom_in", Rect2(337, 778, 48, 42), "zoom_in", "Zoom in", Art.NAV))
	navigation_actions[-1].tooltip_text = "Zoom in · move camera closer"
	navigation_menu_button = symbol_at("systems", Rect2(276, 731, 28, 34), "navigation_menu", "Navigation controls · open map, contact and zoom actions")
	navigation_menu_button.add_theme_constant_override("icon_max_width",22)
	navigation_menu_button.pressed.connect(_toggle_navigation_menu)
	navigation_menu_button.hide()
	# Ship and palette are adjacent, with selected equipment above its slots.
	tool_title = label_at("",Rect2(772,634,516,26),18)
	tool_spec = label_at("",Rect2(772,661,516,25),12,Art.MUTED)
	tool_spec.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tool_title.hide()
	tool_spec.hide()
	var group_index: int = 0
	for group: String in GROUPS:
		var tint: Color = Palette.entry(GROUPS[group][0]).tint
		var button: Button = symbol_at(Palette.CATEGORY_ICONS[group],Rect2(772+group_index*74,686,64,54),"category:"+group,group+" · browse without changing your equipped tool [Tab / Shift-Tab]",tint)
		button.toggle_mode = true
		category_buttons[group] = button
		category_tab_cards[group] = _attach_tab_card(button,tint)
		group_index += 1
	communications_button = symbol_at("communicator",Rect2(772+group_index*74,686,64,54),"contact","Communications · known civilizations, local trade and ship services [Y]",Art.COMMS)
	communications_card = _attach_tab_card(communications_button,Art.COMMS)
	collapse_button = symbol_at("palette_close",Rect2(1252,692,42,42),"palette_toggle","Collapse tools",Art.NAV)
	collapse_button.tooltip_text = "Collapse item palette; keep selected tool and ship status"
	page_previous = symbol_at("page_previous",Rect2(1114,692,38,42),"page_previous","Previous item page",Art.NAV)
	page_next = symbol_at("page_next",Rect2(1206,692,38,42),"page_next","Next item page",Art.NAV)
	page_label = label_at("",Rect2(1153,701,52,24),14)
	page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for group: String in GROUPS:
		for id: String in GROUPS[group]: _make_item(id,Palette.entry(id))
	for id: String in IDS: toolbar.append(item_buttons[id])
	weapon_button = item_buttons.lance
	quick_cargo = button_at("Inventory",Rect2(1445,789,124,32),"cargo",Art.CARGO,"inventory")
	quick_cargo.tooltip_text = "Open inventory: specimens and usable energy packs [I]"
	quick_cargo.visible = false
	scout_label = label_at("SCOUT",Rect2(1324,667,110,23),14,Art.GOLD)
	scout_label.visible = false
	for id: String in ["shield","rally_call"]:
		var chip: Button = button_at("",Rect2(1440+support_badges.size()*63,662,60,30),"item:"+id,Color(Palette.Model.Support.catalog[id].color),id)
		chip.add_theme_constant_override("icon_max_width",22); chip.add_theme_font_size_override("font_size",12)
		support_badges[id] = chip; chip.hide()
	flight_readout = label_at("",Rect2(1410,749,168,16),11,Color("1c2426"))
	flight_readout.visible = false
	flight_readout.clip_text = true
	hull_label = label_at("",Rect2(1324,717,230,17),11,Art.CARGO)
	hull_label.visible = false
	energy_label = label_at("",Rect2(1324,750,230,17),11,Art.GOLD)
	energy_label.visible = false
	hull_bar = ProgressBar.new()
	hull_bar.position = Vector2(1324,758)
	hull_bar.size = Vector2(240,10)
	hull_bar.max_value = 100
	hull_bar.show_percentage = false
	hull_bar.tooltip_text = "Hull condition · clear hazards and use field repair"
	Art.meter(hull_bar,Art.CARGO)
	hull_bar.add_theme_font_size_override("font_size",1)
	hull_bar.modulate.a = 0.0
	add_child(hull_bar)
	hull_bar.size.y = 10
	energy_bar = ProgressBar.new()
	energy_bar.position = Vector2(1324,788)
	energy_bar.size = Vector2(240,10)
	energy_bar.show_percentage = false
	energy_bar.tooltip_text = "Energy · use a pack in Inventory or buy a recharge through local services"
	Art.meter(energy_bar,Art.GOLD)
	energy_bar.add_theme_font_size_override("font_size",1)
	energy_bar.modulate.a = 0.0
	add_child(energy_bar)
	energy_bar.size.y = 10
	equipment_button = button_at("Equipment",Rect2(1318,789,124,32),"systems",Art.GOLD,"subsystems")
	equipment_button.visible = false
	rise_button = symbol_at("ascend",Rect2(1452,825,36,30),"","Ascend",Art.NAV)
	rise_button.tooltip_text = "Hold to ascend · Home / Numpad 9"
	rise_button.button_down.connect(func() -> void: altitude_requested.emit(1))
	rise_button.button_up.connect(func() -> void: altitude_requested.emit(0))
	rise_button.visible = false
	lower_button = symbol_at("descend",Rect2(1492,825,36,30),"","Descend",Art.NAV)
	lower_button.tooltip_text = "Descend · in orbit, approach the planet · End / Numpad 3"
	lower_button.button_down.connect(func() -> void: altitude_requested.emit(-1))
	lower_button.button_up.connect(func() -> void: altitude_requested.emit(0))
	lower_button.visible = false
	brake_button = symbol_at("brake",Rect2(1532,825,36,30),"stop","Stop · Numpad 5",Art.NAV)
	brake_button.visible = false
	departure_button = button_at("Leave atmosphere",Rect2(285,824,104,28),"departure",Art.NAV)
	departure_button.add_theme_font_size_override("font_size",11)
	danger_label = label_at("",Rect2(940,582,590,34),18,Art.CARGO)
	danger_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	guardian_warning = label_at("",Rect2(940,552,590,27),16,Art.CARGO)
	guardian_warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	# Context feedback placard placed neatly between nav and palette
	context_card = ColorRect.new()
	context_card.position = Vector2(450,744)
	context_card.size = Vector2(290,117)
	context_card.color = Color(0.06,0.09,0.11,0.88)
	context_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	context_card.visible = false
	add_child(context_card)
	subject = label_at("",Rect2(462,752,164,22),15)
	subject.visible = false
	action_state = label_at("",Rect2(635,752,95,20),11,Art.GOLD)
	action_state.visible = false
	explanation = label_at("",Rect2(462,778,266,36),12,Art.MUTED)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explanation.visible = false
	use_button = button_at("Use",Rect2(635,818,95,28),"use",Equipment.tint(IDS[0]))
	use_button.visible = false
	progress_bar = ProgressBar.new()
	progress_bar.position = Vector2(450,857)
	progress_bar.size = Vector2(290,4)
	progress_bar.max_value = 1
	progress_bar.show_percentage = false
	Art.meter(progress_bar,Equipment.tint(IDS[0]))
	progress_bar.add_theme_font_size_override("font_size",1)
	progress_bar.visible = false
	add_child(progress_bar)
	progress_bar.size.y = 4
	objective = label_at("",Rect2(36,132,540,34),12,Color("1c2426"))
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	paused_badge = label_at("",Rect2(650,25,300,24),15,Art.GOLD)
	paused_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	select_tool("scan")

func _make_item(id: String, item: Dictionary) -> void:
	var button: Button = symbol_at(item.icon,Palette.slot_rect(0),"item:"+id,item.title,item.tint)
	button.size = Vector2(PALETTE_SLOT_WIDTH,54)
	button.add_theme_constant_override("icon_max_width",52)
	_style_inventory_slot(button)
	button.tooltip_text = Art.tooltip(item.title+"\n"+item.hint)
	var shortcut := Label.new()
	shortcut.position = Vector2(3,38)
	shortcut.size = Vector2(54,14)
	shortcut.add_theme_font_size_override("font_size",10)
	shortcut.modulate = Art.MUTED
	shortcut.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(shortcut)
	var count := Label.new()
	count.position = Vector2(2,1)
	count.size = Vector2(56,15)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count.add_theme_font_size_override("font_size",11)
	count.add_theme_color_override("font_color", Art.PAPER)
	count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(count)
	item_buttons[id] = button
	slot_labels[id] = shortcut
	count_labels[id] = count

func _make_campaign_item(entry: Dictionary) -> void:
	var id: String = str(entry.id)
	var title: String = str(entry.title)
	var icon: String = str(entry.get("icon", "cargo"))
	var button: Button = symbol_at(icon, Rect2(0, 0, PALETTE_SLOT_WIDTH, 54), "cargo", title+" · open cargo inventory", Art.CARGO)
	var item_texture: Texture2D = CargoIcon.texture_for(id)
	if item_texture != null:
		# Keep authored owned-item art large and separate from its live stack count.
		button.icon = null
		var pictogram := TextureRect.new()
		pictogram.texture = item_texture
		pictogram.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pictogram.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pictogram.position = Vector2(4, 1)
		pictogram.size = Vector2(52, 38)
		pictogram.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(pictogram)
	button.size = Vector2(PALETTE_SLOT_WIDTH,54)
	button.add_theme_constant_override("icon_max_width",48)
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	_style_inventory_slot(button)
	var count := Label.new()
	count.position = Vector2(2, 39)
	count.size = Vector2(56, 15)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count.add_theme_font_size_override("font_size", 11)
	count.add_theme_color_override("font_color", Art.PAPER)
	count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(count)
	campaign_item_buttons[id] = button
	campaign_count_labels[id] = count

func _group_entries(group: String) -> Array[String]:
	var entries: Array[String] = []
	if not GROUPS.has(group):
		return entries
	for id: String in GROUPS[group]:
		entries.append(id)
	if group == "Main tools":
		# Keep the real field tools beside usable supplies, as in the approved
		# surface instrument. Counts and availability still come from campaign state.
		entries.append_array(GROUPS["Inventory"])
	if group in ["Main tools", "Inventory"]:
		entries.append_array(campaign_inventory_ids)
	return entries

func _refresh_campaign_items(entries: Array[Dictionary], locked: bool) -> void:
	campaign_inventory_ids.clear()
	campaign_owned_counts.clear()
	for button: Button in campaign_item_buttons.values():
		button.visible = false
	var seen: Dictionary = {}
	for entry: Dictionary in entries:
		var id: String = str(entry.get("id", ""))
		var count: int = int(entry.get("count", 0))
		if id.is_empty() or seen.has(id):
			continue
		seen[id] = true
		if item_buttons.has(id):
			campaign_owned_counts[id] = count
			continue
		if count <= 0:
			continue
		if not campaign_item_buttons.has(id):
			_make_campaign_item(entry)
		campaign_inventory_ids.append(id)
		var button: Button = campaign_item_buttons[id]
		button.tooltip_text = Art.tooltip("%s × %d\nCarried cargo · click to inspect the existing inventory." % [str(entry.title), count])
		button.disabled = locked
		campaign_count_labels[id].text = "× %d" % count
	palette_page = clampi(palette_page, 0, maxi(0, (_group_entries(active_group).size()-1)/PALETTE_PAGE_CAPACITY))
	show_group(active_group)

func _internal_action(action: String) -> void:
	if palette_locked: return
	if action.begins_with("category:"):
		palette_expanded = true
		palette_page = 0
		show_group(action.trim_prefix("category:"))
	elif action == "palette_toggle":
		palette_expanded = not palette_expanded
		show_group(active_group)
	elif action in ["page_previous","page_next"]:
		palette_page = clampi(palette_page+(-1 if action == "page_previous" else 1),0,maxi(0,(_group_entries(active_group).size()-1)/PALETTE_PAGE_CAPACITY))
		show_group(active_group)
	# Item commands are handled by the scene with a fresh model validation.

func _toggle_navigation_menu() -> void:
	if orbital_mode: return
	_set_navigation_menu_open(not navigation_menu_open)

func _set_navigation_menu_open(open: bool) -> void:
	navigation_menu_open = open
	navigation_popup_backing.visible = open
	var controls: Array[Button] = [sector_button, system_button]
	controls.append_array(navigation_actions)
	for index: int in range(controls.size()):
		var control: Button = controls[index]
		control.visible = open
		if open:
			control.position = Vector2(52 + (index % 2) * 52, 696 + (index / 2) * 42)
			control.size = Vector2(48, 36)
			control.add_theme_constant_override("icon_max_width",22)

func show_group(group: String) -> void:
	if not GROUPS.has(group): return
	active_group = group
	var entries: Array[String] = _group_entries(group)
	var page_start: int = palette_page * PALETTE_PAGE_CAPACITY
	var visible_items: int = mini(PALETTE_PAGE_CAPACITY, maxi(0, entries.size()-page_start))
	var pages: int = maxi(1,int(ceil(entries.size()/float(PALETTE_PAGE_CAPACITY))))
	var grid_width: float = float(PALETTE_GRID_WIDTH)
	var panel_height: float = 192.0
	var panel_top: float = 870.0-panel_height-ASSEMBLY_RAISE
	# The six-column tray meets the narrowed status pod inside one continuous
	# shell. The transformed status edge stays aligned to the original right edge.
	var console_left: float = CONSOLE_RIGHT_EDGE-CONSOLE_VISIBLE_WIDTH
	inventory_grid_origin = Vector2(console_left-grid_width-4.0,panel_top+56.0)
	grid_backing.position = inventory_grid_origin - Vector2(4, 4)
	grid_backing.size = Vector2(grid_width+8, 118)
	grid_backing.visible = palette_expanded
	for slot: int in range(PALETTE_PAGE_CAPACITY):
		var empty_cell: Panel = empty_slot_backings[slot]
		empty_cell.position = inventory_grid_origin + Vector2((slot % PALETTE_COLUMNS) * PALETTE_COLUMN_STRIDE, (slot / PALETTE_COLUMNS) * 56)
		empty_cell.size = Vector2(PALETTE_SLOT_WIDTH,54)
		empty_cell.visible = palette_expanded and slot >= visible_items
	if console_pod != null:
		console_pod.position = Vector2(console_left,panel_top+18.0)
		console_pod.size = Vector2(CONSOLE_NATIVE_WIDTH,148)
		console_pod.scale = Vector2(CONSOLE_VISIBLE_WIDTH/CONSOLE_NATIVE_WIDTH,1.0)
	altitude_backing.position = Vector2(console_left+106,panel_top-6)
	flight_readout.position = Vector2(console_left+8,panel_top+21)
	flight_readout.size = Vector2(CONSOLE_VISIBLE_WIDTH-16,16)
	for id: String in item_buttons:
		var slot: int = entries.find(id)-page_start
		item_buttons[id].visible = palette_expanded and slot >= 0 and slot < PALETTE_PAGE_CAPACITY
		if item_buttons[id].visible:
			item_buttons[id].position = inventory_grid_origin + Vector2((slot % PALETTE_COLUMNS) * PALETTE_COLUMN_STRIDE, (slot / PALETTE_COLUMNS) * 56)
			item_buttons[id].size = Vector2(PALETTE_SLOT_WIDTH,54)
			slot_labels[id].text = ("Ctrl+" if slot >= PALETTE_COLUMNS else "")+str(slot%PALETTE_COLUMNS+1)
	for id: String in campaign_inventory_ids:
		var slot: int = entries.find(id)-page_start
		var button: Button = campaign_item_buttons[id]
		button.visible = palette_expanded and slot >= 0 and slot < PALETTE_PAGE_CAPACITY
		if button.visible:
			button.position = inventory_grid_origin + Vector2((slot % PALETTE_COLUMNS) * PALETTE_COLUMN_STRIDE, (slot / PALETTE_COLUMNS) * 56)
			button.size = Vector2(PALETTE_SLOT_WIDTH,54)
	# Five category cards retain their approved scale in every pagination state.
	# Page controls use the unused second line of the compact console header.
	var tab_width: float = 56.0
	var tab_gap: float = 7.0
	var tab_total_width: float = 5.0*56.0+4.0*7.0
	var tab_start_x: float = inventory_grid_origin.x+(grid_width-tab_total_width)*0.5
	var tab_index: int = 0
	for key: String in GROUPS:
		var button: Button = category_buttons[key]
		var tint: Color = Palette.entry(GROUPS[key][0]).tint
		button.position = Vector2(tab_start_x+tab_index*(tab_width+tab_gap),panel_top+8)
		button.size = Vector2(tab_width,42)
		button.add_theme_constant_override("icon_max_width",28)
		button.visible = true
		var artwork: TabCardArtwork = category_tab_cards[key] as TabCardArtwork
		artwork.position = button.position
		artwork.size = button.size
		artwork.visible = button.visible
		_set_tab_appearance(button,artwork,tint,key == group)
		tab_index += 1
	communications_button.position = Vector2(tab_start_x+tab_index*(tab_width+tab_gap),panel_top+8)
	communications_button.size = Vector2(tab_width,42)
	communications_button.add_theme_constant_override("icon_max_width",28)
	communications_button.visible = true
	communications_card.position = communications_button.position
	communications_card.size = communications_button.size
	communications_card.visible = communications_button.visible
	_set_tab_appearance(communications_button,communications_card,Art.COMMS,false)
	if console_pod != null:
		console_pod.active_group = group
		console_pod.queue_redraw()
	palette_backing.visible = true
	# The compact angled housing encloses tabs, live inventory and status in both modes.
	palette_backing.position = Vector2(inventory_grid_origin.x-8,panel_top)
	palette_backing.size = Vector2(CONSOLE_RIGHT_EDGE-palette_backing.position.x,panel_height)
	palette_backing.queue_redraw()
	Art.symbol(collapse_button,"palette_close" if palette_expanded else "palette_open",Art.NAV)
	collapse_button.tooltip_text = "Collapse item palette" if palette_expanded else "Expand item palette"
	var console_header_row: float = console_pod.position.y+20.0
	collapse_button.position = Vector2(console_pod.position.x+8.0,console_header_row)
	collapse_button.size = Vector2(22,20)
	collapse_button.add_theme_constant_override("icon_max_width",16)
	page_previous.position = Vector2(console_pod.position.x+34.0,console_header_row)
	page_previous.size = Vector2(24,20)
	page_previous.add_theme_constant_override("icon_max_width",16)
	page_label.position = Vector2(console_pod.position.x+62.0,console_header_row)
	page_label.size = Vector2(44,20)
	page_label.add_theme_font_size_override("font_size",11)
	page_next.position = Vector2(console_pod.position.x+110.0,console_header_row)
	page_next.size = Vector2(24,20)
	page_next.add_theme_constant_override("icon_max_width",16)
	page_previous.visible = palette_expanded and pages > 1
	page_next.visible = page_previous.visible
	page_label.visible = page_previous.visible
	page_previous.disabled = palette_locked or palette_page == 0
	page_next.disabled = palette_locked or palette_page >= pages-1
	page_label.text = "%d / %d" % [palette_page+1,pages]

func cycle_group(direction: int) -> void:
	if palette_locked: return
	var groups: Array = GROUPS.keys()
	palette_expanded = true
	palette_page = 0
	show_group(groups[posmod(groups.find(active_group)+direction,groups.size())])

func activate_slot(slot: int) -> void:
	if palette_locked or not palette_expanded: return
	# Existing input bindings deliver 1–9 and Ctrl+1–9. The two-row grid uses
	# 1–6 for row one and Ctrl+1–6 for row two; surplus keys remain no-ops.
	if slot >= PALETTE_COLUMNS and slot < 9: return
	if slot >= 9: slot = PALETTE_COLUMNS + slot - 9
	var entries: Array[String] = _group_entries(active_group)
	slot += palette_page*PALETTE_PAGE_CAPACITY
	if slot < 0 or slot >= entries.size(): return
	var button: Button = item_buttons[entries[slot]]
	if not button.disabled: button.pressed.emit()

func select_tool(id: String) -> void:
	var selected: Dictionary = Palette.entry(id)
	if selected.is_empty() or selected.kind != "tool": return
	selected_tool = id
	for group: String in GROUPS:
		if id in GROUPS[group]:
			palette_page = GROUPS[group].find(id)/PALETTE_PAGE_CAPACITY
			show_group(group)
			break
	for key: String in item_buttons:
		var item: Dictionary = Palette.entry(key)
		Art.symbol(item_buttons[key],item.icon,item.tint,key == id)
		item_buttons[key].add_theme_constant_override("icon_max_width",48)
		_style_inventory_slot(item_buttons[key], key == id)
	tool_title.text = selected.title
	tool_spec.text = selected.summary

func refresh_items(model: RefCounted, locked: bool, inventory_entries: Array[Dictionary] = []) -> void:
	palette_locked = locked
	_refresh_campaign_items(inventory_entries, locked)
	for key: String in category_buttons:
		var button: Button = category_buttons[key]
		var tint: Color = Palette.entry(GROUPS[key][0]).tint
		_set_tab_appearance(button,category_tab_cards[key] as TabCardArtwork,tint,key == active_group)
	_set_tab_appearance(communications_button,communications_card,Art.COMMS,false)
	for id: String in support_badges:
		var chip: Button = support_badges[id]
		chip.visible = model.Support.active(model,id)
		chip.text = Palette.count(id,model.state)
		chip.tooltip_text = Art.tooltip(Palette.entry(id).title+" active\n"+Palette.entry(id).hint)
		chip.disabled = locked
	var selected: Dictionary = Palette.entry(selected_tool)
	if Equipment.has_tool(selected_tool):
		selected.summary = Equipment.summary(selected_tool,model.installed_upgrades)
		selected.hint = Equipment.hint(selected_tool,model.installed_upgrades)
	tool_spec.text = selected.summary if selected.view == model.state.flight_mode else Palette.unavailable(selected_tool,model)
	collapse_button.disabled = locked
	page_previous.disabled = locked or palette_page == 0
	page_next.disabled = locked or (palette_page+1)*PALETTE_PAGE_CAPACITY >= _group_entries(active_group).size()
	for id: String in item_buttons:
		var item: Dictionary = Palette.entry(id)
		var reason: String = Palette.unavailable(id,model)
		item_buttons[id].disabled = locked or not reason.is_empty()
		var hint: String = item.title+"\n"+item.hint
		if model.planetary != null and model.planetary.ecosystem != null:
			if id == "seed": hint = "Specimen deployer\nOpen carried specimens, select one, then click a surface habitat. 5 energy; consumes one specimen."
			if id == "collect": hint = "Tractor cradle\nScan an expedition lifeform, then click it with this tool to collect. 13 m reach; 1.5 s; 5 energy."
		if locked: hint += "\nClose the current window / resume flight first."
		elif not reason.is_empty(): hint += "\n"+reason
		elif Equipment.has_tool(id) and model.state.energy < Equipment.energy(id,model.installed_upgrades): hint += "\nInsufficient energy to operate; you can still select this tool."
		elif id == "lance" and model.state.energy < Palette.Model.LANCE_ENERGY: hint += "\nNeed 10 energy to fire; you can still select this weapon."
		item_buttons[id].tooltip_text = hint
		count_labels[id].text = Palette.count(id,model.state)
		if id == "seed" and model.planetary != null and model.planetary.ecosystem != null: count_labels[id].text = "× %d" % model.planetary.ecosystem.used()
		var ready_at: float = float(model.state.pack_ready_at) if id == "pack" else (float(model.state.weapon_ready_at) if id == "lance" else 0.0)
		if Palette.Model.repair_items().has(id): ready_at = float(model.state.last_repair_at)+Palette.Model.REPAIR_COOLDOWN
		if ready_at > model.state.time:
			count_labels[id].text += " · %ds" % int(ceil(ready_at-model.state.time))
			item_buttons[id].tooltip_text += "\nReady in %d s." % int(ceil(ready_at-model.state.time))
		item_buttons[id].tooltip_text = Art.tooltip(item_buttons[id].tooltip_text)
	for id: String in campaign_owned_counts:
		count_labels[id].text = "× %d" % int(campaign_owned_counts[id])
	if model != null and model.state != null:
		var s: Dictionary = model.state
		treasury_readout = "%s Marks" % _format_marks(model.marks)
		stats.text = treasury_readout
		if console_pod != null:
			console_pod.update_status(s.hull, model.max_capacity("hull"), s.energy, model.max_capacity("energy"), model.marks, active_group)
		if orbital_mode and nav_pod != null:
			var alt_km: int = 420
			if s.has("position") and s.position is Array and s.position.size() >= 3:
				var pos := Vector3(s.position[0], s.position[1], s.position[2])
				alt_km = maxi(80, int(pos.length() * 15.0))
			nav_pod.set_mode(true, "%d km" % alt_km)
			flight_readout.text = "ALT %d km" % alt_km
	if context_card != null:
		var has_order: bool = not subject.text.is_empty()
		context_card.visible = has_order
		subject.visible = has_order
		action_state.visible = has_order
		explanation.visible = has_order
		use_button.visible = has_order
		progress_bar.visible = has_order

func set_cargo_readout(used: int, capacity: int) -> void:
	if stats == null:
		return
	# The upper-right instrument is the Marks balance. Cargo and carried items
	# stay together in the lower-right inventory panel.
	stats.text = treasury_readout

func set_orbital_mode(enabled: bool) -> void:
	orbital_mode = enabled
	mode_label.text = "ORBIT" if enabled else "SURFACE"
	mode_label.add_theme_color_override("font_color",Art.PAPER if enabled else Color("58646b"))
	location_label.add_theme_color_override("font_color",Art.PAPER if enabled else Color("1c2426"))
	objective.add_theme_color_override("font_color",Art.PAPER if enabled else Color("1c2426"))
	navigation.visible = not enabled
	# The orbital dial is replaced by a small ALT line beside the condition panel;
	# the local terrain chart itself remains surface-only.
	if nav_pod != null: nav_pod.visible = false
	chart_heading.visible = not enabled
	chart_backing.visible = not enabled
	if nav_pod != null:
		nav_pod.set_mode(enabled, "420 km" if enabled else "")
	if console_pod != null:
		# Keep the same compact condition readout beside the item grid in both scales.
		console_pod.set_orbital(false)
	navigation_menu_button.visible = not enabled
	_set_navigation_menu_open(false)
	for control: Button in [sector_button, system_button]:
		control.visible = enabled
	for control: Button in navigation_actions:
		control.visible = enabled

	if enabled:
		navigation_backing.visible = true
		nav_pod.position = Vector2(26, 730)
		nav_pod.size = Vector2(250, 130)
		chart_backing.position = Vector2(26, 730)
		chart_backing.size = Vector2(250, 130)
		navigation.position = Vector2(48, 749)
		navigation.size = Vector2(92, 92)
		navigation_backing.position = Vector2(281, 680)
		navigation_backing.size = Vector2(108, 190)
		sector_button.position = Vector2(285, 686)
		system_button.position = Vector2(337, 686)
		navigation_actions[0].position = Vector2(285, 732)
		navigation_actions[1].position = Vector2(337, 732)
		navigation_actions[2].position = Vector2(285, 778)
		navigation_actions[3].position = Vector2(337, 778)
		departure_button.position = Vector2(285, 824)
		Art.instrument(departure_button,"",Art.NAV)
		departure_button.icon = null
		departure_button.add_theme_font_size_override("font_size",11)
		departure_button.tooltip_text = ""
		altitude_backing.position = Vector2(1508, 666)
		flight_readout.position = Vector2(1512, 667)
		if console_pod != null:
			console_pod.position = Vector2(1402, 690)
			console_pod.size = Vector2(184, 117)
		hull_bar.position = Vector2(1410, 758)
		hull_bar.size = Vector2(168, 10)
		energy_bar.position = Vector2(1410, 788)
		energy_bar.size = Vector2(168, 10)
		hull_bar.modulate.a = 0.0
		energy_bar.modulate.a = 0.0
		hull_label.visible = false
		energy_label.visible = false
		quick_cargo.visible = false
		flight_readout.visible = true
		stats.visible = true
		treasury_backing.visible = true
		if scout_label != null: scout_label.visible = false
		if equipment_button != null: equipment_button.visible = false
		if rise_button != null: rise_button.visible = false
		if lower_button != null: lower_button.visible = false
		if brake_button != null: brake_button.visible = false
		collapse_button.visible = true
		for i: int in range(GROUPS.size()):
			var grp: String = GROUPS.keys()[i]
			category_buttons[grp].position = Vector2(772 + i * 74, 686)
			category_buttons[grp].size = Vector2(64, 54)
			category_buttons[grp].visible = true
		show_group(active_group)
	else:
		# The surface map uses the left instrument while secondary controls remain
		# available from its footer and expandable tab.
		nav_pod.position = Vector2(16, 674)
		nav_pod.size = Vector2(250, 196)
		# Use the same-width chart frame as the corner pod, with its title on the
		# reserved footer line below the map field.
		chart_backing.position = Vector2(16, 634)
		chart_backing.size = Vector2(250, 220)
		navigation.position = Vector2(20, 644)
		navigation.size = Vector2(238, 170)
		# Give the sampled chart the full instrument aperture. The two secondary
		# actions share its quiet footer instead of consuming a narrow side rail.
		navigation_backing.visible = false
		navigation_backing.position = Vector2(240, 727)
		navigation_backing.size = Vector2(26, 82)
		navigation_menu_button.position = Vector2(198, 824)
		navigation_menu_button.size = Vector2(22, 24)
		navigation_menu_button.tooltip_text = "Navigation controls · open map, contact and zoom actions"
		departure_button.position = Vector2(224, 824)
		departure_button.size = Vector2(22, 24)
		Art.symbol(departure_button,"ascend",Art.NAV)
		departure_button.add_theme_constant_override("icon_max_width",22)
		departure_button.tooltip_text = "Leave atmosphere · ascend to orbit"
		departure_button.add_theme_font_size_override("font_size",1)
		for state: String in ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color"]:
			departure_button.add_theme_color_override(state,Color(0,0,0,0))
		chart_heading.position = Vector2(28, 828)
		chart_heading.size = Vector2(166, 18)
		chart_heading.add_theme_font_size_override("font_size", 10)
		navigation_menu_button.visible = true
		altitude_backing.position = Vector2(1508, 666)
		flight_readout.position = Vector2(1512, 667)
		if console_pod != null:
			console_pod.position = Vector2(1402, 690)
			console_pod.size = Vector2(184, 117)
		hull_bar.position = Vector2(1410, 758)
		hull_bar.size = Vector2(168, 10)
		energy_bar.position = Vector2(1410, 788)
		energy_bar.size = Vector2(168, 10)
		hull_bar.modulate.a = 0.0
		energy_bar.modulate.a = 0.0
		hull_label.position = Vector2(1410, 717)
		energy_label.position = Vector2(1410, 750)
		hull_label.visible = false
		energy_label.visible = false
		quick_cargo.visible = false
		flight_readout.visible = true
		stats.visible = true
		treasury_backing.visible = true
		if scout_label != null: scout_label.visible = false
		if equipment_button != null: equipment_button.visible = false
		if rise_button != null: rise_button.visible = false
		if lower_button != null: lower_button.visible = false
		if brake_button != null: brake_button.visible = false
		collapse_button.visible = true
		for i: int in range(GROUPS.size()):
			var grp: String = GROUPS.keys()[i]
			category_buttons[grp].position = Vector2(772 + i * 74, 686)
			category_buttons[grp].size = Vector2(64, 54)
			category_buttons[grp].visible = true
		show_group(active_group)

func set_active_group(group: String) -> void:
	if not GROUPS.has(group): return
	active_group = group
	if console_pod != null:
		console_pod.active_group = group
		console_pod.queue_redraw()
	for key: String in category_buttons:
		var button: Button = category_buttons[key]
		var tint: Color = Palette.entry(GROUPS[key][0]).tint
		_set_tab_appearance(button,category_tab_cards[key] as TabCardArtwork,tint,key == group)
