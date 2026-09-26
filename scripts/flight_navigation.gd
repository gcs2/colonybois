extends Control
## Bounded live chart, sampled from the same terrain function as the surface.
## Presentation only: all navigation goes back through the encounter commands.
signal destination_requested(at: Vector2)
signal target_requested(id: String)
signal landing_requested
var terrain: ImageTexture
var ship_at := Vector2.ZERO
var heading: float = 0.0
var points: Dictionary = {}
var surveyed: Array = []
var selected: String = ""
var orbital: bool = false
var navigating: bool = false
var destination := Vector2.ZERO
var planet_at := Vector2.ZERO
var wreck_at := Vector2.ZERO
var wreck_known: bool = false
var service_at := Vector2.ZERO
var guardian_at := Vector2.ZERO
var guardian_known: bool = false
var guardian_disabled: bool = false
var guardian_alert: int = 0
var locked: bool = false
## The local terrain window is a 125 m square centered on the ship.
const FIELD_RADIUS := 62.5
var surface_center := Vector2.ZERO
var surface_extent: float = FIELD_RADIUS
var height_sampler: Callable

func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = "Local chart · 125 m across. The scale bar marks 50 m. Click a contact to approach with the selected tool, or open ground to fly. North is up."

func set_terrain(height_at: Callable, extent: float = FIELD_RADIUS) -> void:
	height_sampler = height_at
	surface_extent = maxf(8.0, extent)
	_rebuild_terrain()

func recenter_surface(at: Vector2) -> void:
	if orbital or not at.is_finite(): return
	# Keep the authored landing area and its contacts in view while the scout is
	# inside the 125 m chart. Rebuild once it leaves that window, then hold the new
	# center until the next edge crossing instead of chasing the ship every frame.
	if absf(at.x-surface_center.x) <= surface_extent and absf(at.y-surface_center.y) <= surface_extent:
		return
	surface_center = at
	_rebuild_terrain()

func _rebuild_terrain() -> void:
	if not height_sampler.is_valid(): return
	var img := Image.create(96,96,false,Image.FORMAT_RGBA8)
	var elevations := PackedFloat32Array()
	elevations.resize(96*96)
	var lowest_land: float = INF
	var highest_land: float = -INF
	for y: int in range(96):
		for x: int in range(96):
			var height: float = height_sampler.call(surface_center.x+(float(x)/95*2-1)*surface_extent,surface_center.y+(float(y)/95*2-1)*surface_extent)
			elevations[y*96+x] = height
			if height >= -0.6:
				lowest_land = minf(lowest_land,height)
				highest_land = maxf(highest_land,height)
	var land_range: float = maxf(highest_land-lowest_land,1.0)
	for y: int in range(96):
		for x: int in range(96):
			var h: float = elevations[y*96+x]
			var color: Color
			var relief: float = 0.0
			if h < -0.6:
				var water_depth: float = clampf((-h-0.6)/18.0,0,1)
				color = Color("4d9c91").lerp(Color("173646"),water_depth)
			else:
				relief = clampf((h-lowest_land)/land_range,0,1)
				color = Color("485750").lerp(Color("a99a70"),relief)
			# Shade opposite terrain slopes from adjacent real elevation samples.
			var left: float = elevations[y*96+maxi(0,x-1)]
			var right: float = elevations[y*96+mini(95,x+1)]
			var above: float = elevations[maxi(0,y-1)*96+x]
			var below: float = elevations[mini(95,y+1)*96+x]
			var slope_shade: float = clampf(((right-left)-(below-above))*0.035,-0.22,0.22)
			if slope_shade > 0.0: color = color.lightened(slope_shade)
			elif slope_shade < 0.0: color = color.darkened(-slope_shade)
			# Contours use the sampled local relief range, so small expedition regions
			# still show landform shape even when their absolute elevation is narrow.
			if h >= -0.6 and fposmod(relief*7.0,1.0) < 0.045: color = color.darkened(0.16)
			img.set_pixel(x,y,color)
	terrain = ImageTexture.create_from_image(img)
	queue_redraw()

func chart_rect() -> Rect2:
	return Rect2(Vector2(6,6),size-Vector2(12,12))

func project(at: Vector2) -> Vector2:
	var rect: Rect2 = chart_rect()
	var extent: float = 90.0 if orbital else surface_extent
	var origin: Vector2 = Vector2.ZERO if orbital else surface_center
	return rect.position+((at-origin)/extent+Vector2.ONE)*0.5*rect.size

func unproject(at: Vector2) -> Vector2:
	var rect: Rect2 = chart_rect()
	var extent: float = 90.0 if orbital else surface_extent
	var origin: Vector2 = Vector2.ZERO if orbital else surface_center
	return origin+((at-rect.position)/rect.size*2-Vector2.ONE)*extent

func _gui_input(event: InputEvent) -> void:
	if not is_visible_in_tree(): return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		if locked or not chart_rect().has_point(event.position): return
		if event.position.distance_to(project(service_at)) < 9:
			target_requested.emit("service")
			return
		if orbital:
			var wreck_gap: float = event.position.distance_to(project(wreck_at)) if wreck_known else INF
			var guardian_gap: float = event.position.distance_to(project(guardian_at)) if guardian_known else INF
			if guardian_gap < 13 and guardian_gap < wreck_gap: target_requested.emit("guardian")
			elif wreck_gap < 15: target_requested.emit("wreck")
			elif event.position.distance_to(project(planet_at)) < 22: landing_requested.emit()
			else: destination_requested.emit(unproject(event.position))
			return
		var nearest: String = ""
		var gap: float = 12.0
		for id: String in points:
			var d: float = project(points[id]).distance_to(event.position)
			if d < gap: gap = d; nearest = id
		if not nearest.is_empty(): target_requested.emit(nearest)
		else: destination_requested.emit(unproject(event.position))

func _draw() -> void:
	var rect: Rect2 = chart_rect()
	draw_rect(rect,Color("0d202b"))
	draw_rect(rect,Color("7b887f"),false,1.0)
	if not orbital and terrain != null: draw_texture_rect(terrain,rect,false)
	else:
		draw_circle(project(planet_at),19,Color("69639b"))
		draw_arc(project(planet_at),24,0,TAU,48,Color("bbb4e5"),1,true)
		if wreck_known:
			var wreck: Vector2 = project(wreck_at)
			draw_arc(wreck,19.0/90.0*rect.size.x*0.5,0,TAU,48,Color("a975c4",0.7),1.5,true)
			draw_circle(wreck,4,Color("d7abe8"))
			draw_string(ThemeDB.fallback_font,wreck+Vector2(6,-5),"!",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("edb9db"))
		if guardian_known:
			var skiff: Vector2 = project(guardian_at)
			var skiff_color := Color("818793") if guardian_disabled else (Color("ef897f") if guardian_alert >= 3 else Color("eab77e"))
			draw_arc(skiff,7,0,TAU,24,skiff_color,2,true)
			draw_circle(skiff,3,skiff_color)
	if not orbital and terrain != null and _has_local_lake():
		_draw_local_lake()
	var center: Vector2 = rect.get_center()
	for fraction: float in [0.33,0.66]:
		var x: float = lerpf(rect.position.x,rect.end.x,fraction)
		var y: float = lerpf(rect.position.y,rect.end.y,fraction)
		draw_line(Vector2(x,rect.position.y),Vector2(x,rect.end.y),Color(0.45,0.77,0.78,0.13))
		draw_line(Vector2(rect.position.x,y),Vector2(rect.end.x,y),Color(0.45,0.77,0.78,0.13))
	if not orbital:
		for id: String in points:
			var p: Vector2 = project(points[id])
			if not rect.grow(-7).has_point(p): continue
			var known: bool = id in surveyed
			var color: Color = Color("8ad4a5") if known else Color("d9c6a7")
			if id == "relay":
				draw_arc(p,7,0,TAU,24,Color("7fd0bb",0.75),1.2,true)
				draw_line(p+Vector2(0,-5),p+Vector2(0,5),Color("c3efcf"),1.2)
				draw_line(p+Vector2(-4,0),p+Vector2(4,0),Color("c3efcf"),1.2)
			else:
				draw_circle(p,3.2,color)
				if not known: draw_circle(p,1.5,Color("27313b"))
			if id == selected: draw_arc(p,9,0,TAU,24,Color("f8cf77"),1.5,true)
			if id == "relay" or (known and id in ["vein","bed","pod","grazer"]):
				_draw_map_label(_point_name(id),p+Vector2(7,-4),Color("f5ead1"))
	var port: Vector2 = project(service_at)
	if rect.grow(-7).has_point(port):
		draw_polyline(PackedVector2Array([port+Vector2(0,-6),port+Vector2(6,0),port+Vector2(0,6),port+Vector2(-6,0),port+Vector2(0,-6)]),Color("91d7b2"),1.5,true)
		_draw_map_label("PORT",port+Vector2(7,12),Color("c2edd6"))
	var pos: Vector2 = project(ship_at)
	pos = pos.clamp(rect.position+Vector2(5,5),rect.end-Vector2(5,5))
	if navigating: draw_line(pos,project(destination).clamp(rect.position,rect.end),Color("f0c972"),1.5,true)
	var arrow := PackedVector2Array()
	for p: Vector2 in [Vector2(0,-7),Vector2(5,5),Vector2(0,2),Vector2(-5,5)]: arrow.append(pos+p.rotated(heading))
	draw_colored_polygon(arrow,Color("fff1cd"))
	draw_string(ThemeDB.fallback_font,Vector2(rect.get_center().x-4,rect.position.y+14),"N",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("e6e5d5"))
	var scale_width: float = rect.size.x*0.4
	var scale_y: float = rect.end.y-9
	draw_line(Vector2(rect.end.x-scale_width-12,scale_y),Vector2(rect.end.x-12,scale_y),Color("e6e5d5"),1.5)
	draw_string(ThemeDB.fallback_font,Vector2(rect.end.x-48,scale_y-3),"50 m",HORIZONTAL_ALIGNMENT_LEFT,-1,9,Color("e6e5d5"))

func _has_local_lake() -> bool:
	# Morrow's mapped lake sits below the surrounding basin surface. This keeps
	# surface water visible on the local chart without adding a system map here.
	return height_sampler.is_valid() and height_sampler.call(-23.0,0.0) < -0.6

func _draw_local_lake() -> void:
	var center_at := project(Vector2(-23.0,0.0))
	var map_center: Vector2 = chart_rect().get_center()
	# Water is rasterized from the same sampled height map as land. The lake is
	# near the chart rim, so a separately clipped polygon could fold at the edge.
	var lake_label_at: Vector2 = center_at+Vector2(17,-3)
	if chart_rect().has_point(lake_label_at):
		_draw_map_label("LAKE",lake_label_at,Color("d2e4d8"))

func _point_name(id: String) -> String:
	return {"relay":"RELAY","vein":"GLASS","bed":"BED","pod":"PODS","grazer":"GRAZER"}.get(id,id.to_upper())

func _draw_map_label(text: String, at: Vector2, color: Color) -> void:
	var baseline := at
	# Keep captions inside the chart edge when a contact is near the rim.
	if baseline.x > size.x-58: baseline.x -= 64
	if baseline.y < 16: baseline.y = 16
	if baseline.y > size.y-5: baseline.y = size.y-5
	var font: Font = ThemeDB.fallback_font
	var label_size: Vector2 = font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,9)
	var label_rect := Rect2(baseline+Vector2(-3,-10),label_size+Vector2(6,13))
	label_rect.position.x = clampf(label_rect.position.x,chart_rect().position.x+2,chart_rect().end.x-label_rect.size.x-2)
	label_rect.position.y = clampf(label_rect.position.y,chart_rect().position.y+2,chart_rect().end.y-label_rect.size.y-2)
	draw_rect(label_rect,Color("10191d",0.88))
	draw_string(font,baseline+Vector2(1,1),text,HORIZONTAL_ALIGNMENT_LEFT,-1,9,Color("101719",0.95))
	draw_string(font,baseline,text,HORIZONTAL_ALIGNMENT_LEFT,-1,9,color)
