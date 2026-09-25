extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
var checks: int = 0
var failures: int = 0

func _initialize() -> void: call_deferred("run")

func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+title)

func advance(game: RefCounted, seconds: int) -> void:
	for i: int in range(seconds): game.tick()

func fixture() -> RefCounted:
	var game := Session.new()
	game.field.marks = 1000
	game.colonies.buy_kit(game,"basin_port",Field.service_position("basin_port"))
	game.field.change_flight_mode("orbit"); game.begin_travel("s1p0")
	while game.traveling(): game.tick()
	game.field.start_survey(); advance(game,12); game.field.change_flight_mode("surface")
	game.colonies.deploy(game,Vector2(-6,-18),Vector3(-6,8,-18))
	advance(game,18*30)
	game.colonies.state.outposts.s1p0.stock.water = 12
	game.sector_clock = 0
	for system: Dictionary in game.sector.state.systems:
		system.visited = true
	return game

func run() -> void:
	var game: RefCounted = fixture()
	var freight: RefCounted = game.freight

	# 1. SAFE ROUTES: Outpost s1p0 to s2p0 (unowned territory s1 -> s2)
	# Set up a second outpost on s2p0
	game.colonies.state.outposts["s2p0"] = {"site":[-6.0,-18.0],"module":"glass","stock":{"alloy":0,"water":0,"glass":0},"status":"Export facility commissioned","online_recorded":true}
	game.sector._create_colony("s2p0",false)

	check(freight.configure(game,"s1p0","s2p0","water",4).is_empty(),"Safe route configured between friendly outposts")
	var route: Dictionary = freight.state.routes.s1p0
	check(route.incident.is_empty() and route.incident_count == 0 and route.incidents_this_trip == 0,"New route initialized with empty incident state")

	# Dispatch safe carrier
	freight.tick(game)
	check(freight.pause(game,"s1p0").is_empty(),"Pause future departures so carrier remains waiting upon return")
	check(route.phase == "outbound" and route.cargo == 4,"Safe carrier dispatched with 4 units of cargo")
	check(route.incident.is_empty(),"Safe route experiences 0 incidents upon departure")

	# Travel outbound across safe territory (s1 -> s2)
	for i: int in range(route.duration):
		freight.tick(game)
		check(route.incident.is_empty(),"Carrier in safe territory encounters no incident during day %d" % i)

	check(route.phase == "returning" and route.delivered == 4 and route.cargo == 0,"Safe delivery completes without incident")

	# Complete return trip
	for i: int in range(route.duration):
		freight.tick(game)
		check(route.incident.is_empty(),"Safe return voyage encounters no incident")

	check(route.phase == "waiting" and route.incident.is_empty() and route.incident_count == 0,"Safe round trip completes with 0 total incidents")

	# 2. HOSTILE ROUTES (AT-WAR TERRITORY)
	# Configure route to foreign market s7p0 (owned by consortium, traversed via s1 -> s0 -> s3 -> s7)
	game.diplomacy.contact(game,"consortium")
	game.diplomacy.act(game,"consortium","trade")
	game.colonies.state.outposts.s1p0.stock.water = 12
	check(freight.configure(game,"s1p0","s7p0","water",4).is_empty(),"Configured foreign route to consortium market")
	route = freight.state.routes.s1p0

	# Dispatch carrier
	freight.tick(game)
	check(freight.pause(game,"s1p0").is_empty(),"Pause future departures for test isolation")
	check(route.phase == "outbound" and route.cargo == 4,"Consortium consignment dispatched with 4 cargo")
	var initial_cargo: int = route.cargo
	var warehouse_after_dispatch: int = game.colonies.state.outposts.s1p0.stock.water

	# Now declare war on consortium while carrier is in transit
	game.conflict.declare(game,"consortium","Border dispute")
	check(game.conflict.at_war("consortium"),"Consortium is formally at war")

	# Advance carrier until it encounters hostile territory
	var events_before: int = game.diplomacy.state.events.size()
	for day: int in range(route.duration):
		freight.tick(game)
		if not route.incident.is_empty():
			break

	# 3. VERIFY HOSTILE INCIDENT STATE
	check(not route.incident.is_empty(),"Hostile at-war territory triggers route incident")
	var inc: Dictionary = route.incident
	check(inc.carrier == "s1p0","Incident records actual carrier outpost ID")
	check(inc.system == "s7","Incident records actual hostile star system")
	check(inc.faction == "consortium","Incident records threatening faction")
	check(inc.risk == "privateer","War territory generates privateer risk")
	check(inc.cargo == 4 and inc.item == "water","Incident records actual consignment cargo and commodity")
	check(inc.time == int(game.field.state.time),"Incident records authoritative timestamp")
	check(inc.route == ["s1","s7"],"Incident records charted route endpoints")
	check(inc.resolved == false,"Incident is unresolved")
	check(route.status.begins_with("Intercepted"),"Route status reflects interception: "+route.status)

	# 4. CARGO CONSERVATION
	check(route.cargo == 4,"Carrier cargo is conserved aboard; never silently deleted")
	check(game.colonies.state.outposts.s1p0.stock.water == warehouse_after_dispatch,"Warehouse stock remains intact")
	check(game.colonies.state.outposts.s1p0.stock.water + route.cargo == 12,"Total goods conserved across warehouse and carrier")

	# Chronicle verification
	check(game.diplomacy.state.events.size() > events_before,"Incident records an event in diplomacy chronicle")
	var last_event: Dictionary = game.diplomacy.state.events.back()
	check(last_event.outcome.get("incident_id") == inc.id,"Chronicle links the incident ID")
	check(last_event.outcome.get("cargo") == 4,"Chronicle records cargo held aboard")

	# 5. CAP REPEAT INCIDENTS PER ROUTE
	check(route.incidents_this_trip == 1,"Trip incident count is exactly 1")
	check(route.incident_count == 1,"Total incident count is 1")
	var remaining_days: int = route.remaining
	var incident_id: String = inc.id
	# Tick multiple times while held
	for i: int in range(5):
		freight.tick(game)
	check(route.incidents_this_trip == 1,"Repeat incidents are capped; trip count does not grow while held")
	check(route.incident_count == 1,"Lifetime incident count does not inflate while held")
	check(route.incident.id == incident_id,"Incident ID remains identical")
	check(route.remaining == remaining_days,"Carrier journey is held at incident system")
	check(route.cargo == 4,"Conserved cargo remains fully aboard across held ticks")

	# 6. DETERMINISM TEST
	var sim1 := Session.new()
	var sim2 := Session.new()
	var sim1_snap: Dictionary = game.snapshot()
	sim1.restore_snapshot(sim1_snap)
	sim2.restore_snapshot(sim1_snap)
	# Advance both simulations identically
	advance(sim1, 60)
	advance(sim2, 60)
	check(sim1.snapshot() == sim2.snapshot(),"Identical world state produces 100% deterministic incident simulation")

	# 7. SAVE / LOAD ROUNDTRIP
	var path: String = "res://artifacts/freight_incident.fw"
	check(game.save_to(path) == OK,"Save campaign with active intercepted carrier")
	var loaded := Session.new()
	check(loaded.load_from(path) == OK and loaded.snapshot() == game.snapshot(),"Load campaign restores identical incident state")
	var loaded_route: Dictionary = loaded.freight.state.routes.get("s1p0",{})
	check(loaded_route.incident.id == inc.id and loaded_route.incident.risk == "privateer" and loaded_route.incident.cargo == 4,"Loaded carrier incident matches original")
	check(loaded_route.incident_count == 1 and loaded_route.incidents_this_trip == 1,"Loaded incident counts match original")

	# 8. ATOMIC REJECTION OF CORRUPT INCIDENT DATA
	var before: Dictionary = game.snapshot()
	var corrupt: Dictionary = before.duplicate(true)
	corrupt.freight.routes.s1p0.incident.cargo = 5
	check(game.restore_snapshot(corrupt) != OK and game.snapshot() == before,"Overcapacity cargo in incident rejected atomically")

	corrupt = before.duplicate(true)
	corrupt.freight.routes.s1p0.incident.cargo = -1
	check(game.restore_snapshot(corrupt) != OK and game.snapshot() == before,"Negative cargo in incident rejected atomically")

	corrupt = before.duplicate(true)
	corrupt.freight.routes.s1p0.incident.carrier = "invalid_outpost"
	check(game.restore_snapshot(corrupt) != OK and game.snapshot() == before,"Mismatched carrier in incident rejected atomically")

	corrupt = before.duplicate(true)
	corrupt.freight.routes.s1p0.incident.phase = "waiting"
	check(game.restore_snapshot(corrupt) != OK and game.snapshot() == before,"Waiting phase in active incident rejected atomically")

	corrupt = before.duplicate(true)
	corrupt.freight.routes.s1p0.incident = "not_a_dictionary"
	check(game.restore_snapshot(corrupt) != OK and game.snapshot() == before,"Non-dictionary incident rejected atomically")

	corrupt = before.duplicate(true)
	corrupt.freight.routes.s1p0.incident_count = -1
	check(game.restore_snapshot(corrupt) != OK and game.snapshot() == before,"Negative incident_count rejected atomically")

	corrupt = before.duplicate(true)
	corrupt.freight.routes.s1p0.incidents_this_trip = -1
	check(game.restore_snapshot(corrupt) != OK and game.snapshot() == before,"Negative incidents_this_trip rejected atomically")

	# 9. HOSTILE ROUTE (HOSTILE DISPOSITION / RELATIONS < 0 WITHOUT WAR)
	var game_hostile: RefCounted = fixture()
	game_hostile.colonies.state.outposts.s1p0.stock.water = 12
	game_hostile.diplomacy.contact(game_hostile,"consortium")
	game_hostile.diplomacy.act(game_hostile,"consortium","trade")
	game_hostile.freight.configure(game_hostile,"s1p0","s7p0","water",4)
	var h_route: Dictionary = game_hostile.freight.state.routes.s1p0
	game_hostile.freight.tick(game_hostile)
	check(h_route.phase == "outbound" and h_route.cargo == 4,"Carrier dispatched for disposition test")

	# Set consortium relation to hostile (< 0)
	var consortium_faction: Dictionary = game_hostile.sector.faction_by_id("consortium")
	consortium_faction.relation = -35
	consortium_faction.embargo = false
	# Ensure non-aggression so border remains legally open but territory is hostile
	game_hostile.sector.state.agreements.append("consortium:non_aggression")

	for day: int in range(h_route.duration):
		game_hostile.freight.tick(game_hostile)
		if not h_route.incident.is_empty():
			break

	check(not h_route.incident.is_empty(),"Hostile relations trigger threat incident even when not formally at war")
	check(h_route.incident.risk in ["hostile_patrol","raider"],"Hostile relations yield hostile patrol or raider risk")
	check(h_route.incident.cargo == 4,"Hostile patrol incident preserves all 4 cargo units")

	print("Freight piracy assertions: %d; failures: %d" % [checks,failures])
	quit(1 if failures else 0)
