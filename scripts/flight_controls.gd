extends RefCounted

static func landing_route(start: Vector3, finish: Vector3, center: Vector3) -> Array[Vector3]:
	# A direct approach from the far hemisphere otherwise sticks against the globe.
	var route: Array[Vector3] = []
	var nearest: Vector3 = Geometry3D.get_closest_point_to_segment(center,start,finish)
	if nearest.distance_to(center) < 24:
		var first: Vector3 = (start-center).normalized()
		var last: Vector3 = (finish-center).normalized()
		if first.is_zero_approx(): first = Vector3.UP
		var axis: Vector3 = first.cross(last).normalized()
		if axis.is_zero_approx(): axis = first.cross(Vector3.UP).normalized()
		if axis.is_zero_approx(): axis = Vector3.RIGHT
		var angle: float = first.angle_to(last)
		var count: int = maxi(1,int(ceil(angle/deg_to_rad(20))))
		route.append(center+first*32)
		for i: int in range(1,count+1):
			route.append(center+first.rotated(axis,angle*float(i)/count)*32)
	route.append(finish)
	return route
## Shared, remappable flight actions. Logical mouse buttons honor Windows handedness.
const BINDINGS := {
	"flight_forward":[KEY_W, KEY_UP, KEY_KP_8],
	"flight_back":[KEY_S, KEY_DOWN, KEY_KP_2],
	"flight_left":[KEY_A, KEY_LEFT, KEY_KP_4],
	"flight_right":[KEY_D, KEY_RIGHT, KEY_KP_6],
	"flight_rise":[KEY_E, KEY_HOME, KEY_PAGEUP, KEY_KP_9, KEY_KP_ADD],
	"flight_descend":[KEY_Q, KEY_END, KEY_PAGEDOWN, KEY_KP_3, KEY_KP_SUBTRACT],
	"flight_brake":[KEY_KP_5, KEY_KP_0],
}

static func install() -> void:
	for action: String in BINDINGS:
		if InputMap.has_action(action): continue
		InputMap.add_action(action)
		for key: int in BINDINGS[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action,event)

static func direction() -> Vector3:
	return Vector3(Input.get_axis("flight_left","flight_right"),
		Input.get_axis("flight_descend","flight_rise"),
		Input.get_axis("flight_forward","flight_back"))

static func arrival_velocity(offset: Vector3, speed: float) -> Vector3:
	# Slow down before arrival instead of circling a point under acceleration.
	return offset.normalized()*minf(speed,offset.length()*2.0)
