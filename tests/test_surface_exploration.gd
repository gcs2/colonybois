extends SceneTree

const Geography = preload("res://scripts/planet_geography.gd")
const SurfaceLayout = preload("res://scripts/surface_region_layout.gd")
const Biosphere = preload("res://scripts/planet_biosphere.gd")
const Field = preload("res://scripts/encounter_state.gd")

var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	var guard := create_timer(10.0)
	guard.timeout.connect(_timed_out)
	call_deferred("run")

func _timed_out() -> void:
	failures += 1
	printerr("FAIL: surface exploration test exceeded its 10 second script budget")
	quit(2)

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: "+message)

func run() -> void:
	var world: Dictionary = Geography.definition("morrow")
	var same_world: Dictionary = world.duplicate(true)
	var habitats: Array[Dictionary] = SurfaceLayout.regions(world)
	check(Geography.PLAYABLE_RADIUS == 256.0,"The authored exploration envelope is a shared deterministic bound")
	check(habitats.size() == 3 and habitats[0].id == "morrow_basin","Morrow retains its landing basin and gains two adjacent habitats")
	for habitat: Dictionary in habitats:
		check(SurfaceLayout.region_at(world,habitat.center).id == habitat.id,"Each named habitat is selected at its stable center")
	var tile := Vector2i(1,2)
	var first_features: Array[Dictionary] = SurfaceLayout.tile_features(world,tile)
	var repeat_features: Array[Dictionary] = SurfaceLayout.tile_features(same_world,tile)
	check(first_features == repeat_features and not first_features.is_empty(),"A planet tile reproduces identical data for the same recipe")
	var kinds: Dictionary = {}
	for feature: Dictionary in first_features:
		kinds[feature.kind] = true
		var point: Vector2 = feature.position
		check(floori(point.x/SurfaceLayout.FEATURE_TILE_SIZE) == tile.x and floori(point.y/SurfaceLayout.FEATURE_TILE_SIZE) == tile.y,"Feature positions stay inside their keyed tile")
	check(kinds.has("cover") and kinds.has("flora") and kinds.has("rock"),"Surface tiles carry ground cover, plants and rock features")
	var basin_probe := Vector2(13.0,-11.0)
	check(is_equal_approx(Geography.surface_height(world,basin_probe.x,basin_probe.y),Geography.surface_base(world,basin_probe.x,basin_probe.y)),"The authored Morrow basin remains unchanged")
	var edge_a: float = Geography.surface_height(world,39.0,0.0)
	var edge_b: float = Geography.surface_height(world,39.01,0.0)
	check(absf(edge_a-edge_b) < 0.02,"The seeded outer terrain blends continuously from the basin")
	var sample := Vector2(143.7,-82.2)
	var color_a: Color = Geography.surface_color(world,sample.x,sample.y)
	var color_b: Color = Geography.surface_color(same_world,sample.x,sample.y)
	check(color_a == color_b and is_finite(Geography.surface_height(world,sample.x,sample.y)),"Terrain material and relief are repeatable for the same seed")
	var changed_world: Dictionary = world.duplicate(true)
	changed_world.geography_seed = int(changed_world.geography_seed)+1
	var changed := false
	for point: Vector2 in [Vector2(100,0),Vector2(143.7,-82.2),Vector2(-190,74)]:
		changed = changed or not is_equal_approx(Geography.surface_height(world,point.x,point.y),Geography.surface_height(changed_world,point.x,point.y))
	check(changed,"Changing the planet recipe changes the outer landscape")
	var species_sites: Dictionary = {}
	for id: String in Biosphere.native_species("morrow"):
		var at: Vector3 = Biosphere.position("morrow",id)
		species_sites[id] = [at.x,at.y,at.z]
		check(Vector2(at.x,at.z).length() <= Geography.PLAYABLE_RADIUS,"Native wildlife remains within the reachable Morrow field")
	check(Vector2(species_sites.ribbon_bush[0],species_sites.ribbon_bush[2]).distance_to(Vector2(species_sites.moss_lantern[0],species_sites.moss_lantern[2])) > 100,"Native species occupy distinct, explorable habitats")
	var field := Field.new()
	field.state.position = [170.0,5.0,25.0]
	check(field.change_flight_mode("orbit"),"A scout can leave a distant surface region")
	check(field.state.surface_position == [170.0,5.0,25.0],"Leaving surface stores the exact return site")
	check(field.change_flight_mode("surface") and field.state.position == [170.0,5.0,25.0],"Returning from orbit restores the same surface position")
	var restored := Field.new()
	check(restored.restore_snapshot(field.snapshot()) == OK and restored.state.surface_position == field.state.surface_position,"The regional surface pose survives save validation")
	print("Surface exploration assertions: ",checks,"; failures: ",failures)
	quit(0 if failures == 0 else 1)
