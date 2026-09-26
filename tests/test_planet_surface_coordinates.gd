extends SceneTree
const Coordinates = preload("res://scripts/planet_surface_coordinates.gd")
var checks: int = 0
var failures: int = 0

func _initialize() -> void: call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+message)

func run() -> void:
	var sample: Vector3 = Coordinates.direction(31.5, -72.25)
	var angles: Vector2 = Coordinates.latitude_longitude(sample)
	check(is_equal_approx(angles.x, 31.5) and is_equal_approx(angles.y, -72.25), "Latitude and longitude round-trip")
	var frame: Dictionary = Coordinates.tangent_frame(sample)
	check(is_equal_approx(frame.up.length(), 1.0) and is_equal_approx(frame.east.length(), 1.0) and is_equal_approx(frame.north.length(), 1.0), "Tangent frame directions are unit length")
	check(Coordinates.direction(0.0, 90.0).is_equal_approx(Vector3.RIGHT), "Positive longitude points east")
	var stepped: Vector3 = Coordinates.advance(sample, 120.0, -45.0, 6000.0)
	var offset: Vector2 = Coordinates.local_offset(sample, stepped, 6000.0)
	check(is_equal_approx(offset.x, 120.0) and is_equal_approx(offset.y, -45.0), "Small advance and local-offset operations round-trip")
	var pole_step: Vector3 = Coordinates.advance(Vector3.UP, 0.0, 0.0, 1000.0)
	check(pole_step.is_equal_approx(Vector3.UP), "Zero movement at the north pole stays finite and stable")
	var zero_up_frame: Dictionary = Coordinates.tangent_frame(Vector3.ZERO)
	check(zero_up_frame.up == Vector3.UP and is_equal_approx(zero_up_frame.east.length(), 1.0), "Degenerate input receives a finite unit frame")
	print("Planet surface coordinate assertions: ", checks, "; failures: ", failures)
	quit(0 if failures == 0 else 1)
