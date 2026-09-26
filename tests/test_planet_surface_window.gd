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
var checks: int = 0

func _initialize() -> void:
	_test_repeatable_window_and_local_positions()
	_test_center_crossing_changes_region_window()
	_test_planet_seed_changes_identity()
	_test_feature_kinds_have_independent_streams()
	_test_habitat_roles_create_coherent_groups()
	_test_habitat_roles_form_stable_worldwide_clusters()
	_test_output_is_bounded()
	print("Planet surface window checks: assertions=", checks, " failures=", failures)
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
	var grid: Dictionary = SurfaceWindow._grid(PLANET_RADIUS_M, REGION_SIZE_M)
	for region: Dictionary in first.regions:
		_check(region.up.length_squared() > 0.999, "region source direction is normalized")
		var region_cell: Vector2i = SurfaceWindow._cell_for_up(region.up, grid)
		_check(region.habitat_role == SurfaceWindow._habitat_role_for_cell(region.biome, region.id, region_cell.x, region_cell.y), "region habitat role follows biome and stable spherical cluster coordinates")
		_check(region.position_m.distance_to(Coordinates.local_offset(center, region.up, PLANET_RADIUS_M)) < 0.001, "region position uses the shared tangent transform")
		for feature: Dictionary in region.features:
			_check(feature.region_id == region.id, "feature record retains its parent region id")
			_check(feature.biome == region.biome, "feature record retains its sampled biome")
			_check(feature.habitat_role == region.habitat_role, "feature grouping follows the parent habitat role")
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
	var first_features: Dictionary = {}
	for feature: Dictionary in first.features: first_features[feature.id] = feature
	var stable_overlap: bool = false
	for feature: Dictionary in second.features:
		if first_features.has(feature.id) and _same_stable_feature(first_features[feature.id], feature):
			stable_overlap = true
			break
	_check(stable_overlap, "crossing a streamed window keeps overlapping habitat identities and placements stable")

func _test_planet_seed_changes_identity() -> void:
	var center: Vector3 = Coordinates.direction(-12.0, 143.0)
	var first: Dictionary = SurfaceWindow.build(_world(6421), center, PLANET_RADIUS_M, REGION_SIZE_M, VIEW_RADIUS_M)
	var second: Dictionary = SurfaceWindow.build(_world(6422), center, PLANET_RADIUS_M, REGION_SIZE_M, VIEW_RADIUS_M)
	_check(not first.features.is_empty() and not second.features.is_empty(), "both planet recipes produce feature data")
	_check(first.features[0].id != second.features[0].id, "planet seed participates in stable feature identity")

func _test_feature_kinds_have_independent_streams() -> void:
	var world: Dictionary = _world(6421)
	var grid: Dictionary = SurfaceWindow._grid(PLANET_RADIUS_M, REGION_SIZE_M)
	var region_id: String = SurfaceWindow._region_id(world, grid, 50, 80)
	var center: Vector3 = Coordinates.direction(21.0, 15.0)
	var counts: Array[int] = [2, 1, 2, 1]
	var changed_cover_counts: Array[int] = [5, 1, 2, 1]
	var baseline: Array[Dictionary] = SurfaceWindow._make_features_for_counts(region_id, 50, 80, grid, "lowland", center, PLANET_RADIUS_M, counts)
	var changed: Array[Dictionary] = SurfaceWindow._make_features_for_counts(region_id, 50, 80, grid, "lowland", center, PLANET_RADIUS_M, changed_cover_counts, {"cover": 7})
	var test_longitude_index: int = 80
	var test_band: int = 50
	_check(_records_for_kind(baseline, "rock") == _records_for_kind(changed, "rock"), "cover count and draw changes leave rock records unchanged")
	_check(_records_for_kind(baseline, "flora") == _records_for_kind(changed, "flora"), "cover count and draw changes leave flora records unchanged")
	_check(_records_for_kind(baseline, "fauna") == _records_for_kind(changed, "fauna"), "cover count and draw changes leave fauna records unchanged")
	_check(_records_for_kind(baseline, "rock")[0].id == "%s|feature|rock|1" % region_id, "each kind starts its IDs from its own slot")
	_check(_records_for_kind(baseline, "flora")[0].id == "%s|feature|flora|1" % region_id, "flora identity does not inherit another kind's serial")
	_check(_records_for_kind(baseline, "mineral") == _records_for_kind(changed, "mineral"), "cover count and draw changes leave mineral records unchanged")
	var mineral_found: bool = not _records_for_kind(baseline, "mineral").is_empty()
	for candidate: int in range(1, 150):
		if mineral_found:
			break
		test_longitude_index = 20 + candidate
		region_id = SurfaceWindow._region_id(world, grid, test_band, test_longitude_index)
		baseline = SurfaceWindow._make_features_for_counts(region_id, test_band, test_longitude_index, grid, "lowland", center, PLANET_RADIUS_M, counts)
		changed = SurfaceWindow._make_features_for_counts(region_id, test_band, test_longitude_index, grid, "lowland", center, PLANET_RADIUS_M, changed_cover_counts, {"cover": 7})
		mineral_found = not _records_for_kind(baseline, "mineral").is_empty()
	if mineral_found:
		_check(_records_for_kind(baseline, "mineral") == _records_for_kind(changed, "mineral"), "mineral identity and placement survive unrelated stream changes")
	else:
		_check(false, "test recipes include a mineral for stream-isolation coverage")
	var repeat: Array[Dictionary] = SurfaceWindow._make_features_for_counts(region_id, test_band, test_longitude_index, grid, "lowland", center, PLANET_RADIUS_M, counts)
	_check(_records_for_kind(baseline, "cover") == _records_for_kind(repeat, "cover"), "identical feature recipes reproduce category records")
	var role_baseline: Array[Dictionary] = SurfaceWindow._make_features_for_counts(region_id, test_band, test_longitude_index, grid, "lowland", center, PLANET_RADIUS_M, counts, {}, "grove")
	var role_changed: Array[Dictionary] = SurfaceWindow._make_features_for_counts(region_id, test_band, test_longitude_index, grid, "lowland", center, PLANET_RADIUS_M, changed_cover_counts, {"cover": 7}, "grove")
	_check(_records_for_kind(role_baseline, "rock") == _records_for_kind(role_changed, "rock"), "habitat clustering retains rock stream independence")
	_check(_records_for_kind(role_baseline, "flora") == _records_for_kind(role_changed, "flora"), "habitat clustering retains flora stream independence")
	_check(_records_for_kind(role_baseline, "fauna") == _records_for_kind(role_changed, "fauna"), "habitat clustering retains fauna stream independence")

func _test_habitat_roles_create_coherent_groups() -> void:
	var world: Dictionary = _world(1948)
	var grid: Dictionary = SurfaceWindow._grid(PLANET_RADIUS_M, REGION_SIZE_M)
	var center: Vector3 = Coordinates.direction(21.0, 15.0)
	var cell: Vector2i = SurfaceWindow._cell_for_up(center, grid)
	var region_id: String = SurfaceWindow._region_id(world, grid, cell.x, cell.y)
	var region_up: Vector3 = SurfaceWindow._center_up(cell.x, cell.y, grid)
	var role: String = SurfaceWindow._habitat_role("forest", region_id)
	var features: Array[Dictionary] = SurfaceWindow._make_features(region_id, cell.x, cell.y, grid, "forest", center, PLANET_RADIUS_M)
	var repeated_role: String = SurfaceWindow._habitat_role("forest", region_id)
	var repeated: Array[Dictionary] = SurfaceWindow._make_features(region_id, cell.x, cell.y, grid, "forest", center, PLANET_RADIUS_M)
	_check(role == repeated_role and features == repeated, "a biome habitat role produces stable clustered records")
	var grouped_kinds: Dictionary = {}
	var kind_counts: Dictionary = {}
	var compact: bool = true
	for feature: Dictionary in features:
		grouped_kinds[feature.kind] = true
		kind_counts[feature.kind] = int(kind_counts.get(feature.kind, 0)) + 1
		compact = compact and SurfaceWindow._great_circle_distance(region_up, feature.up, PLANET_RADIUS_M) < 160.0
		_check(feature.habitat_role == role, "feature records retain their reusable habitat role")
	_check(grouped_kinds.has("rock") and grouped_kinds.has("flora") and grouped_kinds.has("fauna"), "forest habitat roles yield grouped rocks, plants and wildlife")
	_check(compact, "habitat feature positions cluster around their stable region patch")
	var role_ranges: Array = SurfaceWindow._feature_count_ranges("forest", role).forest
	var role_kinds: Array[String] = ["cover", "rock", "flora", "fauna"]
	for kind_index: int in range(role_kinds.size()):
		var role_count_range: Array = role_ranges[kind_index]
		var role_count: int = int(kind_counts.get(role_kinds[kind_index], 0))
		_check(role_count >= int(role_count_range[0]) and role_count <= int(role_count_range[1]), "habitat role selects its authored group-size range")
	_check(SurfaceWindow._HABITAT_PROFILES["scree"].spread < SurfaceWindow._HABITAT_PROFILES["meadow"].spread, "rocky and meadow roles retain distinct cluster spreads")

func _test_habitat_roles_form_stable_worldwide_clusters() -> void:
	var world: Dictionary = _world(1948)
	var grid: Dictionary = SurfaceWindow._grid(PLANET_RADIUS_M, REGION_SIZE_M)
	var roles: Dictionary = {}
	var repeated: bool = true
	var neighboring_cluster_cells_match: bool = true
	var candidate_regions: int = 0
	for band: int in range(24, 48, 3):
		for longitude_index: int in range(0, 60, 4):
			var region_id: String = SurfaceWindow._region_id(world, grid, band, longitude_index)
			var role: String = SurfaceWindow._habitat_role_for_cell("forest", region_id, band, longitude_index)
			var repeated_role: String = SurfaceWindow._habitat_role_for_cell("forest", region_id, band, longitude_index)
			repeated = repeated and role == repeated_role
			roles[role] = true
			candidate_regions += 1
			for local_band: int in range(3):
				for local_longitude: int in range(4):
					var neighbor_band: int = band + local_band
					var neighbor_longitude: int = longitude_index + local_longitude
					var neighbor_id: String = SurfaceWindow._region_id(world, grid, neighbor_band, neighbor_longitude)
					var neighbor_role: String = SurfaceWindow._habitat_role_for_cell("forest", neighbor_id, neighbor_band, neighbor_longitude)
					neighboring_cluster_cells_match = neighboring_cluster_cells_match and role == neighbor_role
	_check(candidate_regions >= 30, "habitat role survey spans many spherical cells beyond one landing region")
	_check(repeated, "habitat role clusters are stable at distant coordinates")
	_check(neighboring_cluster_cells_match, "each habitat role persists across its coarse multi-region cluster")
	_check(roles.size() >= 2, "distant forest clusters retain more than one habitat role")

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

func _records_for_kind(records: Array[Dictionary], kind: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for record: Dictionary in records:
		if str(record.kind) == kind:
			result.append(record)
	return result

func _same_stable_feature(first: Dictionary, second: Dictionary) -> bool:
	return (
		first.id == second.id
		and first.region_id == second.region_id
		and first.kind == second.kind
		and first.biome == second.biome
		and first.habitat_role == second.habitat_role
		and first.up == second.up
		and first.variant == second.variant
		and first.size == second.size
		and first.yaw == second.yaw
	)

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: ", message)
