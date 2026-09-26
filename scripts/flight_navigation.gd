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
var water_center := Vector2.ZERO
var water_area: int = 0

func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = "Local chart · 125 m across. The scale bar marks 50 m. Click a contact to approach with the selected tool, or open ground to fly. North is up."

func set_terrain(height_at: Callable, extent: float = FIELD_RADIUS) -> void:
	height_sampler = height_at
	surface_extent = maxf(8.0, extent)
	_rebuild_terrain()

func recenter_surface(at: Vector2) -> void:
	if orbital or not at.is_finite(): return
	# Keep the chart anchored until the scout leaves its visible 125 m square.
	# This keeps contacts steady while they are in view, then brings the scout
	# back to the center when crossing the chart edge.
	var half_width: float = surface_extent
	if absf(at.x-surface_center.x) <= half_width and absf(at.y-surface_center.y) <= half_width:
		return
	surface_center = at
	_rebuild_terrain()

func _rebuild_terrain() -> void:
	if not height_sampler.is_valid(): return
	var img := Image.create(96,96,false,Image.FORMAT_RGBA8)
	var elevations := PackedFloat32Array()
	elevations.resize(96*96)
	water_center = Vector2.ZERO
	water_area = 0
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
	_find_largest_water_body(elevations)
	for y: int in range(96):
		for x: int in range(96):
			var h: float = elevations[y*96+x]
			var color: Color
			var relief: float = 0.0
			if h < -0.6:
				var water_depth: float = clampf((-h-0.6)/18.0,0,1)
				color = Color("397d72").lerp(Color("193a42"),water_depth)
			else:
				relief = clampf((h-lowest_land)/land_range,0,1)
				# Warm basin floors, olive uplands and pale high ridges make the
				# sampled relief read as landforms instead of a single flat fill.
				var upland_mix: float = _smooth_range(relief,0.0,0.58)
				var ridge_mix: float = _smooth_range(relief,0.52,1.0)
				color = Color("403c35").lerp(Color("a17850"),upland_mix)
				color = color.lerp(Color("e0bd83"),ridge_mix)
			# Shade opposite terrain slopes from adjacent real elevation samples.
			var left: float = elevations[y*96+maxi(0,x-1)]
			var right: float = elevations[y*96+mini(95,x+1)]
			var above: float = elevations[maxi(0,y-1)*96+x]
			var below: float = elevations[mini(95,y+1)*96+x]
			var slope_shade: float = clampf(((right-left)-(below-above))*0.085,-0.42,0.42)
			if slope_shade > 0.0: color = color.lightened(slope_shade)
			elif slope_shade < 0.0: color = color.darkened(-slope_shade)
			# A narrow shore tint and contours reinforce coast and ridge shape while
			# remaining derived entirely from the current terrain samples.
			if h >= -0.6 and h < 0.8: color = color.lerp(Color("d6bd8a"),0.34)
			if h >= -0.6 and fposmod(relief*7.0,1.0) < 0.045: color = color.darkened(0.30)
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

func _find_largest_water_body(elevations: PackedFloat32Array) -> void:
	# Label the largest contiguous sampled water shape, rather than assuming a
	# named lake sits at one fixed world coordinate as the chart recenters.
	var visited := PackedByteArray()
	visited.resize(96*96)
	var best_count: int = 0
	var best_sum := Vector2.ZERO
	for start: int in range(96*96):
		if visited[start] != 0 or elevations[start] >= -0.6: continue
		var queue := PackedInt32Array([start])
		visited[start] = 1
		var sum := Vector2.ZERO
		var count: int = 0
		var cursor: int = 0
		while cursor < queue.size():
			var cell: int = queue[cursor]
			cursor += 1
			var x: int = cell % 96
			var y: int = floori(float(cell)/96.0)
			sum += Vector2(float(x),float(y))
			count += 1
			for neighbor: int in [cell-1 if x > 0 else -1,cell+1 if x < 95 else -1,cell-96 if y > 0 else -1,cell+96 if y < 95 else -1]:
				if neighbor < 0 or visited[neighbor] != 0 or elevations[neighbor] >= -0.6: continue
				visited[neighbor] = 1
				queue.append(neighbor)
		if count > best_count:
			best_count = count
			best_sum = sum
	if best_count >= 3:
		water_area = best_count
		var centroid: Vector2 = best_sum/float(best_count)
		water_center = surface_center+((centroid/95.0)*2.0-Vector2.ONE)*surface_extent

func _smooth_range(value: float, low: float, high: float) -> float:
	var t: float = clampf((value-low)/maxf(high-low,0.0001),0.0,1.0)
	return t*t*(3.0-2.0*t)

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
	if not orbital and terrain != null and water_area >= 3:
		_draw_local_water()
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
	if navigating:
		var route_end: Vector2 = project(destination).clamp(rect.position+Vector2(2,2),rect.end-Vector2(2,2))
		draw_line(pos,route_end,Color("f0c972"),1.5,true)
		draw_arc(route_end,4,0,TAU,20,Color("ffdc8d"),1.5,true)
	var arrow := PackedVector2Array()
	for p: Vector2 in [Vector2(0,-7),Vector2(5,5),Vector2(0,2),Vector2(-5,5)]: arrow.append(pos+p.rotated(heading))
	draw_colored_polygon(arrow,Color("fff1cd"))
	draw_string(ThemeDB.fallback_font,Vector2(rect.get_center().x-4,rect.position.y+14),"N",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("e6e5d5"))
	var scale_width: float = _scale_width_pixels(rect) if not orbital else rect.size.x*0.4
	var scale_y: float = rect.end.y-9
	draw_line(Vector2(rect.end.x-scale_width-12,scale_y),Vector2(rect.end.x-12,scale_y),Color("e6e5d5"),1.5)
	draw_line(Vector2(rect.end.x-scale_width-12,scale_y-3),Vector2(rect.end.x-scale_width-12,scale_y+1),Color("e6e5d5"),1)
	draw_line(Vector2(rect.end.x-12,scale_y-3),Vector2(rect.end.x-12,scale_y+1),Color("e6e5d5"),1)
	draw_string(ThemeDB.fallback_font,Vector2(rect.end.x-48,scale_y-3),"50 m",HORIZONTAL_ALIGNMENT_LEFT,-1,9,Color("e6e5d5"))

func _draw_local_water() -> void:
	var label_at: Vector2 = project(water_center)+Vector2(7,-4)
	if chart_rect().has_point(label_at): _draw_map_label("WATER",label_at,Color("d2e4d8"))

func _scale_width_pixels(rect: Rect2) -> float:
	return 50.0/(surface_extent*2.0)*rect.size.x

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
