extends RefCounted
## Deterministic, bounded data window for a planet-fixed surface view.

const Coordinates = preload("res://scripts/planet_surface_coordinates.gd")
const PlanetGenerator = preload("res://scripts/planet_generator.gd")

const DEFAULT_PLANET_RADIUS_M: float = 16000.0
const DEFAULT_REGION_SIZE_M: float = 512.0
const DEFAULT_VIEW_RADIUS_M: float = 1100.0
const _MIN_ANGULAR_STEP: float = PI / 65536.0
const _MAX_ANGULAR_STEP: float = PI / 4.0
const _MAX_BANDS: int = 65536
const _MAX_LONGITUDE_CELLS: int = 131072
const _MAX_QUERY_RADIUS_CELLS: float = 16.0
const _MAX_CANDIDATE_CELLS: int = 1024
const _FEATURE_STREAM_VERSION: int = 1
# Habitat identity follows coarse spherical coordinates so neighboring macro
# regions form readable, repeatable patches instead of changing role per cell.
const _HABITAT_CLUSTER_LAT_CELLS: int = 3
const _HABITAT_CLUSTER_LON_CELLS: int = 4
# Current gameplay persists only the authored seam delta; generated feature IDs have no removal writer.
# Before adding persistent feature actions, version placement in feature IDs and migrate legacy deltas.
const MAX_WINDOW_REGIONS: int = 512
const MAX_WINDOW_FEATURES: int = 8192
const _TAU: float = PI * 2.0
const _HABITAT_ROLES_BY_BIOME: Dictionary = {
	"ocean": ["shoal", "shelf"],
	"ice": ["icefield", "refuge", "outcrop"],
	"highland": ["scree", "alpine", "outcrop"],
	"dryland": ["scrub", "scree", "sparse"],
	"lowland": ["meadow", "grove", "outcrop"],
	"forest": ["thicket", "grove", "clearing"]
}
const _HABITAT_PROFILES: Dictionary = {
	"shoal": {"counts": [[0, 1], [1, 3], [0, 1], [1, 1]], "spread": 0.12, "rock_scale": 1.4, "flora_scale": 1.1, "fauna_scale": 1.45},
	"shelf": {"counts": [[0, 1], [2, 4], [0, 1], [1, 1]], "spread": 0.09, "rock_scale": 1.75, "flora_scale": 1.1, "fauna_scale": 1.35},
	"icefield": {"counts": [[1, 3], [1, 3], [0, 2], [1, 1]], "spread": 0.14, "rock_scale": 1.5, "flora_scale": 1.2, "fauna_scale": 1.5},
	"refuge": {"counts": [[2, 4], [1, 2], [2, 3], [1, 2]], "spread": 0.12, "rock_scale": 1.3, "flora_scale": 1.9, "fauna_scale": 1.5},
	"scree": {"counts": [[0, 1], [3, 5], [0, 1], [1, 1]], "spread": 0.08, "rock_scale": 2.25, "flora_scale": 1.1, "fauna_scale": 1.25},
	"alpine": {"counts": [[2, 4], [1, 3], [1, 3], [1, 1]], "spread": 0.13, "rock_scale": 1.7, "flora_scale": 1.55, "fauna_scale": 1.45},
	"scrub": {"counts": [[1, 3], [1, 2], [3, 5], [1, 2]], "spread": 0.12, "rock_scale": 1.45, "flora_scale": 1.6, "fauna_scale": 1.45},
	"sparse": {"counts": [[1, 2], [1, 2], [1, 2], [1, 1]], "spread": 0.17, "rock_scale": 1.35, "flora_scale": 1.3, "fauna_scale": 1.35},
	"meadow": {"counts": [[2, 4], [1, 2], [2, 4], [1, 3]], "spread": 0.16, "rock_scale": 1.2, "flora_scale": 1.75, "fauna_scale": 1.6},
	"grove": {"counts": [[3, 5], [1, 2], [3, 5], [1, 2]], "spread": 0.11, "rock_scale": 1.25, "flora_scale": 2.0, "fauna_scale": 1.55},
	"outcrop": {"counts": [[1, 2], [3, 5], [1, 2], [1, 1]], "spread": 0.09, "rock_scale": 2.0, "flora_scale": 1.25, "fauna_scale": 1.3},
	"thicket": {"counts": [[3, 5], [1, 2], [3, 5], [1, 2]], "spread": 0.10, "rock_scale": 1.3, "flora_scale": 2.05, "fauna_scale": 1.55},
	"clearing": {"counts": [[2, 4], [1, 2], [1, 3], [2, 3]], "spread": 0.15, "rock_scale": 1.25, "flora_scale": 1.45, "fauna_scale": 1.75}
}

## Returns nearest deterministic region and feature records in one tangent frame.
## Cells use the requested scale up to the explicit grid and query bounds.
static func build(world: Dictionary, center_up: Vector3, planet_radius_m: float = DEFAULT_PLANET_RADIUS_M, region_size_m: float = DEFAULT_REGION_SIZE_M, view_radius_m: float = DEFAULT_VIEW_RADIUS_M) -> Dictionary:
	var radius: float = planet_radius_m if is_finite(planet_radius_m) and planet_radius_m > 0.0 else DEFAULT_PLANET_RADIUS_M
	var requested_region_size: float = region_size_m if is_finite(region_size_m) and region_size_m > 0.0 else DEFAULT_REGION_SIZE_M
	var requested_view_radius: float = view_radius_m if is_finite(view_radius_m) and view_radius_m > 0.0 else DEFAULT_VIEW_RADIUS_M
	var center: Vector3 = _unit_or_north(center_up)
	var grid: Dictionary = _grid(radius, requested_region_size)
	var effective_region_size: float = float(grid.cell_m)
	var bounded_view_radius: float = minf(requested_view_radius, effective_region_size * _MAX_QUERY_RADIUS_CELLS)
	bounded_view_radius = minf(bounded_view_radius, PI * radius)
	var regions: Array[Dictionary] = []
	var features: Array[Dictionary] = []
	var generator: Object = PlanetGenerator.new(_generator_recipe(world))
	var center_latitude: float = asin(clampf(center.y, -1.0, 1.0))
	var center_longitude: float = atan2(center.x, center.z)
	var angular_radius: float = bounded_view_radius / radius
	var first_band: int = maxi(0, int(floor((center_latitude - angular_radius + PI * 0.5) / grid.lat_step)))
	var last_band: int = mini(grid.band_count - 1, int(floor((center_latitude + angular_radius + PI * 0.5) / grid.lat_step)))
	var cosine_limit: float = cos(angular_radius)
	var examined: int = 0
	var truncated: bool = false
	var center_cell: Vector2i = _cell_for_up(center, grid)
	var center_region_id: String = _region_id(world, grid, center_cell.x, center_cell.y)
	var center_region_up: Vector3 = _center_up(center_cell.x, center_cell.y, grid)
	var center_biome: String = str(generator.call("sample", center_region_up).biome)
	for band: int in range(first_band, last_band + 1):
		var latitude: float = -PI * 0.5 + (float(band) + 0.5) * grid.lat_step
		var longitude_count: int = int(grid.longitude_counts[band])
		var longitude_step: float = _TAU / float(longitude_count)
		var center_index: int = int(floor(fposmod(center_longitude + PI, _TAU) / _TAU * longitude_count))
		var denominator: float = cos(latitude) * cos(center_latitude)
		var max_delta: float = PI
		if denominator > 1.0e-10:
			var threshold: float = (cosine_limit - sin(latitude) * sin(center_latitude)) / denominator
			if threshold > 1.0:
				continue
			if threshold > -1.0:
				max_delta = acos(clampf(threshold, -1.0, 1.0))
		var index_radius: int = mini(longitude_count / 2, int(ceil(max_delta / longitude_step)) + 1)
		var seen_longitudes: Dictionary = {}
		for offset: int in range(-index_radius, index_radius + 1):
			if examined >= _MAX_CANDIDATE_CELLS or regions.size() >= MAX_WINDOW_REGIONS:
				truncated = true
				break
			var longitude_index: int = posmod(center_index + offset, longitude_count)
			if seen_longitudes.has(longitude_index):
				continue
			seen_longitudes[longitude_index] = true
			examined += 1
			var region_up: Vector3 = _center_up(band, longitude_index, grid)
			if _great_circle_distance(center, region_up, radius) > bounded_view_radius + 1.0e-5:
				continue
			var region_id: String = _region_id(world, grid, band, longitude_index)
			var sample: Dictionary = generator.call("sample", region_up)
			var biome: String = str(sample.biome)
			var region_position: Vector2 = Coordinates.local_offset(center, region_up, radius)
			var habitat_role: String = _habitat_role_for_cell(biome, region_id, band, longitude_index)
			regions.append({
				"id": region_id,
				"biome": biome,
				"habitat_role": habitat_role,
				"up": region_up,
				"position_m": region_position,
				"distance_m": region_position.length(),
				"features": []
			})
		if truncated:
			break
	regions.sort_custom(func(first: Dictionary, second: Dictionary) -> bool:
		var distance_delta: float = float(first.distance_m) - float(second.distance_m)
		if absf(distance_delta) > 1.0e-5:
			return distance_delta < 0.0
		return str(first.id) < str(second.id)
	)
	for region_index: int in range(regions.size()):
		if features.size() >= MAX_WINDOW_FEATURES:
			truncated = true
			regions.resize(region_index)
			break
		var region: Dictionary = regions[region_index]
		var band_and_longitude: Vector2i = _cell_for_up(region.up, grid)
		var region_features: Array[Dictionary] = _make_features(str(region.id), band_and_longitude.x, band_and_longitude.y, grid, str(region.biome), center, radius, str(region.habitat_role))
		for feature: Dictionary in region_features:
			if features.size() >= MAX_WINDOW_FEATURES:
				truncated = true
				break
			features.append(feature.duplicate(true))
			region.features.append(feature)
		regions[region_index] = region
		if truncated:
			regions.resize(region_index + 1)
			break
	return {
		"center_up": center,
		"current_region_id": center_region_id,
		"current_biome": center_biome,
		"planet_radius_m": radius,
		"requested_region_size_m": requested_region_size,
		"effective_region_size_m": effective_region_size,
		"view_radius_m": bounded_view_radius,
		"regions": regions,
		"features": features,
		"examined_cells": examined,
		"truncated": truncated
	}

static func _grid(radius: float, requested_size: float) -> Dictionary:
	var angular_step: float = clampf(requested_size / radius, _MIN_ANGULAR_STEP, _MAX_ANGULAR_STEP)
	var band_count: int = clampi(int(ceil(PI / angular_step)), 1, _MAX_BANDS)
	var lat_step: float = PI / float(band_count)
	var effective_size: float = radius * lat_step
	var longitude_counts: Array[int] = []
	for band: int in range(band_count):
		var latitude: float = -PI * 0.5 + (float(band) + 0.5) * lat_step
		var circumference: float = _TAU * radius * maxf(0.0, cos(latitude))
		longitude_counts.append(clampi(int(round(circumference / effective_size)), 1, _MAX_LONGITUDE_CELLS))
	return {
		"radius_m": radius,
		"cell_m": effective_size,
		"lat_step": lat_step,
		"band_count": band_count,
		"longitude_counts": longitude_counts,
		"size_key": "radius:%d|bands:%d" % [roundi(radius), band_count]
	}

static func _make_features(region_id: String, band: int, longitude_index: int, grid: Dictionary, biome: String, center: Vector3, radius: float, habitat_role: String = "") -> Array[Dictionary]:
	var role: String = habitat_role if not habitat_role.is_empty() else _habitat_role(biome, region_id)
	var ranges_by_biome: Dictionary = _feature_count_ranges(biome, role)
	var ranges: Array = ranges_by_biome.get(biome, ranges_by_biome.lowland)
	var counts: Array[int] = []
	for kind_index: int in range(4):
		var kind: String = ["cover", "rock", "flora", "fauna"][kind_index]
		var count_rng: RandomNumberGenerator = _feature_rng(region_id, kind)
		var range_values: Array = ranges[kind_index]
		counts.append(count_rng.randi_range(int(range_values[0]), int(range_values[1])))
	return _make_features_for_counts(region_id, band, longitude_index, grid, biome, center, radius, counts, {}, role)

## Builds records with explicit category counts; stream burns are a contract-test seam for draw isolation.
static func _make_features_for_counts(region_id: String, band: int, longitude_index: int, grid: Dictionary, biome: String, center: Vector3, radius: float, counts: Array[int], stream_burns: Dictionary = {}, habitat_role: String = "") -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var kinds: Array[String] = ["cover", "rock", "flora", "fauna"]
	for kind_index: int in range(kinds.size()):
		var kind: String = kinds[kind_index]
		var rng: RandomNumberGenerator = _feature_rng(region_id, kind)
		for _burn: int in range(int(stream_burns.get(kind, 0))):
			rng.randi()
		for slot: int in range(counts[kind_index]):
			var feature_up: Vector3 = _random_direction_in_habitat(band, longitude_index, grid, rng, habitat_role, kind) if not habitat_role.is_empty() else _random_direction_in_cell(band, longitude_index, grid, rng)
			var feature_id: String = "%s|feature|%s|%d" % [region_id, kind, slot + 1]
			var local_position: Vector2 = Coordinates.local_offset(center, feature_up, radius)
			result.append({
				"id": feature_id,
				"region_id": region_id,
				"kind": kind,
				"biome": biome,
				"habitat_role": habitat_role,
				"up": feature_up,
				"position_m": local_position,
				"variant": rng.randi_range(0, {"cover": 5, "rock": 4, "flora": 6, "fauna": 3}[kind]),
				"size": rng.randf_range(0.85, 1.15) if kind == "fauna" else rng.randf_range(0.65, 1.45),
				"yaw": rng.randf_range(-PI, PI)
			})
	var mineral_rng: RandomNumberGenerator = _feature_rng(region_id, "mineral")
	for _burn: int in range(int(stream_burns.get("mineral", 0))):
		mineral_rng.randi()
	if mineral_rng.randf() < 0.035:
		var mineral_up: Vector3 = _random_direction_in_habitat(band, longitude_index, grid, mineral_rng, habitat_role, "mineral") if not habitat_role.is_empty() else _random_direction_in_cell(band, longitude_index, grid, mineral_rng)
		var mineral_id: String = "%s|feature|mineral|1" % region_id
		result.append({
			"id": mineral_id,
			"region_id": region_id,
			"kind": "mineral",
			"biome": biome,
			"habitat_role": habitat_role,
			"up": mineral_up,
			"position_m": Coordinates.local_offset(center, mineral_up, radius),
			"variant": mineral_rng.randi_range(0, 2),
			"size": mineral_rng.randf_range(0.65, 1.45),
			"yaw": mineral_rng.randf_range(-PI, PI)
		})
	return result

static func _feature_count_ranges(biome: String, habitat_role: String = "") -> Dictionary:
	var ranges_by_biome: Dictionary = {
		"ocean": [[0, 1], [0, 1], [0, 0], [0, 1]],
		"ice": [[1, 3], [0, 2], [0, 1], [0, 1]],
		"highland": [[1, 3], [1, 3], [0, 2], [0, 1]],
		"dryland": [[1, 3], [0, 2], [0, 2], [0, 1]],
		"lowland": [[2, 5], [0, 2], [1, 3], [0, 2]],
		"forest": [[3, 5], [0, 2], [2, 4], [1, 2]]
	}
	if _HABITAT_PROFILES.has(habitat_role):
		ranges_by_biome[biome] = _HABITAT_PROFILES[habitat_role].counts
	return ranges_by_biome

static func _habitat_role(biome: String, region_id: String) -> String:
	var roles: Array = _HABITAT_ROLES_BY_BIOME.get(biome, _HABITAT_ROLES_BY_BIOME.lowland)
	var rng: RandomNumberGenerator = _feature_rng(region_id, "habitat")
	return str(roles[rng.randi_range(0, roles.size()-1)])

static func _habitat_role_for_cell(biome: String, region_id: String, band: int, longitude_index: int) -> String:
	var roles: Array = _HABITAT_ROLES_BY_BIOME.get(biome, _HABITAT_ROLES_BY_BIOME.lowland)
	var cluster_band: int = floori(float(band) / float(_HABITAT_CLUSTER_LAT_CELLS))
	var cluster_longitude: int = floori(float(longitude_index) / float(_HABITAT_CLUSTER_LON_CELLS))
	# Remove only the final band/longitude coordinates from the unchanged region ID.
	var longitude_separator: int = region_id.rfind("|")
	var band_separator: int = region_id.rfind("|", longitude_separator - 1)
	var world_key: String = region_id.substr(0, band_separator)
	var cluster_id: String = "%s|habitat|%s|%d|%d|%s" % [
		world_key,
		_FEATURE_STREAM_VERSION,
		cluster_band,
		cluster_longitude,
		biome
	]
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = _stable_seed(cluster_id)
	return str(roles[rng.randi_range(0, roles.size() - 1)])

static func _random_direction_in_habitat(band: int, longitude_index: int, grid: Dictionary, rng: RandomNumberGenerator, habitat_role: String, kind: String) -> Vector3:
	var longitude_count: int = int(grid.longitude_counts[band])
	var longitude_step: float = _TAU / float(longitude_count)
	var center_longitude: float = -PI + (float(longitude_index) + 0.5) * longitude_step
	var center_latitude: float = -PI * 0.5 + (float(band) + 0.5) * grid.lat_step
	var profile: Dictionary = _HABITAT_PROFILES.get(habitat_role, {"spread": 0.15})
	var spread: float = float(profile.get("spread", 0.15))
	if kind == "rock": spread *= 0.62
	elif kind == "fauna": spread *= 1.2
	var longitude: float = center_longitude + rng.randf_range(-spread, spread) * longitude_step
	var latitude: float = center_latitude + rng.randf_range(-spread, spread) * grid.lat_step
	return _direction(clampf(latitude, -PI * 0.5, PI * 0.5), longitude)

static func _feature_rng(region_id: String, kind: String) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = _stable_seed("%s|feature-stream|%d|%s" % [region_id, _FEATURE_STREAM_VERSION, kind])
	return rng

static func _random_direction_in_cell(band: int, longitude_index: int, grid: Dictionary, rng: RandomNumberGenerator) -> Vector3:
	var longitude_step: float = _TAU / float(grid.longitude_counts[band])
	var longitude: float = -PI + (float(longitude_index) + rng.randf()) * longitude_step
	var latitude: float = -PI * 0.5 + (float(band) + rng.randf()) * grid.lat_step
	return _direction(clampf(latitude, -PI * 0.5, PI * 0.5), longitude)

static func _region_id(world: Dictionary, grid: Dictionary, band: int, longitude_index: int) -> String:
	return "%s|%d|%d|%s|%d|%d" % [
		str(world.get("id", world.get("planet_id", ""))).to_lower(),
		int(world.get("geography_seed", world.get("seed", 0))),
		int(world.get("generator_version", 1)),
		grid.size_key,
		band,
		longitude_index
	]

static func _generator_recipe(world: Dictionary) -> Dictionary:
	var recipe: Dictionary = world.duplicate(true)
	recipe["id"] = str(world.get("id", world.get("planet_id", ""))).to_lower()
	recipe["geography_seed"] = int(world.get("geography_seed", world.get("seed", 0)))
	recipe["generator_version"] = int(world.get("generator_version", 1))
	recipe["archetype"] = str(world.get("archetype", "temperate"))
	if not recipe.get("sites", []) is Array:
		recipe["sites"] = []
	return recipe

static func _center_up(band: int, longitude_index: int, grid: Dictionary) -> Vector3:
	var latitude: float = -PI * 0.5 + (float(band) + 0.5) * grid.lat_step
	var longitude: float = -PI + (float(longitude_index) + 0.5) * _TAU / float(grid.longitude_counts[band])
	return _direction(latitude, longitude)

static func _cell_for_up(up: Vector3, grid: Dictionary) -> Vector2i:
	var unit: Vector3 = _unit_or_north(up)
	var latitude: float = asin(clampf(unit.y, -1.0, 1.0))
	var band: int = clampi(int(floor((latitude + PI * 0.5) / grid.lat_step)), 0, grid.band_count - 1)
	var longitude_count: int = int(grid.longitude_counts[band])
	var longitude: float = atan2(unit.x, unit.z)
	var longitude_index: int = mini(longitude_count - 1, int(floor(fposmod(longitude + PI, _TAU) / _TAU * longitude_count)))
	return Vector2i(band, longitude_index)

static func _direction(latitude: float, longitude: float) -> Vector3:
	return Vector3(cos(latitude) * sin(longitude), sin(latitude), cos(latitude) * cos(longitude)).normalized()

static func _great_circle_distance(first: Vector3, second: Vector3, radius: float) -> float:
	return acos(clampf(first.dot(second), -1.0, 1.0)) * radius

static func _unit_or_north(value: Vector3) -> Vector3:
	if not is_finite(value.length_squared()) or value.length_squared() <= 1.0e-12:
		return Vector3.UP
	return value.normalized()

static func _stable_seed(source: String) -> int:
	var value: int = 104729
	for index: int in range(source.length()):
		value = int((value * 257 + source.unicode_at(index) + index) % 2147483647)
	return maxi(1, value)
