extends Control
## Shared matte Field Instruments housing used by map, cargo and telemetry plates.
const FACE := Color("dedad0")
const EDGE := Color("6e6c60")
const HIGHLIGHT := Color("f6f2e8")
const SHADE := Color("8d8c80")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	draw_frame(self, Rect2(Vector2.ZERO, size))

static func draw_frame(canvas: CanvasItem, rect: Rect2, chamfer: float = 0.0, rivets: bool = true) -> void:
	# Keep corner cuts in proportion to each instrument: small readouts stay
	# compact while the larger map and cargo housings share a broader bevel.
	var short_side: float = minf(rect.size.x, rect.size.y)
	var c: float = minf(12.0, short_side * 0.12) if chamfer <= 0.0 else minf(chamfer, short_side * 0.25)
	var points := PackedVector2Array([
		rect.position + Vector2(c, 0),
		rect.position + Vector2(rect.size.x - c, 0),
		rect.position + Vector2(rect.size.x, c),
		rect.position + Vector2(rect.size.x, rect.size.y - c),
		rect.position + Vector2(rect.size.x - c, rect.size.y),
		rect.position + Vector2(c, rect.size.y),
		rect.position + Vector2(0, rect.size.y - c),
		rect.position + Vector2(0, c),
	])
	canvas.draw_colored_polygon(points, FACE)
	var outline := points.duplicate()
	outline.append(points[0])
	canvas.draw_polyline(outline, EDGE, 1.5, true)
	canvas.draw_line(points[0] + Vector2(1, 1), points[1] + Vector2(-1, 1), HIGHLIGHT, 1.0)
	canvas.draw_line(points[7] + Vector2(1, -1), points[6] + Vector2(1, 1), HIGHLIGHT, 1.0)
	canvas.draw_line(points[5] + Vector2(0, -1), points[4] + Vector2(0, -1), SHADE, 1.0)
	canvas.draw_line(points[2] + Vector2(-1, 1), points[3] + Vector2(-1, -1), SHADE, 1.0)
	if rivets and rect.size.x >= 90.0 and rect.size.y >= 36.0:
		var inset: float = minf(11.0, minf(rect.size.x, rect.size.y) * 0.18)
		for point: Vector2 in [
			rect.position + Vector2(inset, inset),
			rect.position + Vector2(rect.size.x - inset, inset),
			rect.position + Vector2(inset, rect.size.y - inset),
			rect.position + Vector2(rect.size.x - inset, rect.size.y - inset)
		]:
			canvas.draw_circle(point, 1.8, SHADE)

static func draw_shadow(canvas: CanvasItem, rect: Rect2, chamfer: float = 8.0) -> void:
	var c: float = minf(chamfer, minf(rect.size.x, rect.size.y) * 0.25)
	var points := PackedVector2Array([
		rect.position + Vector2(c, 0), rect.position + Vector2(rect.size.x - c, 0),
		rect.position + Vector2(rect.size.x, c), rect.position + Vector2(rect.size.x, rect.size.y - c),
		rect.position + Vector2(rect.size.x - c, rect.size.y), rect.position + Vector2(c, rect.size.y),
		rect.position + Vector2(0, rect.size.y - c), rect.position + Vector2(0, c)
	])
	canvas.draw_colored_polygon(points, Color(0, 0, 0, 0.28))
