extends Control
## Field Instruments Consolidated Console Pod.
## Displays segmented HULL and ENERGY meters, category sockets with active LED indicators,
## active comms / signal state, and the Marks treasury balance.
const FONT = preload("res://assets/fonts/Barlow-Regular.ttf")
const MARK = preload("res://assets/ui/mark-symbol.svg")
const SIGNAL_ICON = preload("res://assets/ui/flight/signal.svg")
const IVORY := Color("dedad0")
const IVORY_SHADOW := Color("8d8c80")
const CHARCOAL := Color("1c2426")
const HULL_TINT := Color("dd8565")
const ENERGY_TINT := Color("dca842")
const EMPTY_TINT := Color("141c1e")
const SOCKET_BG := Color("141b1d")
const SOCKET_BORDER := Color("253238")
const ACTIVE_GOLD := Color("f3c567")
const SIGNAL_GREEN := Color("5ce09e")

var orbital: bool = false
var hull_val: int = 100
var max_hull_val: int = 100
var energy_val: int = 100
var max_energy_val: int = 100
var marks_val: int = 1240
var active_group: String = "Main tools"
var groups: Array[String] = ["Main tools", "Environment", "Weapons", "Inventory"]

func _ready() -> void:
	# The same pod is assigned a compact surface footprint and a wider orbital
	# footprint by FlightHUD; a fixed minimum silently defeated the compact size.
	custom_minimum_size = Vector2.ZERO
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func update_status(h: int, mh: int, e: int, me: int, m: int, grp: String = "") -> void:
	hull_val = h
	max_hull_val = maxi(1, mh)
	energy_val = e
	max_energy_val = maxi(1, me)
	marks_val = m
	if not grp.is_empty():
		active_group = grp
	queue_redraw()

func set_orbital(is_orbit: bool) -> void:
	orbital = is_orbit
	queue_redraw()

func _draw() -> void:
	var chamfer: float = 6.0
	var offset := Vector2(2, 4)

	# Drop shadow
	var shadow_poly := PackedVector2Array([
		offset + Vector2(chamfer, 0),
		offset + Vector2(size.x - chamfer, 0),
		offset + Vector2(size.x, chamfer),
		offset + Vector2(size.x, size.y - chamfer),
		offset + Vector2(size.x - chamfer, size.y),
		offset + Vector2(chamfer, size.y),
		offset + Vector2(0, size.y - chamfer),
		offset + Vector2(0, chamfer)
	])
	draw_colored_polygon(shadow_poly, Color(0, 0, 0, 0.35))

	# Ivory faceplate
	var face_poly := PackedVector2Array([
		Vector2(chamfer, 0),
		Vector2(size.x - chamfer, 0),
		Vector2(size.x, chamfer),
		Vector2(size.x, size.y - chamfer),
		Vector2(size.x - chamfer, size.y),
		Vector2(chamfer, size.y),
		Vector2(0, size.y - chamfer),
		Vector2(0, chamfer)
	])
	draw_colored_polygon(face_poly, IVORY)

	# Border & Bevel
	var border_poly := PackedVector2Array([
		Vector2(chamfer, 0),
		Vector2(size.x - chamfer, 0),
		Vector2(size.x, chamfer),
		Vector2(size.x, size.y - chamfer),
		Vector2(size.x - chamfer, size.y),
		Vector2(chamfer, size.y),
		Vector2(0, size.y - chamfer),
		Vector2(0, chamfer),
		Vector2(chamfer, 0)
	])
	draw_polyline(border_poly, Color("6e6c60"), 1.5)
	draw_line(Vector2(chamfer, 1), Vector2(size.x - chamfer, 1), Color("fbf9f2"), 1.0)
	draw_line(Vector2(1, chamfer), Vector2(1, size.y - chamfer), Color("fbf9f2"), 1.0)
	draw_line(Vector2(chamfer, size.y - 1), Vector2(size.x - chamfer, size.y - 1), IVORY_SHADOW, 1.0)
	draw_line(Vector2(size.x - 1, chamfer), Vector2(size.x - 1, size.y - chamfer), IVORY_SHADOW, 1.0)

	# Corner rivets
	for p: Vector2 in [Vector2(8, 8), Vector2(size.x - 8, 8), Vector2(8, size.y - 8), Vector2(size.x - 8, size.y - 8)]:
		draw_circle(p, 2.5, Color("807e72"))
		draw_line(p - Vector2(1, 1), p + Vector2(1, 1), Color("343630"), 1.0)

	if size.x <= 400.0:
		# Compact layout for surface flight (e.g. 268x117)
		# HULL row
		draw_string(FONT, Vector2(16, 32), "HULL", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, CHARCOAL)
		var hull_recess := Rect2(68, 18, 124, 18)
		draw_rect(hull_recess, Color("0e1518"))
		draw_rect(Rect2(hull_recess.position + Vector2(1, 1), hull_recess.size - Vector2(2, 2)), Color("182022"))
		var hull_pct: float = clampf(float(hull_val) / float(max_hull_val), 0.0, 1.0)
		var hull_bars: int = int(round(hull_pct * 10.0))
		for i: int in range(10):
			var bar_rect := Rect2(72 + i * 11.8, 21, 8.5, 12)
			draw_rect(bar_rect, HULL_TINT if i < hull_bars else EMPTY_TINT)
		draw_string(FONT, Vector2(202, 32), "%d%%" % int(hull_pct * 100.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, CHARCOAL)

		# ENERGY row
		draw_string(FONT, Vector2(16, 62), "ENERGY", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, CHARCOAL)
		var energy_recess := Rect2(68, 48, 124, 18)
		draw_rect(energy_recess, Color("0e1518"))
		draw_rect(Rect2(energy_recess.position + Vector2(1, 1), energy_recess.size - Vector2(2, 2)), Color("182022"))
		var energy_pct: float = clampf(float(energy_val) / float(max_energy_val), 0.0, 1.0)
		var energy_bars: int = int(round(energy_pct * 10.0))
		for i: int in range(10):
			var bar_rect := Rect2(72 + i * 11.8, 51, 8.5, 12)
			draw_rect(bar_rect, ENERGY_TINT if i < energy_bars else EMPTY_TINT)
		draw_string(FONT, Vector2(202, 62), "%d%%" % int(energy_pct * 100.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, CHARCOAL)

		# Divider line
		draw_line(Vector2(14, 76), Vector2(size.x - 14, 76), Color("b4b0a4"), 1.0)

		# Row 3: Signal and Marks
		var sig_rect := Rect2(20, 83, 30, 20)
		if SIGNAL_ICON != null:
			draw_texture_rect(SIGNAL_ICON, sig_rect, false, SIGNAL_GREEN)
		var sig_led := Vector2(58, 93)
		draw_circle(sig_led, 4.0, Color(SIGNAL_GREEN.r, SIGNAL_GREEN.g, SIGNAL_GREEN.b, 0.3))
		draw_circle(sig_led, 2.0, SIGNAL_GREEN)

		# Marks balance
		var marks_str: String = _format_number(marks_val)
		var mark_icon_rect := Rect2(size.x - 130, 85, 16, 16)
		if MARK != null:
			draw_texture_rect(MARK, mark_icon_rect, false, Color("9a7a30"))
		draw_string(FONT, Vector2(size.x - 108, 98), marks_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, CHARCOAL)
	elif not orbital:
		# Unified Surface Field Console Layout (e.g. 542 x 117 or similar)
		# Left side: Recessed dark charcoal plate for the item matrix
		var plate_rect := Rect2(6, 6, size.x - 146, size.y - 12)
		draw_rect(plate_rect, Color("101618"))
		draw_rect(plate_rect, Color("202a2d"), false, 1.0)

		# Right telemetry divider
		var div_x: float = size.x - 132
		draw_line(Vector2(div_x, 10), Vector2(div_x, size.y - 10), Color("b4b0a4"), 1.0)

		# Telemetry Section (Right side)
		# Altitude
		draw_string(FONT, Vector2(div_x + 10, 24), "ALT", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("767468"))
		draw_string(FONT, Vector2(div_x + 40, 24), "12 m", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, CHARCOAL)

		# HULL row
		draw_string(FONT, Vector2(div_x + 10, 44), "HULL", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, CHARCOAL)
		var hull_recess := Rect2(div_x + 42, 34, 76, 12)
		draw_rect(hull_recess, Color("0e1518"))
		var hull_pct: float = clampf(float(hull_val) / float(max_hull_val), 0.0, 1.0)
		var hull_bars: int = int(round(hull_pct * 8.0))
		for i: int in range(8):
			var bar_rect := Rect2(div_x + 44 + i * 9.0, 36, 7.0, 8)
			draw_rect(bar_rect, HULL_TINT if i < hull_bars else EMPTY_TINT)

		# ENERGY row
		draw_string(FONT, Vector2(div_x + 10, 64), "ENG", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, CHARCOAL)
		var energy_recess := Rect2(div_x + 42, 54, 76, 12)
		draw_rect(energy_recess, Color("0e1518"))
		var energy_pct: float = clampf(float(energy_val) / float(max_energy_val), 0.0, 1.0)
		var energy_bars: int = int(round(energy_pct * 8.0))
		for i: int in range(8):
			var bar_rect := Rect2(div_x + 44 + i * 9.0, 56, 7.0, 8)
			draw_rect(bar_rect, ENERGY_TINT if i < energy_bars else EMPTY_TINT)

		# Signal & Comms icon at bottom
		var sig_rect := Rect2(div_x + 14, 82, 24, 16)
		if SIGNAL_ICON != null:
			draw_texture_rect(SIGNAL_ICON, sig_rect, false, SIGNAL_GREEN)
		var sig_led := Vector2(div_x + 46, 90)
		draw_circle(sig_led, 3.5, Color(SIGNAL_GREEN.r, SIGNAL_GREEN.g, SIGNAL_GREEN.b, 0.3))
		draw_circle(sig_led, 1.8, SIGNAL_GREEN)
	else:
		# Wide layout for orbital flight (e.g. 610x96)
		# Section 1: Meters (Left side, width ~235)
		# HULL row
		draw_string(FONT, Vector2(22, 38), "HULL", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, CHARCOAL)
		var hull_recess := Rect2(72, 23, 110, 18)
		draw_rect(hull_recess, Color("0e1518"))
		draw_rect(Rect2(hull_recess.position + Vector2(1, 1), hull_recess.size - Vector2(2, 2)), Color("182022"))
		var hull_pct: float = clampf(float(hull_val) / float(max_hull_val), 0.0, 1.0)
		var hull_bars: int = int(round(hull_pct * 10.0))
		for i: int in range(10):
			var bar_rect := Rect2(76 + i * 10.5, 26, 7.5, 12)
			draw_rect(bar_rect, HULL_TINT if i < hull_bars else EMPTY_TINT)
		draw_string(FONT, Vector2(188, 38), "%d%%" % int(hull_pct * 100.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, CHARCOAL)

		# ENERGY row
		draw_string(FONT, Vector2(22, 70), "ENERGY", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, CHARCOAL)
		var energy_recess := Rect2(72, 55, 110, 18)
		draw_rect(energy_recess, Color("0e1518"))
		draw_rect(Rect2(energy_recess.position + Vector2(1, 1), energy_recess.size - Vector2(2, 2)), Color("182022"))
		var energy_pct: float = clampf(float(energy_val) / float(max_energy_val), 0.0, 1.0)
		var energy_bars: int = int(round(energy_pct * 10.0))
		for i: int in range(10):
			var bar_rect := Rect2(76 + i * 10.5, 58, 7.5, 12)
			draw_rect(bar_rect, ENERGY_TINT if i < energy_bars else EMPTY_TINT)
		draw_string(FONT, Vector2(188, 70), "%d%%" % int(energy_pct * 100.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, CHARCOAL)

		# Divider line 1
		draw_line(Vector2(236, 12), Vector2(236, size.y - 12), Color("b4b0a4"), 1.0)

		# Section 2: Category Sockets (Middle, 4 sockets)
		var socket_y: float = 18.0
		var socket_size: float = 46.0
		for i: int in range(groups.size()):
			var grp: String = groups[i]
			var sx: float = 250.0 + float(i) * 54.0
			var socket_rect := Rect2(sx, socket_y, socket_size, socket_size)
			var is_active: bool = (grp == active_group)

			draw_rect(socket_rect, SOCKET_BG)
			draw_rect(socket_rect, ACTIVE_GOLD if is_active else SOCKET_BORDER, false, 1.5 if is_active else 1.0)

			# Indicator LED dot beneath socket
			var led_pos := Vector2(sx + socket_size * 0.5, socket_y + socket_size + 14.0)
			if is_active:
				draw_circle(led_pos, 4.5, Color(ACTIVE_GOLD.r, ACTIVE_GOLD.g, ACTIVE_GOLD.b, 0.3))
				draw_circle(led_pos, 2.5, ACTIVE_GOLD)
			else:
				draw_circle(led_pos, 2.0, Color("253035"))

		# Divider line 2
		draw_line(Vector2(476, 12), Vector2(476, size.y - 12), Color("b4b0a4"), 1.0)

		# Section 3: Signals & Marks (Right, width ~120)
		var sig_rect := Rect2(504, 16, 40, 26)
		if SIGNAL_ICON != null:
			draw_texture_rect(SIGNAL_ICON, sig_rect, false, SIGNAL_GREEN)
		var sig_led := Vector2(524, 48)
		draw_circle(sig_led, 4.5, Color(SIGNAL_GREEN.r, SIGNAL_GREEN.g, SIGNAL_GREEN.b, 0.3))
		draw_circle(sig_led, 2.5, SIGNAL_GREEN)

		# Marks balance
		var marks_str: String = _format_number(marks_val)
		var mark_icon_rect := Rect2(494, 62, 16, 16)
		if MARK != null:
			draw_texture_rect(MARK, mark_icon_rect, false, Color("9a7a30"))
		draw_string(FONT, Vector2(516, 75), marks_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, CHARCOAL)

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
