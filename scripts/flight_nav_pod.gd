extends Control
## Field Instruments Navigation / Altitude Pod.
## Displays altitude horizon dial in orbit, and frames the local terrain chart on planet surfaces.
const FONT = preload("res://assets/fonts/Barlow-Regular.ttf")
const InstrumentFrame = preload("res://scripts/flight_instrument_frame.gd")
const IVORY := Color("dedad0")
const IVORY_SHADOW := Color("8d8c80")
const CHARCOAL := Color("1c2426")
const DIAL_BG := Color("0e1518")
const NEEDLE_COLOR := Color("f3c567")
const RIM_GLOW := Color("6db5e8", 0.7)
const CHART_RAIL_X := 228.0

var orbital: bool = false
var altitude_text: String = "420 km"
var needle_angle: float = -1.75 # Pointing ~11:30 o'clock

func _ready() -> void:
	custom_minimum_size = Vector2(250, 130)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_text = "Local chart · 50 m across. Click a contact to approach with the selected tool."
	resized.connect(queue_redraw)


func set_mode(is_orbit: bool, alt_str: String = "", angle: float = -1.9) -> void:
	orbital = is_orbit
	if not alt_str.is_empty():
		altitude_text = alt_str
	needle_angle = angle
	queue_redraw()

func _draw() -> void:
	InstrumentFrame.draw_frame(self, Rect2(Vector2.ZERO, size), 14.0)
	draw_line(Vector2(CHART_RAIL_X, 9), Vector2(CHART_RAIL_X, size.y - 9), IVORY_SHADOW, 1.0)
	draw_line(Vector2(CHART_RAIL_X + 2, 9), Vector2(CHART_RAIL_X + 2, size.y - 9), Color("f6f2e8"), 1.0)
	if not orbital:
		return

	# Circular instrument dial on the left
	var center := Vector2(68, size.y * 0.5)
	var radius: float = 46.0

	draw_circle(center, radius + 2.0, Color("1c2426"))
	draw_circle(center, radius, DIAL_BG)
	draw_arc(center, radius - 1.0, 0, TAU, 48, Color(0.4, 0.55, 0.6, 0.2), 1.0)

	if orbital:
		# Tick marks on the upper arc
		for i: int in range(9):
			var a: float = -PI * 0.75 + float(i) * (PI * 0.95 / 8.0)
			var p1: Vector2 = center + Vector2.RIGHT.rotated(a) * (radius - 2.0)
			var p2: Vector2 = center + Vector2.RIGHT.rotated(a) * (radius - 6.0)
			draw_line(p1, p2, Color("c2cbcf"), 1.0)

		# Planet crescent / horizon in the lower section
		var planet_c := center + Vector2(0, 16)
		var pr: float = 40.0
		var planet_pts := PackedVector2Array()
		for i: int in range(25):
			var a: float = PI * 0.05 + float(i) * (PI * 0.9 / 24.0)
			planet_pts.append(planet_c + Vector2.RIGHT.rotated(a) * pr)
		planet_pts.append(center + Vector2(radius, 0))
		planet_pts.append(center + Vector2(radius, radius))
		planet_pts.append(center + Vector2(-radius, radius))
		planet_pts.append(center + Vector2(-radius, 0))
		# Clip by drawing arc and subtle fill
		draw_circle(planet_c, pr - 1.0, Color("162430"))
		draw_arc(planet_c, pr, PI * 0.05, PI * 0.95, 32, RIM_GLOW, 1.8)

		# Yellow horizon needle
		var needle_tip: Vector2 = center + Vector2.RIGHT.rotated(needle_angle) * (radius - 8.0)
		draw_line(center, needle_tip, NEEDLE_COLOR, 2.5)
		draw_circle(center, 4.0, Color("1c2426"))
		draw_circle(center, 2.0, NEEDLE_COLOR)

		# Right side: Altitude readout
		draw_string(FONT, Vector2(130, size.y * 0.5 - 6), "ALT", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("58646b"))
		draw_string(FONT, Vector2(130, size.y * 0.5 + 20), altitude_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, CHARCOAL)
	else:
		# The live terrain chart overlays this surface pod. Its title and range are
		# mounted above the map, so no dial markings intrude on the chart edge.
		pass
