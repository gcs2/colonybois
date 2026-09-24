extends Control
## Read-only instrument; climate commands remain on mouse-selected ship tools.
var values: Dictionary = {"temperature":50.0,"atmosphere":50.0,"project":{}}
var tier: int = 3
var font: Font = ThemeDB.fallback_font
func _ready() -> void:
	custom_minimum_size = Vector2(266,266); mouse_filter = Control.MOUSE_FILTER_IGNORE
func present(current: Dictionary, score: int) -> void:
	values = current; tier = score; queue_redraw()
func _draw() -> void:
	draw_rect(Rect2(0,0,266,266),Color(0.025,0.05,0.08,0.88))
	var center := Vector2(133,130)
	draw_line(Vector2(33,130),Vector2(233,130),Color("526976"),1)
	draw_line(Vector2(133,30),Vector2(133,230),Color("526976"),1)
	var radii: Array = [80.0,54.0,28.0]
	var colors: Array = [Color("b88269"),Color("b8aa77"),Color("91c5a6")]
	for i: int in range(3): draw_arc(center,radii[i],0,TAU,64,colors[i],1.4,true)
	var marker := Vector2(33+float(values.temperature)*2,230-float(values.atmosphere)*2)
	draw_circle(marker,5,Color("f3cf83"))
	draw_arc(marker,8,0,TAU,24,Color("e9efe5"),1,true)
	draw_string(font,Vector2(12,20),"T%d CLIMATE" % tier,HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("e9efe5"))
	draw_string(font,Vector2(145,20),"ATMOSPHERE ↑",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("9bb9df"))
	draw_string(font,Vector2(35,249),"COLD     TEMPERATURE     HOT",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("d5baa3"))
	if not values.project.is_empty(): draw_string(font,Vector2(178,263),"%d s" % values.project.remaining,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("f3cf83"))
