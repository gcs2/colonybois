extends RefCounted
## Campaign ownership boundary: one treasury, fixed clock and atomic save for both models.
## The flagship owns travel; inactive planet state contains no copied ship or money.
const Sector = preload("res://scripts/simulation.gd")
const Field = preload("res://scripts/encounter_state.gd")
const VERSION := 12
const Climate = preload("res://scripts/planet_climate.gd")
var climate := Climate.new()
const Fleet = preload("res://scripts/allied_fleet.gd")
var fleet := Fleet.new()
const SurfaceCombat = preload("res://scripts/surface_combat.gd")
var combat := SurfaceCombat.new()
const Freight = preload("res://scripts/expedition_freight.gd")
var freight := Freight.new()
const Colonies = preload("res://scripts/expedition_colonies.gd")
var colonies := Colonies.new()
const Diplomacy = preload("res://scripts/expedition_diplomacy.gd")
var diplomacy := Diplomacy.new()
const Commerce = preload("res://scripts/space_commerce.gd")
var commerce := Commerce.new()
const Geography = preload("res://scripts/planet_geography.gd")
const LOCAL_KEYS := ["scanned","native_stock","warm","seeded","growth","produce","buyer_remaining","route","route_clock","harvest_clock","survey_ticks","survey_active","threat_clock","guardian_x","guardian_z","guardian_hull","guardian_alert","guardian_ready_at","guardian_disabled","guardian_shots","service_stock","guardian_aim","guardian_fire_at","guardian_salvaged","repair_stock"]
const SECONDS_PER_DAY := 30
const HEADER := "FWEXP001"
var sector := Sector.new()
var field := Field.new()
var sector_clock: int = 0
var worlds: Dictionary = {}

func _init() -> void:
	sector.new_game()
	# A new flight campaign keeps the existing zero-Mark start. No migration windfall.
	sector.state.credits = field.marks
	sector.state.planets.s0p0.name = "Morrow"
	field.bind_account(sector.state)
	configure_flagship()
	climate.bind(self)

func tick(threat_distance: float = INF) -> String:
	var was_surveying: bool = field.state.survey_active
	var result: String = field.tick(INF if traveling() else threat_distance)
	combat.resolve(self)
	climate.tick(self)
	if was_surveying and not field.state.survey_active:
		diplomacy.record(self,"exploration","Completed orbital survey of "+str(field.definition().name)+".","",{"survey_ticks":field.state.survey_ticks},0,"survey:"+str(field.state.planet_id))
	advance_worlds()
	if traveling(): advance_travel()
	commerce.update_badges(self)
	sector_clock += 1
	if sector_clock >= SECONDS_PER_DAY:
		sector_clock = 0
		var trade_access: Dictionary = {}
		for faction: Dictionary in sector.state.factions:
			if faction.get("contacted",false): trade_access[faction.id] = faction.get("embargo",false)
		sector.tick()
		colonies.tick(self)
		commerce.tick_markets(self)
		freight.tick(self)
		for id: String in trade_access:
			var faction: Dictionary = sector.faction_by_id(id)
			if bool(faction.get("embargo",false)) != trade_access[id]:
				diplomacy.record(self,"diplomacy",str(faction.name)+(" imposed a trade embargo." if faction.embargo else " reopened trade."),id,{"embargo":faction.embargo,"relation":faction.relation,"reason":faction.reason})
	fleet.reconcile(self)
	return result

func import_legacy(path: String) -> Error:
	var imported := Field.new()
	var error: Error = imported.load_from(path)
	if error != OK: return error
	# Never combine balances from unrelated strategic and field campaigns.
	sector.state.credits = imported.marks
	field = imported
	field.bind_account(sector.state)
	sector_clock = 0
	worlds.clear()
	commerce = Commerce.new()
	combat = SurfaceCombat.new()
	fleet = Fleet.new()
	climate = Climate.new()
	colonies = Colonies.new()
	freight = Freight.new()
	diplomacy = Diplomacy.new()
	diplomacy.record(self,"archive","Detailed chronicle begins here. Earlier activity remains in the expedition log.")
	climate.bind(self)
	configure_flagship()
	return OK

static func newest_save(manual: String, automatic: String) -> String:
	if not FileAccess.file_exists(manual): return automatic if FileAccess.file_exists(automatic) else ""
	if not FileAccess.file_exists(automatic): return manual
	return automatic if FileAccess.get_modified_time(automatic) > FileAccess.get_modified_time(manual) else manual

func snapshot() -> Dictionary:
	return {"version":VERSION,"climate":climate.state.duplicate(true),"fleet":fleet.state.duplicate(true),"combat":combat.state.duplicate(true),"freight":freight.state.duplicate(true),"colonies":colonies.state.duplicate(true),"diplomacy":diplomacy.state.duplicate(true),"commerce":commerce.state.duplicate(true),"sector_clock":sector_clock,"worlds":worlds.duplicate(true),
		"sector":sector.state.duplicate(true),"field":field.state.duplicate(true)}

func save_to(path: String) -> Error:
	var file := FileAccess.open(path+".tmp",FileAccess.WRITE)
	if file == null: return FileAccess.get_open_error()
	file.store_buffer(HEADER.to_utf8_buffer())
	file.store_var(snapshot(),false)
	file.flush()
	var error: Error = file.get_error()
	file.close()
	if error != OK: return error
	return DirAccess.rename_absolute(path+".tmp",path)

func load_from(path: String) -> Error:
	var file := FileAccess.open(path,FileAccess.READ)
	if file == null: return FileAccess.get_open_error()
	if file.get_buffer(8).get_string_from_utf8() != HEADER: return ERR_FILE_UNRECOGNIZED
	if file.get_length() < 16: return ERR_INVALID_DATA
	var payload_size: int = file.get_32()
	if payload_size < 4 or payload_size != file.get_length()-12: return ERR_INVALID_DATA
	file.seek(8)
	return restore_snapshot(file.get_var(false))

func restore_snapshot(source: Variant) -> Error:
	if not source is Dictionary or not source.has_all(["version","sector_clock","sector","field"]): return ERR_INVALID_DATA
	if source.version not in [1,2,3,4,5,6,7,8,9,10,11,VERSION] or not source.sector_clock is int or source.sector_clock < 0 or source.sector_clock >= SECONDS_PER_DAY: return ERR_INVALID_DATA
	if not source.sector is Dictionary or not source.field is Dictionary: return ERR_INVALID_DATA
	var bank: Variant = source.sector.get("credits")
	if not (bank is float or bank is int) or not is_finite(float(bank)) or bank < 0: return ERR_INVALID_DATA
	# Detached candidates keep failed loads from half-replacing a live campaign.
	var candidate_sector := Sector.new()
	var error: Error = candidate_sector.restore_snapshot(source.sector)
	if error != OK: return error
	var candidate_field := Field.new()
	# Validate owned equipment before hull/energy; a forged capacity cannot admit an overfilled ship.
	var candidate_commerce := Commerce.new()
	if source.version >= 3 and candidate_commerce.restore(source.get("commerce")) != OK: return ERR_INVALID_DATA
	candidate_field.installed_upgrades = candidate_commerce.state.upgrades
	var field_data: Dictionary = source.field.duplicate(true)
	if field_data.has("marks"): return ERR_INVALID_DATA
	field_data["marks"] = 0
	error = candidate_field.restore_snapshot(field_data)
	if error != OK: return error
	if source.version >= 2 and not source.has("worlds"): return ERR_INVALID_DATA
	var saved_worlds: Variant = source.get("worlds",{})
	if not saved_worlds is Dictionary or saved_worlds.size() > 23: return ERR_INVALID_DATA
	saved_worlds = saved_worlds.duplicate(true)
	for id: Variant in saved_worlds:
		if not id is String or Geography.definition(id).is_empty() or id == candidate_field.state.planet_id or not saved_worlds[id] is Dictionary: return ERR_INVALID_DATA
		if source.version < 7:
			saved_worlds[id].merge({"guardian_aim":[0.0,8.0,0.0],"guardian_fire_at":0,"guardian_salvaged":false})
			if id != "morrow" and not saved_worlds[id].get("guardian_disabled",false): saved_worlds[id].guardian_hull = Field.Encounters.hull(id)
		if source.version < 9 and not saved_worlds[id].has("repair_stock"): saved_worlds[id].repair_stock = Field.initial_repair_stock()
		if saved_worlds[id].size() != LOCAL_KEYS.size(): return ERR_INVALID_DATA
		var probe: Dictionary = Field.fresh()
		probe.planet_id = id
		probe.flight_mode = "orbit"
		probe.time = candidate_field.state.time
		for key: String in LOCAL_KEYS:
			if not saved_worlds[id].has(key): return ERR_INVALID_DATA
			probe[key] = saved_worlds[id][key]
		if Field.new().restore_snapshot(probe) != OK: return ERR_INVALID_DATA
	var candidate_diplomacy := Diplomacy.new()
	var candidate_combat := SurfaceCombat.new()
	var candidate_fleet := Fleet.new()
	var candidate_climate := Climate.new()
	if source.version >= 12 and candidate_climate.restore(source.get("climate"),candidate_commerce.state.upgrades) != OK: return ERR_INVALID_DATA
	if source.version >= 11 and candidate_fleet.restore(source.get("fleet"),int(candidate_field.state.time),candidate_sector) != OK: return ERR_INVALID_DATA
	var fleet_slots: int = mini(3,maxi(candidate_commerce.state.badges.explorer,maxi(candidate_commerce.state.badges.merchant,candidate_commerce.state.badges.defender)))
	if candidate_fleet.active_ids().size() > fleet_slots: return ERR_INVALID_DATA
	if source.version >= 10 and candidate_combat.restore(source.get("combat"),int(candidate_field.state.time),candidate_commerce.state.upgrades) != OK: return ERR_INVALID_DATA
	var candidate_colonies := Colonies.new()
	if source.version >= 5 and candidate_colonies.restore(source.get("colonies"),candidate_sector,candidate_commerce) != OK: return ERR_INVALID_DATA
	var candidate_freight := Freight.new()
	if source.version >= 6 and candidate_freight.restore(source.get("freight"),candidate_sector,candidate_colonies) != OK: return ERR_INVALID_DATA
	if source.version >= 4 and candidate_diplomacy.restore(source.get("diplomacy")) != OK: return ERR_INVALID_DATA
	if not candidate_diplomacy.state.events.is_empty() and candidate_diplomacy.state.events.back().time > candidate_field.state.time: return ERR_INVALID_DATA
	if source.version >= 2:
		var ship: Dictionary = candidate_sector.state.flagship
		if not ship.has_all(["personal","planet","target_planet","duration","remaining","destination","system","route"]) or ship.personal != true: return ERR_INVALID_DATA
		if ship.planet != candidate_field.state.planet_id or system_of(ship.planet) != ship.system: return ERR_INVALID_DATA
		if not ship.remaining is int or not ship.duration is int or ship.remaining < 0 or ship.duration < 0 or ship.remaining > ship.duration: return ERR_INVALID_DATA
		if not ship.target_planet is String or not ship.destination is String or not ship.route is Array: return ERR_INVALID_DATA
		if not ship.target_planet.is_empty():
			if Geography.definition(ship.target_planet).is_empty() or system_of(ship.target_planet) != ship.destination or ship.remaining <= 0 or candidate_field.state.flight_mode != "orbit": return ERR_INVALID_DATA
		elif ship.remaining != 0 or not ship.destination.is_empty(): return ERR_INVALID_DATA
	sector.state = candidate_sector.state
	field.state = candidate_field.state
	field.bind_account(sector.state)
	sector_clock = source.sector_clock
	worlds = saved_worlds.duplicate(true)
	commerce = candidate_commerce
	combat = candidate_combat
	fleet = candidate_fleet
	climate = candidate_climate
	field.installed_upgrades = commerce.state.upgrades
	colonies = candidate_colonies
	freight = candidate_freight
	diplomacy = candidate_diplomacy
	climate.bind(self)
	if source.version < 4: diplomacy.record(self,"archive","Detailed chronicle begins here. Earlier activity remains in the expedition log.")
	if source.version == 1: configure_flagship()
	return OK

func configure_flagship() -> void:
	field.installed_upgrades = commerce.state.upgrades
	sector.state.flagship = {"personal":true,"planet":field.state.planet_id,"system":system_of(field.state.planet_id),"target_planet":"","destination":"","route":[],"remaining":0,"duration":0}

func service_reason(port: String, at: Vector3, action: String) -> String:
	var blocked: String = commerce.access(self,port,at)
	if not blocked.is_empty(): return blocked
	if action in ["recharge","pack"]: return field.service_reason(port,at,action == "pack")
	var items: Dictionary = Field.repair_items()
	if not items.has(action): return "Unknown service."
	var requirements: Dictionary = items[action].requires
	var eligible: bool = requirements.is_empty()
	for badge: String in requirements:
		if int(commerce.state.badges[badge]) >= int(requirements[badge]): eligible = true
	if not eligible:
		var alternatives: PackedStringArray = []
		for badge: String in requirements: alternatives.append("%s %d" % [commerce.catalog.badges[badge].name,requirements[badge]])
		return "Requires "+" or ".join(alternatives)+"."
	return field.repair_purchase_reason(port,at,action)

func purchase_service(port: String, at: Vector3, action: String) -> String:
	var blocked: String = service_reason(port,at,action)
	if not blocked.is_empty(): return blocked
	var balance: float = field.marks
	var error: String
	if action == "recharge": error = field.recharge(port,at)
	elif action == "pack": error = field.buy_energy_pack(port,at)
	else: error = field.buy_repair_pack(port,at,action)
	if not error.is_empty(): return error
	var title: String = "Recharge" if action == "recharge" else "Energy pack" if action == "pack" else Field.repair_items()[action].name
	diplomacy.record(self,"equipment","%s · %d Marks at %s." % [title,balance-field.marks,field.local_services()[port].name],"",{"service":action,"cost":balance-field.marks,"port":port,"planet":field.state.planet_id})
	return ""

func use_repair_pack(item: String) -> String:
	var hull_before: float = field.state.hull
	var error: String = field.use_repair_pack(item)
	if error.is_empty(): diplomacy.record(self,"equipment","Used %s · restored %d hull." % [Field.repair_items()[item].name,field.state.hull-hull_before],"",{"item":item,"restored":field.state.hull-hull_before})
	return error

static func system_of(id: String) -> String:
	return "s0" if id == "morrow" else id.get_slice("p",0)

static func local_id(id: String) -> String:
	return "morrow" if id == "s0p0" else id

func traveling() -> bool:
	return not str(sector.state.flagship.get("target_planet","")).is_empty()

func quote(id: String) -> Dictionary:
	var target: Dictionary = Geography.definition(id)
	if target.is_empty(): return {"reason":"Unknown destination.","energy":0,"seconds":0,"route":[]}
	var destination: String = system_of(id)
	var route: Array = sector.route_between(sector.state.flagship.system,destination,true)
	var hops: int = maxi(0,route.size()-1)
	var energy: int = 3 if hops == 0 else hops*8
	var seconds: int = 6 if hops == 0 else hops*12
	var reason: String = ""
	if traveling(): reason = "Journey already underway."
	elif field.state.flight_mode != "orbit": reason = "Leave the atmosphere first."
	elif id == field.state.planet_id: reason = "Already in orbit here."
	elif not sector.is_revealed(destination): reason = "Explore the frontier to reveal this system."
	elif route.is_empty(): reason = "No accessible route; check border restrictions."
	elif hops > commerce.drive_range(): reason = "Beyond the drive's %d-link range." % commerce.drive_range()
	elif field.state.survey_active: reason = "Wait for the orbital survey to finish."
	elif field.state.guardian_alert > 0: reason = "Break contact with the custodian before jumping."
	elif field.state.energy < energy: reason = "Need %d energy. Dock or use a reserve pack." % energy
	return {"reason":reason,"energy":energy,"seconds":seconds,"route":route}

func begin_travel(id: String) -> String:
	var offer: Dictionary = quote(id)
	if not offer.reason.is_empty(): return offer.reason
	if field.has_wreck():
		var at := Vector3(field.state.position[0],field.state.position[1],field.state.position[2])
		if at.distance_to(Field.WRECK_POSITION) < Field.HAZARD_WARNING: return "Leave the defense field before jumping."
	field.state.energy -= offer.energy
	field.state.shroud_on = false
	var ship: Dictionary = sector.state.flagship
	ship.target_planet = id
	ship.destination = system_of(id)
	ship.route = offer.route
	ship.remaining = offer.seconds
	ship.duration = offer.seconds
	var known_system: Dictionary = sector.system_by_id(system_of(id))
	var destination_name: String = Geography.definition(id).name if known_system.visited or known_system.get("charted",false) else "an uncharted system"
	field.note("departure_%d" % field.state.time,"Departed for %s; drive consumed %d energy." % [destination_name,offer.energy])
	return ""

func advance_travel() -> void:
	var ship: Dictionary = sector.state.flagship
	if sector.route_between(ship.system,ship.destination,true).is_empty():
		field.note("blocked_%d" % field.state.time,"Passage closed. Returned to departure orbit; spent drive energy is not refunded.")
		ship.target_planet = ""; ship.destination = ""; ship.remaining = 0; ship.route = []
		return
	ship.remaining -= 1
	if ship.remaining > 0: return
	var departing: String = field.state.planet_id
	worlds[departing] = {}
	for key: String in LOCAL_KEYS: worlds[departing][key] = field.state[key]
	var target: String = ship.target_planet
	var next_world: Dictionary = worlds.get(target,Field.fresh(target))
	for key: String in LOCAL_KEYS: field.state[key] = next_world[key]
	worlds.erase(target)
	field.state.planet_id = target
	field.state.position = [0.0,8.0,8.0]
	field.state.yaw = 0.0
	ship.planet = target
	ship.system = ship.destination
	ship.target_planet = ""; ship.destination = ""; ship.remaining = 0; ship.route = []
	var system: Dictionary = sector.system_by_id(ship.system)
	system.visited = true
	if not str(system.owner).is_empty(): diplomacy.contact(self,system.owner)
	diplomacy.record(self,"exploration","Reached "+str(Geography.definition(target).name)+".","",{"planet":target},0,"arrival:"+target)
	field.note("arrival_%d" % field.state.time,"Reached "+Geography.definition(target).name+". Chart its orbit or approach a landing site.")

func advance_worlds() -> void:
	# Aggregate local production only; no hidden geometry, creatures or ship hazards.
	for id: String in worlds:
		var local := Field.new()
		local.state.planet_id = id
		local.state.time = field.state.time
		local.state.history = field.state.history
		for key: String in LOCAL_KEYS: local.state[key] = worlds[id][key]
		local.bind_account(sector.state)
		local.tick_ecology()
		for key: String in LOCAL_KEYS: worlds[id][key] = local.state[key]

func fire_weapon(at: Vector3) -> String:
	var error: String = field.fire_lance(at)
	if error.is_empty() and field.state.guardian_disabled:
		diplomacy.record(self,"combat",field.enemy_profile().name+" neutralized at "+field.definition().name+".","",{"planet":field.state.planet_id,"enemy":field.enemy_profile().name,"nonlethal":field.has_wreck()},0,"defeat:"+field.state.planet_id)
		commerce.update_badges(self)
	return error

func salvage_enemy(at: Vector3) -> String:
	if traveling() or field.state.flight_mode != "orbit" or not field.has_guardian() or field.has_wreck(): return "No recoverable enemy cargo here."
	if not field.state.guardian_disabled: return "Neutralize the hostile ship first."
	if field.state.guardian_salvaged: return "Cargo already recovered."
	if not at.is_finite() or at.distance_to(field.guardian_position()) > 10: return "Approach within 10 m to recover cargo."
	var profile: Dictionary = field.enemy_profile()
	if commerce.used_space(self)+int(profile.quantity) > commerce.capacity(): return "Reserve two cargo spaces for salvage."
	commerce.add_cargo(profile.bounty,int(profile.quantity),field.state.planet_id)
	field.state.guardian_salvaged = true
	field.note("enemy_salvage","Recovered %d %s from %s." % [profile.quantity,commerce.catalog.goods[profile.bounty].name,profile.name])
	diplomacy.record(self,"combat","Recovered cargo from "+str(profile.name)+".","",{"planet":field.state.planet_id,"item":profile.bounty,"quantity":profile.quantity})
	return ""
