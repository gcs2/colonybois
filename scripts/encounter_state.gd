extends RefCounted
## Independent encounter snapshot. No changes to campaign economy or save slots.
const VERSION := 3
const Geography = preload("res://scripts/planet_geography.gd")
const Equipment = preload("res://scripts/equipment_catalog.gd")
const TARGETS := ["pod", "grazer", "bed", "relay"]
var state: Dictionary = fresh()

static func fresh() -> Dictionary:
	return {"version":VERSION, "time":0, "scanned":[], "samples":0, "native_stock":3,
		"warm":false, "seeded":false, "growth":0.0, "produce":0, "marks":0, "buyer_remaining":6,
		"route":false, "route_clock":0, "harvest_clock":0, "energy":100.0, "history":[],
		"position":[0.0,5.0,12.0], "yaw":0.0, "flight_mode":"surface", "landings":0,
		"planet_id":"morrow", "survey_ticks":0, "survey_active":false}

func survey_reason() -> String:
	if state.survey_ticks >= int(Geography.definition().survey_seconds): return "Morrow's orbital chart is complete."
	if state.survey_active: return "Orbital survey already commissioned."
	if state.flight_mode != "orbit": return "Reach orbit to chart the planet."
	if state.energy < float(Geography.definition().survey_energy): return "Need 20 energy to initiate orbital survey."
	return ""

func start_survey() -> String:
	var error: String = survey_reason()
	if not error.is_empty(): return error
	state.energy -= float(Geography.definition().survey_energy)
	state.survey_active = true
	return ""

func change_flight_mode(mode: String) -> bool:
	if mode not in ["surface","orbit"] or mode == state.flight_mode: return false
	state.flight_mode = mode
	if mode == "orbit":
		state.position = [0.0,8.0,35.0]
		note("first_orbit","Beyond the clouds — reached Morrow orbit under your own power.")
	else:
		state.position = [0.0,32.0,12.0]
		state.landings += 1
		note("first_return","Homeward — returned to Morrow with the expedition intact.")
	return true

func note(id: String, text: String) -> void:
	for entry: Dictionary in state.history:
		if entry.id == id: return
	state.history.append({"id":id, "time":state.time, "text":text})

func reason(action: String, target: String, distance: float) -> String:
	if not Equipment.has_tool(action): return "Unknown tool."
	if target not in TARGETS: return "Select a lifeform or a site."
	if not is_finite(distance) or distance < 0 or distance > Equipment.reach(action): return "Fly closer — tool reach is %s m." % Equipment.amount(Equipment.reach(action))
	if action == "scan":
		if target in state.scanned: return "Already catalogued. Try another tool or another subject."
	if Equipment.value(action,"requires_scan") and target not in state.scanned: return "Scan this subject first."
	if target not in Equipment.value(action,"targets"): return str(Equipment.value(action,"target_error"))
	if action == "collect":
		if state.native_stock <= 1: return "Keep the last native pod for the grazers. Cultivate more in the bed."
		if state.samples >= 2: return "Sample cradle full (2). Plant one in the warmed bed."
	if action == "warm":
		if state.warm: return "The bed is warm. Deploy a collected seed."
	if action == "seed":
		if not state.warm: return "Warm the bed before planting."
		if state.seeded: return "Already planted. Watch the canopy develop."
	if state.samples < Equipment.samples(action): return "Collect a seed pod first."
	if state.energy < Equipment.energy(action): return "Need %s energy. The ship recharges while you explore." % Equipment.amount(Equipment.energy(action))
	return ""

func act(action: String, target: String, distance: float) -> String:
	var error: String = reason(action,target,distance)
	if not error.is_empty(): return error
	state.energy -= Equipment.energy(action)
	state.samples -= Equipment.samples(action)
	match action:
		"scan":
			state.scanned.append(target)
			note("scan_"+target,"Catalogued " + {"pod":"lantern pods: seeds need warm mineral soil.","grazer":"bell grazers: they feed on native pods; preserve a wild reserve.","bed":"a cold mineral bed: suitable for optional cultivation.","relay":"an orbital navigation relay. Its signal continues above the clouds."}[target])
		"collect":
			state.samples += 1
			state.native_stock -= 1
			note("first_sample","Collected a living seed; retained a native feeding reserve.")
		"warm":
			state.warm = true
			note("warm_bed","Spent %s ship energy warming the mineral bed." % Equipment.amount(Equipment.energy(action)))
		"seed":
			state.seeded = true
			note("seed_bed","Established lantern pods in the prepared bed.")
	return ""

func tick() -> void:
	state.time += 1
	state.energy = minf(100.0,float(state.energy)+1.5)
	if state.survey_active and state.flight_mode == "orbit":
		state.survey_ticks += 1
		if state.survey_ticks >= int(Geography.definition().survey_seconds):
			state.survey_active = false
			note("orbital_chart","Charted Morrow from orbit. Continental geography resolved; ground resources and life remain to be surveyed.")
	if state.seeded and state.growth < 1.0:
		state.growth = minf(1.0,float(state.growth)+0.05)
		if state.growth >= 1.0: note("bloom","The bed bloomed. The old relay answered with light; its purpose remains unknown.")
	if state.growth >= 1.0:
		state.harvest_clock += 1
		if state.harvest_clock >= 12:
			state.harvest_clock = 0
			state.produce = mini(8,int(state.produce)+1)
	if state.route:
		state.route_clock += 1
		if state.route_clock >= 12:
			state.route_clock = 0
			if state.produce > 1 and state.buyer_remaining > 0: sell()
			if state.buyer_remaining == 0:
				state.route = false
				note("contract_complete","Completed the nursery's six-unit order. Deliveries stopped; no unlimited buyer demand.")

func sell() -> String:
	if state.produce < 1: return "No cultivated pods ready. The mature bed produces one every 12 seconds."
	if state.buyer_remaining <= 0: return "The nursery's order is filled. Keep the remaining harvest."
	state.produce -= 1
	state.buyer_remaining -= 1
	state.marks += 18
	var shipment: int = 6-int(state.buyer_remaining)
	note("sale_%d" % shipment,"Nursery delivery %d: one cultivated pod sold for 18 Marks." % shipment)
	return ""

func set_route(enabled: bool) -> String:
	if enabled and state.growth < 1.0: return "Establish a flowering bed first."
	if enabled and state.buyer_remaining <= 0: return "This order has already been filled."
	state.route = enabled
	state.route_clock = 0
	if enabled: note("route","Agreed recurring nursery deliveries: 18 Marks per pod, one local pod reserved, six units total demand.")
	return ""

func save_to(path: String) -> Error:
	var file := FileAccess.open(path,FileAccess.WRITE)
	if file == null: return FileAccess.get_open_error()
	file.store_string(JSON.stringify(state))
	return OK

func load_from(path: String) -> Error:
	var file := FileAccess.open(path,FileAccess.READ)
	if file == null: return FileAccess.get_open_error()
	var value: Variant = JSON.parse_string(file.get_as_text())
	if not value is Dictionary: return ERR_INVALID_DATA
	# Additive migration preserves the original field save and its optional ecology.
	if value.get("version") == 1:
		value.version = 2
		value.flight_mode = "surface"
		value.landings = 0
	if value.get("version") == 2:
		value.version = VERSION
		value.planet_id = "morrow"
		value.survey_ticks = 0
		value.survey_active = false
	var defaults: Dictionary = fresh()
	for key: String in defaults:
		if not value.has(key): return ERR_INVALID_DATA
		if typeof(defaults[key]) in [TYPE_INT,TYPE_FLOAT]:
			if not (typeof(value[key]) in [TYPE_INT,TYPE_FLOAT]) or not is_finite(float(value[key])): return ERR_INVALID_DATA
		elif typeof(defaults[key]) != typeof(value[key]): return ERR_INVALID_DATA
	if value.version != VERSION or value.samples < 0 or value.samples > 2 or value.native_stock < 1 or value.native_stock > 3: return ERR_INVALID_DATA
	if value.growth < 0 or value.growth > 1 or value.produce < 0 or value.produce > 8 or value.buyer_remaining < 0 or value.buyer_remaining > 6: return ERR_INVALID_DATA
	if value.energy < 0 or value.energy > 100 or value.time < 0 or value.marks < 0: return ERR_INVALID_DATA
	if value.flight_mode not in ["surface","orbit"] or value.landings < 0: return ERR_INVALID_DATA
	if value.planet_id != "morrow" or value.survey_ticks < 0 or value.survey_ticks > int(Geography.definition().survey_seconds): return ERR_INVALID_DATA
	if value.survey_ticks == int(Geography.definition().survey_seconds) and value.survey_active: return ERR_INVALID_DATA
	if value.survey_ticks > 0 and value.survey_ticks < int(Geography.definition().survey_seconds) and not value.survey_active: return ERR_INVALID_DATA
	if value.position.size() != 3 or value.scanned.size() > 4 or value.history.size() > 64: return ERR_INVALID_DATA
	for coordinate: Variant in value.position:
		if not (typeof(coordinate) in [TYPE_INT,TYPE_FLOAT]) or not is_finite(float(coordinate)) or absf(float(coordinate)) > 100: return ERR_INVALID_DATA
	for target: Variant in value.scanned:
		if target not in TARGETS: return ERR_INVALID_DATA
	for entry: Variant in value.history:
		if not entry is Dictionary or not entry.has_all(["id","time","text"]): return ERR_INVALID_DATA
		if not entry.id is String or not entry.text is String or not (typeof(entry.time) in [TYPE_INT,TYPE_FLOAT]): return ERR_INVALID_DATA
	if value.seeded and not value.warm: return ERR_INVALID_DATA
	if value.growth > 0 and not value.seeded: return ERR_INVALID_DATA
	for key: String in defaults:
		if typeof(defaults[key]) == TYPE_INT:
			if float(value[key]) != floorf(float(value[key])): return ERR_INVALID_DATA
			value[key] = int(value[key])
		elif typeof(defaults[key]) == TYPE_FLOAT: value[key] = float(value[key])
	for entry: Dictionary in value.history: entry.time = int(entry.time)
	state = value.duplicate(true)
	return OK
