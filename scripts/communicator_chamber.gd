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
	# Perspective side walls
	draw_colored_polygon(PackedVector2Array([Vector2(1,1),Vector2(w*0.14,28),Vector2(w*0.14,h-32),Vector2(1,h-1)]),Color("354344"))
	draw_colored_polygon(PackedVector2Array([Vector2(w-1,1),Vector2(w*0.86,28),Vector2(w*0.86,h-32),Vector2(w-1,h-1)]),Color("263438"))
	# Vertical mullions and indicator accents
	for x: float in [w*0.08, w*0.89]:
		draw_rect(Rect2(x, 24, 7, h-58), Color("0c1317"))
		draw_rect(Rect2(x+2, 36, 3, h*0.22), Color("929e91"))
	# Horizontal wall panel seams
	for y: float in [h*0.25, h*0.48, h*0.70]:
		draw_line(Vector2(w*0.14, y), Vector2(w*0.86, y), Color("344446"), 1.5, true)
	# Overhead warm lighting fixture
	draw_rect(Rect2(w*0.28, 8, w*0.44, 5), Color("d2b58c"))
	draw_line(Vector2(w*0.28, 13), Vector2(w*0.72, 13), Color(0.9, 0.8, 0.6, 0.35), 1.0, true)
	# Lower desk / console ledge in foreground
	draw_rect(Rect2(1, h-62, w-2, 58), Color("303b3d"))
	draw_colored_polygon(PackedVector2Array([Vector2(8, h-60), Vector2(w-8, h-60), Vector2(w-24, h-34), Vector2(24, h-34)]), Color("465251"))
	draw_line(Vector2(24, h-34), Vector2(w-24, h-34), Color("77827b"), 1.0, true)
