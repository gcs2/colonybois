extends Control
## Dedicated Field Instruments status pod displayed during communications and dock services.
const FONT = preload("res://assets/fonts/Barlow-Regular.ttf")
const MARK = preload("res://assets/ui/mark-symbol.svg")
const IVORY := Color("dedad0")
const IVORY_SHADOW := Color("8d8c80")
const CHARCOAL := Color("1c2426")
const HULL_TINT := Color("dd8565")
const ENERGY_TINT := Color("dca842")
const EMPTY_TINT := Color("141c1e")

var hull_val: int = 100
var max_hull_val: int = 100
var energy_val: int = 100
var max_energy_val: int = 100
var marks_val: int = 0

func _ready() -> void:
	custom_minimum_size = Vector2(460, 76)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func update_status(h: int, mh: int, e: int, me: int, m: int) -> void:
	hull_val = h
	max_hull_val = maxi(1, mh)
	energy_val = e
	max_energy_val = maxi(1, me)
	marks_val = m
	queue_redraw()

func _draw() -> void:
	# Subtle drop shadow
	draw_rect(Rect2(Vector2(2, 4), size), Color(0, 0, 0, 0.35))
	# Matte ivory face plate with rounded/chamfered corners
	var r := Rect2(Vector2.ZERO, size)
	draw_rect(r, Color("6e6c60"))
	draw_rect(Rect2(Vector2(1, 1), size - Vector2(2, 2)), IVORY)
	draw_line(Vector2(2, 2), Vector2(size.x - 2, 2), Color("fbf9f2"), 1.0)
	draw_line(Vector2(2, size.y - 2), Vector2(size.x - 2, size.y - 2), IVORY_SHADOW, 1.0)

	# Corner rivets
	for p: Vector2 in [Vector2(8, 8), Vector2(size.x - 8, 8), Vector2(8, size.y - 8), Vector2(size.x - 8, size.y - 8)]:
		draw_circle(p, 2.5, Color("807e72"))
		draw_line(p - Vector2(1, 1), p + Vector2(1, 1), Color("343630"), 1.0)

	# Hull row
	draw_string(FONT, Vector2(24, 30), "HULL", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, CHARCOAL)
	var hull_recess := Rect2(88, 16, 136, 18)
	draw_rect(hull_recess, Color("0f1516"))
	draw_rect(Rect2(hull_recess.position + Vector2(1, 1), hull_recess.size - Vector2(2, 2)), Color("182022"))
	var hull_pct: float = clampf(float(hull_val) / float(max_hull_val), 0.0, 1.0)
	var hull_bars: int = int(round(hull_pct * 10.0))
	for i: int in range(10):
		var bar_rect := Rect2(92 + i * 13, 19, 9, 12)
		draw_rect(bar_rect, HULL_TINT if i < hull_bars else EMPTY_TINT)
	draw_string(FONT, Vector2(232, 30), "%d%%" % int(hull_pct * 100.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, CHARCOAL)

	# Energy row
	draw_string(FONT, Vector2(24, 56), "ENERGY", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, CHARCOAL)
	var energy_recess := Rect2(88, 42, 136, 18)
	draw_rect(energy_recess, Color("0f1516"))
	draw_rect(Rect2(energy_recess.position + Vector2(1, 1), energy_recess.size - Vector2(2, 2)), Color("182022"))
	var energy_pct: float = clampf(float(energy_val) / float(max_energy_val), 0.0, 1.0)
	var energy_bars: int = int(round(energy_pct * 10.0))
	for i: int in range(10):
		var bar_rect := Rect2(92 + i * 13, 45, 9, 12)
		draw_rect(bar_rect, ENERGY_TINT if i < energy_bars else EMPTY_TINT)
	draw_string(FONT, Vector2(232, 56), "%d%%" % int(energy_pct * 100.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, CHARCOAL)

	# Marks section on the right
	var marks_str: String = "%s Marks" % _format_number(marks_val)
	var str_size: Vector2 = FONT.get_string_size(marks_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
	var mark_x: float = size.x - 24 - str_size.x
	draw_string(FONT, Vector2(mark_x, 44), marks_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, CHARCOAL)
	if MARK != null:
		draw_texture_rect(MARK, Rect2(mark_x - 22, 28, 18, 18), false, Color("9a7a30"))

func _format_number(n: int) -> String:
	var s: String = str(n)
	var res: String = ""
	var count: int = 0
	for i: int in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			res = "," + res
		res = s[i] + res
		count += 1
	return res