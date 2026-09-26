extends PanelContainer
## Read-only navigation presentation. The campaign validates and executes travel.
signal close_requested
signal travel_requested(planet: String)
signal system_requested(system: String)
const Stage = preload("res://scripts/navigation_stage.gd")
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
	signal activated(id: String)
	const Galaxy = preload("res://scripts/galaxy_catalog.gd")
	var campaign: RefCounted
	var selected_id: String = "s0"
	var magnification: float = 1.0
	var pan := Vector2.ZERO
	var dragging: bool = false
	var panning: bool = false
	var yaw: float = 0.0
	var pitch: float = 0.58
	var hovered: String = ""
	static var dust_cache: Dictionary = {}
	var draw_ms: float = 0.0
	var travel_fraction: float = 0.0
	var dust: Texture2D
	var focus_pc := Vector2(58,0)
	var star_points := PackedVector2Array()
	var star_colors := PackedColorArray()
	var star_known := PackedByteArray()
	var star_batch: MultiMesh
	var star_sprite: Texture2D
	func view_center() -> Vector2: return size*0.5
	func reset_view() -> void:
		magnification = 1; pan = Vector2.ZERO
		focus_pc = Galaxy.position(campaign.sector.system_by_id(campaign.sector.state.flagship.system))
		queue_redraw()
	func overview() -> void:
		magnification = minf(size.x/10000.0,size.y/6800.0)
		pan = Vector2.ZERO; focus_pc = Vector2.ZERO
		queue_redraw()
	func world_at(screen: Vector2) -> Vector2:
		var axes: Basis = camera_axes()
		var offset: Vector2 = (screen-view_center()-pan)/(size.y*0.8)
		var ray: Vector3 = axes.x*offset.x+axes.y*offset.y-axes.z
		var camera: Vector3 = Vector3(focus_pc.x,0,focus_pc.y)+axes.z*camera_distance()
		if absf(ray.y) < 0.0001: return focus_pc
		var hit: Vector3 = camera-ray*(camera.y/ray.y)
		return Vector2(hit.x,hit.z)
	func zoom_at(steps: float, anchor: Vector2) -> void:
		var world: Vector2 = world_at(anchor)
		magnification = clampf(magnification*pow(1.18,-steps),0.055,3.5)
		if in_front(world): pan += anchor-project(world)
		queue_redraw()
	func camera_axes() -> Basis:
		var right := Vector3(cos(yaw),0,-sin(yaw))
		var up := Vector3(sin(yaw)*sin(pitch),cos(pitch),cos(yaw)*sin(pitch))
		return Basis(right,up,right.cross(up))
	func relative_position(pc: Vector2) -> Vector3:
		return Vector3(pc.x-focus_pc.x,0,pc.y-focus_pc.y)
	func camera_distance() -> float: return size.y*0.8/(36*magnification)
	func in_front(pc: Vector2) -> bool:
		return camera_distance()-relative_position(pc).dot(camera_axes().z) > 0.5
	func project(pc: Vector2) -> Vector2:
		var relative: Vector3 = relative_position(pc)
		var axes: Basis = camera_axes()
		var depth: float = maxf(0.5,camera_distance()-relative.dot(axes.z))
		return Vector2(relative.dot(axes.x),relative.dot(axes.y))*size.y*0.8/depth+view_center()+pan
	func point(system: Dictionary) -> Vector2: return project(Galaxy.position(system))
	func make_dust() -> void:
		if dust_cache.has(campaign.sector.state.seed):
			dust = dust_cache[campaign.sector.state.seed]; return
		# One cached faint density texture. The selectable stars remain world data.
		var img := Image.create(512,512,false,Image.FORMAT_RGBA8)
		var noise := FastNoiseLite.new(); noise.seed = campaign.sector.state.seed; noise.frequency = 0.11
		for x: int in range(512):
			for y: int in range(512):
				var pos: Vector2 = Vector2(x,y)/512*220-Vector2.ONE*110
				var r: float = pos.length()
				var theta: float = atan2(pos.y,pos.x)
				var arm_angle: float = (log(1+r)-log(59.0))*1.32
				var delta: float = absf(wrapf(theta-arm_angle,-PI/4,PI/4))*r
				var arm: float = exp(-pow(delta/(1.1+r*0.055),2))*smoothstep(102,78,r)
				var core: float = exp(-r*r/180)
				var detail: float = 0.75+noise.get_noise_2d(x,y)*0.65
				var tone: Color = Color("737496").lerp(Color("ffe0a0"),core)
				tone.a = clampf(arm*0.25*detail+core*0.8+exp(-r/30)*0.025,0,0.9)
				img.set_pixel(x,y,tone)

		img.generate_mipmaps(); dust = ImageTexture.create_from_image(img)
		dust_cache[campaign.sector.state.seed] = dust
	func cache_stars() -> void:
		star_points.clear(); star_colors.clear(); star_known.clear()
		var tones := [Color("f2dab0"),Color("b4cce7"),Color("f2bdb0")]
		for star: Dictionary in campaign.sector.state.systems:
			star_points.append(Galaxy.position(star))
			var known: bool = star.visited or star.get("charted",false)
			var detected: bool = known or star.get("detected",false)
			star_known.append(1 if detected else 0)
			var tint: Color = tones[int(star.id.substr(1))%3]
			star_colors.append(tint if known else tint.darkened(0.25) if detected else Color("687080"))
		if star_batch == null:
			star_batch = MultiMesh.new(); star_batch.transform_format = MultiMesh.TRANSFORM_2D
			star_batch.use_colors = true
			var quad := QuadMesh.new(); quad.size = Vector2.ONE; star_batch.mesh = quad
			star_batch.instance_count = star_points.size()
			var img := Image.create(32,32,false,Image.FORMAT_RGBA8)
			for x: int in range(32):
				for y: int in range(32):
					var r: float = Vector2(x-15.5,y-15.5).length()/15.5
					img.set_pixel(x,y,Color(1,1,1,clampf(exp(-r*r*30)+exp(-r*r*5)*0.15,0,1)))
			star_sprite = ImageTexture.create_from_image(img)
	func _draw() -> void:
		if campaign == null: return
		var draw_start: int = Time.get_ticks_usec()
		var font: Font = ThemeDB.fallback_font
		if dust != null and absf(sin(pitch)) > 0.01:
			# Project tiles onto the SAME physical galactic plane as stars/range.
			# Small tiles avoid a stretched screen-facing background at oblique angles.
			for x: int in range(12):
				for y: int in range(12):
					var corners := PackedVector2Array()
					var uv := PackedVector2Array()
					var visible_tile: bool = true
					for offset: Vector2 in [Vector2.ZERO,Vector2.RIGHT,Vector2.ONE,Vector2.DOWN]:
						var v: Vector2 = (Vector2(x,y)+offset)/12.0
						var pc: Vector2 = v*220-Vector2.ONE*110
						visible_tile = visible_tile and in_front(pc)
						corners.append(project(pc)); uv.append(v)
					if visible_tile: draw_polygon(corners,PackedColorArray([Color.WHITE]),uv,dust)

		var current: Dictionary = campaign.sector.system_by_id(campaign.sector.state.flagship.system)
		var origin: Vector2 = point(current)
		var axes: Basis = camera_axes()
		var focal: float = size.y*0.8
		var distance: float = camera_distance()
		var center: Vector2 = view_center()+pan
		var visible_stars: int = 0
		for i: int in range(star_points.size()):
			var relative: Vector2 = star_points[i]-focus_pc
			var depth: float = distance-relative.x*axes.z.x-relative.y*axes.z.z
			if depth <= 0.5: continue
			var scale: float = focal/depth
			var at := Vector2(relative.x*axes.x.x+relative.y*axes.x.z,relative.x*axes.y.x+relative.y*axes.y.z)*scale+center
			if at.x < -20 or at.y < -20 or at.x > size.x+20 or at.y > size.y+20: continue
			var diameter: float = clampf(7+9*magnification,7,20) if star_known[i] else 4.0
			star_batch.set_instance_transform_2d(visible_stars,Transform2D(Vector2(diameter,0),Vector2(0,diameter),at))
			star_batch.set_instance_color(visible_stars,star_colors[i])
			visible_stars += 1
		if star_batch != null:
			star_batch.visible_instance_count = visible_stars
			draw_multimesh(star_batch,star_sprite)
		if magnification > 0.3:
			var label_ids: Array[String] = [selected_id]
			if hovered != selected_id: label_ids.append(hovered)
			for id: String in label_ids:
				if id.is_empty(): continue
				var star: Dictionary = campaign.sector.system_by_id(id)
				if not in_front(Galaxy.position(star)) or not campaign.sector.is_revealed(id): continue
				var title: String = star.name if star.visited or star.get("charted",false) else "Uncharted star"
				draw_string(font,point(star)+Vector2(14,-14),title,HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("e6e8e4"))

		var reach: float = campaign.commerce.drive_range()
		var arc := PackedVector2Array()
		var origin_pc: Vector2 = Galaxy.position(current)
		for i: int in range(129):
			var pc: Vector2 = origin_pc+Vector2(cos(i*TAU/128),sin(i*TAU/128))*reach
			if in_front(pc): arc.append(project(pc))
		if arc.size() > 1: draw_polyline(arc,Color("cfb968"),1.3,true)
		if reach*36*magnification > 40: draw_string(font,project(origin_pc+Vector2(0,-reach))+Vector2(0,-12),"%d pc" % int(reach),HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("e7d18b"))

		draw_colored_polygon(PackedVector2Array([origin+Vector2(0,-9),origin+Vector2(-5,7),origin+Vector2(0,4),origin+Vector2(5,7)]),Color("f9e5a2"))
		var target: Dictionary = campaign.sector.system_by_id(selected_id)
		if not target.is_empty() and in_front(Galaxy.position(target)) and campaign.sector.is_revealed(selected_id) and magnification > 0.3:
			var at: Vector2 = point(target)
			draw_arc(at,13,0.3,2.7,20,Color("e9d99c"),2,true)
			draw_arc(at,13,3.45,5.85,20,Color("e9d99c"),2,true)
			if selected_id != current.id:
				var offer: Dictionary = campaign.quote(preload("res://scripts/expedition_session.gd").local_id(target.planets[0]))
				var allowed: bool = offer.reason.is_empty()
				if allowed: draw_dashed_line(origin,at,Color(0.85,0.79,0.53,0.6),1,6,true)
				draw_string(font,at+Vector2(14,24),"%.1f pc · %d energy" % [offer.distance,offer.energy],HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("c9d2d6"))
		if campaign.traveling():
			var ship: Dictionary = campaign.sector.state.flagship
			var fraction: float = travel_fraction
			var at: Vector2 = origin.lerp(point(campaign.sector.system_by_id(ship.destination)),fraction)
			draw_line(origin,at,Color("ecca77"),2,true); draw_circle(at,5,Color("fff0c2"))
		draw_ms = (Time.get_ticks_usec()-draw_start)/1000.0
	func nearest(at: Vector2) -> String:
		var result: String = ""; var best: float = 18
		for star: Dictionary in campaign.sector.state.systems:
			if not campaign.sector.is_revealed(star.id) or not in_front(Galaxy.position(star)): continue
			var d: float = point(star).distance_to(at)
			if d < best: best = d; result = star.id
		return result
	func _gui_input(event: InputEvent) -> void:
		if campaign == null: return
		if event is InputEventMouseMotion:
			if dragging:
				yaw = wrapf(yaw-event.relative.x*0.006,-PI,PI)
				pitch = wrapf(pitch+event.relative.y*0.006,-PI,PI)
				accept_event()
			elif panning: pan += event.relative; accept_event()
			else:
				hovered = nearest(event.position)
				tooltip_text = "" if hovered.is_empty() else "Click to select · click selected star again to travel or enter its system"
			queue_redraw(); return
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				dragging = event.pressed and not event.shift_pressed; panning = event.pressed and event.shift_pressed; accept_event(); return
			if event.button_index == MOUSE_BUTTON_MIDDLE: panning = event.pressed; accept_event(); return
			if event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
				zoom_at(-1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1,event.position); accept_event(); return
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not campaign.traveling():
				var id: String = nearest(event.position)
				if not id.is_empty():
					if selected_id == id: activated.emit(id)
					else: selected.emit(id)
					accept_event()

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

func icon_button(id: String, hint: String, action: Callable) -> Button:
	var result: Button = button("",action)
	result.custom_minimum_size = Vector2(48,48)
	UI.instrument(result,id,UI.NAV); result.tooltip_text = hint
	return result

func _ready() -> void:
	var stage: Control = Stage.create(self)
	var header: HBoxContainer = Stage.header(stage)
	heading = label("GALAXY",24)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(heading)
	close = button("Close [G / Esc]",func() -> void: close_requested.emit())
	header.add_child(close)
	graph = StarGraph.new()
	graph.selected.connect(select_system)
	graph.activated.connect(activate_system)
	Stage.world(stage,graph)
	var side: VBoxContainer = Stage.sidebar(stage,360)
	var destination_plate := StyleBoxFlat.new()
	destination_plate.bg_color = Color("11171a")
	destination_plate.border_color = Color("c9c2ad")
	destination_plate.set_border_width_all(1)
	destination_plate.set_corner_radius_all(0)
	destination_plate.set_content_margin_all(16)
	side.get_parent().add_theme_stylebox_override("panel",destination_plate)
	var destination_heading: Label = label("SYSTEM DESTINATIONS",13)
	destination_heading.add_theme_color_override("font_color",Color("d7c99e"))
	side.add_child(destination_heading)
	worlds = VBoxContainer.new()
	side.add_child(worlds)
	inspect_system = button("View system",func() -> void: system_requested.emit(selected_system))
	UI.instrument(inspect_system,"system_view",UI.NAV)
	inspect_system.text = ""; inspect_system.custom_minimum_size = Vector2(48,48)
	header.add_child(inspect_system); header.move_child(inspect_system,1)
	details = label("")
	details.custom_minimum_size = Vector2(320,100)
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.add_theme_color_override("font_color",Color("e4e5df"))
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
	var footer: HBoxContainer = Stage.footer(stage)
	footer.add_child(icon_button("zoom_out","Zoom out",func() -> void: graph.zoom_at(1,graph.view_center())))
	footer.add_child(icon_button("zoom_in","Zoom in",func() -> void: graph.zoom_at(-1,graph.view_center())))
	footer.add_child(icon_button("ascend","Focus ship [Home]",graph.reset_view))
	footer.add_child(icon_button("systems","Frame galaxy [End]",graph.overview))
	footer.add_child(label("Wheel: zoom · Right-drag: orbit · Shift + drag: pan · Click star twice: travel",15))
	var hint := Label.new(); hint.name = "GalaxyHint"; stage.add_child(hint)
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT); hint.offset_left = 32; hint.offset_top = -108; hint.offset_right = 1250; hint.offset_bottom = -82
	hint.add_theme_font_size_override("font_size",17)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()

func present(session: RefCounted) -> void:
	campaign = session
	graph.campaign = session
	if graph.dust == null: graph.make_dust()
	graph.reset_view()
	graph.cache_stars()
	select_system(campaign.sector.state.flagship.destination if campaign.traveling() else campaign.sector.state.flagship.system)
	show()

func activate_system(id: String) -> void:
	if campaign.traveling(): return
	if id == campaign.sector.state.flagship.system: system_requested.emit(id); return
	var pid: String = Session.local_id(campaign.sector.system_by_id(id).planets[0])
	if campaign.quote(pid).reason.is_empty(): travel_requested.emit(pid)

func key(code: Key) -> bool:
	match code:
		KEY_ENTER, KEY_KP_ENTER: activate_system(selected_system)
		KEY_HOME: graph.reset_view()
		KEY_END: graph.overview()
		KEY_LEFT, KEY_KP_4: graph.yaw -= 0.1
		KEY_RIGHT, KEY_KP_6: graph.yaw += 0.1
		KEY_UP, KEY_KP_8: graph.pitch += 0.1
		KEY_DOWN, KEY_KP_2: graph.pitch -= 0.1
		KEY_KP_ADD: graph.zoom_at(-1,graph.view_center())
		KEY_KP_SUBTRACT: graph.zoom_at(1,graph.view_center())
		_: return false
	graph.queue_redraw(); return true

func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or not event is InputEventKey or not event.pressed: return
	if key(event.keycode): get_viewport().set_input_as_handled()

func select_system(id: String) -> void:
	selected_system = id
	graph.selected_id = id
	for child: Node in worlds.get_children(): worlds.remove_child(child); child.queue_free()
	var system: Dictionary = campaign.sector.system_by_id(id)
	heading.text = "GALAXY  /  "+ (system.name.to_upper() if system.visited or system.get("charted",false) else "UNCHARTED SIGNAL")
	selected_planet = Session.local_id(system.planets[0])
	for pid: String in system.planets:
		var world: String = Session.local_id(pid)
		if not system.visited and not system.get("charted",false) and pid != system.planets[0]: continue
		var title: String = Geography.definition(world).name if system.visited or system.get("charted",false) else "Approach first orbital body"
		var item: Button = button(title,func() -> void: selected_planet = world; refresh())
		item.icon = UI.icon("planet_map")
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
	get_node("NavigationStage/GalaxyHint").text = ("In transit · %d s" % campaign.sector.state.flagship.remaining) if campaign.traveling() else (offer.reason if not offer.reason.is_empty() else "Click selected star again · %d energy" % offer.energy)
	graph.queue_redraw()
