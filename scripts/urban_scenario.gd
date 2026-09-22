extends RefCounted
## Bounded civic scenario. District totals, never individual citizen agents.

const HOME: String = "s0p0"
const LINK: String = "32,32"

static func install(sim: RefCounted) -> void:
	var colony: Dictionary = sim.state.colonies[HOME]
	colony.cells.clear()
	colony["population_scale"] = 10
	colony.materials = 260.0
	colony.supplies = 240.0
	sim.state.credits = 650.0
	sim.state.planets[HOME].name = "Latch · South Loop"
	# Two street loops linked by a single damaged crossing. Each block has frontage.
	for start_x: int in [24,34]:
		for z: int in range(26,39):
			for x: int in [start_x,start_x+6]: _cell(colony,x,z,"road")
		for z: int in [26,32,38]:
			for x: int in range(start_x,start_x+7): _cell(colony,x,z,"road")
		for z: int in [27,31,33,37]:
			for x: int in range(start_x+1,start_x+6):
				_cell(colony,x,z,"habitat",1 if (x+z)%3 == 0 else 2)
		for z: int in [28,29,30,34,35,36]:
			_cell(colony,start_x+1,z,"service",2)
			_cell(colony,start_x+5,z,"industry",1 if z in [29,35] else 2)
		for z: int in [27,29,35,37]: _cell(colony,start_x-1,z,"power")
		_cell(colony,start_x+2,25,"life_support")
	_cell(colony,23,32,"spaceport")
	for x: int in [31,33]: _cell(colony,x,32,"road")
	# Apartment terraces occupy real frontage, with different lot rhythms across the crossing.
	for start_x: int in [24,34]:
		for z: int in [27,31,33,37]:
			var first_width: int = 3 if (z+start_x)%4 == 1 else 2
			for offset: int in [1,1+first_width]:
				var width: int = first_width if offset == 1 else 5-first_width
				var anchor: String = "%d,%d" % [start_x+offset,z]
				colony.cells[anchor]["width"] = width
				for dx: int in range(1,width): colony.cells.erase("%d,%d" % [start_x+offset+dx,z])
	# Courtyard civic hall and workshop wings; leave the other interiors available for zoning.
	colony.cells["25,28"]["width"] = 3
	colony.cells["25,28"]["depth"] = 2
	colony.cells.erase("25,29")
	colony.cells["39,34"]["depth"] = 3
	colony.cells.erase("39,35")
	colony.cells.erase("39,36")
	sim.refresh_colony(HOME)
	sim.state["urban"] = {
		"name":"Latch", "district":"South Loop", "path":"", "remaining":0, "tutorial_step":0,
		"repaired":false, "ability_ready":0, "uses":0, "fees_paid":0.0, "fee_due":0.0,
		"background":[
			{"name":"Crown Gardens","population":32000,"jobs":15600},
			{"name":"Spore Quays","population":28000,"jobs":18900},
			{"name":"North Coil","population":27000,"jobs":12800},
			{"name":"Lantern Borough","population":33000-int(colony.population),"jobs":14300}
		]
	}
	sim._log("South Loop: the damaged crossing divides a working city. Inspect access, then choose a repair agreement.")

static func _cell(colony: Dictionary, x: int, z: int, kind: String, level: int = 1) -> void:
	colony.cells["%d,%d" % [x,z]] = {"type":kind,"level":level}

static func population(sim: RefCounted) -> int:
	var total: int = int(sim.state.colonies[HOME].population)
	for district: Dictionary in sim.state.urban.background: total += int(district.population)
	return total

static func isolated_population(sim: RefCounted) -> int:
	var colony: Dictionary = sim.state.colonies[HOME]
	var total: int = 0
	for key: String in colony.cells:
		var cell: Dictionary = colony.cells[key]
		if cell.type == "habitat" and not colony.connected.has(key): total += int(cell.level)*120*int(cell.get("width",1))*int(cell.get("depth",1))
	return total

static func command(sim: RefCounted, args: Dictionary) -> String:
	if not sim.state.has("urban"): return "Start the urban tutorial to use civic powers."
	var city: Dictionary = sim.state.urban
	var colony: Dictionary = sim.state.colonies[HOME]
	var action: String = str(args.get("choice",""))
	if action == "inspect":
		city.tutorial_step = 1
		return ""
	if action in ["public","sponsor"]:
		if not str(city.path).is_empty(): return "Your repair agreement is already signed."
		if action == "public":
			if colony.materials < 60: return "Public repair needs 60 materials."
			colony.materials -= 60
			city.remaining = 8
		else:
			if sim.state.credits < 180: return "Sponsored repair needs 180 Marks."
			sim.state.credits -= 180
			city.remaining = 2
		city.path = action
		city.tutorial_step = 1
		sim._log("Public crews begin an eight-day repair. Mutual aid will keep a 60-supply reserve." if action == "public" else "A two-day repair is commissioned. The sponsor receives 1 Mark/day after reopening.")
		return ""
	if not city.repaired: return "Reopen the crossing before using civic powers."
	if int(sim.state.tick) < int(city.ability_ready): return "Crews available again on day %d." % city.ability_ready
	if action == "mutual_aid":
		if city.path != "public": return "Mutual aid requires the public agreement."
		if colony.supplies < 90: return "Dispatch needs 30 supplies while retaining the promised 60."
		if colony.materials > 9979: return "Use some material storage before dispatching crews."
		colony.supplies -= 30
		colony.materials += 20
		city.ability_ready = int(sim.state.tick)+12
		sim._log("Mutual-aid crews recover 20 materials using 30 supplies. The community reserve remains protected.")
	elif action == "priority":
		if city.path != "sponsor": return "Priority works requires the sponsored agreement."
		if city.fee_due > 0: return "Priority works is suspended until the sponsorship arrears are paid from treasury income."
		var key: String = str(args.get("tile",""))
		if not colony.cells.has(key) or colony.reasons.get(key,"") != "Ready to grow": return "Inspect a connected zone marked Ready to grow first."
		if sim.state.credits < 30 or colony.materials < 15: return "Priority works needs 30 Marks and 15 materials."
		sim.state.credits -= 30
		colony.materials -= 15
		colony.cells[key].level = mini(2,int(colony.cells[key].level)+1)
		city.ability_ready = int(sim.state.tick)+4
		sim.refresh_colony(HOME)
		sim._log("Priority works completes one zone level. The sponsorship fee continues.")
	else: return "Unknown civic action."
	city.uses += 1
	return ""

static func tick(sim: RefCounted) -> void:
	var city: Dictionary = sim.state.urban
	if int(city.remaining) > 0:
		city.remaining -= 1
		if int(city.remaining) == 0:
			_cell(sim.state.colonies[HOME],32,32,"road")
			city.repaired = true
			sim.refresh_colony(HOME)
			sim._log("South Loop reconnected. Your coalition has earned its first civic power. Build on that support, or scout opportunities in the frontier.")
	if city.repaired and city.path == "sponsor":
		city.fee_due += 1.0
		var fee: float = minf(float(city.fee_due),float(sim.state.credits))
		sim.state.credits -= fee
		city.fees_paid += fee
		city.fee_due -= fee
