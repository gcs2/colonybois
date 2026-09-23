extends RefCounted
## Planet-fixed coordinates: north +Y; longitude zero +Z, east toward +X.
static var cached_definition: Dictionary = {}
static var sector_definitions: Dictionary = {}
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
	if system >= 12 or planet >= 1+system%3 or system == 0: return {}
	var names: Array = ["Solace","Nacre","Kestrel","Ilyr","Meridian","Aster","Veyr","Orin","Lumen","Thalen","Cinder","Far Reach"]
	var sites: Array = []
	if id in ["s1p0","s2p0"]:
		sites.append({"id":id+"_site","name":"Thawline" if id == "s1p0" else "Glass Basin","latitude":22.0 if id == "s1p0" else -18.0,"longitude":35.0 if id == "s1p0" else -42.0,"landable":true})
	sector_definitions[id] = {"id":id,"name":names[system]+" "+["I","II","III"][planet],"geography_seed":2409+system*101+planet*37,
		"generator_version":1,"archetype":["temperate","frozen","arid"][(system+planet)%3],"sites":sites,"survey_energy":20,"survey_seconds":12}
	return sector_definitions[id]
