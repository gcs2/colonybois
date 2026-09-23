extends RefCounted
## Planet-fixed coordinates: north +Y; longitude zero +Z, east toward +X.
static var cached_definition: Dictionary = {}
static func definition() -> Dictionary:
	if cached_definition.is_empty():
		cached_definition = JSON.parse_string(FileAccess.get_file_as_string("res://data/morrow_planet.json")) as Dictionary
	return cached_definition

static func direction(latitude: float, longitude: float) -> Vector3:
	var lat: float = deg_to_rad(latitude)
	var lon: float = deg_to_rad(longitude)
	return Vector3(cos(lat)*sin(lon),sin(lat),cos(lat)*cos(lon))

static func site_direction() -> Vector3:
	var site: Dictionary = definition().sites[0]
	return direction(site.latitude,site.longitude)

static func seed_offset(seed_value: int) -> Vector3:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return Vector3(rng.randf_range(1,20),rng.randf_range(1,20),rng.randf_range(1,20))
