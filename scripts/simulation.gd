class_name FrontierSimulation
extends RefCounted
## Authoritative fixed-tick state. Contains no scene nodes or rendering dependencies.

signal changed
signal message(text: String)

const SIZE: int = 64
const Urban = preload("res://scripts/urban_scenario.gd")
const Settlement = preload("res://scripts/settlement_projects.gd")
const SAVE_VERSION: int = 3
const SAVE_PATH: String = "user://frontier_save.fw"
var catalog: Dictionary = {}
var state: Dictionary = {}
var playtest: bool = "--playtest" in OS.get_cmdline_user_args()

func _init() -> void:
	catalog = JSON.parse_string(FileAccess.get_file_as_string("res://data/catalog.json"))

func new_game(seed_value: int = 2409, mode: String = "expedition") -> void:
	state = {"version":SAVE_VERSION, "seed":seed_value, "tick":0, "credits":650.0,
		"systems":[], "planets":{}, "colonies":{}, "settlements":{}, "factions":catalog.factions.duplicate(true),
		"agreements":[], "discoveries":{}, "milestones":[], "rank":0, "log":[],
		"flagship":{"system":"s0", "destination":"", "route":[], "remaining":0}, "fleets":[],
		"mode":mode if mode in ["sandbox","urban"] else "expedition", "cheats":{"free_build":false,"instant_travel":false}}
	var positions: Array = [[-19,0],[-11,-8],[-7,5],[1,-10],[3,2],[-14,14],[12,-7],[12,8],[0,17],[21,0],[19,18],[9,23]]
	var names: Array = ["Solace","Nacre","Kestrel","Ilyr","Meridian","Aster","Veyr","Orin","Lumen","Thalen","Cinder","Far Reach"]
	var edges: Array = [[0,1],[0,2],[0,5],[1,3],[2,4],[2,5],[3,4],[3,6],[4,7],[4,8],[5,8],[6,9],[7,9],[7,10],[8,11],[10,11]]
	for i: int in range(12):
		var owner: String = ["directorate","consortium","commune"][i - 6] if i >= 6 and i <= 8 else ""
		var system: Dictionary = {"id":"s%d" % i,"name":names[i],"x":positions[i][0],"z":positions[i][1],"links":[],"owner":owner,"visited":i == 0,"planets":[]}
		for j: int in range(1 + i % 3):
			var pid: String = "s%dp%d" % [i,j]
			var env: String = ["temperate","frozen","arid"][(i + j) % 3]
			state.planets[pid] = {"id":pid,"system":system.id,"name":"%s %s" % [names[i],["I","II","III"][j]],"environment":env,"owner":owner,"terraform":0.0,"project":false,"seed":seed_value + i * 101 + j * 37}
			system.planets.append(pid)
		state.systems.append(system)
	for edge: Array in edges:
		state.systems[edge[0]].links.append("s%d" % edge[1])
		state.systems[edge[1]].links.append("s%d" % edge[0])
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var candidates: Array = [1,2,3,4,5,9,10,11]
	for discovery: Dictionary in catalog.discoveries:
		var index: int = rng.randi_range(0,candidates.size()-1)
		state.discoveries["s%d" % candidates.pop_at(index)] = {"id":discovery.id,"resolved":false}
	_create_colony("s0p0")
	if mode == "urban": Urban.install(self)
	else: _log("Welcome to Solace. Connect zones, then explore the frontier.")
	changed.emit()

func system_by_id(id: String) -> Dictionary:
	for system: Dictionary in state.systems:
		if system.id == id:
			return system
	return {}

func faction_by_id(id: String) -> Dictionary:
	for faction: Dictionary in state.factions:
		if faction.id == id:
			return faction
	return {}

func is_revealed(sid: String) -> bool:
	var system: Dictionary = system_by_id(sid)
	if system.is_empty(): return false
	if system.visited: return true
	for neighbor: String in system.links:
		if system_by_id(neighbor).visited: return true
	return false

func save_path(autosave: bool = false) -> String:
	var suffix: String = "_autosave" if autosave else "_save"
	var prefix: String = str(state.get("mode","expedition"))
	if prefix == "expedition": prefix = "frontier"
	if playtest: prefix = "review_"+prefix
	return "user://%s%s.fw" % [prefix,suffix]

static func key(x: int, z: int) -> String:
	return "%d,%d" % [x,z]

static func cell_position(cell_key: String) -> Vector2i:
	var parts: PackedStringArray = cell_key.split(",")
	return Vector2i(int(parts[0]), int(parts[1]))

func features(pid: String) -> Array:
	var n: int = int(state.planets[pid].seed) % 5
	return [{"x":25+n,"z":25,"type":"geothermal"},{"x":38,"z":35+n,"type":"mineral"},{"x":22,"z":37-n,"type":"water"},{"x":42-n,"z":23,"type":"mineral"}]

func near_feature(pid: String, x: int, z: int, kind: String, radius: float) -> bool:
	for feature: Dictionary in features(pid):
		if feature.type == kind and Vector2(x,z).distance_to(Vector2(feature.x,feature.z)) <= radius:
			return true
	return false

func terrain(pid: String, x: int, z: int) -> String:
	if x < 0 or z < 0 or x >= SIZE or z >= SIZE:
		return "outside"
	var seed_value: float = float(int(state.planets[pid].seed) % 17)
	if x < 8 + int(3.0 * sin(z * 0.16 + seed_value)):
		return "water" if state.planets[pid].environment != "arid" else "cliff"
	if x > 56 + int(2.0 * sin(z * 0.3)) or z < 4:
		return "cliff"
	return "land"

func _create_colony(pid: String, developed: bool = true) -> void:
	var colony: Dictionary = {"planet":pid,"materials":150.0,"supplies":110.0,"cells":{},"population":0,"power":0.0,"power_used":0.0,"income":0.0,"material_rate":0.0,"supply_rate":0.0,"connected":{},"reasons":{},"trade_target":"","trade_resource":"materials","import_from":""}
	var cells: Dictionary = colony.cells
	cells[key(30,30)] = {"type":"spaceport","level":1}
	if not developed:
		colony.materials = 70.0
		colony.supplies = 60.0
		state.colonies[pid] = colony
		state.planets[pid].owner = "player"
		refresh_colony(pid)
		return
	for x: int in range(26,38):
		cells[key(x,31)] = {"type":"road","level":1}
	for x: int in [28,29,32]:
		cells[key(x,30)] = {"type":"habitat","level":1}
	cells[key(34,30)] = {"type":"industry","level":1}
	cells[key(35,30)] = {"type":"service","level":1}
	cells[key(27,30)] = {"type":"power","level":1}
	cells[key(31,32)] = {"type":"life_support","level":1}
	state.colonies[pid] = colony
	state.planets[pid].owner = "player"
	refresh_colony(pid)

func command(action: String, args: Dictionary = {}) -> String:
	var error: String = ""
	match action:
		"civic": error = Urban.command(self,args)
		"build": error = _build(args)
		"travel": error = _travel(str(args.get("system","")))
		"colonize": error = Settlement.begin(self,str(args.get("planet","")),str(args.get("source","s0p0")))
		"diplomacy": error = _diplomacy(args)
		"trade": error = _trade(args)
		"import": error = _import(args)
		"terraform": error = _terraform(str(args.get("planet","")))
		"discover": error = _discover(args)
		"cheat": error = _cheat(args)
		"specialize":
			if state.rank < 1: error = "Earn the Pathfinder rank first."
			elif not state.colonies.has(args.get("planet","")): error = "Select a colony."
			elif not ["balanced","industry","ecology"].has(args.get("policy","")): error = "Unknown specialization."
			else: state.colonies[args.planet]["policy"] = args.policy
		_: error = "Unknown command."
	if error.is_empty():
		_check_milestones()
		changed.emit()
	return error

func _build(args: Dictionary) -> String:
	var pid: String = str(args.get("planet",""))
	if not state.colonies.has(pid): return "This world has no colony."
	var x: int = int(args.get("x",-1))
	var z: int = int(args.get("z",-1))
	var type: String = str(args.get("type",""))
	var colony: Dictionary = state.colonies[pid]
	var k: String = key(x,z)
	if state.has("urban") and pid == Urban.HOME:
		if x < 22 or x > 42 or z < 24 or z > 40: return "Your construction authority covers South Loop: tiles 22–42 / 24–40."
		if k == Urban.LINK and not state.urban.repaired: return "Choose a repair agreement in the South Loop panel for this damaged crossing."
	if type == "bulldoze":
		if not colony.cells.has(k): return "Nothing to remove."
		if colony.cells[k].type == "spaceport": return "The colony's spaceport must remain."
		colony.materials += float(catalog.buildings[colony.cells[k].type].cost) * 0.5
		colony.cells.erase(k)
		refresh_colony(pid)
		return ""
	if not catalog.buildings.has(type) or type == "spaceport": return "Select a construction tool."
	if terrain(pid,x,z) != "land": return "Build on stable land."
	if colony.cells.has(k): return "This tile is occupied."
	var cost: float = 0.0 if state.get("cheats",{}).get("free_build",false) else float(catalog.buildings[type].cost)
	if colony.materials < cost: return "Not enough construction materials."
	colony.materials -= cost
	colony.cells[k] = {"type":type,"level":0 if type in ["habitat","industry","service"] else 1}
	refresh_colony(pid)
	return ""

func connected_cells(colony: Dictionary) -> Dictionary:
	var distances: Dictionary = {}
	var queue: Array[Vector2i] = []
	for k: String in colony.cells:
		if colony.cells[k].type == "spaceport":
			distances[k] = 0
			queue.append(cell_position(k))
	var head: int = 0
	while head < queue.size():
		var current: Vector2i = queue[head]
		head += 1
		for delta: Vector2i in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i = current + delta
			var k: String = key(next.x,next.y)
			if colony.cells.has(k) and not distances.has(k):
				distances[k] = distances[key(current.x,current.y)] + 1
				if colony.cells[k].type == "road": queue.append(next)
	return distances

func suitability(pid: String, x: int, z: int) -> float:
	var planet: Dictionary = state.planets[pid]
	var value: float = 0.85
	if planet.environment == "frozen":
		value = 0.42 + float(planet.terraform) * 0.4
		if near_feature(pid,x,z,"geothermal",7): value += 0.35
	elif planet.environment == "arid":
		value = 0.40 + float(planet.terraform) * 0.4
		if near_feature(pid,x,z,"water",8): value += 0.4
	if state.colonies.has(pid):
		var cells: Dictionary = state.colonies[pid].cells
		for k: String in cells:
			var cell: Dictionary = cells[k]
			if int(cell.level) == 0: continue
			var p: Vector2i = cell_position(k)
			var distance: float = Vector2(x,z).distance_to(Vector2(p))
			if cell.type == "industry" and distance < 5: value -= 0.14 * (1.0-distance/5.0)
			if cell.type == "service" and distance < 5: value += 0.12
	return clampf(value,0.0,1.0)

func refresh_colony(pid: String) -> void:
	var colony: Dictionary = state.colonies[pid]
	colony.connected = connected_cells(colony)
	var power: float = 14.0
	var used: float = 0.0
	var population: int = 0
	var jobs: int = 18
	var life_sites: Array[Vector2i] = [Vector2i(30,30)]
	var env: String = state.planets[pid].environment
	var factor: float = lerpf(float(catalog.environments[env].power_factor),1.0,float(state.planets[pid].terraform))
	for k: String in colony.cells:
		var cell: Dictionary = colony.cells[k]
		var p: Vector2i = cell_position(k)
		if cell.type == "habitat": population += int(cell.level) * 12
		if not colony.connected.has(k): continue
		if cell.type == "power": power += 48.0 if env == "frozen" and near_feature(pid,p.x,p.y,"geothermal",6) else 32.0
		var cost: float = float(catalog.buildings[cell.type].power) * maxf(1.0,float(cell.level)) * factor
		if cell.type == "life_support":
			life_sites.append(p)
			if env == "arid" and not near_feature(pid,p.x,p.y,"water",7): cost *= 2.0
		used += cost
		if cell.type == "industry": jobs += int(cell.level) * 18
		if cell.type == "service": jobs += int(cell.level) * 10
	colony.power = power
	colony.power_used = used
	var population_scale: int = int(colony.get("population_scale",1))
	colony.population = population * population_scale
	colony.jobs = jobs * population_scale
	colony.reasons = {}
	for k: String in colony.cells:
		var cell: Dictionary = colony.cells[k]
		if cell.type not in ["habitat","industry","service"]: continue
		var p: Vector2i = cell_position(k)
		var reason: String = ""
		if not colony.connected.has(k): reason = "No road connection"
		elif used > power: reason = "Growth limited by power"
		elif colony.supplies < 5: reason = "Growth limited by supplies"
		else:
			var covered: bool = false
			for site: Vector2i in life_sites:
				if Vector2(site).distance_to(Vector2(p)) <= 9: covered = true
			if not covered: reason = "Growth limited by life support"
			elif cell.type == "habitat" and population >= jobs + 12: reason = "More jobs needed"
			elif cell.type == "habitat" and suitability(pid,p.x,p.y) < (0.55 if int(cell.level) == 1 else 0.3): reason = "Low residential suitability"
			elif cell.type in ["industry","service"] and jobs > population + 36: reason = "More residents needed"
			elif int(colony.connected[k]) > 28: reason = "Long commute: extend a shorter road"
		if reason.is_empty(): reason = "Ready to grow" if int(cell.level) < 2 else "Thriving · maximum density"
		colony.reasons[k] = reason

func tick() -> void:
	state.tick += 1
	for pid: String in state.colonies:
		refresh_colony(pid)
		var colony: Dictionary = state.colonies[pid]
		if int(state.tick) % 6 == 0:
			for k: String in colony.reasons:
				if colony.reasons[k] == "Ready to grow":
					colony.cells[k].level = mini(2,int(colony.cells[k].level)+1)
					refresh_colony(pid)
		var materials: float = 0.22
		var economic_population: float = float(colony.population)/float(colony.get("population_scale",1))
		var economic_jobs: float = float(colony.jobs)/float(colony.get("population_scale",1))
		var supplies: float = 0.25 - economic_population * 0.007
		var upkeep: float = 0.10
		for k: String in colony.cells:
			var cell: Dictionary = colony.cells[k]
			if not colony.connected.has(k): continue
			var performance: float = minf(1.0,float(colony.power)/maxf(1.0,float(colony.power_used)))
			var workforce: float = minf(1.0,(economic_population+18)/maxf(1.0,economic_jobs))
			var level: float = float(cell.level) * performance * workforce
			if cell.type == "industry": materials += level * 0.32
			if cell.type == "service": supplies += level * 0.50
			if cell.type == "extractor":
				var p: Vector2i = cell_position(k)
				materials += (0.9 if near_feature(pid,p.x,p.y,"mineral",3) else 0.1) * performance
			if cell.type not in ["road","habitat","spaceport"]: upkeep += 0.025
		var policy: String = colony.get("policy","balanced")
		if policy == "industry": materials *= 1.25; supplies -= 0.15
		if policy == "ecology": supplies += 0.3; materials *= 0.85
		colony.material_rate = materials
		colony.supply_rate = supplies
		colony.materials = minf(9999.0,colony.materials + materials)
		colony.supplies = clampf(colony.supplies + supplies,0.0,9999.0)
		colony.income = economic_population * 0.018 - upkeep
		state.credits = maxf(0.0,state.credits + colony.income)
		_tick_project(pid)
	if state.has("urban"): Urban.tick(self)
	Settlement.tick(self)
	_tick_trade()
	_tick_travel()
	if int(state.tick) % 30 == 0: _tick_factions()
	_check_milestones()
	changed.emit()

func route_between(start: String, end: String, known_only: bool = false) -> Array:
	if system_by_id(start).is_empty() or system_by_id(end).is_empty(): return []
	var queue: Array = [start]
	var previous: Dictionary = {start:""}
	var head: int = 0
	while head < queue.size():
		var current: String = queue[head]
		head += 1
		if current == end:
			var route: Array = []
			while not current.is_empty():
				route.push_front(current)
				current = previous[current]
			return route
		for next: String in system_by_id(current).links:
			if previous.has(next): continue
			if known_only and not system_by_id(next).visited and next != end: continue
			var owner: String = system_by_id(next).owner
			if not owner.is_empty() and bool(faction_by_id(owner).get("embargo",false)): continue
			previous[next] = current
			queue.append(next)
	return []

func _travel(sid: String) -> String:
	var flagship: Dictionary = state.flagship
	if not str(flagship.destination).is_empty(): return "Flagship is already traveling."
	if sid == flagship.system: return "Flagship is already here."
	if not is_revealed(sid): return "Explore the frontier to reveal a route to this system."
	var route: Array = route_between(flagship.system,sid,true)
	if route.is_empty(): return "No accessible route. An embargo may block passage."
	flagship.destination = sid
	flagship.route = route
	flagship.remaining = (route.size()-1)*6
	flagship["duration"] = flagship.remaining
	_log("Flagship departing for %s." % system_by_id(sid).name)
	if state.get("cheats",{}).get("instant_travel",false):
		flagship.remaining = 1
		_tick_travel()
	return ""

func _tick_travel() -> void:
	var flagship: Dictionary = state.flagship
	if str(flagship.destination).is_empty(): return
	if route_between(flagship.system,flagship.destination).is_empty():
		flagship.destination = ""
		flagship.route = []
		_log("Travel canceled: passage is now restricted.")
		return
	flagship.remaining -= 1
	if flagship.remaining > 0: return
	flagship.system = flagship.destination
	flagship.destination = ""
	var system: Dictionary = system_by_id(flagship.system)
	system.visited = true
	if not str(system.owner).is_empty(): faction_by_id(system.owner)["contacted"] = true
	_log("Arrived at %s. Planet surveys complete." % system.name)

func _diplomacy(args: Dictionary) -> String:
	var faction: Dictionary = faction_by_id(str(args.get("faction","")))
	if faction.is_empty() or not faction.get("contacted",false): return "Visit this faction's system to make contact."
	var pact: String = str(args.get("pact",""))
	if pact == "reconcile":
		if int(faction.relation) >= 0: return "Relations are already open."
		if state.credits < 80: return "Reconciliation costs 80 Marks."
		state.credits -= 80
		faction.relation = 0
		faction.embargo = false
		faction.reason = "Your reconciliation offer reopened relations."
		return ""
	var thresholds: Dictionary = {"trade":0,"non_aggression":15,"alliance":40}
	if not thresholds.has(pact): return "Unknown agreement."
	if int(faction.relation) < int(thresholds[pact]): return "Requires %d relations." % thresholds[pact]
	if bool(faction.get("embargo",false)): return "Resolve the embargo first."
	var agreement: String = "%s:%s" % [faction.id,pact]
	if agreement in state.agreements: return "Agreement already signed."
	state.agreements.append(agreement)
	faction.relation += 5
	faction.reason = "Our %s agreement builds trust (+5)." % pact.replace("_"," ")
	_log("%s: %s signed." % [faction.name,pact.replace("_"," ")])
	return ""

func _trade(args: Dictionary) -> String:
	var pid: String = str(args.get("planet",""))
	var target: String = str(args.get("faction",""))
	var resource: String = str(args.get("resource","materials"))
	if not state.colonies.has(pid): return "Select your colony."
	if target.is_empty(): state.colonies[pid].trade_target = ""; return ""
	if not resource in ["materials","supplies"]: return "Unknown resource."
	if not (target+":trade") in state.agreements: return "Sign a trade agreement first."
	if faction_by_id(target).get("embargo",false): return "This faction has imposed an embargo."
	state.colonies[pid].trade_target = target
	state.colonies[pid].trade_resource = resource
	_log("%s exports %s above a 60-unit reserve." % [state.planets[pid].name,resource])
	return ""

func _import(args: Dictionary) -> String:
	var pid: String = str(args.get("planet",""))
	var source: String = str(args.get("source",""))
	if not state.colonies.has(pid): return "Select your colony."
	if not source.is_empty() and (source == pid or not state.colonies.has(source)): return "Choose a different established colony."
	state.colonies[pid].import_from = source
	return ""

func _tick_trade() -> void:
	for pid: String in state.colonies:
		var colony: Dictionary = state.colonies[pid]
		colony["trade_status"] = "No exports configured"
		var source: String = colony.import_from
		if state.colonies.has(source) and not route_between(state.planets[source].system,state.planets[pid].system).is_empty():
			for resource: String in ["materials","supplies"]:
				var donor: Dictionary = state.colonies[source]
				var transfer: float = minf(0.8,minf(maxf(0.0,float(donor[resource])-80),maxf(0.0,60.0-float(colony[resource]))))
				donor[resource] -= transfer
				colony[resource] += transfer
		var target: String = colony.trade_target
		if target.is_empty(): continue
		var faction: Dictionary = faction_by_id(target)
		if faction.is_empty() or faction.get("embargo",false) or not (target+":trade") in state.agreements:
			colony.trade_status = "Exports suspended: embargo or missing treaty"
			continue
		var target_system: String = "s6" if target == "directorate" else ("s7" if target == "consortium" else "s8")
		if route_between(state.planets[pid].system,target_system).is_empty():
			colony.trade_status = "Exports suspended: route blocked"
			continue
		var resource: String = colony.trade_resource
		var capacity: float = 0.8 if target == "consortium" else 0.5
		var amount: float = minf(capacity,maxf(0.0,float(colony[resource])-60.0))
		colony[resource] -= amount
		var price: float = 1.6 if faction.need == resource else 1.0
		state.credits += amount * price
		colony.trade_status = "Exporting %.1f %s/day" % [amount,resource] if amount > 0 else "Holding 60-unit local reserve"
		if amount > 0:
			_award("First export")
			if int(state.tick) % 20 == 0:
				faction.relation = mini(80,int(faction.relation)+2)
				faction.reason = "Reliable exports build trust (+2)."

func _terraform(pid: String) -> String:
	if not state.colonies.has(pid): return "Establish a colony first."
	var planet: Dictionary = state.planets[pid]
	if planet.environment == "temperate" or planet.terraform >= 1.0: return "This world's climate is already stable."
	if planet.project: return "Climate project already active."
	var colony: Dictionary = state.colonies[pid]
	var has_array: bool = false
	for k: String in colony.cells:
		if colony.cells[k].type == "terraformer" and colony.connected.has(k): has_array = true
	if not has_array: return "Build a road-connected climate array first."
	if state.credits < 120: return "Starting the project costs 120 Marks."
	state.credits -= 120
	planet.project = true
	var faction: Dictionary = faction_by_id("commune")
	faction.relation -= 18
	faction.reason = "You began replacing a native environment (-18)."
	_log("Climate project started. Uses 0.5 materials and 0.2 supplies/day; pauses during shortages.")
	return ""

func _tick_project(pid: String) -> void:
	var planet: Dictionary = state.planets[pid]
	if not planet.project: return
	var colony: Dictionary = state.colonies[pid]
	planet["project_status"] = "Paused: restore array, power or reserves"
	if colony.materials < 10.5 or colony.supplies < 10.2 or colony.power_used > colony.power: return
	var connected_array: bool = false
	for k: String in colony.cells:
		if colony.cells[k].type == "terraformer" and colony.connected.has(k): connected_array = true
	if not connected_array: return
	colony.materials -= 0.5
	colony.supplies -= 0.2
	planet.terraform = minf(1.0,float(planet.terraform)+1.0/180.0)
	planet.project_status = "Climate recovery progressing"
	if planet.terraform >= 0.999:
		planet.terraform = 1.0
		planet.project = false
		_award("Worldshaper")
		_log("%s's climate recovery is complete." % planet.name)

func _discover(args: Dictionary) -> String:
	var sid: String = str(args.get("system",""))
	var choice: int = int(args.get("choice",-1))
	if choice not in [0,1]: return "Choose a discovery response."
	if not state.discoveries.has(sid) or not system_by_id(sid).visited: return "Survey this system first."
	var discovery: Dictionary = state.discoveries[sid]
	if discovery.resolved: return "This discovery is already resolved."
	discovery.resolved = true
	discovery["choice"] = choice
	if choice == 0:
		for faction: Dictionary in state.factions:
			faction.relation = mini(100,int(faction.relation)+8)
			faction.reason = "You shared a discovery or protected its world (+8)."
	else:
		if discovery.id in ["garden","seed"]: state.colonies["s0p0"].supplies += 65
		elif discovery.id in ["beacon","lattice"]: state.colonies["s0p0"].materials += 65
		else: state.credits += 120
	_award("First discovery")
	_log("Discovery resolved: %s." % discovery.id)
	return ""

func _cheat(args: Dictionary) -> String:
	if state.get("mode","expedition") != "sandbox": return "Cheats are available in Sandbox mode only."
	var ability: String = str(args.get("ability",""))
	match ability:
		"credits": state.credits += 1000.0
		"resources":
			for colony: Dictionary in state.colonies.values():
				colony.materials += 500.0
				colony.supplies += 500.0
		"reveal":
			for system: Dictionary in state.systems: system.visited = true
			for faction: Dictionary in state.factions: faction["contacted"] = true
		"free_build", "instant_travel": state.cheats[ability] = not bool(state.cheats[ability])
		"friendship":
			for faction: Dictionary in state.factions:
				faction.relation = 80
				faction["contacted"] = true
				faction["embargo"] = false
				faction.reason = "Sandbox: diplomatic goodwill."
		"climate":
			var pid: String = str(args.get("planet",""))
			if not state.colonies.has(pid): return "Select a colony to restore its climate."
			state.planets[pid].terraform = 1.0
			state.planets[pid].project = false
			refresh_colony(pid)
		_: return "Unknown sandbox ability."
	_log("Sandbox · " + ("Marks granted" if ability == "credits" else ability.replace("_"," ")))
	return ""

func _tick_factions() -> void:
	for faction: Dictionary in state.factions:
		var blocked: bool = int(faction.relation) < -15
		if blocked != bool(faction.get("embargo",false)):
			faction.embargo = blocked
			_log("%s %s." % [faction.name,"has imposed an embargo" if blocked else "has reopened its borders"])
		if faction.id == "consortium":
			var total: float = 0.0
			for colony: Dictionary in state.colonies.values(): total += float(colony.supplies)
			faction.need = "supplies" if total > 150.0 else "materials"
		if faction.id == "commune" and int(state.tick) % 120 == 0:
			var protected: bool = true
			for planet: Dictionary in state.planets.values():
				if planet.project or planet.terraform > 0: protected = false
			if protected:
				faction.relation = mini(60,int(faction.relation)+2)
				faction.reason = "Your settlements preserve native climates (+2)."

func _check_milestones() -> void:
	var visited: int = 0
	for system: Dictionary in state.systems:
		if system.visited: visited += 1
	if visited >= 3: _award("Three horizons")
	if state.colonies.size() >= 2: _award("New beginning")
	for pid: String in state.colonies:
		var colony: Dictionary = state.colonies[pid]
		if float(colony.population)/float(colony.get("population_scale",1)) >= 72 and not (state.has("urban") and pid == Urban.HOME): _award("Growing community")
		if state.planets[pid].environment != "temperate" and colony.population >= 60 and colony.power >= colony.power_used: _award("Harsh-world pioneer")
	for agreement: String in state.agreements:
		if agreement.ends_with(":alliance"): _award("First alliance")
	var rank: int = 2 if state.milestones.size() >= 6 else (1 if state.milestones.size() >= 3 else 0)
	if rank > int(state.rank):
		state.rank = rank
		_log("Promotion: %s. Colony specializations available." % ["Captain","Pathfinder","Steward"][rank])

func _award(title: String) -> void:
	if title not in state.milestones:
		state.milestones.append(title)
		_log("Milestone: %s" % title)

func _log(text: String) -> void:
	state.log.append({"tick":state.tick,"text":text})
	if state.log.size() > 80: state.log.pop_front()
	message.emit(text)

func save_game(path: String = "") -> Error:
	if path.is_empty(): path = save_path()
	var file := FileAccess.open(path + ".tmp",FileAccess.WRITE)
	if file == null: return FileAccess.get_open_error()
	# Native variants retain float bits and dictionary order; both affect deterministic ticks.
	file.store_buffer("FWORLD01".to_utf8_buffer())
	file.store_var(state,false)
	file.close()
	return DirAccess.rename_absolute(path + ".tmp",path)

func load_game(path: String = "") -> Error:
	if path.is_empty(): path = save_path()
	if not FileAccess.file_exists(path): return ERR_FILE_NOT_FOUND
	var file := FileAccess.open(path,FileAccess.READ)
	if file == null: return FileAccess.get_open_error()
	if file.get_buffer(8).get_string_from_utf8() != "FWORLD01": return ERR_FILE_UNRECOGNIZED
	var parsed: Variant = file.get_var(false)
	if not parsed is Dictionary: return ERR_PARSE_ERROR
	if int(parsed.get("version",0)) not in [1,2,SAVE_VERSION]: return ERR_FILE_UNRECOGNIZED
	for field: String in ["planets","colonies","systems","factions","flagship","agreements","milestones","discoveries","log","credits","tick","seed","rank"]:
		if not parsed.has(field): return ERR_FILE_CORRUPT
	if not parsed.colonies is Dictionary or not parsed.systems is Array: return ERR_FILE_CORRUPT
	state = parsed
	state.version = SAVE_VERSION
	if not state.has("settlements"): state["settlements"] = {}
	if state.has("urban") and not state.urban.has("tutorial_step"): state.urban["tutorial_step"] = 1 if not str(state.urban.path).is_empty() else 0
	if not state.has("mode"): state["mode"] = "expedition"
	if not state.has("cheats"): state["cheats"] = {"free_build":false,"instant_travel":false}
	for pid: String in state.colonies: refresh_colony(pid)
	changed.emit()
	return OK
