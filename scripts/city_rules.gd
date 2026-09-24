extends RefCounted
## Lot development, service reach and aggregate civic risks. No citizen agents.
const ZONES: Array[String] = ["habitat","industry","service"]
const SERVICES: Dictionary = {"police":9.0,"fire":10.0,"clinic":8.0,"transit":10.0}

static func area(cell: Dictionary) -> int:
	return int(cell.get("width",1))*int(cell.get("depth",1))

static func occupancy(colony: Dictionary) -> void:
	colony["occupied"] = {}
	for key: String in colony.cells:
		var cell: Dictionary = colony.cells[key]
		var bits: PackedStringArray = key.split(",")
		for dx: int in range(int(cell.get("width",1))):
			for dz: int in range(int(cell.get("depth",1))):
				colony.occupied["%d,%d" % [int(bits[0])+dx,int(bits[1])+dz]] = key

static func zone(sim: RefCounted, args: Dictionary) -> String:
	var pid: String = str(args.get("planet",""))
	var kind: String = str(args.get("type",""))
	if not sim.state.colonies.has(pid) or kind not in ZONES: return "Select a colony and a zone type."
	var x0: int = mini(int(args.get("x0",-1)),int(args.get("x1",-1)))
	var x1: int = maxi(int(args.get("x0",-1)),int(args.get("x1",-1)))
	var z0: int = mini(int(args.get("z0",-1)),int(args.get("z1",-1)))
	var z1: int = maxi(int(args.get("z0",-1)),int(args.get("z1",-1)))
	if x0 < 0 or z0 < 0 or x1 >= 64 or z1 >= 64: return "Keep the zoning rectangle inside the buildable map."
	var colony: Dictionary = sim.state.colonies[pid]
	var tiles: Array[String] = []
	for x: int in range(x0,x1+1):
		for z: int in range(z0,z1+1):
			if sim.state.has("urban") and pid == "s0p0" and (x < 22 or x > 42 or z < 24 or z > 40): continue
			var key: String = "%d,%d" % [x,z]
			if sim.terrain(pid,x,z) != "land" or colony.get("occupied",{}).has(key) or colony.cells.has(key): continue
			if sim.state.has("urban") and pid == "s0p0" and key == "32,32": continue
			tiles.append(key)
	if tiles.is_empty(): return "No empty buildable land in that rectangle."
	if colony.cells.size()+tiles.size() > 600: return "This district's current simulation cap is 600 lots and zone tiles."
	for key: String in tiles: colony.cells[key] = {"type":kind,"level":0}
	sim.refresh_colony(pid)
	sim._log("Zoned %d tiles for %s. Designation is free; development uses materials when demand and services allow." % [tiles.size(),sim.catalog.buildings[kind].name])
	return ""

static func grow(sim: RefCounted, pid: String) -> void:
	var colony: Dictionary = sim.state.colonies[pid]
	for key: String in colony.cells.keys():
		if not colony.cells.has(key) or colony.reasons.get(key,"") != "Ready to grow": continue
		var cell: Dictionary = colony.cells[key]
		if cell.type not in ZONES: continue
		if cell.type == "habitat" and colony.get("tax_rate",1.0) > 1.1 and int(sim.state.tick)%12 != 0: continue
		var size := Vector2i(int(cell.get("width",1)),int(cell.get("depth",1)))
		var p: Vector2i = sim.cell_position(key)
		if int(cell.level) == 0:
			for candidate: Vector2i in [Vector2i(3,2),Vector2i(2,3),Vector2i(2,2),Vector2i(2,1),Vector2i(1,2)]:
				var valid: bool = true
				for dx: int in range(candidate.x):
					for dz: int in range(candidate.y):
						var other: Dictionary = colony.cells.get(sim.key(p.x+dx,p.y+dz),{})
						if other.get("type","") != cell.type or int(other.get("level",-1)) != 0: valid = false
				if valid and colony.materials >= float(sim.catalog.buildings[cell.type].cost)*candidate.x*candidate.y*0.5: size = candidate; break
		var cost: float = float(sim.catalog.buildings[cell.type].cost)*size.x*size.y*0.5
		if cell.type == "habitat" and sim.climate_effects.has(pid):
			var population: float = float(colony.population)/float(colony.get("population_scale",1))
			if population+12*size.x*size.y > sim.climate_effects[pid].population_cap:
				colony.reasons[key] = "Growth limited by planetary climate capacity"
				continue
		if colony.materials < cost: continue
		colony.materials -= cost
		if int(cell.level) == 0:
			for dx: int in range(size.x):
				for dz: int in range(size.y):
					var other_key: String = sim.key(p.x+dx,p.y+dz)
					if other_key != key: colony.cells.erase(other_key)
		cell["width"] = size.x
		cell["depth"] = size.y
		cell.level = mini(2,int(cell.level)+1)
		sim.refresh_colony(pid)

static func coverage(colony: Dictionary, kind: String, point: Vector2) -> float:
	var reach: float = 0.0
	var sites: Array = colony.get("service_sites",{}).get(kind,[])
	if kind == "transit" and sites.size() < 2: return 0.0
	for site: Vector2 in sites:
		reach = maxf(reach,clampf(1.0-point.distance_to(site)/float(SERVICES[kind]),0,1))
	return reach

static func refresh(sim: RefCounted, pid: String) -> void:
	var colony: Dictionary = sim.state.colonies[pid]
	var sites: Dictionary = {"police":[],"fire":[],"clinic":[],"transit":[]}
	for key: String in colony.cells:
		var cell: Dictionary = colony.cells[key]
		if SERVICES.has(cell.type) and colony.connected.has(key) and colony.power >= colony.power_used:
			sites[cell.type].append(Vector2(sim.cell_position(key)))
	colony["service_sites"] = sites
	colony["risks"] = {}
	var crime_total: float = 0
	var fire_total: float = 0
	var count: int = 0
	var unemployment: float = maxf(0,1.0-float(colony.jobs)/maxf(1,float(colony.population)))
	for key: String in colony.cells:
		var cell: Dictionary = colony.cells[key]
		if cell.type not in ZONES or int(cell.level) == 0: continue
		var point := Vector2(sim.cell_position(key))
		var crime: float = clampf(18+unemployment*45+int(cell.level)*4-coverage(colony,"police",point)*65,0,100)
		var fire: float = clampf((62 if cell.type == "industry" else 22)+int(cell.level)*6+(12 if sim.state.planets[pid].environment == "arid" else 0)-coverage(colony,"fire",point)*85,0,100)
		colony.risks[key] = {"crime":crime,"fire":fire}
		crime_total += crime*area(cell)
		fire_total += fire*area(cell)
		count += area(cell)
	colony["crime"] = crime_total/maxi(1,count)
	colony["fire_risk"] = fire_total/maxi(1,count)
	colony["layer_signature"] = hash([colony.cells,colony.connected,sites,colony.risks,colony.power,colony.power_used,colony.reasons])

static func command(sim: RefCounted, args: Dictionary) -> String:
	var pid: String = str(args.get("planet",""))
	if not sim.state.colonies.has(pid): return "Select a settlement."
	var colony: Dictionary = sim.state.colonies[pid]
	if args.get("action","") == "tax":
		var rate: float = float(args.get("rate",1.0))
		if rate not in [0.75,1.0,1.25]: return "Choose low, standard or high taxes."
		colony["tax_rate"] = rate
		return ""
	if args.get("action","") == "repair":
		var key: String = str(args.get("tile",""))
		if not colony.cells.has(key) or int(colony.cells[key].get("damaged_until",0)) <= int(sim.state.tick): return "Select a building with active fire damage."
		if sim.state.credits < 25 or colony.materials < 10: return "Emergency repair costs 25 Marks and 10 materials."
		sim.state.credits -= 25
		colony.materials -= 10
		colony.cells[key].damaged_until = 0
		sim.refresh_colony(pid)
		sim._log("Emergency repair restored the damaged building: 25 Marks, 10 materials.")
		return ""
	return "Unknown city policy."

static func tick_risks(sim: RefCounted, pid: String) -> void:
	if int(sim.state.tick)%30 != 0: return
	var colony: Dictionary = sim.state.colonies[pid]
	var rng := RandomNumberGenerator.new()
	rng.seed = int(sim.state.seed)+int(sim.state.tick)*173+pid.hash()
	for key: String in colony.risks:
		var cell: Dictionary = colony.cells[key]
		var risk: float = float(colony.risks[key].fire)
		if risk > 35 and int(cell.get("damaged_until",0)) <= sim.state.tick and rng.randf() < risk/100.0*0.018:
			cell["damaged_until"] = int(sim.state.tick)+12
			cell["incident"] = "Fire damage"
			sim._log("Fire in %s at %s. Production stops for 12 days, or commission an emergency repair. Fire coverage lowers the risk." % [sim.state.planets[pid].name,key])
			break
	if colony.crime > 30 and rng.randf() < float(colony.crime)/200.0:
		var loss: float = minf(float(colony.supplies),8.0)
		colony.supplies -= loss
		sim._log("Theft in %s: %.0f supplies lost. Unemployment and missing police coverage increase crime." % [sim.state.planets[pid].name,loss])
