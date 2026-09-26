extends SceneTree

const SurfaceRegions = preload("res://scripts/planet_surface_regions.gd")
const PlanetGenerator = preload("res://scripts/planet_generator.gd")
const PLANET_RADIUS_M: float = 6371000.0
const REGION_SIZE_M: float = 250000.0

func _initialize() -> void:
	_test_seed_repeatability()
	_test_seed_changes_identity_and_content()
	_test_biome_comes_from_planet_recipe()
	_test_longitude_wrap()
	_test_polar_positions_are_finite()
	_test_nearby_query_is_bounded()
	print("Planet surface region checks passed.")
	quit()

func _test_seed_repeatability() -> void:
	var world: Dictionary = _world(6421)
	var point: Vector3 = _direction(deg_to_rad(28.0), deg_to_rad(63.0))
	var first: String = SurfaceRegions.region_key(world, point, PLANET_RADIUS_M, REGION_SIZE_M)
	var second: String = SurfaceRegions.region_key(world, point, PLANET_RADIUS_M, REGION_SIZE_M)
	assert(first == second)
	var first_nearby: Array[Dictionary] = SurfaceRegions.nearby_regions(world, point, REGION_SIZE_M * 1.7, PLANET_RADIUS_M, REGION_SIZE_M)
	var second_nearby: Array[Dictionary] = SurfaceRegions.nearby_regions(world, point, REGION_SIZE_M * 1.7, PLANET_RADIUS_M, REGION_SIZE_M)
	assert(first_nearby == second_nearby)
	assert(not first_nearby.is_empty())

func _test_seed_changes_identity_and_content() -> void:
	var point: Vector3 = _direction(deg_to_rad(-12.0), deg_to_rad(143.0))
	var first: Array[Dictionary] = SurfaceRegions.nearby_regions(_world(6421), point, REGION_SIZE_M, PLANET_RADIUS_M, REGION_SIZE_M)
	var second: Array[Dictionary] = SurfaceRegions.nearby_regions(_world(6422), point, REGION_SIZE_M, PLANET_RADIUS_M, REGION_SIZE_M)
	assert(not first.is_empty() and not second.is_empty())
	assert(first[0].id != second[0].id)
	assert(first[0].features != second[0].features)

func _test_biome_comes_from_planet_recipe() -> void:
	var world: Dictionary = _world(6421)
	var recipe: Dictionary = PlanetGenerator.make_recipe("test-world", 6421, "temperate")
	var generator := PlanetGenerator.new(recipe)
	var regions: Array[Dictionary] = SurfaceRegions.nearby_regions(world, Vector3.UP, 500000.0, PLANET_RADIUS_M, REGION_SIZE_M)
	assert(not regions.is_empty())
	for region: Dictionary in regions:
		assert(region.biome == generator.sample(region.center_up).biome)
	var frozen_world: Dictionary = world.duplicate(true)
	frozen_world.archetype = "frozen"
	var frozen_recipe: Dictionary = PlanetGenerator.make_recipe("test-world", 6421, "frozen")
	var frozen_generator := PlanetGenerator.new(frozen_recipe)
	var frozen_regions: Array[Dictionary] = SurfaceRegions.nearby_regions(frozen_world, Vector3.UP, 500000.0, PLANET_RADIUS_M, REGION_SIZE_M)
	assert(not frozen_regions.is_empty())
	for region: Dictionary in frozen_regions:
		assert(region.biome == frozen_generator.sample(region.center_up).biome)

func _test_longitude_wrap() -> void:
	var world: Dictionary = _world(6421)
	var east_side: Vector3 = _direction(deg_to_rad(12.0), PI + 1.0e-7)
	var west_side: Vector3 = _direction(deg_to_rad(12.0), -PI + 1.0e-7)
	assert(SurfaceRegions.region_key(world, east_side, PLANET_RADIUS_M, REGION_SIZE_M) == SurfaceRegions.region_key(world, west_side, PLANET_RADIUS_M, REGION_SIZE_M))
	var near_seam: Array[Dictionary] = SurfaceRegions.nearby_regions(world, east_side, 300000.0, PLANET_RADIUS_M, REGION_SIZE_M)
	assert(not near_seam.is_empty())
	for region: Dictionary in near_seam:
		assert(region.center_up.length_squared() > 0.999)

func _test_polar_positions_are_finite() -> void:
	var world: Dictionary = _world(6421)
	var polar: Array[Dictionary] = SurfaceRegions.nearby_regions(world, Vector3(1.0e-12, 1.0, -1.0e-12), 1000000.0, PLANET_RADIUS_M, REGION_SIZE_M)
	assert(not polar.is_empty())
	for region: Dictionary in polar:
		assert(_finite_vector(region.center_up))
		for feature: Dictionary in region.features:
			assert(_finite_vector(feature.up))
			assert(is_finite(float(feature.size)))
			assert(is_finite(float(feature.yaw)))

func _test_nearby_query_is_bounded() -> void:
	var world: Dictionary = _world(6421)
	var regions: Array[Dictionary] = SurfaceRegions.nearby_regions(world, Vector3.UP, 1.0e30, PLANET_RADIUS_M, 100000000.0)
	assert(regions.size() <= 256)
	assert(regions.size() <= 4096)
	for region: Dictionary in regions:
		assert(_finite_vector(region.center_up))

func _world(seed_value: int) -> Dictionary:
	return {"id": "test-world", "geography_seed": seed_value, "generator_version": PlanetGenerator.VERSION, "archetype": "temperate", "sites": []}

func _direction(latitude: float, longitude: float) -> Vector3:
	return Vector3(cos(latitude) * sin(longitude), sin(latitude), cos(latitude) * cos(longitude)).normalized()

func _finite_vector(value: Vector3) -> bool:
	return is_finite(value.x) and is_finite(value.y) and is_finite(value.z)
