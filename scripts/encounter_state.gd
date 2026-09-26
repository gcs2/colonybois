extends RefCounted
## Local encounter rules. A campaign may bind its shared treasury as the account.
const VERSION := 14
const Support = preload("res://scripts/ship_support.gd")
var shield_hit_time: int = -10
const Encounters = preload("res://scripts/orbital_encounters.gd")
var installed_upgrades: Array = []
var planetary: RefCounted
const Geography = preload("res://scripts/planet_geography.gd")
const Equipment = preload("res://scripts/equipment_catalog.gd")
const TARGETS := ["pod", "grazer", "bed", "relay", "vein"]
const MINERAL_DEPOSIT_UNITS := 4
const HAZARD_WARNING := 31.0
const HAZARD_RADIUS := 19.0
const SALVAGE_REACH := 10.0
const SALVAGE_ENERGY := 20.0
const REPAIR_ENERGY := 30.0
const REPAIR_HULL := 35.0
const REPAIR_COOLDOWN := 20
const WRECK_POSITION := Vector3(32,8,32)
const GUARDIAN_HOME := Vector3(43,8,36)
const GUARDIAN_ALERT_RANGE := 28.0
const GUARDIAN_FIRE_RANGE := 22.0
const LANCE_RANGE := 24.0
const LANCE_ENERGY := 10.0
const LANCE_DAMAGE := 22.0
const LANCE_COOLDOWN := 2
const PACK_ENERGY := 50.0
const PACK_CAPACITY := 3
const PACK_COOLDOWN := 8
const REPAIR_PACK_CAPACITY := 3
static var repair_catalog: Dictionary = {}
static var service_catalog: Dictionary = {}
static var upgrade_catalog: Dictionary = {}
var state: Dictionary = fresh()
var account: Dictionary = {}
var marks: float:
	get:
		return float(account.credits) if not account.is_empty() else float(state.marks)
	set(value):
		if not account.is_empty(): account.credits = value
		else: state.marks = int(value)

func bind_account(treasury: Dictionary) -> void:
	account = treasury
	state.erase("marks")

func snapshot() -> Dictionary:
	var result: Dictionary = state.duplicate(true)
	# Legacy format uses integer Marks. Integrated saves store the exact treasury separately.
	result["marks"] = int(marks)
	return result

static func services() -> Dictionary:
	if service_catalog.is_empty(): service_catalog = JSON.parse_string(FileAccess.get_file_as_string("res://data/energy_services.json"))
	return service_catalog.duplicate(true)

static func service_position(id: String) -> Vector3:
	var at: Array = services()[id].position
	return Vector3(at[0],at[1],at[2])

static func repair_items() -> Dictionary:
	if repair_catalog.is_empty(): repair_catalog = JSON.parse_string(FileAccess.get_file_as_string("res://data/repair_supplies.json"))
	return repair_catalog.duplicate(true)

static func initial_repair_stock() -> Dictionary:
	var result: Dictionary = {}
	for id: String in services():
		result[id] = {}
		for item: String in repair_items(): result[id][item] = int(services()[id].repair_stock[item])
	return result

func definition() -> Dictionary:
	return Geography.definition(state.planet_id)

func local_services() -> Dictionary:
	var result: Dictionary = services()
	var system_index: int = int(str(state.planet_id).get_slice("p",0).trim_prefix("s"))
	if system_index >= 12:
		if system_index%17 != 0: return {}
		result.erase("basin_port")
	if state.planet_id != "morrow":
		for id: String in result:
			result[id].planet = state.planet_id
			result[id].name = definition().name + (" landing port" if id == "basin_port" else " service tender")
			result[id].marks_per_energy = 0.6 if definition().archetype == "frozen" else 0.9
			result[id].marks_per_hull = 0.7 if definition().archetype == "frozen" else 1.0
			result[id].pack_price = 32 if definition().archetype == "frozen" else 44
			result[id].repair_prices = {"repair_pack":80,"mega_repair_pack":300} if definition().archetype == "frozen" else {"repair_pack":105,"mega_repair_pack":360}
	return result

func has_wreck() -> bool:
	return state.planet_id == "morrow"

func enemy_profile() -> Dictionary:
	return Encounters.profile(state.planet_id)

func has_guardian() -> bool:
	return not enemy_profile().is_empty()

func lance_damage() -> float:
	return (33.0 if "emitter" in installed_upgrades else LANCE_DAMAGE)*damage_multiplier()

func damage_multiplier() -> float:
	return 2.0 if Support.active(self,"rally_call") else 1.0

func receive_damage(amount: float) -> bool:
	if Support.active(self,"shield"):
		shield_hit_time = int(state.time)
		return false
	state.hull = maxf(0,float(state.hull)-amount)
	return true

func max_capacity(family: String) -> float:
	if upgrade_catalog.is_empty(): upgrade_catalog = JSON.parse_string(FileAccess.get_file_as_string("res://data/space_commerce.json")).upgrades
	var capacity: float = 100.0
	for id: String in installed_upgrades:
		var upgrade: Dictionary = upgrade_catalog.get(id,{})
		if upgrade.get("family","") == family: capacity = maxf(capacity,float(upgrade.get("capacity",100)))
	return capacity

func recharge_price(id: String) -> int:
	if not services().has(id): return -1
	if state.planet_id == state.homeworld_id: return 0
	return int(ceil(maxf(0,max_capacity("energy")-float(state.energy))*float(local_services()[id].marks_per_energy)))

func service_reason(id: String, at: Vector3, purchase_pack: bool = false) -> String:
	var providers: Dictionary = local_services()
	if not providers.has(id): return "No service provider at this location."
	var port: Dictionary = providers[id]
	if state.planet_id != port.planet or state.flight_mode != port.mode: return "Travel to %s first." % port.name
	if not at.is_finite() or at.distance_to(service_position(id)) > float(port.reach): return "Approach %s to dock." % port.name
	if purchase_pack:
		if state.energy_packs >= PACK_CAPACITY: return "Energy-pack storage full (3)."
		if state.service_stock[id] <= 0: return "This shop has sold its remaining energy packs."
		if marks < int(port.pack_price): return "Need %d Marks for an energy pack." % int(port.pack_price)
	else:
		if state.energy >= max_capacity("energy"): return "Energy is already full."
		if marks < recharge_price(id): return "Recharge costs %d Marks." % recharge_price(id)
	return ""

func recharge(id: String, at: Vector3) -> String:
	var error: String = service_reason(id,at)
	if not error.is_empty(): return error
	var cost: int = recharge_price(id)
	marks -= cost
	state.energy = max_capacity("energy")
	note("first_recharge","Docked for a recharge. Homeworld service is free; away from home, shops set their own rates.")
	return ""

func repair_hull_price(id: String) -> int:
	if not services().has(id): return -1
	var missing: float = maxf(0.0, max_capacity("hull") - float(state.hull))
	if missing <= 0.0: return 0
	var rate: float = float(local_services()[id].get("marks_per_hull", 0.5))
	return maxi(1, int(ceil(missing * rate)))

func dock_repair_price(id: String) -> int:
	return repair_hull_price(id)

func dock_repair_reason(id: String, at: Vector3) -> String:
	var providers: Dictionary = local_services()
	if not providers.has(id): return "No service provider at this location."
	var port: Dictionary = providers[id]
	if state.planet_id != port.planet or state.flight_mode != port.mode: return "Travel to %s first." % port.name
	if not at.is_finite() or at.distance_to(service_position(id)) > float(port.reach): return "Approach %s to dock." % port.name
	if state.hull >= max_capacity("hull"): return "Hull is sound."
	var price: int = repair_hull_price(id)
	if marks < price: return "Hull repair costs %d Marks." % price
	return ""

func dock_repair(id: String, at: Vector3) -> String:
	var error: String = dock_repair_reason(id, at)
	if not error.is_empty(): return error
	var cost: int = repair_hull_price(id)
	marks -= cost
	state.hull = max_capacity("hull")
	note("first_dock_repair", "Docked for hull repairs. Restored hull to full capacity.")
	return ""

func buy_energy_pack(id: String, at: Vector3) -> String:
	var error: String = service_reason(id,at,true)
	if not error.is_empty(): return error
	marks -= int(local_services()[id].pack_price)
	state.service_stock[id] -= 1
	state.energy_packs += 1
	return ""

func pack_reason() -> String:
	if state.energy_packs <= 0: return "No energy packs aboard. Dock at a shop to buy one."
	if state.energy >= max_capacity("energy"): return "Energy is already full."
	if state.time < state.pack_ready_at: return "Pack coupling cooling down."
	return ""

func use_energy_pack() -> String:
	var error: String = pack_reason()
	if not error.is_empty(): return error
	state.energy_packs -= 1
	state.energy = minf(max_capacity("energy"),float(state.energy)+PACK_ENERGY)
	state.pack_ready_at = state.time+PACK_COOLDOWN
	note("first_energy_pack","Consumed a reserve pack to restore ship energy away from a recharge dock.")
	return ""

func repair_pack_count() -> int:
	return int(state.repair_packs.repair_pack)+int(state.repair_packs.mega_repair_pack)

func repair_purchase_reason(id: String, at: Vector3, item: String) -> String:
	if not services().has(id) or not repair_items().has(item): return "Unknown repair supply."
	var port: Dictionary = local_services()[id]
	if state.planet_id != port.planet or state.flight_mode != port.mode: return "Travel to %s first." % port.name
	if not at.is_finite() or at.distance_to(service_position(id)) > float(port.reach): return "Approach %s to dock." % port.name
	if repair_pack_count() >= REPAIR_PACK_CAPACITY: return "Repair locker full (3)."
	if state.repair_stock[id][item] <= 0: return "This repair supply is sold out."
	if marks < int(port.repair_prices[item]): return "Need %d Marks." % int(port.repair_prices[item])
	return ""

func buy_repair_pack(id: String, at: Vector3, item: String) -> String:
	var error: String = repair_purchase_reason(id,at,item)
	if not error.is_empty(): return error
	marks -= int(local_services()[id].repair_prices[item])
	state.repair_stock[id][item] -= 1
	state.repair_packs[item] += 1
	return ""

func repair_pack_reason(item: String) -> String:
	if not repair_items().has(item): return "Unknown repair supply."
	if state.repair_packs[item] <= 0: return "No %s aboard. Buy one at a dock." % str(repair_items()[item].name).to_lower()
	if state.hull >= max_capacity("hull"): return "Hull is sound."
	if state.time-int(state.last_repair_at) < REPAIR_COOLDOWN: return "Repair system cooling down · %d s." % (REPAIR_COOLDOWN-state.time+int(state.last_repair_at))
	return ""

func use_repair_pack(item: String) -> String:
	var error: String = repair_pack_reason(item)
	if not error.is_empty(): return error
	var supply: Dictionary = repair_items()[item]
	state.repair_packs[item] -= 1
	state.hull = max_capacity("hull") if supply.full else minf(max_capacity("hull"),float(state.hull)+float(supply.hull))
	state.last_repair_at = state.time
	note("first_"+item,"Used a %s from the repair locker." % str(supply.name).to_lower())
	return ""


static func fresh(planet: String = "morrow") -> Dictionary:
	var initial_up: Vector3 = Geography.surface_direction(Geography.definition(planet), 0.0, 12.0)
	return {"version":VERSION, "support":Support.fresh(), "time":0, "scanned":[], "samples":0, "native_stock":3, "ore_remaining":MINERAL_DEPOSIT_UNITS,
		"surface_changes":{},
		"warm":false, "seeded":false, "growth":0.0, "produce":0, "marks":0, "buyer_remaining":6,
		"route":false, "route_clock":0, "harvest_clock":0, "energy":100.0, "history":[],
		"position":[0.0,5.0,12.0], "surface_position":[0.0,5.0,12.0], "surface_direction":[initial_up.x,initial_up.y,initial_up.z], "yaw":0.0, "flight_mode":"surface", "landings":0,
		"planet_id":planet, "survey_ticks":0, "survey_active":false,
		"hull":100.0, "shroud_unlocked":false, "shroud_on":false,
		"threat_clock":0, "tow_count":0, "last_repair_at":-REPAIR_COOLDOWN,
		"guardian_x":GUARDIAN_HOME.x, "guardian_z":GUARDIAN_HOME.z,
		"guardian_hull":Encounters.hull(planet), "guardian_alert":0, "guardian_ready_at":0,
		"guardian_disabled":false, "guardian_shots":0,
		"guardian_aim":[0.0,8.0,0.0], "guardian_fire_at":0, "guardian_salvaged":false,
		"weapon_ready_at":0, "weapon_shots":0, "homeworld_id":"morrow",
		"energy_packs":0, "pack_ready_at":0, "service_stock":{"basin_port":4,"orbit_tender":2},
		"repair_packs":{"repair_pack":0,"mega_repair_pack":0},"repair_stock":initial_repair_stock()}

func guardian_position() -> Vector3:
	return Vector3(float(state.guardian_x),GUARDIAN_HOME.y,float(state.guardian_z))

func lance_reason(ship_at: Vector3) -> String:
	if not has_guardian(): return "No orbital target here."
	if state.flight_mode != "orbit": return "Arc lance operates in orbit."
	if state.guardian_disabled: return "Custodian disabled. Its hull is intact."
	if not ship_at.is_finite(): return "Ship position unavailable."
	if ship_at.distance_to(guardian_position()) > LANCE_RANGE: return "Close within 24 m to fire."
	if state.time < state.weapon_ready_at: return "Arc lance recharging."
	if state.energy < LANCE_ENERGY: return "Need 10 energy to fire the arc lance."
	return ""

func fire_lance(ship_at: Vector3) -> String:
	var error: String = lance_reason(ship_at)
	if not error.is_empty(): return error
	state.energy -= LANCE_ENERGY
	state.weapon_ready_at = state.time+LANCE_COOLDOWN
	state.weapon_shots += 1
	damage_guardian(lance_damage())
	return ""

func damage_guardian(amount: float) -> void:
	if state.guardian_disabled: return
	state.guardian_hull = maxf(0,float(state.guardian_hull)-amount)
	if state.guardian_hull == 0:
		state.guardian_disabled = true
		state.guardian_alert = 0
		state.guardian_fire_at = 0
		note("guardian_disabled","Arc lance disabled the custodian skiff without destroying it. Its old exclusion order fell silent; ownership of the wreck remains unknown." if has_wreck() else enemy_profile().name+" neutralized. Its cargo can be recovered.")

func guardian_step(ship_at: Vector3, escorts: Array = []) -> String:
	if not has_guardian(): return ""
	# Called once after tick(), with the actual ship position. No scene nodes or RNG.
	if not ship_at.is_finite(): return ""
	if state.flight_mode != "orbit" or state.guardian_disabled:
		state.guardian_alert = 0
		state.guardian_fire_at = 0
		return ""
	var current: Vector3 = guardian_position()
	var intruding: bool = ship_at.distance_to(WRECK_POSITION) < GUARDIAN_ALERT_RANGE
	if intruding:
		state.guardian_alert = mini(3,int(state.guardian_alert)+1)
		if state.guardian_alert >= 3 and current.distance_to(ship_at) > 14:
			current = current.move_toward(Vector3(ship_at.x,GUARDIAN_HOME.y,ship_at.z),float(enemy_profile().chase))
			current = GUARDIAN_HOME+((current-GUARDIAN_HOME).limit_length(22))
	else:
		state.guardian_alert = 0
		state.guardian_fire_at = 0
		current = current.move_toward(GUARDIAN_HOME,4.0)
	state.guardian_x = current.x
	state.guardian_z = current.z
	var target: Vector3 = ship_at
	for escort: Vector3 in escorts:
		if escort.distance_to(current) < target.distance_to(current): target = escort
	if int(enemy_profile().windup) > 0:
		if state.guardian_fire_at > 0:
			if state.time < state.guardian_fire_at: return ""
			state.guardian_fire_at = 0
			state.guardian_ready_at = state.time+4
			state.guardian_shots += 1
			var aim := Vector3(state.guardian_aim[0],state.guardian_aim[1],state.guardian_aim[2])
			if ship_at.distance_to(aim) > float(enemy_profile().radius): return "guardian_miss"
			if not receive_damage(float(enemy_profile().damage)*(0.3 if state.shroud_on else 1.0)): return "shield_block"
			if state.hull > 0: return "guardian_hit"
			_emergency_tow(); return "tow"
		if intruding and state.guardian_alert >= 3 and current.distance_to(ship_at) <= GUARDIAN_FIRE_RANGE and state.time >= state.guardian_ready_at:
			state.guardian_aim = [target.x,target.y,target.z]
			state.guardian_fire_at = state.time+int(enemy_profile().windup)
			return "guardian_aim"
		return ""
	if not intruding or state.guardian_alert < 3 or current.distance_to(ship_at) > GUARDIAN_FIRE_RANGE or state.time < state.guardian_ready_at: return ""
	state.guardian_ready_at = state.time+4
	state.guardian_shots += 1
	state.guardian_aim = [target.x,target.y,target.z]
	if target.distance_to(ship_at) > 0.5: return "guardian_miss"
	if not receive_damage(3 if state.shroud_on else 10): return "shield_block"
	note("first_guardian_fire","A custodian skiff challenged the scout inside the wreck's exclusion zone. It breaks pursuit when ships withdraw.")
	if state.hull > 0: return "guardian_hit"
	_emergency_tow()
	return "tow"

func _emergency_tow() -> void:
	state.tow_count += 1
	for effect: Dictionary in state.support.values(): effect.until = 0
	state.hull = 35.0
	state.energy = minf(float(state.energy),15.0)
	state.shroud_on = false
	state.threat_clock = 0
	state.guardian_alert = 0
	state.guardian_fire_at = 0
	state.position = [0.0,8.0,35.0]
	if state.flight_mode == "surface": state.position = [0.0,5.0,12.0]
	note("emergency_tow_%d" % state.tow_count,"Scout disabled at %s. Emergency tow returned it to a safe holding position; hull and energy were lost." % definition().name)

func salvage_reason(distance: float) -> String:
	if not has_wreck(): return "No orbital target here."
	if state.flight_mode != "orbit": return "Reach orbit to investigate the wreck."
	if state.shroud_unlocked: return "The phase shroud has already been recovered."
	if state.survey_ticks < int(definition().survey_seconds): return "Chart Morrow first to locate the drifting wreck."
	if not is_finite(distance) or distance < 0 or distance > SALVAGE_REACH: return "Approach within 10 m of the wreck."
	if state.energy < SALVAGE_ENERGY: return "Need 20 energy to secure the shroud."
	return ""

func salvage(distance: float) -> String:
	var error: String = salvage_reason(distance)
	if not error.is_empty(): return error
	state.energy -= SALVAGE_ENERGY
	state.shroud_unlocked = true
	note("phase_shroud","Recovered a phase shroud from a drifting wreck. It blunts orbital pulses at a continuous energy cost.")
	return ""

func toggle_shroud() -> String:
	if not state.shroud_unlocked: return "Recover the phase shroud first."
	if state.flight_mode != "orbit": return "Engage the phase shroud in orbit."
	if not state.shroud_on and state.energy < 2: return "Need 2 energy to engage the shroud."
	state.shroud_on = not state.shroud_on
	return ""

func repair_reason(threat_distance: float) -> String:
	if state.hull >= max_capacity("hull"): return "Hull is sound."
	if state.flight_mode == "orbit" and (not is_finite(threat_distance) or threat_distance < 0): return "Ship location unavailable."
	if state.flight_mode == "orbit" and threat_distance < HAZARD_WARNING: return "Clear the pulse field before repair."
	if state.time-int(state.last_repair_at) < REPAIR_COOLDOWN: return "Repair cradle cooling down."
	if state.energy < REPAIR_ENERGY: return "Need 30 energy for field repairs."
	return ""

func repair(threat_distance: float) -> String:
	var error: String = repair_reason(threat_distance)
	if not error.is_empty(): return error
	state.energy -= REPAIR_ENERGY
	state.hull = minf(max_capacity("hull"),float(state.hull)+REPAIR_HULL)
	state.last_repair_at = state.time
	note("first_repair","Used the field cradle to repair the scout's hull.")
	return ""

func survey_reason() -> String:
	if state.survey_ticks >= int(definition().survey_seconds): return "This planet's orbital chart is complete."
	if state.survey_active: return "Orbital survey already commissioned."
	if state.flight_mode != "orbit": return "Reach orbit to chart the planet."
	if state.energy < float(definition().survey_energy): return "Need 20 energy to initiate orbital survey."
	return ""

func start_survey() -> String:
	var error: String = survey_reason()
	if not error.is_empty(): return error
	state.energy -= float(definition().survey_energy)
	state.survey_active = true
	return ""

func change_flight_mode(mode: String) -> bool:
	if mode == "surface" and definition().sites.is_empty(): return false
	if mode not in ["surface","orbit"] or mode == state.flight_mode: return false
	if state.flight_mode == "surface":
		state.surface_position = state.position.duplicate(true)
	state.flight_mode = mode
	state.guardian_alert = 0
	state.guardian_fire_at = 0
	if mode == "orbit":
		state.position = [0.0,8.0,35.0]
		note("first_orbit","Beyond the clouds — reached %s orbit under your own power." % definition().name)
	else:
		state.shroud_on = false
		var up := Vector3(float(state.surface_direction[0]),float(state.surface_direction[1]),float(state.surface_direction[2])).normalized()
		var offset: Vector2 = Geography.surface_local_position(definition(),up)
		state.position = [offset.x,float(state.surface_position[1]),offset.y]
		state.landings += 1
		note("first_return","Returned to %s with the expedition intact." % definition().name)
	return true

func note(id: String, text: String) -> void:
	if state.planet_id != "morrow": id = state.planet_id+":"+id
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
	if action == "mine" and state.ore_remaining <= 0: return "This seam is exhausted. Prospect another world."
	if action == "collect":
		if state.native_stock <= 1: return "Keep the last native pod for the grazers. Cultivate more in the bed."
		if state.samples >= 2: return "Sample cradle full (2). Plant one in the warmed bed."
	if action == "warm":
		if state.warm: return "The bed is warm. Deploy a collected seed."
	if action == "seed":
		if not state.warm: return "Warm the bed before planting."
		if state.seeded: return "Already planted. Watch the canopy develop."
	if state.samples < Equipment.samples(action): return "Collect a seed pod first."
	if state.energy < Equipment.energy(action,installed_upgrades): return "Need %s energy. Use an energy pack or dock for recharge." % Equipment.amount(Equipment.energy(action,installed_upgrades))
	return ""

func act(action: String, target: String, distance: float) -> String:
	var error: String = reason(action,target,distance)
	if not error.is_empty(): return error
	state.energy -= Equipment.energy(action,installed_upgrades)
	state.samples -= Equipment.samples(action)
	match action:
		"scan":
			state.scanned.append(target)
			note("scan_"+target,"Catalogued " + {"pod":"lantern pods: seeds need warm mineral soil.","grazer":"bell grazers: they feed on native pods; preserve a wild reserve.","bed":"a cold mineral bed: suitable for optional cultivation.","relay":"an orbital navigation relay. Its signal continues above the clouds.","vein":"resonant glass: exposed crystals grew under repeated thermal stress. The seam holds four recoverable pieces."}[target])
		"collect":
			state.samples += 1
			state.native_stock -= 1
			note("first_sample","Collected a living seed; retained a native feeding reserve.")
		"warm":
			state.warm = true
			note("warm_bed","Spent %s ship energy warming the mineral bed." % Equipment.amount(Equipment.energy(action,installed_upgrades)))
		"seed":
			state.seeded = true
			note("seed_bed","Established lantern pods in the prepared bed.")
		"mine":
			state.ore_remaining -= 1
			state.surface_changes["%s|site|vein" % str(state.planet_id)] = {"remaining":state.ore_remaining}
			note("cut_glass_%d" % (MINERAL_DEPOSIT_UNITS-state.ore_remaining),"Cut a resonant crystal from the exposed seam. %d pieces remain." % state.ore_remaining)
	return ""

func tick(threat_distance: float = INF) -> String:
	state.time += 1
	if state.survey_active and state.flight_mode == "orbit":
		state.survey_ticks += 1
		if state.survey_ticks >= int(definition().survey_seconds):
			state.survey_active = false
			note("orbital_chart","Charted %s from orbit. Continental geography resolved; ground resources and life remain to be surveyed." % definition().name)
	tick_ecology()
	if state.shroud_on:
		if state.energy >= 2: state.energy -= 2
		else: state.shroud_on = false
	if not has_wreck() or state.flight_mode != "orbit" or not is_finite(threat_distance) or threat_distance >= HAZARD_WARNING:
		state.threat_clock = 0
		return ""
	state.threat_clock += 1
	if state.threat_clock < 6: return ""
	state.threat_clock = 0
	if threat_distance >= HAZARD_RADIUS: return "warning"
	if not receive_damage(5 if state.shroud_on else 18): return "shield_block"
	note("first_pulse","The orbital wreck's defense field struck the scout. The pulse repeats while inside its core.")
	if state.hull > 0: return "pulse"
	_emergency_tow()
	return "tow"

func tick_ecology() -> void:
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
	marks += 18
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
	file.store_string(JSON.stringify(snapshot()))
	return OK

func load_from(path: String) -> Error:
	var file := FileAccess.open(path,FileAccess.READ)
	if file == null: return FileAccess.get_open_error()
	return restore_snapshot(JSON.parse_string(file.get_as_text()))

func restore_snapshot(source: Variant) -> Error:
	var value: Variant = source.duplicate(true) if source is Dictionary else source
	if not value is Dictionary: return ERR_INVALID_DATA
	# Additive migration preserves the original field save and its optional ecology.
	if value.get("version") == 1:
		value.version = 2
		value.flight_mode = "surface"
		value.landings = 0
	if value.get("version") == 2:
		value.version = 3
		value.planet_id = "morrow"
		value.survey_ticks = 0
		value.survey_active = false
	if value.get("version") == 3:
		value.version = 4
		value.hull = 100.0
		value.shroud_unlocked = false
		value.shroud_on = false
		value.threat_clock = 0
		value.tow_count = 0
		value.last_repair_at = -REPAIR_COOLDOWN
	if value.get("version") == 4:
		value.version = 5
		value.guardian_x = GUARDIAN_HOME.x
		value.guardian_z = GUARDIAN_HOME.z
		value.guardian_hull = 66.0
		value.guardian_alert = 0
		value.guardian_ready_at = 0
		value.guardian_disabled = false
		value.guardian_shots = 0
		value.weapon_ready_at = 0
		value.weapon_shots = 0
	if value.get("version") == 5:
		value.version = 6
		value.homeworld_id = "morrow"
		value.energy_packs = 0
		value.pack_ready_at = 0
		value.service_stock = {"basin_port":4,"orbit_tender":2}
	if value.get("version") == 6:
		value.version = 7
		value.guardian_aim = [0.0,8.0,0.0]
		value.guardian_fire_at = 0
		value.guardian_salvaged = false
		if value.planet_id != "morrow" and not value.guardian_disabled: value.guardian_hull = Encounters.hull(value.planet_id)
	if value.get("version") == 7:
		value.version = 8
		value.repair_packs = {"repair_pack":0,"mega_repair_pack":0}
		value.repair_stock = initial_repair_stock()
	if value.get("version") == 8:
		value.version = 9
		value.support = Support.fresh()
	if value.get("version") == 9:
		value.version = 10
		value.ore_remaining = MINERAL_DEPOSIT_UNITS
	if value.get("version") == 10:
		value.version = 11
		value.surface_position = value.position.duplicate(true) if value.get("flight_mode", "surface") == "surface" else [0.0,5.0,12.0]
	if value.get("version") == 11:
		value.version = 12
		# Old local coordinates have no defined planetary frame. Anchor migrated saves
		# to the authored landing direction; keep the exact planar return position too.
		value.surface_direction = [0.0,0.0,1.0]
	if value.get("version") == 12:
		value.version = 13
		var saved_surface: Variant = value.get("surface_position", [0.0,5.0,12.0])
		if not saved_surface is Array or saved_surface.size() != 3: return ERR_INVALID_DATA
		for component: Variant in saved_surface:
			if not (typeof(component) in [TYPE_INT,TYPE_FLOAT]) or not is_finite(float(component)): return ERR_INVALID_DATA
		var up: Vector3 = Geography.surface_direction(Geography.definition(str(value.get("planet_id", "morrow"))), float(saved_surface[0]), float(saved_surface[2]))
		value.surface_direction = [up.x,up.y,up.z]
	if value.get("version") == 13:
		value.version = VERSION
		value.surface_changes = {}
		if int(value.get("ore_remaining", MINERAL_DEPOSIT_UNITS)) < MINERAL_DEPOSIT_UNITS:
			value.surface_changes["%s|site|vein" % str(value.get("planet_id", "morrow"))] = {"remaining":int(value.ore_remaining)}
	var defaults: Dictionary = fresh()
	for key: String in defaults:
		if not value.has(key): return ERR_INVALID_DATA
		if typeof(defaults[key]) in [TYPE_INT,TYPE_FLOAT]:
			if not (typeof(value[key]) in [TYPE_INT,TYPE_FLOAT]) or not is_finite(float(value[key])): return ERR_INVALID_DATA
		elif typeof(defaults[key]) != typeof(value[key]): return ERR_INVALID_DATA
	if not Support.validate(value.support,int(value.time),installed_upgrades): return ERR_INVALID_DATA
	if value.version != VERSION or value.samples < 0 or value.samples > 2 or value.native_stock < 1 or value.native_stock > 3 or value.ore_remaining < 0 or value.ore_remaining > MINERAL_DEPOSIT_UNITS: return ERR_INVALID_DATA
	if not value.surface_changes is Dictionary or value.surface_changes.size() > 4096: return ERR_INVALID_DATA
	for surface_id: Variant in value.surface_changes:
		var change: Variant = value.surface_changes[surface_id]
		if not surface_id is String or surface_id.length() > 256 or not surface_id.begins_with("%s|" % str(value.planet_id)): return ERR_INVALID_DATA
		if not change is Dictionary or change.is_empty() or change.size() > 4: return ERR_INVALID_DATA
		if surface_id == "%s|site|vein" % str(value.planet_id):
			var remaining: Variant = change.get("remaining")
			if change.size() != 1 or not (remaining is int or remaining is float) or not is_finite(float(remaining)) or float(remaining) != floorf(float(remaining)) or int(remaining) != int(value.ore_remaining): return ERR_INVALID_DATA
		elif "|feature|" in surface_id:
			if change != {"removed":true}: return ERR_INVALID_DATA
		else:
			return ERR_INVALID_DATA
	if value.growth < 0 or value.growth > 1 or value.produce < 0 or value.produce > 8 or value.buyer_remaining < 0 or value.buyer_remaining > 6: return ERR_INVALID_DATA
	if value.homeworld_id.is_empty() or value.homeworld_id.length() > 64: return ERR_INVALID_DATA
	if value.energy_packs < 0 or value.energy_packs > PACK_CAPACITY or value.pack_ready_at < 0 or value.pack_ready_at > value.time+PACK_COOLDOWN: return ERR_INVALID_DATA
	if value.repair_packs.size() != repair_items().size() or value.repair_stock.size() != services().size(): return ERR_INVALID_DATA
	var repair_total: int = 0
	for item: String in repair_items():
		var count: Variant = value.repair_packs.get(item)
		if not (count is int or count is float) or not is_finite(float(count)) or count != floorf(count) or count < 0 or count > REPAIR_PACK_CAPACITY: return ERR_INVALID_DATA
		repair_total += int(count)
		value.repair_packs[item] = int(count)
	if repair_total > REPAIR_PACK_CAPACITY: return ERR_INVALID_DATA
	for id: String in services():
		var stock: Variant = value.repair_stock.get(id)
		if not stock is Dictionary or stock.size() != repair_items().size(): return ERR_INVALID_DATA
		for item: String in repair_items():
			var count: Variant = stock.get(item)
			if not (count is int or count is float) or not is_finite(float(count)) or count != floorf(count) or count < 0 or count > int(services()[id].repair_stock[item]): return ERR_INVALID_DATA
			stock[item] = int(count)
	if value.service_stock.size() != services().size(): return ERR_INVALID_DATA
	for id: String in services():
		if not value.service_stock.has(id): return ERR_INVALID_DATA
		var stock: Variant = value.service_stock[id]
		if not (stock is int or stock is float) or not is_finite(float(stock)) or stock != floorf(stock) or stock < 0 or stock > int(services()[id].pack_stock): return ERR_INVALID_DATA
		value.service_stock[id] = int(stock)
	if value.energy < 0 or value.energy > max_capacity("energy") or value.time < 0 or value.marks < 0: return ERR_INVALID_DATA
	if value.hull <= 0 or value.hull > max_capacity("hull") or value.threat_clock < 0 or value.threat_clock >= 6 or value.tow_count < 0: return ERR_INVALID_DATA
	if value.last_repair_at > value.time or value.last_repair_at < -REPAIR_COOLDOWN: return ERR_INVALID_DATA
	if value.shroud_on and not value.shroud_unlocked: return ERR_INVALID_DATA
	if value.guardian_hull < 0 or value.guardian_hull > Encounters.hull(value.planet_id) or value.guardian_alert < 0 or value.guardian_alert > 3: return ERR_INVALID_DATA
	if value.guardian_fire_at < 0 or value.guardian_fire_at > value.time+3 or (value.guardian_disabled and value.guardian_fire_at > 0): return ERR_INVALID_DATA
	if value.guardian_salvaged and not value.guardian_disabled: return ERR_INVALID_DATA
	if value.guardian_aim.size() != 3: return ERR_INVALID_DATA
	for coordinate: Variant in value.guardian_aim:
		if not (coordinate is int or coordinate is float) or not is_finite(float(coordinate)) or absf(float(coordinate)) > 100: return ERR_INVALID_DATA
	if not is_finite(float(value.guardian_x)) or not is_finite(float(value.guardian_z)): return ERR_INVALID_DATA
	if Vector2(float(value.guardian_x)-GUARDIAN_HOME.x,float(value.guardian_z)-GUARDIAN_HOME.z).length() > 22.01: return ERR_INVALID_DATA
	if value.guardian_ready_at < 0 or value.guardian_ready_at > value.time+4 or value.weapon_ready_at < 0 or value.weapon_ready_at > value.time+LANCE_COOLDOWN: return ERR_INVALID_DATA
	if value.guardian_shots < 0 or value.weapon_shots < 0 or value.guardian_disabled != (value.guardian_hull == 0): return ERR_INVALID_DATA
	if value.flight_mode not in ["surface","orbit"] or value.landings < 0: return ERR_INVALID_DATA
	if Geography.definition(value.planet_id).is_empty(): return ERR_INVALID_DATA
	if value.flight_mode == "surface" and Geography.definition(value.planet_id).sites.is_empty(): return ERR_INVALID_DATA
	if value.survey_ticks < 0 or value.survey_ticks > int(Geography.definition(value.planet_id).survey_seconds): return ERR_INVALID_DATA
	if value.survey_ticks == int(Geography.definition(value.planet_id).survey_seconds) and value.survey_active: return ERR_INVALID_DATA
	if value.survey_ticks > 0 and value.survey_ticks < int(Geography.definition(value.planet_id).survey_seconds) and not value.survey_active: return ERR_INVALID_DATA
	if value.position.size() != 3 or value.surface_position.size() != 3 or value.surface_direction.size() != 3 or value.scanned.size() > 4 or value.history.size() > 4096: return ERR_INVALID_DATA
	var surface_limit: float = Geography.surface_travel_radius(str(value.planet_id))
	for index: int in range(3):
		var coordinate: Variant = value.position[index]
		if not (typeof(coordinate) in [TYPE_INT,TYPE_FLOAT]) or not is_finite(float(coordinate)): return ERR_INVALID_DATA
		var bound: float = surface_limit if value.flight_mode == "surface" and index != 1 else 100.0
		if absf(float(coordinate)) > bound: return ERR_INVALID_DATA
		var surface_coordinate: Variant = value.surface_position[index]
		if not (typeof(surface_coordinate) in [TYPE_INT,TYPE_FLOAT]) or not is_finite(float(surface_coordinate)): return ERR_INVALID_DATA
		var surface_bound: float = 100.0 if index == 1 else surface_limit
		if absf(float(surface_coordinate)) > surface_bound: return ERR_INVALID_DATA
		var direction_component: Variant = value.surface_direction[index]
		if not (typeof(direction_component) in [TYPE_INT,TYPE_FLOAT]) or not is_finite(float(direction_component)): return ERR_INVALID_DATA
	if Vector2(float(value.surface_position[0]),float(value.surface_position[2])).length() > surface_limit: return ERR_INVALID_DATA
	var saved_direction := Vector3(float(value.surface_direction[0]),float(value.surface_direction[1]),float(value.surface_direction[2]))
	if saved_direction.length_squared() < 0.000001 or absf(saved_direction.length()-1.0) > 0.01: return ERR_INVALID_DATA
	saved_direction = saved_direction.normalized()
	value.surface_direction = [saved_direction.x,saved_direction.y,saved_direction.z]
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
	for entry: Dictionary in value.support.values():
		for key: String in entry: entry[key] = int(entry[key])
	state = value.duplicate(true)
	account = {}
	return OK
