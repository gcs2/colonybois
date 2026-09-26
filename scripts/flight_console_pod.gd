extends Control
## Field Instruments Consolidated Console Pod.
## Displays segmented HULL and ENERGY meters, category sockets with active LED indicators,
## and active comms / signal state. The Marks balance belongs to FlightHUD's top-right anchor.
const FONT = preload("res://assets/fonts/Barlow-Regular.ttf")
const InstrumentFrame = preload("res://scripts/flight_instrument_frame.gd")
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
	# FlightHUD keeps the same compact footprint beside the item matrix at both scales.
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
	var offset := Vector2(2, 4)
	InstrumentFrame.draw_shadow(self, Rect2(offset, size), 8.0)
	InstrumentFrame.draw_frame(self, Rect2(Vector2.ZERO, size), 8.0, true)

	if size.x <= 400.0:
		# Compact layout beside the item grid for both flight scales.
		# HULL row
		draw_string(FONT, Vector2(8, 32), "HULL", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, CHARCOAL)
		var hull_recess := Rect2(48, 18, 100, 18)
		draw_rect(hull_recess, Color("0e1518"))
		draw_rect(Rect2(hull_recess.position + Vector2(1, 1), hull_recess.size - Vector2(2, 2)), Color("182022"))
		var hull_pct: float = clampf(float(hull_val) / float(max_hull_val), 0.0, 1.0)
		var hull_bars: int = int(round(hull_pct * 10.0))
		for i: int in range(10):
			var bar_rect := Rect2(52 + i * 9.0, 21, 7.5, 12)
			draw_rect(bar_rect, HULL_TINT if i < hull_bars else EMPTY_TINT)
		draw_string(FONT, Vector2(154, 32), "%d%%" % int(hull_pct * 100.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, CHARCOAL)

		# ENERGY row
		draw_string(FONT, Vector2(8, 62), "ENERGY", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, CHARCOAL)
		var energy_recess := Rect2(48, 48, 100, 18)
		draw_rect(energy_recess, Color("0e1518"))
		draw_rect(Rect2(energy_recess.position + Vector2(1, 1), energy_recess.size - Vector2(2, 2)), Color("182022"))
		var energy_pct: float = clampf(float(energy_val) / float(max_energy_val), 0.0, 1.0)
		var energy_bars: int = int(round(energy_pct * 10.0))
		for i: int in range(10):
			var bar_rect := Rect2(52 + i * 9.0, 51, 7.5, 12)
			draw_rect(bar_rect, ENERGY_TINT if i < energy_bars else EMPTY_TINT)
		draw_string(FONT, Vector2(154, 62), "%d%%" % int(energy_pct * 100.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, CHARCOAL)

		# Divider line
		draw_line(Vector2(14, 76), Vector2(size.x - 14, 76), Color("b4b0a4"), 1.0)

		# Row 3: Signal state. Marks live once in the top-right treasury anchor.
		var sig_rect := Rect2(20, 83, 30, 20)
		if SIGNAL_ICON != null:
			draw_texture_rect(SIGNAL_ICON, sig_rect, false, SIGNAL_GREEN)
		var sig_led := Vector2(58, 93)
		draw_circle(sig_led, 4.0, Color(SIGNAL_GREEN.r, SIGNAL_GREEN.g, SIGNAL_GREEN.b, 0.3))
		draw_circle(sig_led, 2.0, SIGNAL_GREEN)
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
