extends PanelContainer
## A quiet transmission alcove behind the existing portrait, not a new character.
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color("191d1d")
	style.set_content_margin_all(12)
	style.set_border_width_all(1)
	style.border_color = Color("606866")
	add_theme_stylebox_override("panel",style)
	resized.connect(queue_redraw)
func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	draw_colored_polygon(PackedVector2Array([Vector2(1,1),Vector2(27,20),Vector2(27,h-20),Vector2(1,h-1)]),Color("303737"))
	draw_colored_polygon(PackedVector2Array([Vector2(w-1,1),Vector2(w-27,20),Vector2(w-27,h-20),Vector2(w-1,h-1)]),Color("272d2d"))
	for x: float in [12,w-16]:
		draw_rect(Rect2(x,24,4,h-48),Color("111616"))
		draw_rect(Rect2(x+1,32,2,h*.20),Color("b0b5a7"))
	for y: float in [h*.24,h*.48,h*.72]:
		draw_line(Vector2(27,y),Vector2(w-27,y),Color("282f2f"),1,true)
	draw_rect(Rect2(12,h-34,w-24,22),Color("373c3b"))
	draw_line(Vector2(12,h-34),Vector2(w-12,h-34),Color("666b65"),1,true)
