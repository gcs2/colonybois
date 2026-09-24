extends Control
## Original, resolution-independent field-instrument casing. No simulation state.
const IVORY := Color("dedad0")
const IVORY_DARK := Color("c2bcb0")
const IVORY_SHADOW := Color("858376")
const CHARCOAL := Color("1c2426")
const SCREEN_RIM := Color("0d1314")
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
func outline(rect: Rect2, cut: float) -> PackedVector2Array:
	var p := rect.position
	var e := rect.end
	return PackedVector2Array([p+Vector2(cut,0),Vector2(e.x-cut,p.y),Vector2(e.x,p.y+cut),e-Vector2(0,cut),e-Vector2(cut,0),Vector2(p.x+cut,e.y),Vector2(p.x,e.y-cut),p+Vector2(0,cut)])
func plate(rect: Rect2, cut: float, fill: Color, edge: Color) -> void:
	var points := outline(rect,cut)
	draw_colored_polygon(points,fill)
	points.append(points[0]); draw_polyline(points,edge,1.0,true)
func _draw() -> void:
	# Subtle drop shadow
	plate(Rect2(Vector2(0,8),size),20,Color(0,0,0,0.40),Color(0,0,0,0.25))
	# Outer base bezel plate with chamfered corners
	plate(Rect2(Vector2.ZERO,size),20,Color("5c5a4f"),Color("1a1c18"))
	# Matte ivory casing face
	plate(Rect2(Vector2(2,2),size-Vector2(4,5)),18,IVORY,Color("fbf8ee"))
	# Bevel shadow on bottom edge of ivory plate
	draw_line(Vector2(20,size.y-3),Vector2(size.x-20,size.y-3),IVORY_SHADOW,1.5,true)
	draw_line(Vector2(size.x-3,20),Vector2(size.x-3,size.y-20),IVORY_SHADOW,1.5,true)
	# Recessed screen frame and display well
	plate(Rect2(Vector2(18,36),size-Vector2(36,54)),10,SCREEN_RIM,Color("4a5250"))
	plate(Rect2(Vector2(20,38),size-Vector2(40,58)),8,CHARCOAL,Color("2d3738"))
	# Continuous display: thin dark structural seam between portrait and interaction
	draw_rect(Rect2(366,39,3,size.y-60),Color("111617"))
	draw_line(Vector2(369,40),Vector2(369,size.y-22),Color("323d3e"),1.0,true)
	# Top right molded close button bezel fixture
	plate(Rect2(Vector2(size.x-54,6),Vector2(36,26)),5,Color("182022"),Color("4a5658"))
	# Bottom right molded foot for Goodbye button
	var foot := PackedVector2Array([Vector2(size.x-175,size.y-18),Vector2(size.x-154,size.y-54),Vector2(size.x-20,size.y-54),Vector2(size.x-20,size.y-18)])
	draw_colored_polygon(foot,IVORY)
	draw_polyline(foot,Color("f4efe2"),1.0,true)
	draw_line(Vector2(size.x-175,size.y-18),Vector2(size.x-20,size.y-18),IVORY_SHADOW,1.5,true)
	# Corner fastener screws
	for p: Vector2 in [Vector2(14,24),Vector2(size.x-14,24),Vector2(14,size.y-24),Vector2(size.x-14,size.y-24)]:
		draw_circle(p,3.2,Color("767468"))
		draw_circle(p,2.4,Color("9a988b"))
		draw_line(p-Vector2(1.2,1.2),p+Vector2(1.2,1.2),Color("343b32"),1.0,true)
	# Speaker / ventilation slits in bottom left
	for i: int in range(5):
		var x: float = 34+i*6
		draw_line(Vector2(x,size.y-12),Vector2(x+3,size.y-8),Color("8b897b"),1.2,true)
	# Functional casing seam
	for x: float in [size.x*0.38,size.x-68]:
		draw_line(Vector2(x,2),Vector2(x,18),Color("8b887b"),1.0,true)
