extends RefCounted
## Deterministic, data-only layout for visitable surface habitats.
## Coordinates use the expedition's absolute X/Z plane; no shared RNG is consumed.

const MORROW_ID := "morrow"
const LANDING_CENTER := Vector2.ZERO
const LANDING_RADIUS := 112.0
const ADJACENT_RADIUS := 126.0
const ADJACENT_DISTANCE := 156.0
const FEATURE_TILE_SIZE := 64.0

static func regions(world: Dictionary) -> Array[Dictionary]:
	var planet_id := str(world.get("id", world.get("planet_id", ""))).to_lower()
	if planet_id != MORROW_ID:
		return []
	var seed_value := _recipe_seed(world)
	var layout_rng := RandomNumberGenerator.new()
	layout_rng.seed = _stable_seed(world, "habitats")
	var first_angle := layout_rng.randf_range(-PI, PI)
	var second_angle := first_angle + layout_rng.randf_range(2.05, 2.55)
	var result: Array[Dictionary] = [
		{
			"id": "morrow_basin",
			"name": "Morrow Basin",
			"habitat": "landing_basin",
			"center": LANDING_CENTER,
			"radius": LANDING_RADIUS,
			"terrain": "basin",
			"seed": seed_value
		},
		_make_habitat("glassgrass_reach", "Glassgrass Reach", "open_steppe", first_angle, seed_value),
		_make_habitat("rillstone_shelf", "Rillstone Shelf", "rocky_shelf", second_angle, seed_value)
	]
	return result

static func region_at(world: Dictionary, at: Vector2) -> Dictionary:
	var found: Dictionary = {}
	var nearest := INF
	for region: Dictionary in regions(world):
		var distance: float = at.distance_to(region.center)
		if distance < nearest:
			found = region
			nearest = distance
	return found.duplicate(true)

static func tile_features(world: Dictionary, tile: Vector2i, tile_size: float = FEATURE_TILE_SIZE) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if str(world.get("id", world.get("planet_id", ""))).to_lower() != MORROW_ID or tile_size <= 0.0:
		return result
	var recipe_seed := _stable_seed(world, "tile:%d:%d:%s" % [tile.x, tile.y, _float_key(tile_size)])
	var rng := RandomNumberGenerator.new()
	rng.seed = recipe_seed
	var region_cache := regions(world)
	var feature_counts := {
		"cover": rng.randi_range(11, 17),
		"rock": rng.randi_range(2, 4),
		"flora": rng.randi_range(4, 7),
		"fauna": rng.randi_range(1, 3) if rng.randf() < 0.58 else 0
	}
	var kinds: Array[String] = ["cover", "rock", "flora", "fauna"]
	var serial := 0
	for kind: String in kinds:
		# Flora grows in two recipe-stable clumps per tile; fauna arrive in small
		# local groups. Cover and geology retain the broader scatter pattern.
		var clusters: Array[Vector2] = []
		if kind == "flora":
			for _cluster: int in range(2):
				clusters.append(Vector2(
					(float(tile.x) + rng.randf_range(0.22, 0.78)) * tile_size,
					(float(tile.y) + rng.randf_range(0.22, 0.78)) * tile_size
				))
		elif kind == "fauna" and int(feature_counts[kind]) > 0:
			clusters.append(Vector2(
				(float(tile.x) + rng.randf_range(0.24, 0.76)) * tile_size,
				(float(tile.y) + rng.randf_range(0.24, 0.76)) * tile_size
			))
		for _index: int in range(int(feature_counts[kind])):
			var position: Vector2
			if not clusters.is_empty():
				var cluster_index: int = mini(clusters.size() - 1, _index * clusters.size() / maxi(1, int(feature_counts[kind])))
				var cluster: Vector2 = clusters[cluster_index]
				position = cluster + Vector2(rng.randfn(0.0, 5.5 if kind == "flora" else 8.0), rng.randfn(0.0, 5.5 if kind == "flora" else 8.0))
				position.x = clampf(position.x, float(tile.x) * tile_size + 2.0, float(tile.x + 1) * tile_size - 2.0)
				position.y = clampf(position.y, float(tile.y) * tile_size + 2.0, float(tile.y + 1) * tile_size - 2.0)
			else:
				position = Vector2(
					(float(tile.x) + rng.randf()) * tile_size,
					(float(tile.y) + rng.randf()) * tile_size
				)
			var habitat := _region_at_cached(region_cache, position)
			if habitat.is_empty():
				continue
			serial += 1
			var variant_count: int = {"cover": 6, "rock": 5, "flora": 6, "fauna": 3}[kind]
			result.append({
				"id": "%s:%d:v%d:%d:%d:%s:%02d" % [MORROW_ID, _recipe_seed(world), int(world.get("generator_version", 1)), tile.x, tile.y, kind, serial],
				"kind": kind,
				"variant": rng.randi_range(0, variant_count - 1),
				"position": position,
				"size": rng.randf_range(0.72, 1.32) if kind != "fauna" else rng.randf_range(0.9, 1.12),
				"rotation": rng.randf_range(-PI, PI),
				"habitat_id": str(habitat.id)
			})
	return result

static func _make_habitat(id: String, name: String, terrain: String, angle: float, seed_value: int) -> Dictionary:
	var center := Vector2(cos(angle), sin(angle)) * ADJACENT_DISTANCE
	return {
		"id": id,
		"name": name,
		"habitat": terrain,
		"center": center,
		"radius": ADJACENT_RADIUS,
		"terrain": terrain,
		"seed": seed_value
	}

static func _region_at_cached(candidates: Array[Dictionary], at: Vector2) -> Dictionary:
	var found: Dictionary = {}
	var nearest := INF
	for region: Dictionary in candidates:
		var distance: float = at.distance_to(region.center)
		if distance < nearest:
			found = region
			nearest = distance
	return found

static func _recipe_seed(world: Dictionary) -> int:
	return int(world.get("geography_seed", world.get("seed", 0)))

static func _stable_seed(world: Dictionary, purpose: String) -> int:
	var source := "%s|%d|%d|%s" % [
		str(world.get("id", world.get("planet_id", ""))).to_lower(),
		_recipe_seed(world),
		int(world.get("generator_version", 1)),
		purpose
	]
	var value: int = 104729
	for index: int in range(source.length()):
		value = int((value * 257 + source.unicode_at(index) + index) % 2147483647)
	return maxi(1, value)

static func _float_key(value: float) -> String:
	return "%.3f" % value
