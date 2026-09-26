extends SceneTree

const Geography = preload("res://scripts/planet_geography.gd")
const Runtime = preload("res://scripts/planet_surface_runtime.gd")

var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: "+message)

func run() -> void:
	var world: Dictionary = Geography.definition("morrow")
	var runtime := Runtime.new(world)
	var repeated := Runtime.new(world.duplicate(true))
	var center: Vector3 = Geography.site_direction("morrow")
	var cached_runtime: Object = Geography.surface_runtime(world)
	check(cached_runtime == Geography.surface_runtime(world.duplicate(true)), "identical normalized recipe inputs reuse one geography runtime")
	var changed_archetype: Dictionary = world.duplicate(true)
	changed_archetype.archetype = "arid"
	check(cached_runtime != Geography.surface_runtime(changed_archetype), "runtime cache distinguishes archetype inputs")
	var changed_sites: Dictionary = world.duplicate(true)
	changed_sites.sites[0]["longitude"] = 75.0
	check(cached_runtime != Geography.surface_runtime(changed_sites), "runtime cache distinguishes authored site directions")
	var changed_climate: Dictionary = world.duplicate(true)
	changed_climate["climate"] = {"equator_temperature": -24.0}
	check(cached_runtime != Geography.surface_runtime(changed_climate), "runtime cache distinguishes climate overrides")
	var sample: Dictionary = runtime.sample(center)
	check(sample == repeated.sample(center), "the façade samples identical geography for an identical saved recipe")
	check(runtime.surface_color(center) == repeated.surface_color(center), "surface color uses the same deterministic spherical sample")
	var across: Vector3 = runtime.advance(center, 620.0, 0.0)
	check(is_equal_approx(across.length(), 1.0) and across.distance_to(repeated.advance(center, 620.0, 0.0)) < 1.0e-8, "geodesic advance is normalized and repeatable")
	var offset: Vector2 = runtime.local_offset(center, across)
	check(absf(offset.x-620.0) < 0.01 and absf(offset.y) < 0.01, "the tangent offset recovers the requested short geodesic step")
	var at_center: Dictionary = runtime.window(center)
	var at_adjacent: Dictionary = runtime.window(across)
	var repeated_window: Dictionary = repeated.window(center)
	check(at_center.current_region_id == repeated_window.current_region_id, "the same recipe and center keep a stable region identity")
	check(at_center.current_region_id != at_adjacent.current_region_id, "advancing into an adjacent cell selects a different stable region identity")
	var scaled := Runtime.new(world, 32000.0, 256.0, 1200.0)
	var scaled_across: Vector3 = scaled.advance(center, 620.0, 0.0)
	var scaled_window: Dictionary = scaled.window(center)
	var scaled_offset: Vector2 = scaled.local_offset(center, scaled_across)
	check(scaled.planet_radius_m == 32000.0 and scaled_window.planet_radius_m == 32000.0, "constructor-bound non-default radius is shared by advance, window and offset")
	check(scaled_window.requested_region_size_m == 256.0 and scaled_window.view_radius_m == 1200.0 and absf(scaled_offset.x-620.0) < 0.01, "constructor-bound region and view scales stay consistent across runtime operations")
	print("Planet surface runtime checks: ", checks, "; failures: ", failures)
	quit(0 if failures == 0 else 1)
