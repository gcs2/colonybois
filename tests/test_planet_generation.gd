extends SceneTree
const Generator = preload("res://scripts/planet_generator.gd")
const Geography = preload("res://scripts/planet_geography.gd")
const SurfaceCoordinates = preload("res://scripts/planet_surface_coordinates.gd")
var failures: int = 0
var checks: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+message)
func run() -> void:
	var source: Dictionary = Geography.definition().duplicate(true)
	var original: Dictionary = source.duplicate(true)
	var a := Generator.new(source)
	var b := Generator.new(source)
	check(source == original,"Constructing geography does not mutate planet definitions")
	var changed := Generator.new(Generator.make_recipe("other",999,"temperate"))
	var frozen := Generator.new(Generator.make_recipe("ice",1948,"frozen"))
	var arid := Generator.new(Generator.make_recipe("sand",1948,"arid"))
	var deterministic: bool = true
	var distinct: bool = false
	var cold: bool = true
	var dry: bool = true
	var valid: bool = true
	var biomes: Dictionary = {}
	for latitude: int in range(-80,81,20):
		for longitude: int in range(-180,180,20):
			var direction: Vector3 = Generator.direction(latitude,longitude)
			var cell: Dictionary = a.sample(direction)
			deterministic = deterministic and cell == b.sample(direction)
			distinct = distinct or cell.elevation != changed.sample(direction).elevation
			cold = cold and frozen.sample(direction).temperature_c < cell.temperature_c
			dry = dry and arid.sample(direction).moisture < cell.moisture
			valid = valid and is_finite(cell.elevation) and cell.moisture >= 0 and cell.moisture <= 1 and cell.clouds >= 0 and cell.clouds <= 1
			biomes[cell.biome] = true
	check(deterministic,"Repeated seeds produce identical geographic and climate samples")
	check(distinct,"Different seeds change actual elevation")
	check(cold and dry,"Archetypes change physical climate rather than only color")
	check(valid,"Spherical samples remain finite and bounded across the globe")
	check(biomes.has("ocean") and biomes.size() >= 4,"Authored landing constraint preserves oceans and diverse biomes")
	check(a.sample(Geography.site_direction()).elevation > 0,"Morrow's fixed landing site is on land")
	check(a.region_sample(15.9454,0,0,0) == a.sample(Geography.site_direction()),"Regional origin is exactly the same geographic sample as its globe site")
	var morrow_generator := Generator.new(Geography.definition("morrow"))
	var lake: Dictionary = morrow_generator.waterbody_specs()[0]
	var lake_center: Vector3 = lake.center_up
	var lake_sample: Dictionary = morrow_generator.sample(lake_center)
	var morrow_runtime: Object = Geography.surface_runtime(Geography.definition("morrow"))
	var runtime_lakes: Array[Dictionary] = morrow_runtime.generator.waterbody_specs()
	var runtime_lake_sample: Dictionary = morrow_runtime.sample(lake_center)
	var lake_edge_up: Vector3 = SurfaceCoordinates.advance(lake_center,float(lake.east_radius_m)*1.2,0.0,Generator.SURFACE_RADIUS_M)
	var lake_edge: Dictionary = morrow_generator.sample(lake_edge_up)
	var repeated_morrow := Generator.new(Geography.definition("morrow"))
	var repeated_lake: Dictionary = repeated_morrow.sample(lake_center)
	check(lake_sample.waterbody_id == lake.id and lake_sample.elevation < -0.025,"The recipe-authored Morrow lake is a depressed waterbody in the shared spherical sampler")
	check(runtime_lakes.size() == 1 and runtime_lakes[0].id == lake.id and runtime_lake_sample.elevation < -0.025,"The Morrow surface runtime retains the recipe lake and samples its submerged floor")
	check(str(lake_edge.waterbody_id).is_empty() and lake_edge.elevation > lake_sample.elevation,"The sampled lake has a stable shoreline beyond its basin floor")
	check(morrow_generator.surface_color(lake_sample) == repeated_morrow.surface_color(repeated_lake),"The lake water color repeats from the same versioned planet recipe")
	var warmed_recipe: Dictionary = frozen.recipe.duplicate(true)
	warmed_recipe.climate = {"equator_temperature":29.0}
	var warmed := Generator.new(warmed_recipe)
	var sample_at: Vector3 = Generator.direction(30,42)
	check(warmed.sample(sample_at).elevation == frozen.sample(sample_at).elevation and warmed.sample(sample_at).temperature_c > frozen.sample(sample_at).temperature_c,"Warming changes climate while preserving geography")
	var watered_recipe: Dictionary = arid.recipe.duplicate(true)
	watered_recipe.climate = {"moisture":0.63}
	var watered := Generator.new(watered_recipe)
	check(watered.sample(sample_at).elevation == arid.sample(sample_at).elevation and watered.sample(sample_at).moisture > arid.sample(sample_at).moisture,"Water recovery changes humidity without relocating coasts")
	var left: Dictionary = a.sample(Generator.direction(12,-180))
	var right: Dictionary = a.sample(Generator.direction(12,180))
	check(is_equal_approx(left.elevation,right.elevation) and is_equal_approx(left.moisture,right.moisture),"Longitude seam is continuous")
	var maps_a: Dictionary = a.maps(64)
	Generator.map_cache.clear()
	var maps_b: Dictionary = b.maps(64)
	check(maps_a.albedo.get_image().get_data() == maps_b.albedo.get_image().get_data(),"Rebuilding produces identical surface pixels")
	check(maps_a.conditions.get_image().get_data() == maps_b.conditions.get_image().get_data(),"Climate map is reproducible independently of cache")
	check(maps_a.normals.get_image().get_data() == maps_b.normals.get_image().get_data(),"Relief normals are reproducible")
	check(b.maps(64).albedo == maps_b.albedo,"Repeated views reuse baked textures")
	for i: int in range(7): Generator.new(Generator.make_recipe(str(i),i,"arid")).maps(32)
	check(Generator.map_cache.size() == 4,"Visiting many worlds cannot grow the texture cache without bound")
	check(maps_a.albedo.get_width() == 64,"Eviction leaves textures owned by visible globes intact")
	print("Planet generation assertions: ",checks,"; failures: ",failures)
	quit(0 if failures == 0 else 1)
