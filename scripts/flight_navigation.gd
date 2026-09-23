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
const FIELD_RADIUS := 40.0

func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = "Local chart · click a contact to approach with the selected tool, or open ground to fly. North is up."

func set_terrain(height_at: Callable) -> void:
	var img := Image.create(96,96,false,Image.FORMAT_RGBA8)
	for y: int in range(96):
		for x: int in range(96):
			var h: float = height_at.call((float(x)/95*2-1)*FIELD_RADIUS,(float(y)/95*2-1)*FIELD_RADIUS)
			var color: Color = Color("202d39").lerp(Color("6c7770"),clampf((h+3)/8,0,1))
			if fposmod(h,0.75) < 0.08: color = color.lightened(0.15)
			if Vector2(x-47.5,y-47.5).length() > 47.0: color.a = 0
			img.set_pixel(x,y,color)
	terrain = ImageTexture.create_from_image(img)
	queue_redraw()

func chart_rect() -> Rect2:
	return Rect2(Vector2(6,6),size-Vector2(12,12))

func project(at: Vector2) -> Vector2:
	var rect: Rect2 = chart_rect()
	var extent: float = 90.0 if orbital else FIELD_RADIUS
	return rect.position+(at/extent+Vector2.ONE)*0.5*rect.size

func unproject(at: Vector2) -> Vector2:
	var rect: Rect2 = chart_rect()
	return ((at-rect.position)/rect.size*2-Vector2.ONE)*(90.0 if orbital else FIELD_RADIUS)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		if locked or event.position.distance_to(size*0.5) > size.x*0.5-6: return
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
	draw_circle(size*0.5,size.x*0.5-5,Color("0d202b"))
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
	var center: Vector2 = size*0.5
	var radius: float = size.x*0.5-7
	for ring: float in [0.33,0.66,1.0]: draw_arc(center,radius*ring,0,TAU,64,Color(0.45,0.77,0.78,0.16),1,true)
	draw_line(center-Vector2(radius,0),center+Vector2(radius,0),Color(0.45,0.77,0.78,0.16))
	draw_line(center-Vector2(0,radius),center+Vector2(0,radius),Color(0.45,0.77,0.78,0.16))
	if not orbital:
		for id: String in points:
			var p: Vector2 = project(points[id])
			var known: bool = id in surveyed
			var color: Color = Color("8ad4a5") if known else Color("d9c6a7")
			if id == selected: draw_arc(p,8,0,TAU,24,Color("f8cf77"),1.5,true)
			draw_circle(p,3,color)
			if not known: draw_circle(p,1.5,Color("27313b"))
	var port: Vector2 = project(service_at)
	draw_polyline(PackedVector2Array([port+Vector2(0,-6),port+Vector2(6,0),port+Vector2(0,6),port+Vector2(-6,0),port+Vector2(0,-6)]),Color("91d7b2"),1.5,true)
	var pos: Vector2 = project(ship_at)
	pos = pos.clamp(rect.position+Vector2(5,5),rect.end-Vector2(5,5))
	if navigating: draw_line(pos,project(destination).clamp(rect.position,rect.end),Color("f0c972"),1.5,true)
	var arrow := PackedVector2Array()
	for p: Vector2 in [Vector2(0,-7),Vector2(5,5),Vector2(0,2),Vector2(-5,5)]: arrow.append(pos+p.rotated(heading))
	draw_colored_polygon(arrow,Color("fff1cd"))
	draw_string(ThemeDB.fallback_font,Vector2(size.x*0.5-4,17),"N",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("c1c9cf"))
