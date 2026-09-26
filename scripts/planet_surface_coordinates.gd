extends RefCounted
## Pure coordinate helpers for movement and measurements on a spherical surface.
## Directions use +Y as north, longitude 0 along +Z, and positive longitude eastward.

const _EPSILON_SQUARED: float = 1.0e-12
const _POLE_HORIZONTAL_EPSILON: float = 1.0e-8

static func tangent_frame(up: Vector3) -> Dictionary:
	var surface_up: Vector3 = _unit_or_north(up)
	var east: Vector3 = Vector3.UP.cross(surface_up)
	if east.length_squared() <= _EPSILON_SQUARED:
		# Longitude has no unique east direction at a pole; choose a stable frame.
		east = Vector3.RIGHT
	else:
		east = east.normalized()
	var north: Vector3 = surface_up.cross(east).normalized()
	return {"up": surface_up, "east": east, "north": north}

static func advance(up: Vector3, east_m: float, north_m: float, radius_m: float) -> Vector3:
	var frame: Dictionary = tangent_frame(up)
	var movement: Vector3 = frame.east * east_m + frame.north * north_m
	var distance_m: float = movement.length()
	if distance_m <= 0.0 or not is_finite(distance_m):
		return frame.up
	if radius_m <= 0.0 or not is_finite(radius_m):
		return frame.up
	var angle: float = distance_m / radius_m
	return (frame.up * cos(angle) + movement / distance_m * sin(angle)).normalized()

static func local_offset(origin_up: Vector3, target_up: Vector3, radius_m: float) -> Vector2:
	if radius_m <= 0.0 or not is_finite(radius_m):
		return Vector2.ZERO
	var frame: Dictionary = tangent_frame(origin_up)
	var target: Vector3 = _unit_or_north(target_up)
	var dot: float = clampf(frame.up.dot(target), -1.0, 1.0)
	var angle: float = acos(dot)
	if angle <= 0.0:
		return Vector2.ZERO
	var tangent: Vector3 = target - frame.up * dot
	if tangent.length_squared() <= _EPSILON_SQUARED:
		# Antipodes have no unique shortest-path direction; keep the result finite.
		return Vector2.ZERO
	var offset: Vector3 = tangent.normalized() * (angle * radius_m)
	return Vector2(offset.dot(frame.east), offset.dot(frame.north))

static func direction(latitude_degrees: float, longitude_degrees: float) -> Vector3:
	var latitude: float = deg_to_rad(latitude_degrees)
	var longitude: float = deg_to_rad(longitude_degrees)
	return Vector3(cos(latitude) * sin(longitude), sin(latitude), cos(latitude) * cos(longitude)).normalized()

static func latitude_longitude(up: Vector3) -> Vector2:
	var surface_up: Vector3 = _unit_or_north(up)
	var latitude: float = rad_to_deg(asin(clampf(surface_up.y, -1.0, 1.0)))
	var longitude: float = 0.0
	if Vector2(surface_up.x, surface_up.z).length() > _POLE_HORIZONTAL_EPSILON:
		longitude = rad_to_deg(atan2(surface_up.x, surface_up.z))
	return Vector2(latitude, longitude)

static func _unit_or_north(value: Vector3) -> Vector3:
	if value.length_squared() <= _EPSILON_SQUARED or not is_finite(value.length_squared()):
		return Vector3.UP
	return value.normalized()
