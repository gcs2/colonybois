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
const NavPod = preload("res://scripts/flight_nav_pod.gd")
const ConsolePod = preload("res://scripts/flight_console_pod.gd")
var nav_pod: Control
var console_pod: Control
var IDS: Array[String] = Equipment.ids()
var GROUPS: Dictionary = Palette.GROUPS.duplicate(true)
var navigation := Navigation.new()
var sector_button: Button
var system_button: Button
var chart_heading: Label
var chart_backing: ColorRect
var navigation_backing: ColorRect
var navigation_actions: Array[Button] = []
var toolbar: Array[Button] = []
var support_badges: Dictionary = {}
var category_buttons: Dictionary = {}
var active_group: String = "Main tools"
var palette_expanded: bool = true
var palette_locked: bool = false
var item_buttons: Dictionary = {}
var slot_labels: Dictionary = {}
var count_labels: Dictionary = {}
var palette_backing: ColorRect
var collapse_button: Button
var palette_page: int = 0
var page_previous: Button
var page_next: Button
var page_label: Label
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

func symbol_at(icon: String, rect: Rect2, action: String, title: String, tint: Color = Art.NAV) -> Button:
	var button: Button = button_at("",rect,action,tint,icon)
	Art.symbol(button,icon,tint)
	button.tooltip_text = title
	return button

func _build() -> void:
	nav_pod = NavPod.new()
	nav_pod.position = Vector2(26, 730)
	nav_pod.size = Vector2(250, 130)
	add_child(nav_pod)

	chart_backing = ColorRect.new()
	chart_backing.position = Vector2(26, 730)
	chart_backing.size = Vector2(250, 130)
	chart_backing.color = Color(0, 0, 0, 0)
	chart_backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(chart_backing)

	console_pod = ConsolePod.new()
	console_pod.position = Vector2(1312, 744)
	console_pod.size = Vector2(268, 117)
	add_child(console_pod)

	palette_backing = ColorRect.new()
	palette_backing.position = Vector2(760, 744)
	palette_backing.size = Vector2(138, 68)
	palette_backing.color = Color(0.045, 0.05, 0.05, 0.72)
	palette_backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(palette_backing)

	navigation_backing = ColorRect.new()
	navigation_backing.position = Vector2(281, 726)
	navigation_backing.size = Vector2(108, 174)
	navigation_backing.color = Color(0.06, 0.09, 0.11, 0.88)
	navigation_backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(navigation_backing)

	stats = label_at("", Rect2(1090, 31, 430, 25), 14, Art.PAPER)
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stats.clip_text = true

	# Top-left clean location header matching Field Instruments
	location_label = label_at("MORROW", Rect2(36, 28, 400, 28), 20)
	chart_heading = label_at("LOCAL CHART", Rect2(40, 735, 200, 16), 11, Art.MUTED)
	chart_heading.visible = false

	# Local navigation chart mounted cleanly inside the dial of nav_pod
	navigation.position = Vector2(48, 749)
	navigation.size = Vector2(92, 92)
	add_child(navigation)

	# Compact navigation controls
	sector_button = symbol_at("systems", Rect2(285, 730, 48, 42), "sector", "Galaxy · select a star and orbital destination [G]", Art.GOLD)
	system_button = symbol_at("system_view", Rect2(337, 730, 48, 42), "system_view", "System view · nearby planets [J]", Art.NAV)
	navigation_actions.append(symbol_at("planet_map", Rect2(285, 776, 48, 42), "atlas", "Planet map", Art.NAV))
	navigation_actions[-1].tooltip_text = "Planet map · Morrow, survey coverage and landing site [M]"
	navigation_actions.append(symbol_at("communicator", Rect2(337, 776, 48, 42), "contact", "Communicate", Art.COMMS))
	navigation_actions[-1].tooltip_text = "Communicate · local trade and ship services [Y]"
	navigation_actions.append(symbol_at("zoom_out", Rect2(285, 822, 48, 42), "zoom_out", "Zoom out", Art.NAV))
	navigation_actions[-1].tooltip_text = "Zoom out · at surface limit, ascend to orbit"
	navigation_actions.append(symbol_at("zoom_in", Rect2(337, 822, 48, 42), "zoom_in", "Zoom in", Art.NAV))
	navigation_actions[-1].tooltip_text = "Zoom in · move camera closer"
	# Ship and palette are adjacent, with selected equipment above its slots.
	tool_title = label_at("",Rect2(772,634,516,26),18)
	tool_spec = label_at("",Rect2(772,661,516,25),12,Art.MUTED)
	tool_spec.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tool_title.hide()
	tool_spec.hide()
	var group_index: int = 0
	for group: String in GROUPS:
		var button: Button = symbol_at(Palette.CATEGORY_ICONS[group],Rect2(772+group_index*74,686,64,54),"category:"+group,group+" · browse without changing your equipped tool [Tab / Shift-Tab]",Palette.entry(GROUPS[group][0]).tint)
		category_buttons[group] = button
		group_index += 1
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
	flight_readout = label_at("",Rect2(1324,692,240,21),13)
	flight_readout.visible = false
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
	departure_button = button_at("Leave atmosphere",Rect2(285,872,104,24),"departure",Art.NAV)
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
	objective = label_at("",Rect2(36,58,420,56),14,Art.MUTED)
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	paused_badge = label_at("",Rect2(650,25,300,24),15,Art.GOLD)
	paused_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	select_tool("scan")

func _make_item(id: String, item: Dictionary) -> void:
	var button: Button = symbol_at(item.icon,Palette.slot_rect(0),"item:"+id,item.title,item.tint)
	button.add_theme_constant_override("icon_max_width",30)
	button.tooltip_text = Art.tooltip(item.title+"\n"+item.hint)
	var shortcut := Label.new()
	shortcut.position = Vector2(3,36)
	shortcut.add_theme_font_size_override("font_size",11)
	shortcut.modulate = Art.MUTED
	shortcut.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(shortcut)
	var count := Label.new()
	count.position = Vector2(3,-2)
	count.add_theme_font_size_override("font_size",11)
	count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(count)
	item_buttons[id] = button
	slot_labels[id] = shortcut
	count_labels[id] = count

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
		palette_page = clampi(palette_page+(-1 if action == "page_previous" else 1),0,maxi(0,(GROUPS[active_group].size()-1)/Palette.PAGE_SIZE))
		show_group(active_group)
	# Item commands are handled by the scene with a fresh model validation.

func show_group(group: String) -> void:
	if not GROUPS.has(group): return
	active_group = group
	var entries: Array = GROUPS[group]
	for id: String in item_buttons:
		var slot: int = entries.find(id)-palette_page*Palette.PAGE_SIZE
		item_buttons[id].visible = palette_expanded and slot >= 0 and slot < Palette.PAGE_SIZE
		if item_buttons[id].visible:
			item_buttons[id].position = Palette.slot_rect(slot).position
			slot_labels[id].text = ("Ctrl+" if slot >= 9 else "")+str(slot%9+1)
	for key: String in category_buttons:
		Art.symbol(category_buttons[key],Palette.CATEGORY_ICONS[key],Palette.entry(GROUPS[key][0]).tint,key == group)
	if console_pod != null:
		console_pod.active_group = group
		console_pod.queue_redraw()
	palette_backing.visible = palette_expanded
	var visible_items: int = mini(Palette.PAGE_SIZE, maxi(0, entries.size()-palette_page*Palette.PAGE_SIZE))
	var columns: int = mini(9, visible_items)
	var rows: int = int(ceil(visible_items/9.0))
	palette_backing.position = Vector2(760, 744)
	palette_backing.size = Vector2(12+columns*59, 12+rows*56)
	Art.symbol(collapse_button,"palette_close" if palette_expanded else "palette_open",Art.NAV)
	collapse_button.tooltip_text = "Collapse item palette" if palette_expanded else "Expand item palette"
	var pages: int = maxi(1,int(ceil(entries.size()/float(Palette.PAGE_SIZE))))
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
	var entries: Array = GROUPS[active_group]
	slot += palette_page*Palette.PAGE_SIZE
	if slot < 0 or slot >= entries.size(): return
	var button: Button = item_buttons[entries[slot]]
	if not button.disabled: button.pressed.emit()

func select_tool(id: String) -> void:
	var selected: Dictionary = Palette.entry(id)
	if selected.is_empty() or selected.kind != "tool": return
	selected_tool = id
	for group: String in GROUPS:
		if id in GROUPS[group]:
			palette_page = GROUPS[group].find(id)/Palette.PAGE_SIZE
			show_group(group)
			break
	for key: String in item_buttons:
		var item: Dictionary = Palette.entry(key)
		Art.symbol(item_buttons[key],item.icon,item.tint,key == id)
		item_buttons[key].add_theme_constant_override("icon_max_width",30)
	tool_title.text = selected.title
	tool_spec.text = selected.summary

func refresh_items(model: RefCounted, locked: bool) -> void:
	palette_locked = locked
	for id: String in support_badges:
		var chip: Button = support_badges[id]
		chip.visible = model.Support.active(model,id)
		chip.text = Palette.count(id,model.state)
		chip.tooltip_text = Art.tooltip(Palette.entry(id).title+" active\n"+Palette.entry(id).hint)
		chip.disabled = locked
	var selected: Dictionary = Palette.entry(selected_tool)
	tool_spec.text = selected.summary if selected.view == model.state.flight_mode else Palette.unavailable(selected_tool,model)
	for button: Button in category_buttons.values(): button.disabled = locked
	collapse_button.disabled = locked
	page_previous.disabled = locked or palette_page == 0
	page_next.disabled = locked or (palette_page+1)*Palette.PAGE_SIZE >= GROUPS[active_group].size()
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
		elif Equipment.has_tool(id) and model.state.energy < Equipment.energy(id): hint += "\nInsufficient energy to operate; you can still select this tool."
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
	if model != null and model.state != null:
		var s: Dictionary = model.state
		if console_pod != null:
			console_pod.update_status(s.hull, model.max_capacity("hull"), s.energy, model.max_capacity("energy"), model.marks, active_group)
		if orbital_mode and nav_pod != null:
			var alt_km: int = 420
			if s.has("position") and s.position is Array and s.position.size() >= 3:
				var pos := Vector3(s.position[0], s.position[1], s.position[2])
				alt_km = maxi(80, int(pos.length() * 15.0))
			nav_pod.set_mode(true, "%d km" % alt_km)
	if context_card != null:
		var has_order: bool = not subject.text.is_empty()
		context_card.visible = has_order
		subject.visible = has_order
		action_state.visible = has_order
		explanation.visible = has_order
		use_button.visible = has_order
		progress_bar.visible = has_order

func set_orbital_mode(enabled: bool) -> void:
	orbital_mode = enabled
	navigation.visible = not enabled
	chart_heading.visible = not enabled
	chart_backing.visible = not enabled
	if nav_pod != null:
		nav_pod.set_mode(enabled, "420 km" if enabled else "")
	if console_pod != null:
		console_pod.set_orbital(enabled)

	if enabled:
		if console_pod != null:
			console_pod.position = Vector2(960, 770)
			console_pod.size = Vector2(610, 96)
		hull_bar.position = Vector2(1032, 796)
		hull_bar.size = Vector2(110, 10)
		energy_bar.position = Vector2(1032, 828)
		energy_bar.size = Vector2(110, 10)
		hull_bar.modulate.a = 0.0
		energy_bar.modulate.a = 0.0
		hull_label.visible = false
		energy_label.visible = false
		quick_cargo.visible = false
		flight_readout.visible = false
		stats.visible = false
		if scout_label != null: scout_label.visible = false
		if equipment_button != null: equipment_button.visible = false
		if rise_button != null: rise_button.visible = false
		if lower_button != null: lower_button.visible = false
		if brake_button != null: brake_button.visible = false
		collapse_button.visible = false
		page_previous.visible = false
		page_next.visible = false
		page_label.visible = false
		palette_backing.visible = false
		for id: String in item_buttons:
			item_buttons[id].visible = false
		for i: int in range(GROUPS.size()):
			var grp: String = GROUPS.keys()[i]
			category_buttons[grp].position = Vector2(1210 + i * 54, 788)
			category_buttons[grp].size = Vector2(46, 46)
			category_buttons[grp].visible = true
	else:
		if console_pod != null:
			console_pod.position = Vector2(1312, 744)
			console_pod.size = Vector2(268, 117)
		hull_bar.position = Vector2(1324, 758)
		hull_bar.size = Vector2(240, 10)
		energy_bar.position = Vector2(1324, 788)
		energy_bar.size = Vector2(240, 10)
		hull_bar.modulate.a = 0.0
		energy_bar.modulate.a = 0.0
		hull_label.position = Vector2(1324, 717)
		energy_label.position = Vector2(1324, 750)
		hull_label.visible = false
		energy_label.visible = false
		quick_cargo.visible = false
		flight_readout.visible = false
		stats.visible = true
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
		Art.symbol(category_buttons[key],Palette.CATEGORY_ICONS[key],Palette.entry(GROUPS[key][0]).tint,key == group)
