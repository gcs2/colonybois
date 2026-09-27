extends Control
## Compact hover hint for the flight HUD's category tabs.
const HUD_WIDTH := 1600.0
const MIN_WIDTH := 220.0
const MAX_WIDTH := 300.0
const HEIGHT := 26.0
const FONT_SIZE := 12
const HORIZONTAL_PADDING := 12.0

const BORDER := Color("b6b2a5")
const FACE := Color("192322")
const EDGE := Color("59625d")
const HIGHLIGHT := Color("eee9d9")
const TEXT := Color("e9efe5")

var hint_text: String = ""
var text_label: Label

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	text_label = Label.new()
	text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	text_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_label.add_theme_font_size_override("font_size", FONT_SIZE)
	text_label.add_theme_color_override("font_color", TEXT)
	add_child(text_label)

func present(button: Control, text: String, panel_top: float) -> void:
	if button == null or text.strip_edges().is_empty():
		dismiss()
		return
	hint_text = text.replace("\n", " ").strip_edges()
	text_label.text = hint_text
	var font: Font = text_label.get_theme_default_font()
	if font == null:
		font = ThemeDB.fallback_font
	var measured_width: float = font.get_string_size(hint_text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x
	var parent_control: Control = get_parent() as Control
	var hud_width: float = parent_control.size.x if parent_control != null and parent_control.size.x > 0.0 else HUD_WIDTH
	size = Vector2(minf(MAX_WIDTH, maxf(MIN_WIDTH, measured_width + HORIZONTAL_PADDING * 2.0)), HEIGHT)
	# FlightHUD owns both the button and hint as direct children.
	var anchor_center: Vector2 = button.position + button.size * 0.5
	position = Vector2(clampf(anchor_center.x - size.x * 0.5, 0.0, hud_width - size.x), panel_top - 60.0)
	text_label.position = Vector2(HORIZONTAL_PADDING, 0.0)
	text_label.size = Vector2(size.x - HORIZONTAL_PADDING * 2.0, size.y)
	visible = true
	queue_redraw()

func dismiss() -> void:
	hint_text = ""
	if text_label != null:
		text_label.text = ""
	visible = false

func _shape(inset: float) -> PackedVector2Array:
	var cut: float = minf(5.0, (HEIGHT - inset * 2.0) * 0.22)
	return PackedVector2Array([
		Vector2(inset + cut, inset),
		Vector2(size.x - inset - cut, inset),
		Vector2(size.x - inset, inset + cut),
		Vector2(size.x - inset, HEIGHT - inset - cut),
		Vector2(size.x - inset - cut, HEIGHT - inset),
		Vector2(inset + cut, HEIGHT - inset),
		Vector2(inset, HEIGHT - inset - cut),
		Vector2(inset, inset + cut)
	])

func _closed(points: PackedVector2Array) -> PackedVector2Array:
	var closed: PackedVector2Array = points.duplicate()
	closed.append(points[0])
	return closed

func _draw() -> void:
	if size.x <= 0.0:
		return
	var outer: PackedVector2Array = _shape(0.0)
	draw_colored_polygon(outer, BORDER)
	draw_colored_polygon(_shape(1.0), FACE)
	draw_polyline(_closed(outer), EDGE, 1.0, true)
	draw_line(Vector2(8.0, 1.0), Vector2(size.x - 8.0, 1.0), Color(HIGHLIGHT, 0.48), 1.0, true)
