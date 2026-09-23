extends Control
## Composed ship instruments. Emits intentions; never mutates simulation state.
signal action_requested(action: String)
signal tool_requested(tool: String)
signal altitude_requested(direction: float)
signal ui_cue(cue: String)
const Art = preload("res://scripts/flight_interface.gd")
const Navigation = preload("res://scripts/flight_navigation.gd")
const Equipment = preload("res://scripts/equipment_catalog.gd")
const Palette = preload("res://scripts/flight_palette.gd")
var IDS: Array[String] = Equipment.ids()
var GROUPS: Dictionary = Palette.GROUPS
var navigation := Navigation.new()
var toolbar: Array[Button] = []
var category_buttons: Dictionary = {}
var active_group: String = "Main tools"
var palette_expanded: bool = true
var palette_locked: bool = false
var item_buttons: Dictionary = {}
var slot_labels: Dictionary = {}
var count_labels: Dictionary = {}
var palette_backing: ColorRect
var collapse_button: Button
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
	for rect: Rect2 in [Rect2(26,626,398,225),Rect2(452,724,405,133),Rect2(880,655,422,93),Rect2(880,748,422,113),Rect2(1312,661,264,200)]:
		var backing := ColorRect.new()
		backing.position = rect.position
		backing.size = rect.size
		backing.color = Color(0.025,0.05,0.065,0.82)
		backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(backing)
		if rect.position == Vector2(880,748): palette_backing = backing
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
	tool_title = label_at("",Rect2(888,661,414,26),18)
	tool_spec = label_at("",Rect2(888,688,414,25),12,Art.MUTED)
	tool_spec.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var group_index: int = 0
	for group: String in GROUPS:
		var button: Button = button_at(group,Rect2(880+group_index*98,718,98,30),"category:"+group,Palette.entry(GROUPS[group][0]).tint)
		button.add_theme_font_size_override("font_size",14)
		category_buttons[group] = button
		group_index += 1
	collapse_button = button_at("−",Rect2(1274,718,28,30),"palette_toggle",Art.NAV)
	collapse_button.tooltip_text = "Collapse item palette; keep selected tool and ship status"
	for group: String in GROUPS:
		for id: String in GROUPS[group]: _make_item(id)
	for id: String in IDS: toolbar.append(item_buttons[id])
	weapon_button = item_buttons.lance
	quick_cargo = button_at("Inventory",Rect2(1445,789,124,32),"cargo",Art.CARGO,"cargo")
	quick_cargo.tooltip_text = "Open inventory: specimens and usable energy packs [I]"
	label_at("SCOUT",Rect2(1324,667,240,23),14,Art.GOLD)
	flight_readout = label_at("",Rect2(1324,692,240,21),13)
	hull_label = label_at("",Rect2(1324,717,230,17),11,Art.CARGO)
	energy_label = label_at("",Rect2(1324,750,230,17),11,Art.GOLD)
	hull_bar = ProgressBar.new()
	hull_bar.position = Vector2(1324,738)
	hull_bar.size = Vector2(240,10)
	hull_bar.max_value = 100
	hull_bar.show_percentage = false
	hull_bar.tooltip_text = "Hull condition · clear hazards and use field repair"
	Art.meter(hull_bar,Art.CARGO)
	hull_bar.add_theme_font_size_override("font_size",1)
	add_child(hull_bar)
	hull_bar.size.y = 10
	energy_bar = ProgressBar.new()
	energy_bar.position = Vector2(1324,771)
	energy_bar.size = Vector2(240,10)
	energy_bar.show_percentage = false
	energy_bar.tooltip_text = "Energy · use a pack in Inventory or buy a recharge through local services"
	Art.meter(energy_bar,Art.GOLD)
	energy_bar.add_theme_font_size_override("font_size",1)
	add_child(energy_bar)
	energy_bar.size.y = 10
	button_at("Equipment",Rect2(1318,789,124,32),"systems",Art.GOLD,"systems")
	var rise: Button = button_at("↑",Rect2(1452,825,36,30),"",Art.NAV)
	rise.tooltip_text = "Hold to ascend · Home / Numpad 9"
	rise.button_down.connect(func() -> void: altitude_requested.emit(1))
	rise.button_up.connect(func() -> void: altitude_requested.emit(0))
	var lower: Button = button_at("↓",Rect2(1492,825,36,30),"",Art.NAV)
	lower.tooltip_text = "Descend · in orbit, approach the planet · End / Numpad 3"
	lower.button_down.connect(func() -> void: altitude_requested.emit(-1))
	lower.button_up.connect(func() -> void: altitude_requested.emit(0))
	button_at("■",Rect2(1532,825,36,30),"stop",Art.NAV).tooltip_text = "Stop · Numpad 5"
	departure_button = button_at("Leave atmosphere",Rect2(1318,825,130,30),"departure",Art.NAV)
	departure_button.add_theme_font_size_override("font_size",12)
	danger_label = label_at("",Rect2(940,582,590,34),18,Art.CARGO)
	danger_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	guardian_warning = label_at("",Rect2(940,552,590,27),16,Art.CARGO)
	guardian_warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	# Context feedback does not masquerade as another tool palette.
	subject = label_at("",Rect2(452,728,405,26),17)
	action_state = label_at("",Rect2(452,759,108,19),11,Art.GOLD)
	explanation = label_at("",Rect2(564,757,288,44),13,Art.MUTED)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	use_button = button_at("Use",Rect2(752,813,100,36),"use",Equipment.tint(IDS[0]))
	progress_bar = ProgressBar.new()
	progress_bar.position = Vector2(452,850)
	progress_bar.size = Vector2(400,3)
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
	select_tool("scan")

func _make_item(id: String) -> void:
	var item: Dictionary = Palette.entry(id)
	var button: Button = button_at("",Rect2(888,756,76,94),"item:"+id,item.tint,item.icon)
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_constant_override("icon_max_width",42)
	button.tooltip_text = item.hint
	var shortcut := Label.new()
	shortcut.position = Vector2(7,72)
	shortcut.add_theme_font_size_override("font_size",11)
	shortcut.modulate = Art.MUTED
	shortcut.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(shortcut)
	var count := Label.new()
	count.position = Vector2(7,3)
	count.add_theme_font_size_override("font_size",13)
	count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(count)
	item_buttons[id] = button
	slot_labels[id] = shortcut
	count_labels[id] = count

func _internal_action(action: String) -> void:
	if palette_locked: return
	if action.begins_with("category:"):
		palette_expanded = true
		show_group(action.trim_prefix("category:"))
	elif action == "palette_toggle":
		palette_expanded = not palette_expanded
		show_group(active_group)
	# Item commands are handled by the scene with a fresh model validation.

func show_group(group: String) -> void:
	if not GROUPS.has(group): return
	active_group = group
	var entries: Array = GROUPS[group]
	for id: String in item_buttons:
		var slot: int = entries.find(id)
		item_buttons[id].visible = palette_expanded and slot >= 0
		if slot >= 0:
			item_buttons[id].position = Vector2(888+slot*82,756)
			slot_labels[id].text = ("Ctrl+" if slot >= 9 else "")+str(slot%9+1)
	for key: String in category_buttons:
		Art.instrument(category_buttons[key],"",Palette.entry(GROUPS[key][0]).tint,key == group)
	palette_backing.visible = palette_expanded
	collapse_button.text = "−" if palette_expanded else "+"
	collapse_button.tooltip_text = "Collapse item palette" if palette_expanded else "Expand item palette"

func cycle_group(direction: int) -> void:
	if palette_locked: return
	var groups: Array = GROUPS.keys()
	palette_expanded = true
	show_group(groups[posmod(groups.find(active_group)+direction,groups.size())])

func activate_slot(slot: int) -> void:
	if palette_locked or not palette_expanded: return
	var entries: Array = GROUPS[active_group]
	if slot < 0 or slot >= entries.size(): return
	var button: Button = item_buttons[entries[slot]]
	if not button.disabled: button.pressed.emit()

func select_tool(id: String) -> void:
	var selected: Dictionary = Palette.entry(id)
	if selected.is_empty() or selected.kind != "tool": return
	selected_tool = id
	for group: String in GROUPS:
		if id in GROUPS[group]: show_group(group); break
	for key: String in item_buttons:
		var item: Dictionary = Palette.entry(key)
		Art.instrument(item_buttons[key],item.icon,item.tint,key == id)
		item_buttons[key].add_theme_constant_override("icon_max_width",42)
	tool_title.text = selected.title
	tool_spec.text = selected.summary

func refresh_items(model: RefCounted, locked: bool) -> void:
	palette_locked = locked
	var selected: Dictionary = Palette.entry(selected_tool)
	tool_spec.text = selected.summary if selected.view == model.state.flight_mode else Palette.unavailable(selected_tool,model)
	for button: Button in category_buttons.values(): button.disabled = locked
	collapse_button.disabled = locked
	for id: String in item_buttons:
		var item: Dictionary = Palette.entry(id)
		var reason: String = Palette.unavailable(id,model)
		item_buttons[id].disabled = locked or not reason.is_empty()
		var hint: String = item.title+"\n"+item.hint
		if locked: hint += "\nClose the current window / resume flight first."
		elif not reason.is_empty(): hint += "\n"+reason
		elif Equipment.has_tool(id) and model.state.energy < Equipment.energy(id): hint += "\nInsufficient energy to operate; you can still select this tool."
		elif id == "lance" and model.state.energy < Palette.Model.LANCE_ENERGY: hint += "\nNeed 10 energy to fire; you can still select this weapon."
		item_buttons[id].tooltip_text = hint
		count_labels[id].text = Palette.count(id,model.state)
		var ready_at: float = float(model.state.pack_ready_at) if id == "pack" else (float(model.state.weapon_ready_at) if id == "lance" else 0.0)
		if ready_at > model.state.time:
			count_labels[id].text += " · %ds" % int(ceil(ready_at-model.state.time))
			item_buttons[id].tooltip_text += "\nReady in %d s." % int(ceil(ready_at-model.state.time))

func set_orbital_mode(enabled: bool) -> void:
	orbital_mode = enabled
	# Selection persists; context explains why the tool is currently unavailable.
	show_group(active_group)
