extends Control
## Original, resolution-independent field-instrument casing. No simulation state.
const IVORY := Color("d6cfbc")
const CHARCOAL := Color("222525")
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
	plate(Rect2(Vector2(0,8),size),20,Color(0,0,0,0.45),Color(0,0,0,0.3))
	plate(Rect2(Vector2.ZERO,size),20,Color("777568"),Color("181b18"))
	plate(Rect2(Vector2(2,2),size-Vector2(4,7)),18,IVORY,Color("f2ecdc"))
	plate(Rect2(Vector2(19,43),size-Vector2(38,65)),10,Color("111515"),Color("70736d"))
	plate(Rect2(Vector2(22,46),size-Vector2(44,71)),8,CHARCOAL,Color("424746"))
	draw_rect(Rect2(374,44,10,size.y-68),IVORY)
	draw_line(Vector2(374,44),Vector2(374,size.y-24),Color("efeadc"),1,true)
	draw_line(Vector2(384,44),Vector2(384,size.y-24),Color("858679"),2,true)
	var foot := PackedVector2Array([Vector2(size.x-218,size.y-22),Vector2(size.x-191,size.y-58),Vector2(size.x-22,size.y-58),Vector2(size.x-22,size.y-22)])
	draw_colored_polygon(foot,IVORY)
	# A housing join and functional edge catches, deliberately sparse.
	for x: float in [size.x*0.40,size.x-72]:
		draw_line(Vector2(x,3),Vector2(x,24),Color("8b887b"),1,true)
	for p: Vector2 in [Vector2(12,31),Vector2(size.x-12,31),Vector2(12,size.y-32),Vector2(size.x-12,size.y-32)]:
		draw_circle(p,2.3,Color("8a897b"),true,-1,true)
		draw_line(p-Vector2(1,1),p+Vector2(1,1),Color("343b32"),1,true)
	for i: int in range(5):
		var x: float = 35+i*6
		draw_line(Vector2(x,size.y-14),Vector2(x+3,size.y-10),Color("979586"),1,true)
	draw_line(Vector2(size.x-172,size.y-12),Vector2(size.x-42,size.y-12),Color("aaa491"),1,true)
