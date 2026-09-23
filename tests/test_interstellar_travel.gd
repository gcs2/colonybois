extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Geography = preload("res://scripts/planet_geography.gd")
var checks: int = 0
var failures: int = 0

func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+title)

func _initialize() -> void: call_deferred("run")

func finish(game: RefCounted) -> void:
	for i: int in range(60):
		if not game.traveling(): break
		game.tick()

func run() -> void:
	var game := Session.new()
	check(not game.begin_travel("s1p0").is_empty() and game.field.state.energy == 100,"Surface cannot jump and rejection spends nothing")
	game.field.change_flight_mode("orbit")
	check(not game.begin_travel("s11p0").is_empty(),"Unknown distant systems cannot bypass discovery fog")
	check(not game.sector.command("travel",{"system":"s1"}).is_empty(),"Legacy strategic travel cannot move the same ship independently")
	check(game.quote("s1p0").energy == 8 and game.quote("s1p0").seconds == 12,"Neighbor journey exposes cost and duration before launch")
	game.field.state.scanned.append("relay")
	game.field.state.samples = 1
	game.field.state.hull = 63.0
	game.field.state.shroud_unlocked = true
	game.field.state.energy_packs = 2
	game.field.state.warm = true
	game.field.state.seeded = true
	game.field.state.growth = 1.0
	game.field.state.service_stock.orbit_tender = 0
	check(game.begin_travel("s1p0").is_empty() and game.field.state.energy == 92,"Departure consumes energy once")
	check(not game.begin_travel("s2p0").is_empty() and game.field.state.energy == 92,"Repeated departure cannot double spend or replace the destination")
	for i: int in range(5): game.tick()
	check(game.traveling() and game.field.state.planet_id == "morrow" and game.sector.state.flagship.remaining == 7,"Travel takes time without revealing destination early")
	var path: String = "res://artifacts/transit_test.fw"
	check(game.save_to(path) == OK,"In-transit campaign saves")
	var loaded := Session.new()
	check(loaded.load_from(path) == OK and loaded.snapshot() == game.snapshot(),"Destination, spent fuel and remaining journey survive restore")
	finish(game); finish(loaded)
	check(game.snapshot() == loaded.snapshot(),"Mid-flight restore reaches the same outcome")
	check(game.field.state.planet_id == "s1p0" and game.sector.state.flagship.system == "s1" and game.sector.system_by_id("s1").visited,"Arrival unifies personal and strategic location and discovers the system")
	check(game.field.state.samples == 1 and game.field.state.hull == 63 and game.field.state.shroud_unlocked and game.field.state.energy_packs == 2,"Arrival preserves cargo, hull, equipment and reserve packs")
	check(game.field.state.scanned.is_empty() and game.field.state.survey_ticks == 0 and not game.field.state.seeded,"A new world starts with its own uncharted ecology")
	check(game.worlds.morrow.scanned == ["relay"] and game.worlds.morrow.service_stock.orbit_tender == 0,"Visited world retains discoveries and depleted shop stock")
	check(not game.worlds.has("s1p0") and not game.field.state.has("marks"),"Active world and account are not duplicated into inactive records")
	game.field.state.energy = 40.0
	game.sector.state.credits = 100.0
	var cost: int = game.field.recharge_price("orbit_tender")
	check(cost == 36,"Frozen-world recharge uses the local provider rate")
	game.field.recharge("orbit_tender",game.field.service_position("orbit_tender"))
	check(game.field.marks == 64 and game.field.state.energy == 100,"Remote docking charges the real treasury")
	game.field.act("scan","relay",0)
	check(game.field.state.history.any(func(entry: Dictionary) -> bool: return entry.id == "s1p0:scan_relay"),"Discovery history keeps separate world-scoped achievements")
	game.field.state.energy = 1.0
	check(not game.begin_travel("morrow").is_empty() and game.field.state.planet_id == "s1p0","Insufficient fuel blocks travel instead of granting a free return")
	game.field.state.energy = 100.0
	game.begin_travel("morrow")
	finish(game)
	check(game.field.state.scanned == ["relay"] and game.field.state.seeded and game.field.state.service_stock.orbit_tender == 0,"Returning home restores its local changes instead of resetting the world")
	check(game.field.state.produce >= 2,"Established local production continues while the ship is away")
	check(game.field.recharge_price("orbit_tender") == 0,"Home recharge remains free after interstellar travel")
	check(game.worlds.s1p0.scanned == ["relay"],"Leaving the second world preserves its own discovery state")
	check(game.save_to(path) == OK and loaded.load_from(path) == OK and loaded.snapshot() == game.snapshot(),"Multiple visited worlds round-trip without losing independent state")
	var old: Dictionary = Session.new().snapshot()
	old.version = 1
	old.erase("worlds")
	old.sector.flagship = {"system":"s0","destination":"","route":[],"remaining":0}
	check(Session.new().restore_snapshot(old) == OK,"Previous combined saves migrate to personal travel ownership")
	var snapshot: Dictionary = game.snapshot()
	var corrupt: Dictionary = snapshot.duplicate(true)
	corrupt.worlds.s1p0.service_stock.orbit_tender = -1
	check(game.restore_snapshot(corrupt) != OK and game.snapshot() == snapshot,"Invalid inactive-world data cannot partially restore a campaign")
	check(Geography.definition("s2p0").archetype == "arid" and Geography.definition("s1p0").archetype == "frozen","Pilot destinations use distinct environment recipes")
	check(Geography.definition("s1p1").sites.is_empty(),"Orbital-only worlds do not advertise nonexistent landing sites")
	var border := Session.new()
	border.field.change_flight_mode("orbit")
	border.sector.system_by_id("s1").owner = "consortium"
	border.sector.faction_by_id("consortium")["embargo"] = true
	check(not border.begin_travel("s1p0").is_empty() and border.field.state.energy == 100,"Embargo blocks departure without spending energy")
	border.sector.faction_by_id("consortium").embargo = false
	border.begin_travel("s1p0")
	border.sector.faction_by_id("consortium").embargo = true
	border.tick()
	check(not border.traveling() and border.field.state.planet_id == "morrow" and border.field.state.energy == 92,"Border closure cancels transit without inventing an arrival or refund")
	check(not border.sector.system_by_id("s1").visited,"Canceled journey does not reveal the destination")
	var explorer := Session.new()
	explorer.field.change_flight_mode("orbit")
	var visited_bodies: int = 0
	var itinerary_ok: bool = true
	for system: Dictionary in explorer.sector.state.systems:
		var route: Array = explorer.sector.route_between(explorer.sector.state.flagship.system,system.id,true)
		for hop: String in route:
			if hop == explorer.sector.state.flagship.system: continue
			explorer.field.state.energy = 100.0
			var destination: String = Session.local_id(explorer.sector.system_by_id(hop).planets[0])
			itinerary_ok = itinerary_ok and explorer.begin_travel(destination).is_empty()
			finish(explorer)
		for pid: String in system.planets:
			var destination: String = Session.local_id(pid)
			if destination != explorer.field.state.planet_id:
				explorer.field.state.energy = 100.0
				itinerary_ok = itinerary_ok and explorer.begin_travel(destination).is_empty()
				finish(explorer)
			if explorer.field.state.planet_id == destination: visited_bodies += 1
	check(itinerary_ok and visited_bodies == 24,"All 24 orbital destinations are reachable through discovered routes and intermediate stops")
	check(explorer.worlds.size() == 23 and explorer.save_to(path) == OK and loaded.load_from(path) == OK,"Full-sector exploration saves every inactive world without duplicating the active world")
	check(not explorer.field.change_flight_mode("surface"),"An orbital-only world rejects descent through the model as well as the interface")
	# Exercise real chart controls, transition, landing and the suspended title callback.
	var main: Node3D = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main.speed = 0
	main._open_field()
	await process_frame
	var scene: Node3D = root.get_node("ExpeditionFlight")
	scene.set_process(false); scene.set_physics_process(false)
	scene.campaign = Session.new(); scene.model = scene.campaign.field
	scene.save_path = "res://artifacts/travel_scene.json"
	scene._change_flight_mode("orbit")
	scene.hud.sector_button.pressed.emit()
	check(scene.sector_map.visible and not scene.hud.navigation.visible,"Sector navigation opens from a button; no local chart leaks into orbit")
	scene.sector_map.select_system("s1")
	check(not scene.sector_map.travel.disabled and "8 energy" in scene.sector_map.travel.text,"Chart exposes a real actionable journey quote")
	scene.sector_map.travel.pressed.emit()
	check(scene.campaign.traveling() and scene.sector_map.close.disabled,"Clicking departure starts persistent transit")
	scene._process(12)
	await process_frame
	await process_frame
	scene = root.get_node("ExpeditionFlight")
	scene.set_process(false); scene.set_physics_process(false)
	check(scene.model.state.planet_id == "s1p0" and scene.orbit.planet.planet_definition.id == "s1p0","Arrival rebuilds the actual orbital globe for the destination")
	check(not scene.orbit.wreck.visible and not scene.orbit.guardian.visible,"Morrow's authored enemy and wreck are not duplicated on other planets")
	scene._begin_landing()
	for i: int in range(2000):
		if scene.model.state.flight_mode == "surface": break
		scene._physics_process(1.0/60)
	check(scene.model.state.flight_mode == "surface" and scene.surface_root.visible,"The frozen destination supports a real approach and surface flight")
	scene._toggle_planet_map()
	check(scene.planet_map.definition.id == "s1p0" and scene.planet_map.globe.planet_definition.id == "s1p0","Planet overview shares destination geography and site coordinates")
	scene.planet_map.hide()
	var frozen_height: float = scene.terrain_height(38,4)
	scene._change_flight_mode("orbit")
	scene._toggle_sector_map()
	scene._launch_journey("s2p0")
	scene._process(24)
	await process_frame
	await process_frame
	scene = root.get_node("ExpeditionFlight")
	scene.set_process(false); scene.set_physics_process(false)
	check(scene.model.state.planet_id == "s2p0" and scene.world_definition.archetype == "arid","The same ship reaches the third pilot world")
	check(scene.terrain_height(38,4) != frozen_height,"Arid and frozen surfaces differ in topography, not only color")
	scene._begin_landing()
	for i: int in range(2000):
		if scene.model.state.flight_mode == "surface": break
		scene._physics_process(1.0/60)
	check(scene.model.state.flight_mode == "surface","Arid destination supports atmospheric entry")
	scene.leave.emit()
	await process_frame
	check(main.is_inside_tree(),"Returning to title still works after replacing the flight scene")
	main.free()
	print("Interstellar travel assertions: ",checks,"; failures: ",failures)
	quit(0 if failures == 0 else 1)
