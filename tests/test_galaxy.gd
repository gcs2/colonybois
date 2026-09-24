extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Galaxy = preload("res://scripts/galaxy_catalog.gd")
const Chart = preload("res://scripts/sector_chart.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+title)
func finish(game: RefCounted) -> void:
	for i: int in range(60):
		if not game.traveling(): break
		game.tick()
func run() -> void:
	var started: int = Time.get_ticks_msec()
	var game := Session.new()
	check(game.sector.state.systems.size() == 2048,"Galaxy contains real persistent star records beyond the twelve authored systems")
	check(Galaxy.coordinates(2409) == Galaxy.coordinates(2409) and Galaxy.coordinates(2410) != Galaxy.coordinates(2409),"Generation is seeded and repeatable")
	check(game.commerce.drive_range() == 3,"Initial reach is three parsecs")
	game.field.change_flight_mode("orbit")
	var origin: Dictionary = game.sector.system_by_id("s0")
	var target: Dictionary = game.sector.system_by_id("s12")
	check(is_equal_approx(Galaxy.distance(origin,target),4.2),"Distance is physical star separation, not a graph hop")
	check(game.sector.is_revealed("s12") and not target.visited,"Sensors detect a reachable future frontier without inventing a visit")
	check(not game.quote("s12p0").reason.is_empty(),"Base drive cannot reach a detected 4.2 pc star")
	var before: Dictionary = game.snapshot()
	check(not game.begin_travel("s12p0").is_empty() and game.snapshot() == before,"Rejected jump spends and changes nothing")
	game.commerce.state.badges.explorer = 5; game.sector.state.credits = 6000
	var upgrades := ["drive","drive_2","drive_3","drive_4"]
	for i: int in range(upgrades.size()):
		var balance: float = game.field.marks
		check(game.commerce.buy_upgrade(game,"orbit_tender",game.field.service_position("orbit_tender"),upgrades[i]).is_empty(),"Eligible engine is actually purchased: "+upgrades[i])
		check(game.commerce.drive_range() == [5,8,12,20][i] and game.field.marks == balance-game.commerce.catalog.upgrades[upgrades[i]].price,"Purchase increases actual parsec reach and debits Marks")
	check(game.quote("s12p0").reason.is_empty() and game.quote("s12p0").route == ["s0","s12"],"Paid reach opens a direct jump, independent of freight links")
	var booked: Array = origin.links.duplicate()
	check(booked == game.sector.system_by_id("s0").links,"Personal upgrade preserves carrier connections")
	var fuel: float = game.field.state.energy
	var cost: int = game.quote("s12p0").energy
	check(game.begin_travel("s12p0").is_empty() and game.field.state.energy == fuel-cost,"Generated destination charges real energy")
	game.tick()
	var saved: Dictionary = game.snapshot()
	var loaded := Session.new()
	check(loaded.restore_snapshot(saved) == OK and loaded.snapshot() == saved,"Generated destination restores mid-jump atomically")
	finish(game); finish(loaded)
	check(game.snapshot() == loaded.snapshot() and game.field.state.planet_id == "s12p0","Seed, commands and loaded continuation give identical outcomes")
	check(game.field.definition().id == "s12p0" and game.sector.system_by_id("s12").visited,"Arrival creates a real generated orbital destination")
	check(game.field.start_survey().is_empty(),"New destination supports actual survey")
	for i: int in range(12): game.tick()
	check(game.field.state.survey_ticks == 12,"Survey completes on the generated world")
	check(not game.field.change_flight_mode("surface"),"Does not falsely claim a whole surface is implemented")
	check(game.field.local_services().is_empty(),"Uninhabited generated worlds do not fabricate free shops")
	var itinerary_ok: bool = true
	for index: int in range(13,40):
		game.field.state.energy = 100.0
		itinerary_ok = itinerary_ok and game.begin_travel("s%dp0" % index).is_empty()
		finish(game)
	check(itinerary_ok and game.worlds.size() > 24,"Actual travel explores beyond the old saved-world limit")
	check(loaded.restore_snapshot(game.snapshot()) == OK and loaded.snapshot() == game.snapshot(),"More than twenty-four explored worlds preserve independent state")
	var damaged: Dictionary = game.snapshot(); damaged.sector.systems[12].pc_x = NAN
	before = loaded.snapshot()
	check(loaded.restore_snapshot(damaged) != OK and loaded.snapshot() == before,"Invalid galaxy coordinates cannot partially replace a live save")
	var old := Session.new(); var legacy: Dictionary = old.snapshot(); legacy.version = 18
	legacy.sector.erase("galaxy_version"); legacy.sector.systems = legacy.sector.systems.slice(0,12)
	for star: Dictionary in legacy.sector.systems:
		star.erase("pc_x"); star.erase("pc_z"); star.erase("detected")
		star.links = star.links.filter(func(id: String) -> bool: return int(id.substr(1)) < 12)
	for id: String in legacy.sector.planets.keys():
		if int(id.get_slice("p",0).substr(1)) >= 12: legacy.sector.planets.erase(id)
	check(loaded.restore_snapshot(legacy) == OK and loaded.sector.state.systems.size() == 2048,"Version 18 campaign migrates into galaxy with original IDs")
	check(loaded.field.state.energy == old.field.state.energy and loaded.field.marks == old.field.marks and loaded.sector.state.colonies == old.sector.state.colonies,"Migration gifts no resources and preserves colonies")
	var chart := Chart.new(); root.add_child(chart); chart.present(game); await process_frame
	var graph: Control = chart.graph
	var current_id: String = game.sector.state.flagship.system
	var pc: Vector2 = Galaxy.position(game.sector.system_by_id(current_id))
	var at: Vector2 = graph.project(pc+Vector2(3,0))
	graph.yaw = 1.2; graph.pitch = -0.6
	check(graph.project(pc+Vector2(3,0)).distance_to(at) > 20,"Camera orbits around and below the galaxy")
	check(graph.point(game.sector.system_by_id(current_id)).is_equal_approx(graph.project(pc)),"Stars and range geometry share the same plane projection")
	graph.overview(); check(graph.project(Vector2.ZERO).distance_to(graph.view_center()) < 0.01,"Galaxy overview centres the real core after orbiting")
	graph.reset_view(); check(graph.point(game.sector.system_by_id(current_id)).distance_to(graph.view_center()) < 0.01,"Ship focus returns from overview")
	var old_yaw: float = graph.yaw; chart.key(KEY_KP_6)
	check(graph.yaw != old_yaw,"Numpad controls galaxy orbit for left-handed mouse users")
	var cursor: Vector2 = graph.project(pc+Vector2(2,-1))
	var underneath: Vector2 = graph.world_at(cursor)
	graph.zoom_at(-2,cursor)
	check(graph.project(underneath).distance_to(cursor) < 0.01,"Perspective zoom keeps the actual plane point under the cursor")
	var departures: Array = []; chart.travel_requested.connect(func(id: String) -> void: departures.append(id))
	chart.select_system("s38"); chart.activate_system("s38")
	check(departures == ["s38p0"],"Direct selected-star activation requests a real destination")
	game.field.state.energy = 0.0; chart.activate_system("s38")
	check(departures.size() == 1,"Insufficient fuel prevents direct activation")
	chart.free()
	# Build the actual flight scene at a generated destination, not only model data.
	game.field.state.energy = 100.0
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); scene.campaign = game
	root.add_child(scene); scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	check(scene.orbit.planet.planet_definition.id == "s39p0","Real orbital scene uses the generated planet's geography")
	check(not scene.model.has_guardian(),"Does not copy authored enemy encounters to every generated star")
	scene.free()
	print("Galaxy checks: %d; failures: %d; elapsed %d ms" % [checks,failures,Time.get_ticks_msec()-started])
	quit(1 if failures else 0)
