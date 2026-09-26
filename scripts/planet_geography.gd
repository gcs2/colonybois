extends RefCounted
## Planet-fixed coordinates: north +Y; longitude zero +Z, east toward +X.
const PLAYABLE_RADIUS := 256.0
## Temporary first-slice tangent-frame envelope. This is not a planet-scale limit.
const SURFACE_TRAVEL_RADIUS_M := 1200.0
const SurfaceRuntime = preload("res://scripts/planet_surface_runtime.gd")
const PLANET_RADIUS_M := SurfaceRuntime.PROVISIONAL_PLANET_RADIUS_M
static var cached_definition: Dictionary = {}
static var sector_definitions: Dictionary = {}
static var surface_noise_cache: Dictionary = {}
static var surface_runtime_cache: Dictionary = {}

static func surface_travel_radius(planet_id: String) -> float:
	return SURFACE_TRAVEL_RADIUS_M if planet_id.to_lower() == "morrow" else PLAYABLE_RADIUS

static func surface_direction(world: Dictionary, x: float, z: float) -> Vector3:
	var anchor: Vector3 = site_direction(str(world.get("id", "morrow")))
	return surface_runtime(world).advance(anchor, x, z)

static func surface_pose(world: Dictionary, x: float, z: float) -> Vector3:
	return surface_direction(world, x, z)

static func surface_local_position(world: Dictionary, up: Vector3) -> Vector2:
	return surface_runtime(world).local_offset(site_direction(str(world.get("id", world.get("planet_id", "morrow")))), up)

static func surface_region_id(world: Dictionary, up: Vector3) -> String:
	return surface_runtime(world).region_id(up)

static func surface_runtime(world: Dictionary) -> Object:
	var key: String = "%s:%d:%d" % [str(world.get("id", world.get("planet_id", ""))).to_lower(), int(world.get("geography_seed", world.get("seed", 0))), int(world.get("generator_version", 1))]
	var cached: Variant = surface_runtime_cache.get(key)
	if cached is Object and cached.matches_recipe(world): return cached
	var runtime: Object = SurfaceRuntime.new(SurfaceRuntime.normalized_recipe(world))
	surface_runtime_cache[key] = runtime
	if surface_runtime_cache.size() > 4: surface_runtime_cache.erase(surface_runtime_cache.keys()[0])
	return runtime
static func surface_height(world: Dictionary, x: float, z: float) -> float:
	if str(world.get("id", "")) == "morrow":
		# Shared spherical sample drives movement, camera, chart picking, deployment,
		# and combat ground queries through the encounter's existing local frame.
		var runtime: Object = surface_runtime(world)
		var anchor: Vector3 = site_direction(str(world.get("id", "morrow")))
		var sample: Dictionary = runtime.sample(runtime.advance(anchor, x, z))
		return float(sample.elevation) * SurfaceRuntime.PROVISIONAL_HEIGHT_SCALE_M
	var height: float = surface_base(world,x,z)
	if world.archetype != "temperate":
		var basin: float = 1.0-smoothstep(4.4,6.5,Vector2(x-8,z+4).length())
		height = lerpf(height,surface_base(world,8,-4),basin)
	return height

static func surface_base(world: Dictionary, x: float, z: float) -> float:
	var ridge: float = smoothstep(25.0,45.0,Vector2(x,z).length())
	var pool: float = 2.0*exp(-pow((x+23)/6,2)-pow(z/12,2))
	if world.archetype == "frozen": return 0.3+sin(x*0.07+1.3)*cos(z*0.09)*0.5+ridge*(5.5+cos(z*0.13)*2.0)-pool*0.3
	if world.archetype == "arid": return 0.6+sin(x*0.1+z*0.16)*0.8+ridge*(4.0+sin(x*0.12-z*0.18)*2.6)
	return 0.25+sin(x*0.14)*cos(z*0.12)*0.65+ridge*(2.4+sin(x*0.28+z*0.19)*1.6)-pool

## Deterministic material color at planet-local surface coordinates (x, z).
## Morrow color and relief share cached noise fields keyed by its recipe seed/version.
## Other archetypes retain the existing encounter palette calculation.
static func surface_color(world: Dictionary, x: float, z: float) -> Color:
	if world.get("id","") == "morrow":
		var runtime: Object = surface_runtime(world)
		var anchor: Vector3 = site_direction(str(world.get("id", "morrow")))
		return runtime.surface_color(runtime.advance(anchor, x, z))

	var radial_distance: float = Vector2(x,z).length()
	var far_blend: float = smoothstep(55.0,155.0,radial_distance)
	var local_color_mix: float = clampf((sin(x*0.04+z*0.015)+cos(z*0.05))*0.25+0.5,0,1)
	var far_color_mix: float = clampf(0.52+sin(x*0.006+sin(z*0.004)*1.8)*0.14+cos(z*0.007-sin(x*0.003))*0.12,0.25,0.8)
	var color_mix: float = lerpf(local_color_mix,far_color_mix,far_blend)
	var height: float = surface_height(world,x,z)
	height = lerpf(height,_legacy_distant_landform(world,x,z),far_blend)
	height -= pow(maxf(0.0,radial_distance-50.0),2.0)/3200.0
	var color: Color = Color("8c5e4a").lerp(Color("b37d57"),color_mix).lerp(Color("cda077"),smoothstep(1.0,4.0,height))
	if world.archetype == "temperate":
		var pond_distance: float = sqrt(pow((x+23.0)/7.2,2.0)+pow(z/13.5,2.0))
		var shore: float = 1.0-smoothstep(0.85,1.35,pond_distance)
		color = color.lerp(Color("5e4939"),shore*0.75)
	elif world.archetype == "frozen":
		color = Color("708f9b").lerp(Color("a9c2cf"),color_mix).lerp(Color("d1e0e3"),smoothstep(1.0,5.0,height))
	elif world.archetype == "arid":
		color = Color("735565").lerp(Color("ba8b64"),color_mix).lerp(Color("dac49c"),smoothstep(1.0,5.0,height))
	return color

static func _legacy_distant_landform(world: Dictionary, x: float, z: float) -> float:
	var warp_x: float = sin((x+z)*0.006)*42.0
	var warp_z: float = cos((x-z)*0.004)*54.0
	var ridge: float = sin((x+warp_x)*0.018+cos((z+warp_z)*0.009)*1.4)
	var shoulder: float = sin((z+warp_z)*0.013+sin((x+warp_x)*0.007)*1.1)
	var broken_edge: float = cos((x-z)*0.025+sin((x+z)*0.008))*0.35
	var amplitude: float = 0.8 if world.archetype == "frozen" else 1.0
	return (3.0+ridge*6.0+shoulder*2.0+broken_edge)*amplitude

static func _surface_noise_field(world: Dictionary) -> Dictionary:
	var seed_value: int = int(world.get("geography_seed",1948))
	var version: int = int(world.get("generator_version",1))
	var key: String = "%s:%d:%d" % [str(world.get("id","morrow")),seed_value,version]
	if surface_noise_cache.has(key): return surface_noise_cache[key]
	var seed_base: int = seed_value+version*104729
	var macro := FastNoiseLite.new()
	macro.seed = seed_base
	macro.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	macro.frequency = 0.014
	macro.fractal_type = FastNoiseLite.FRACTAL_FBM
	macro.fractal_octaves = 4
	macro.fractal_gain = 0.5
	var detail := FastNoiseLite.new()
	detail.seed = seed_base+1013
	detail.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	detail.frequency = 0.052
	detail.fractal_type = FastNoiseLite.FRACTAL_FBM
	detail.fractal_octaves = 3
	detail.fractal_gain = 0.48
	var ridge := FastNoiseLite.new()
	ridge.seed = seed_base+2027
	ridge.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	ridge.frequency = 0.027
	ridge.fractal_type = FastNoiseLite.FRACTAL_FBM
	ridge.fractal_octaves = 3
	ridge.fractal_gain = 0.52
	var field := {"macro":macro,"detail":detail,"ridge":ridge}
	if surface_noise_cache.size() >= 4: surface_noise_cache.erase(surface_noise_cache.keys()[0])
	surface_noise_cache[key] = field
	return field

static func definition(id: String = "morrow") -> Dictionary:
	if id != "morrow": return sector_definition(id)
	if cached_definition.is_empty():
		cached_definition = JSON.parse_string(FileAccess.get_file_as_string("res://data/morrow_planet.json")) as Dictionary
	return cached_definition

static func direction(latitude: float, longitude: float) -> Vector3:
	var lat: float = deg_to_rad(latitude)
	var lon: float = deg_to_rad(longitude)
	return Vector3(cos(lat)*sin(lon),sin(lat),cos(lat)*cos(lon))

static func site_direction(id: String = "morrow") -> Vector3:
	if definition(id).get("sites",[]).is_empty(): return Vector3.FORWARD
	var site: Dictionary = definition(id).sites[0]
	return direction(site.latitude,site.longitude)

static func seed_offset(seed_value: int) -> Vector3:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return Vector3(rng.randf_range(1,20),rng.randf_range(1,20),rng.randf_range(1,20))

static func sector_definition(id: String) -> Dictionary:
	if sector_definitions.has(id): return sector_definitions[id]
	var pattern := RegEx.new()
	pattern.compile("^s([0-9]+)p([0-2])$")
	var found: RegExMatch = pattern.search(id)
	if found == null: return {}
	var system: int = int(found.get_string(1))
	var planet: int = int(found.get_string(2))
	if system >= preload("res://scripts/galaxy_catalog.gd").COUNT or (system == 0 and planet == 0): return {}
	var body_count: int = 3 if system == 0 else 1+system%3
	if planet >= body_count: return {}
	var names: Array = ["Solace","Nacre","Kestrel","Ilyr","Meridian","Aster","Veyr","Orin","Lumen","Thalen","Cinder","Far Reach"]
	var sites: Array = []
	var body_name: String = (names[system] if system < 12 else preload("res://scripts/galaxy_catalog.gd").generated_name(system))+" "+["I","II","III"][planet]
	var archetype: String = ["temperate","frozen","arid"][(system+planet)%3]
	var body_kind: String = "planet"
	var parent_id: String = ""
	if system == 0:
		body_name = "Vesper" if planet == 1 else "Morrow's Moon"
		archetype = "arid" if planet == 1 else "frozen"
		if planet == 2:
			body_kind = "moon"
			parent_id = "morrow"
	if id in ["s1p0","s2p0"]:
		sites.append({"id":id+"_site","name":"Thawline" if id == "s1p0" else "Glass Basin","latitude":22.0 if id == "s1p0" else -18.0,"longitude":35.0 if id == "s1p0" else -42.0,"landable":true})
	if preload("res://scripts/territory_catalog.gd").catalog.has(id):
		sites.append({"id":id+"_site","name":preload("res://scripts/territory_catalog.gd").catalog[id].name,"latitude":14.0+planet*7,"longitude":25.0+planet*32,"landable":true})
	sector_definitions[id] = {"id":id,"name":body_name,"geography_seed":2409+system*101+planet*37,
		"generator_version":1,"archetype":archetype,"body_kind":body_kind,"parent_id":parent_id,"sites":sites,"survey_energy":20,"survey_seconds":12}
	return sector_definitions[id]
