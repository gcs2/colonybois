extends RefCounted
## Persistent physical galaxy coordinates. No rendering nodes or per-star ticking.
const COUNT := 2048
const VERSION := 1
const RADIUS := 95.0
const HOME := Vector2(58,0)
static var cache: Dictionary = {}

static func position(star: Dictionary) -> Vector2:
	return Vector2(float(star.get("pc_x",0)),float(star.get("pc_z",0)))

static func distance(a: Dictionary, b: Dictionary) -> float:
	return position(a).distance_to(position(b))

static func generated_name(index: int) -> String:
	var roots := ["Sere","Oru","Vela","Isca","Tamar","Ossa","Nemi","Aru"]
	return "%s %04d" % [roots[index%roots.size()],index]

static func coordinates(seed_value: int) -> PackedVector2Array:
	if cache.has(seed_value): return cache[seed_value]
	var points := PackedVector2Array()
	var rng := RandomNumberGenerator.new(); rng.seed = seed_value
	for i: int in range(COUNT-12):
		var r: float = sqrt(rng.randf())*RADIUS
		var arm: float = (i%4)*TAU/4.0
		var angle: float = arm+(log(1+r)-log(59.0))*1.32+rng.randfn(0,0.065+0.6/(r+2))
		var p := Vector2(cos(angle),sin(angle))*r
		# A local continuation ensures the starting region leads into the wider arm.
		if i < 28:
			p = HOME+Vector2(4.2+i*1.3,sin(i*0.52)*2.1)
		points.append(p)
	cache[seed_value] = points
	return points

static func install(sector: RefCounted) -> void:
	if sector.state.get("galaxy_version",0) == VERSION: return
	var detected: Array = []
	for star: Dictionary in sector.state.systems:
		if sector.is_revealed(star.id): detected.append(star.id)
	for star: Dictionary in sector.state.systems:
		star["pc_x"] = HOME.x+(float(star.x)+19)/6.0
		star["pc_z"] = float(star.z)/6.0
		star["detected"] = star.id in detected
	var points: PackedVector2Array = coordinates(int(sector.state.seed))
	for i: int in range(12,COUNT):
		var p: Vector2 = points[i-12]
		var star := {"id":"s%d" % i,"name":generated_name(i),"x":p.x,"z":p.y,"pc_x":p.x,"pc_z":p.y,"links":[],"owner":"","visited":false,"detected":false,"planets":[]}
		for j: int in range(1+i%3):
			var pid: String = "s%dp%d" % [i,j]
			star.planets.append(pid)
			sector.state.planets[pid] = {"id":pid,"system":star.id,"name":star.name+" "+["I","II","III"][j],"environment":["temperate","frozen","arid"][(i+j)%3],"owner":"","terraform":0.0,"project":false,"seed":2409+i*101+j*37}
		sector.state.systems.append(star)
	# Freight retains its existing authored contracts. New systems gain their own
	# fixed 5 pc carrier connections; flagship engine upgrades never change them.
	var cells: Dictionary = {}
	for star: Dictionary in sector.state.systems:
		var cell := Vector2i(floori(position(star).x/5),floori(position(star).y/5))
		if not cells.has(cell): cells[cell] = []
		cells[cell].append(star)
	for star: Dictionary in sector.state.systems:
		var cell := Vector2i(floori(position(star).x/5),floori(position(star).y/5))
		for x: int in range(-1,2):
			for y: int in range(-1,2):
				for other: Dictionary in cells.get(cell+Vector2i(x,y),[]):
					if int(star.id.substr(1)) < 12 and int(other.id.substr(1)) < 12: continue
					if star.id != other.id and distance(star,other) <= 5.0 and other.id not in star.links: star.links.append(other.id)
	sector.state["galaxy_version"] = VERSION
	sector.reindex_systems()
	for star: Dictionary in sector.state.systems:
		if star.visited: reveal(sector,star.id,5.0)

static func reveal(sector: RefCounted, from: String, radius: float) -> void:
	var origin: Dictionary = sector.system_by_id(from)
	for star: Dictionary in sector.state.systems:
		if distance(origin,star) <= radius+0.00001: star["detected"] = true
