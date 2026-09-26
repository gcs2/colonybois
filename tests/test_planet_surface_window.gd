extends SceneTree

const SurfaceWindow = preload("res://scripts/planet_surface_window.gd")
const Coordinates = preload("res://scripts/planet_surface_coordinates.gd")
const PlanetGenerator = preload("res://scripts/planet_generator.gd")

const PLANET_RADIUS_M: float = 16000.0
const REGION_SIZE_M: float = 512.0
const VIEW_RADIUS_M: float = 1100.0
const MAX_WINDOW_REGIONS: int = 512
const MAX_WINDOW_FEATURES: int = 8192
var failures: int = 0

func _initialize() -> void:
	_test_repeatable_window_and_local_positions()
	_test_center_crossing_changes_region_window()
	_test_planet_seed_changes_identity()
	_test_output_is_bounded()
	print("Planet surface window checks: failures=", failures)
	quit(0 if failures == 0 else 1)

func _test_repeatable_window_and_local_positions() -> void:
	var world: Dictionary = _world(6421)
	var center: Vector3 = Coordinates.direction(21.0, 15.0)
	var first: Dictionary = SurfaceWindow.build(world, center, PLANET_RADIUS_M, REGION_SIZE_M, VIEW_RADIUS_M)
	var repeat: Dictionary = SurfaceWindow.build(world, center, PLANET_RADIUS_M, REGION_SIZE_M, VIEW_RADIUS_M)
	_check(first == repeat, "the same recipe and center reproduce the same records")
	_check(not first.regions.is_empty() and not first.features.is_empty(), "the requested view returns regions and features")
	var flattened_ids: Dictionary = {}
	for feature: Dictionary in first.features:
		flattened_ids[feature.id] = feature
	for region: Dictionary in first.regions:
		_check(region.up.length_squared() > 0.999, "region source direction is normalized")
		_check(region.position_m.distance_to(Coordinates.local_offset(center, region.up, PLANET_RADIUS_M)) < 0.001, "region position uses the shared tangent transform")
		for feature: Dictionary in region.features:
			_check(feature.region_id == region.id, "feature record retains its parent region id")
			_check(feature.biome == region.biome, "feature record retains its sampled biome")
			_check(feature.position_m.distance_to(Coordinates.local_offset(center, feature.up, PLANET_RADIUS_M)) < 0.001, "feature position uses the shared tangent transform")
			_check(flattened_ids.has(feature.id), "region feature appears in the flattened window list")

func _test_center_crossing_changes_region_window() -> void:
	var world: Dictionary = _world(6421)
	var center: Vector3 = Coordinates.direction(21.0, 15.0)
	var across_boundary: Vector3 = Coordinates.advance(center, REGION_SIZE_M * 2.5, 0.0, PLANET_RADIUS_M)
	var first: Dictionary = SurfaceWindow.build(world, center, PLANET_RADIUS_M, REGION_SIZE_M, VIEW_RADIUS_M)
	var second: Dictionary = SurfaceWindow.build(world, across_boundary, PLANET_RADIUS_M, REGION_SIZE_M, VIEW_RADIUS_M)
	var first_ids: Array[String] = _region_ids(first.regions)
	var second_ids: Array[String] = _region_ids(second.regions)
	_check(first_ids != second_ids, "moving across cells changes the stable region window")
	_check(first.center_up != second.center_up, "the returned window records its new center")
	_check(first.current_region_id != second.current_region_id, "the current region identity changes across the cell boundary")
	_check(not str(first.current_biome).is_empty() and not str(second.current_biome).is_empty(), "the current region returns its sampled biome")

func _test_planet_seed_changes_identity() -> void:
	var center: Vector3 = Coordinates.direction(-12.0, 143.0)
	var first: Dictionary = SurfaceWindow.build(_world(6421), center, PLANET_RADIUS_M, REGION_SIZE_M, VIEW_RADIUS_M)
	var second: Dictionary = SurfaceWindow.build(_world(6422), center, PLANET_RADIUS_M, REGION_SIZE_M, VIEW_RADIUS_M)
	_check(not first.features.is_empty() and not second.features.is_empty(), "both planet recipes produce feature data")
	_check(first.features[0].id != second.features[0].id, "planet seed participates in stable feature identity")

func _test_output_is_bounded() -> void:
	var world: Dictionary = _world(6421)
	var result: Dictionary = SurfaceWindow.build(world, Coordinates.direction(0.0, 0.0), PLANET_RADIUS_M, 0.1, 1.0e30)
	_check(result.regions.size() <= MAX_WINDOW_REGIONS, "region output remains capped")
	_check(result.features.size() <= MAX_WINDOW_FEATURES, "feature output remains capped")
	_check(result.truncated, "oversized requests report when bounded data is truncated")
	_check(result.effective_region_size_m > result.requested_region_size_m, "sub-meter cells clamp to the documented grid resolution")
	var defaults: Dictionary = SurfaceWindow.build(world, Vector3.UP)
	_check(is_equal_approx(defaults.requested_region_size_m, SurfaceWindow.DEFAULT_REGION_SIZE_M), "default region size matches the shared expedition value")
	_check(is_equal_approx(defaults.view_radius_m, SurfaceWindow.DEFAULT_VIEW_RADIUS_M), "default view radius matches the shared expedition value")
	_check(absf(defaults.effective_region_size_m - 512.0) < 10.0, "the 512 m region default is honored on the 16 km abstract surface")
	_check(not defaults.truncated, "the normal 1.1 km visible window fits within its data bounds")

func _world(seed_value: int) -> Dictionary:
	var recipe: Dictionary = PlanetGenerator.make_recipe("test-world", seed_value, "temperate")
	recipe["sites"] = []
	return recipe

func _region_ids(regions: Array) -> Array[String]:
	var result: Array[String] = []
	for region: Dictionary in regions:
		result.append(str(region.id))
	return result

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: ", message)
