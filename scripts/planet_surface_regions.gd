extends RefCounted
## Pure, bounded spherical region and feature records for repeatable planet visits.
## Directions follow +Y north, longitude 0 at +Z, and positive longitude east.

const _TAU: float = PI * 2.0
const _MIN_ANGULAR_STEP: float = PI / 4096.0
const _MAX_ANGULAR_STEP: float = PI / 4.0
const _MAX_LONGITUDE_CELLS: int = 16384
const _MAX_QUERY_RADIUS_CELLS: float = 8.0
const _MAX_CANDIDATE_CELLS: int = 4096
const _MAX_RETURNED_REGIONS: int = 256

static func region_key(world: Dictionary, up: Vector3, planet_radius_m: float, region_size_m: float) -> String:
	var grid: Dictionary = _grid(planet_radius_m, region_size_m)
	var cell: Vector2i = _cell_for_up(up, grid)
	return "%s|%d|%d|%s|%d|%d" % [
		_planet_id(world), _geography_seed(world), _generator_version(world),
		grid.size_key, cell.x, cell.y
	]

## Nearby queries inspect at most 4096 candidate cells, return at most 256,
## and clamp the search radius to eight effective cell widths.
static func nearby_regions(world: Dictionary, center_up: Vector3, search_radius_m: float, planet_radius_m: float, region_size_m: float) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var grid: Dictionary = _grid(planet_radius_m, region_size_m)
	var center: Vector3 = _unit_or_north(center_up)
	var search_radius: float = maxf(0.0, search_radius_m) if is_finite(search_radius_m) else 0.0
	search_radius = minf(search_radius, grid.cell_m * _MAX_QUERY_RADIUS_CELLS)
	search_radius = minf(search_radius, PI * grid.radius_m)
	var angular_radius: float = search_radius / grid.radius_m
	var center_latitude: float = asin(clampf(center.y, -1.0, 1.0))
	var center_longitude: float = atan2(center.x, center.z)
	var first_band: int = maxi(0, int(floor((center_latitude - angular_radius + PI * 0.5) / grid.lat_step)))
	var last_band: int = mini(grid.band_count - 1, int(floor((center_latitude + angular_radius + PI * 0.5) / grid.lat_step)))
	var cosine_limit: float = cos(angular_radius)
	var examined: int = 0
	for band: int in range(first_band, last_band + 1):
		var latitude: float = -PI * 0.5 + (float(band) + 0.5) * grid.lat_step
		var longitude_count: int = int(grid.longitude_counts[band])
		var longitude_step: float = _TAU / float(longitude_count)
		var center_index: int = int(floor(fposmod(center_longitude + PI, _TAU) / _TAU * longitude_count))
		var latitude_cosine: float = cos(latitude)
		var center_cosine: float = cos(center_latitude)
		var max_delta: float = PI
		var denominator: float = latitude_cosine * center_cosine
		if denominator > 1.0e-10:
			var threshold: float = (cosine_limit - sin(latitude) * sin(center_latitude)) / denominator
			if threshold > 1.0:
				continue
			if threshold > -1.0:
				max_delta = acos(clampf(threshold, -1.0, 1.0))
		var index_radius: int = mini(longitude_count / 2, int(ceil(max_delta / longitude_step)) + 1)
		var seen_longitudes: Dictionary = {}
		for offset: int in range(-index_radius, index_radius + 1):
			if examined >= _MAX_CANDIDATE_CELLS or result.size() >= _MAX_RETURNED_REGIONS:
				return result
			var longitude_index: int = posmod(center_index + offset, longitude_count)
			if seen_longitudes.has(longitude_index):
				continue
			seen_longitudes[longitude_index] = true
			examined += 1
			var cell_up: Vector3 = _center_up(band, longitude_index, grid)
			if _great_circle_distance(center, cell_up, grid.radius_m) <= search_radius + 1.0e-5:
				result.append(_make_region(world, band, longitude_index, grid))
	return result

static func _make_region(world: Dictionary, band: int, longitude_index: int, grid: Dictionary) -> Dictionary:
	var region_id: String = "%s|%d|%d|%s|%d|%d" % [
		_planet_id(world), _geography_seed(world), _generator_version(world),
		grid.size_key, band, longitude_index
	]
	var center_up: Vector3 = _center_up(band, longitude_index, grid)
	var rng := RandomNumberGenerator.new()
	rng.seed = _stable_seed(region_id)
	var latitude: float = -PI * 0.5 + (float(band) + 0.5) * grid.lat_step
	var climate_value: int = int(rng.randi() % 100)
	var biome: String = _biome_for(latitude, climate_value)
	var features: Array[Dictionary] = _make_features(region_id, band, longitude_index, latitude, grid, rng)
	return {"id": region_id, "center_up": center_up, "biome": biome, "features": features}

static func _make_features(region_id: String, band: int, longitude_index: int, latitude: float, grid: Dictionary, rng: RandomNumberGenerator) -> Array[Dictionary]:
	var features: Array[Dictionary] = []
	var counts: Array[int] = [rng.randi_range(2, 5), rng.randi_range(0, 2), rng.randi_range(0, 3), rng.randi_range(0, 1)]
	var kinds: Array[String] = ["cover", "rock", "flora", "fauna"]
	var serial: int = 0
	for kind_index: int in range(kinds.size()):
		for _item: int in range(counts[kind_index]):
			var longitude_count: int = int(grid.longitude_counts[band])
			var longitude_step: float = _TAU / float(longitude_count)
			var longitude: float = -PI + (float(longitude_index) + rng.randf()) * longitude_step
			var latitude_jitter: float = (rng.randf() - 0.5) * grid.lat_step
			var feature_latitude: float = clampf(latitude + latitude_jitter, -PI * 0.5, PI * 0.5)
			serial += 1
			features.append(_feature(region_id, serial, kinds[kind_index], _direction(feature_latitude, longitude), rng))
	if rng.randf() < 0.035:
		var longitude_count: int = int(grid.longitude_counts[band])
		var longitude: float = -PI + (float(longitude_index) + rng.randf()) * _TAU / float(longitude_count)
		var feature_latitude: float = clampf(latitude + (rng.randf() - 0.5) * grid.lat_step, -PI * 0.5, PI * 0.5)
		serial += 1
		features.append(_feature(region_id, serial, "mineral", _direction(feature_latitude, longitude), rng))
	return features

static func _feature(region_id: String, serial: int, kind: String, up: Vector3, rng: RandomNumberGenerator) -> Dictionary:
	var variant_count: int = {"cover": 6, "rock": 5, "flora": 7, "fauna": 4, "mineral": 3}[kind]
	var size: float = rng.randf_range(0.65, 1.45) if kind != "fauna" else rng.randf_range(0.85, 1.15)
	return {
		"id": "%s|feature|%s|%d" % [region_id, kind, serial],
		"kind": kind,
		"up": up,
		"variant": rng.randi_range(0, variant_count - 1),
		"size": size,
		"yaw": rng.randf_range(-PI, PI)
	}

static func _biome_for(latitude: float, climate_value: int) -> String:
	if absf(latitude) > 1.18:
		return "ice"
	if climate_value < 18:
		return "dryland"
	if climate_value < 35:
		return "highland"
	if climate_value < 76:
		return "lowland"
	return "forest"

static func _grid(planet_radius_m: float, region_size_m: float) -> Dictionary:
	var radius: float = planet_radius_m if is_finite(planet_radius_m) and planet_radius_m > 0.0 else 1.0
	var requested_size: float = region_size_m if is_finite(region_size_m) and region_size_m > 0.0 else 1.0
	var angular_step: float = clampf(requested_size / radius, _MIN_ANGULAR_STEP, _MAX_ANGULAR_STEP)
	var band_count: int = maxi(1, int(ceil(PI / angular_step)))
	var lat_step: float = PI / float(band_count)
	# Resolution limits keep pathological caller sizes from allocating an unbounded grid.
	var effective_size: float = radius * lat_step
	var counts: Array[int] = []
	for band: int in range(band_count):
		var latitude: float = -PI * 0.5 + (float(band) + 0.5) * lat_step
		var circumference: float = _TAU * radius * maxf(0.0, cos(latitude))
		counts.append(clampi(int(round(circumference / effective_size)), 1, _MAX_LONGITUDE_CELLS))
	return {
		"radius_m": radius,
		"cell_m": effective_size,
		"lat_step": lat_step,
		"band_count": band_count,
		"longitude_counts": counts,
		"size_key": "bands:%d" % band_count
	}

static func _cell_for_up(up: Vector3, grid: Dictionary) -> Vector2i:
	var unit: Vector3 = _unit_or_north(up)
	var latitude: float = asin(clampf(unit.y, -1.0, 1.0))
	var band: int = clampi(int(floor((latitude + PI * 0.5) / grid.lat_step)), 0, grid.band_count - 1)
	var longitude_count: int = int(grid.longitude_counts[band])
	var longitude: float = atan2(unit.x, unit.z)
	var normalized_longitude: float = fposmod(longitude + PI, _TAU)
	var longitude_index: int = mini(longitude_count - 1, int(floor(normalized_longitude / _TAU * longitude_count)))
	return Vector2i(band, longitude_index)

static func _center_up(band: int, longitude_index: int, grid: Dictionary) -> Vector3:
	var latitude: float = -PI * 0.5 + (float(band) + 0.5) * grid.lat_step
	var longitude: float = -PI + (float(longitude_index) + 0.5) * _TAU / float(grid.longitude_counts[band])
	return _direction(latitude, longitude)

static func _direction(latitude: float, longitude: float) -> Vector3:
	return Vector3(cos(latitude) * sin(longitude), sin(latitude), cos(latitude) * cos(longitude)).normalized()

static func _great_circle_distance(first: Vector3, second: Vector3, radius: float) -> float:
	return acos(clampf(first.dot(second), -1.0, 1.0)) * radius

static func _unit_or_north(value: Vector3) -> Vector3:
	if not is_finite(value.length_squared()) or value.length_squared() <= 1.0e-12:
		return Vector3.UP
	return value.normalized()

static func _planet_id(world: Dictionary) -> String:
	return str(world.get("id", world.get("planet_id", ""))).to_lower()

static func _geography_seed(world: Dictionary) -> int:
	return int(world.get("geography_seed", world.get("seed", 0)))

static func _generator_version(world: Dictionary) -> int:
	return int(world.get("generator_version", 1))

static func _stable_seed(source: String) -> int:
	var value: int = 104729
	for index: int in range(source.length()):
		value = int((value * 257 + source.unicode_at(index) + index) % 2147483647)
	return maxi(1, value)
