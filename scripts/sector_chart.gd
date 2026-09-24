extends PanelContainer
## Read-only navigation presentation. The campaign validates and executes travel.
signal close_requested
signal travel_requested(planet: String)
signal system_requested(system: String)
const UI = preload("res://scripts/flight_interface.gd")
const Geography = preload("res://scripts/planet_geography.gd")
const Session = preload("res://scripts/expedition_session.gd")
var campaign: RefCounted
var selected_system: String = "s0"
var selected_planet: String = "morrow"
var graph: StarGraph
var worlds: VBoxContainer
var heading: Label
var details: Label
var status: Label
var travel: Button
var close: Button
var inspect_system: Button
var progress: ProgressBar

class StarGraph extends Control:
	signal selected(id: String)
	var campaign: RefCounted
	var selected_id: String = "s0"
	func point(system: Dictionary) -> Vector2:
		return Vector2(55+(system.x+20)/42.0*(size.x-110),45+(system.z+11)/36.0*(size.y-90))
	func _draw() -> void:
		if campaign == null: return
		var font: Font = ThemeDB.fallback_font
		for system: Dictionary in campaign.sector.state.systems:
			if not campaign.sector.is_revealed(system.id): continue
			for other: String in system.links:
				if other > system.id and campaign.sector.is_revealed(other):
					draw_line(point(system),point(campaign.sector.system_by_id(other)),Color("34424d"),2,true)
			var at: Vector2 = point(system)
			var current: bool = system.id == campaign.sector.state.flagship.system
			var ink := Color("ecca77") if current else (Color("9dd9d0") if system.visited else Color("687387"))
			draw_circle(at,7,ink)
			if system.id == selected_id: draw_arc(at,15,0,TAU,32,Color("e4e9ed"),2,true)
			draw_string(font,at+Vector2(16,5),system.name if system.visited or system.get("charted",false) else "Uncharted",HORIZONTAL_ALIGNMENT_LEFT,-1,17,ink)
		for source: String in campaign.freight.state.routes:
			var freight: Dictionary = campaign.freight.state.routes[source]
			if freight.phase == "waiting" or freight.path.is_empty(): continue
			var tint := Color("eba66d")
			for i: int in range(freight.path.size()-1):
				draw_dashed_line(point(campaign.sector.system_by_id(freight.path[i])),point(campaign.sector.system_by_id(freight.path[i+1])),tint.darkened(0.25),2,7,true)
			var fraction: float = 1.0-float(freight.remaining)/maxi(1,freight.duration)
			var at: Vector2 = point(campaign.sector.system_by_id(freight.path[0]))
			if freight.path.size() > 1:
				var phase: float = fraction*(freight.path.size()-1)
				var leg: int = mini(int(phase),freight.path.size()-2)
				at = point(campaign.sector.system_by_id(freight.path[leg])).lerp(point(campaign.sector.system_by_id(freight.path[leg+1])),phase-leg)
			draw_rect(Rect2(at-Vector2(5,5),Vector2(10,10)),tint)
		var ship: Dictionary = campaign.sector.state.flagship
		if campaign.traveling():
			var fraction: float = 1.0-float(ship.remaining)/maxf(1,ship.duration)
			var at: Vector2 = point(campaign.sector.system_by_id(ship.system))
			if ship.route.size() > 1:
				for i: int in range(ship.route.size()-1):
					draw_line(point(campaign.sector.system_by_id(ship.route[i])),point(campaign.sector.system_by_id(ship.route[i+1])),Color("ecca77"),2,true)
				var phase: float = fraction*(ship.route.size()-1)
				var leg: int = mini(int(phase),ship.route.size()-2)
				at = point(campaign.sector.system_by_id(ship.route[leg])).lerp(point(campaign.sector.system_by_id(ship.route[leg+1])),phase-leg)
			draw_colored_polygon(PackedVector2Array([at+Vector2(0,-8),at+Vector2(6,5),at+Vector2(-6,5)]),Color("fff0c2"))
	func _gui_input(event: InputEvent) -> void:
		if campaign == null or campaign.traveling(): return
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			for system: Dictionary in campaign.sector.state.systems:
				if campaign.sector.is_revealed(system.id) and point(system).distance_to(event.position) < 24:
					selected.emit(system.id)
					accept_event()
					return

func label(text: String, font_size: int = 17) -> Label:
	var result := Label.new()
	result.text = text
	result.add_theme_font_size_override("font_size",font_size)
	return result

func button(text: String, action: Callable) -> Button:
	var result := Button.new()
	result.text = text
	result.custom_minimum_size.y = 44
	result.pressed.connect(action)
	UI.instrument(result,"",UI.NAV)
	return result

func _ready() -> void:
	position = Vector2(24,100)
	size = Vector2(1552,592)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("0b1520")
	style.set_content_margin_all(24)
	add_theme_stylebox_override("panel",style)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",12)
	add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	heading = label("SECTOR CHART",24)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(heading)
	close = button("Close [G / Esc]",func() -> void: close_requested.emit())
	header.add_child(close)
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation",24)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(body)
	graph = StarGraph.new()
	graph.custom_minimum_size = Vector2(880,410)
	graph.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	graph.size_flags_vertical = Control.SIZE_EXPAND_FILL
	graph.selected.connect(select_system)
	body.add_child(graph)
	var side := VBoxContainer.new()
	side.custom_minimum_size.x = 490
	side.add_theme_constant_override("separation",8)
	body.add_child(side)
	worlds = VBoxContainer.new()
	side.add_child(worlds)
	inspect_system = button("View system",func() -> void: system_requested.emit(selected_system))
	UI.instrument(inspect_system,"system_view",UI.NAV); side.add_child(inspect_system)
	details = label("")
	details.custom_minimum_size = Vector2(490,100)
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(details)
	travel = button("",func() -> void: travel_requested.emit(selected_planet))
	side.add_child(travel)
	status = label("",15)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(status)
	progress = ProgressBar.new()
	progress.custom_minimum_size.y = 10
	progress.show_percentage = false
	UI.meter(progress,UI.GOLD)
	side.add_child(progress)
	column.add_child(label("Select a star, then an orbital destination. Gold: your system · mint: explored · gray: uncharted · orange: freight",14))
	hide()

func present(session: RefCounted) -> void:
	campaign = session
	graph.campaign = session
	select_system(campaign.sector.state.flagship.destination if campaign.traveling() else campaign.sector.state.flagship.system)
	show()

func select_system(id: String) -> void:
	selected_system = id
	graph.selected_id = id
	for child: Node in worlds.get_children(): worlds.remove_child(child); child.queue_free()
	var system: Dictionary = campaign.sector.system_by_id(id)
	heading.text = "SECTOR CHART  /  "+ (system.name.to_upper() if system.visited or system.get("charted",false) else "UNCHARTED SIGNAL")
	selected_planet = Session.local_id(system.planets[0])
	for pid: String in system.planets:
		var world: String = Session.local_id(pid)
		if not system.visited and not system.get("charted",false) and pid != system.planets[0]: continue
		var title: String = Geography.definition(world).name if system.visited or system.get("charted",false) else "Approach first orbital body"
		var item: Button = button(title,func() -> void: selected_planet = world; refresh())
		item.set_meta("planet",world)
		item.disabled = campaign.traveling()
		worlds.add_child(item)
	refresh()

func refresh() -> void:
	if campaign == null: return
	var offer: Dictionary = campaign.quote(selected_planet)
	var known_system: Dictionary = campaign.sector.system_by_id(selected_system)
	var known: bool = known_system.visited or known_system.get("charted",false)
	inspect_system.disabled = not known or campaign.traveling()
	inspect_system.tooltip_text = "View the known star and planetary destinations" if known else "Visit or obtain a chart before inspecting this system."
	var definition: Dictionary = Geography.definition(selected_planet)
	details.text = (definition.name+" · "+definition.archetype.capitalize()+"\n"+("Landing site available" if not definition.sites.is_empty() else "Orbital visit · surface not available in this build")) if known else "Uncharted system. Arrival reveals its orbital bodies; individual planetary surveys remain separate."
	travel.text = "Depart · %d energy · %d seconds" % [offer.energy,offer.seconds]
	travel.disabled = not offer.reason.is_empty()
	UI.instrument(travel,"ascend",UI.GOLD)
	travel.tooltip_text = offer.reason if travel.disabled else "Spend drive energy and begin the journey. Time continues during travel."
	status.text = offer.reason if travel.disabled else "Energy after departure: %d / %d. Reserve fuel or buy recharge away from home." % [campaign.field.state.energy-offer.energy,campaign.field.max_capacity("energy")]
	for item: Node in worlds.get_children():
		item.disabled = campaign.traveling()
		UI.instrument(item,"planet_map",UI.NAV,item.get_meta("planet","") == selected_planet)
	progress.visible = campaign.traveling()
	close.disabled = campaign.traveling()
	close.tooltip_text = "Journey in progress. Escape opens the pause menu." if close.disabled else "Return to flight"
	if campaign.traveling():
		var ship: Dictionary = campaign.sector.state.flagship
		progress.value = 100*(1.0-float(ship.remaining)/maxf(1,ship.duration))
		status.text = "IN TRANSIT · %d seconds remaining\nEscape: pause / save" % ship.remaining
	graph.queue_redraw()
