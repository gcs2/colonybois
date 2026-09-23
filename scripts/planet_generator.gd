extends RefCounted
## Versioned, spherical geography. All samples are pure functions of recipe + direction.
## No population, species or climate agent simulation runs in the renderer.
const VERSION: int = 1
const MAP_WIDTH: int = 512
static var profiles: Dictionary = {}
static var map_cache: Dictionary = {}
var recipe: Dictionary
var profile: Dictionary
var continent := FastNoiseLite.new()
var detail := FastNoiseLite.new()
var climate := FastNoiseLite.new()
var weather := FastNoiseLite.new()
var site_directions: Array[Vector3] = []
var palette: Dictionary = {}

static func archetypes() -> Dictionary:
	if profiles.is_empty(): profiles = JSON.parse_string(FileAccess.get_file_as_string("res://data/planet_archetypes.json"))
	return profiles.duplicate(true)

static func make_recipe(id: String, seed_value: int, archetype: String) -> Dictionary:
	assert(archetypes().has(archetype),"Unknown planet archetype")
	return {"id":id,"geography_seed":seed_value,"generator_version":VERSION,"archetype":archetype,"sites":[]}

func _init(source: Dictionary) -> void:
	recipe = source.duplicate(true)
	assert(int(recipe.get("generator_version",VERSION)) == VERSION,"Unsupported geography version")
	profile = archetypes()[recipe.get("archetype","temperate")].duplicate(true)
	for key: String in profile:
		if recipe.get("climate",{}).has(key): profile[key] = recipe.climate[key]
	for key: String in ["atmosphere","deep_ocean","shallow_ocean","lowland","forest","dryland","highland","ice"]:
		palette[key] = Color(profile[key])
	var seed_value: int = int(recipe.geography_seed)
	configure(continent,seed_value,4)
	configure(detail,seed_value+103,3)
	configure(climate,seed_value+227,3)
	configure(weather,seed_value+409,4)
	for site: Dictionary in recipe.get("sites",[]):
		if site.get("landable",false): site_directions.append(direction(site.latitude,site.longitude))

func configure(noise: FastNoiseLite, seed_value: int, octaves: int) -> void:
	noise.seed = seed_value
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 1.0
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = octaves
	noise.fractal_gain = 0.48

static func direction(latitude: float, longitude: float) -> Vector3:
	var lat: float = deg_to_rad(latitude)
	var lon: float = deg_to_rad(longitude)
	return Vector3(cos(lat)*sin(lon),sin(lat),cos(lat)*cos(lon))

func sample(at: Vector3) -> Dictionary:
	var p: Vector3 = at.normalized()
	var warp := Vector3(detail.get_noise_3dv(p*2.2),detail.get_noise_3dv(p*2.2+Vector3(7,0,0)),detail.get_noise_3dv(p*2.2+Vector3(0,11,0)))
	var plates: float = continent.get_noise_3dv(p*1.25+warp*0.42)
	var ridge: float = pow(1.0-absf(detail.get_noise_3dv(p*10.0)),5.0)
	var height: float = (plates-float(profile.sea_level))*1.7
	height += (ridge-0.5)*0.13*smoothstep(-0.03,0.2,height)*float(profile.relief)
	for site: Vector3 in site_directions:
		# An authored landable basin is a geological constraint, not a floating decal.
		height = lerpf(height,maxf(height,0.10),smoothstep(0.965,0.998,p.dot(site)))
	var temperature: float = float(profile.equator_temperature)-44*pow(absf(p.y),1.8)-maxf(0,height)*22
	var moisture: float = clampf(float(profile.moisture)+climate.get_noise_3dv(p*3.7)*0.52-maxf(0,height)*0.15,0,1)
	var biome: String = "ocean"
	if height >= 0:
		biome = "ice" if temperature < -3 else ("highland" if height > 0.43 else ("dryland" if moisture < 0.36 else ("forest" if moisture > 0.66 else "lowland")))
	var clouds: float = smoothstep(0.37-float(profile.cloud_cover)*0.7,0.61-float(profile.cloud_cover)*0.7,weather.get_noise_3dv(p*4.2+warp*0.6))
	return {"elevation":height,"temperature_c":temperature,"moisture":moisture,"biome":biome,"ruggedness":ridge,"clouds":clouds}

func surface_color(cell: Dictionary) -> Color:
	var height: float = cell.elevation
	var color: Color
	if height < 0:
		color = palette.deep_ocean.lerp(palette.shallow_ocean,smoothstep(-0.20,0.0,height))
		if cell.temperature_c < -5: color = color.lerp(palette.ice,(1.0-smoothstep(-22,-5,cell.temperature_c))*0.95)
	else:
		color = palette.dryland.lerp(palette.lowland,smoothstep(0.28,0.46,cell.moisture))
		color = color.lerp(palette.forest,smoothstep(0.57,0.76,cell.moisture))
		color = color.lerp(palette.highland,smoothstep(0.26,0.56,height))
		color = color.lerp(palette.ice,1.0-smoothstep(-10,0,cell.temperature_c))
		color = color.darkened((1.0-cell.ruggedness)*0.16)
		# Restrained shelf beaches make coastlines readable without neon outlining.
		color = color.lerp(palette.dryland,0.45*(1.0-smoothstep(0,0.025,height)))
	return color

func maps(width: int = MAP_WIDTH) -> Dictionary:
	assert(width >= 32 and width <= 2048 and width%2 == 0)
	var key: String = JSON.stringify(recipe)+":"+str(width)
	if map_cache.has(key): return map_cache[key]
	var started: int = Time.get_ticks_msec()
	var height: int = width/2
	var albedo := Image.create(width,height,false,Image.FORMAT_RGB8)
	var conditions := Image.create(width,height,false,Image.FORMAT_RGBA8)
	var elevations := Image.create(width,height,false,Image.FORMAT_RF)
	for y: int in range(height):
		var latitude: float = 90.0-(float(y)+0.5)/height*180.0
		for x: int in range(width):
			var longitude: float = (float(x)+0.5)/width*360.0-180.0
			var cell: Dictionary = sample(direction(latitude,longitude))
			albedo.set_pixel(x,y,surface_color(cell))
			elevations.set_pixel(x,y,Color(maxf(0,cell.elevation)*0.5,0,0))
			conditions.set_pixel(x,y,Color(clampf(cell.elevation*0.5+0.5,0,1),cell.moisture,clampf((cell.temperature_c+80)/160,0,1),cell.clouds))
	# Bake geographic relief into object-space normals, shared by every globe view.
	var normals := Image.create(width,height,false,Image.FORMAT_RGB8)
	for y: int in range(height):
		var lat: float = PI*0.5-(float(y)+0.5)/height*PI
		for x: int in range(width):
			var lon: float = (float(x)+0.5)/width*TAU-PI
			var p := Vector3(cos(lat)*sin(lon),sin(lat),cos(lat)*cos(lon))
			var east := Vector3(cos(lon),0,-sin(lon))
			var north: Vector3 = p.cross(east).normalized()
			var right_h: float = maxf(0,elevations.get_pixel((x+1)%width,y).r)
			var left_h: float = maxf(0,elevations.get_pixel((x+width-1)%width,y).r)
			var north_h: float = maxf(0,elevations.get_pixel(x,maxi(0,y-1)).r)
			var south_h: float = maxf(0,elevations.get_pixel(x,mini(height-1,y+1)).r)
			var slope_e: float = (right_h-left_h)*width/(TAU*maxf(0.05,cos(lat)))*0.022
			var slope_n: float = (north_h-south_h)*height/PI*0.022
			var normal: Vector3 = (p-east*slope_e-north*slope_n).normalized()
			normals.set_pixel(x,y,Color(normal.x*0.5+0.5,normal.y*0.5+0.5,normal.z*0.5+0.5))
	normals.generate_mipmaps()
	albedo.generate_mipmaps()
	conditions.generate_mipmaps()
	var result := {"albedo":ImageTexture.create_from_image(albedo),"normals":ImageTexture.create_from_image(normals),"conditions":ImageTexture.create_from_image(conditions),"generation_ms":Time.get_ticks_msec()-started}
	# Bounded cache; active globes retain their textures when old entries are evicted.
	if map_cache.size() >= 4: map_cache.erase(map_cache.keys()[0])
	map_cache[key] = result
	return result

func region_sample(latitude: float, longitude: float, east_km: float, north_km: float, radius_km: float = 3200) -> Dictionary:
	var center: Vector3 = direction(latitude,longitude)
	var east := Vector3(cos(deg_to_rad(longitude)),0,-sin(deg_to_rad(longitude)))
	var north: Vector3 = center.cross(east).normalized()
	return sample((center+(east*east_km+north*north_km)/radius_km).normalized())
