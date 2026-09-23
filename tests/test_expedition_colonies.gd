extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
const Geography = preload("res://scripts/planet_geography.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+title)
func _initialize() -> void: call_deferred("run")
func advance(game: RefCounted, seconds: int) -> void:
	for i: int in range(seconds): game.tick()
func travel(game: RefCounted, planet: String) -> void:
	game.field.change_flight_mode("orbit")
	check(game.begin_travel(planet).is_empty(),"Launch physical kit/colony journey: "+planet)
	for i: int in range(60):
		if not game.traveling(): break
		game.tick()
func run() -> void:
	var game := Session.new()
	var c: RefCounted = game.colonies
	var port: Vector3 = Field.service_position("basin_port")
	var before: Dictionary = game.snapshot()
	check(not c.buy_kit(game,"basin_port",port).is_empty() and game.snapshot() == before,"Unaffordable colony kit spends nothing")
	game.field.marks = 500
	game.commerce.add_cargo("water",5,"morrow")
	before = game.snapshot()
	check(not c.buy_kit(game,"basin_port",port).is_empty() and game.snapshot() == before,"Kit needs four actual free hold spaces")
	game.commerce.state.cargo.clear()
	var materials: float = game.sector.state.colonies.s0p0.materials
	var supplies: float = game.sector.state.colonies.s0p0.supplies
	check(c.buy_kit(game,"basin_port",port).is_empty(),"Home dock assembles and loads a paid kit")
	check(game.field.marks == 200 and game.sector.state.colonies.s0p0.materials == materials-100 and game.sector.state.colonies.s0p0.supplies == supplies-80,"Marks and physical construction stocks are debited exactly once")
	check(game.commerce.used_space(game) == 4 and game.commerce.quantity() == 0,"Kit occupies cargo space without masquerading as saleable commodities")
	before = game.snapshot()
	check(not c.buy_kit(game,"basin_port",port).is_empty() and game.snapshot() == before,"Repeated purchase cannot duplicate a kit")
	check(not game.commerce.transact(game,"basin_port",port,"water",5,true).is_empty(),"Commodity purchases respect reserved kit space")
	check(not game.sector.command("colonize",{"planet":"s1p0"}).is_empty(),"Legacy command cannot bypass physical deployment")
	travel(game,"s1p0")
	game.field.change_flight_mode("surface")
	var site := Vector2(-6,-18)
	var ship := Vector3(site.x,Geography.surface_height(game.field.definition(),site.x,site.y)+7,site.y)
	before = game.snapshot()
	check(not c.deploy(game,site,ship).is_empty() and game.snapshot() == before,"Uncharted ground cannot consume a kit")
	game.field.change_flight_mode("orbit")
	game.field.start_survey()
	advance(game,12)
	game.field.change_flight_mode("surface")
	check(c.site_reason("s1p0",site).is_empty(),"Authored pilot terrain has a usable clear footprint")
	before = game.snapshot()
	check(not c.deploy(game,Vector2(8,-4),ship).is_empty() and game.snapshot() == before,"Protected mineral patch rejects placement without consuming cargo")
	check(not c.deploy(game,site,Vector3(30,40,30)).is_empty() and game.snapshot() == before,"Remote click must fly into unloading range")
	var placement_snapshot: Dictionary = game.snapshot()
	check(c.deploy(game,site,ship).is_empty(),"Surveyed clear site accepts physically delivered cargo")
	check(c.reserved_space() == 0 and game.sector.state.settlements.s1p0.remaining == 18 and not game.sector.state.colonies.has("s1p0"),"Kit becomes an eighteen-day project, not an instant occupied city")
	check(c.phase(game,"s1p0") == 0 and c.state.outposts.s1p0.stock.water == 0,"Initial stage is cargo with no free export output")
	before = game.snapshot()
	check(not c.deploy(game,site,ship).is_empty() and game.snapshot() == before,"Second deployment does not create another site")
	advance(game,7*30)
	check(c.phase(game,"s1p0") == 1,"Construction advances to lifting frame over time")
	var path: String = "res://artifacts/colony_kit.fw"
	check(game.save_to(path) == OK,"In-progress kit deployment saves")
	var loaded := Session.new()
	check(loaded.load_from(path) == OK and loaded.snapshot() == game.snapshot(),"Kit source, terrain coordinates, construction time and stock survive load")
	advance(game,6*30); advance(loaded,6*30)
	check(game.snapshot() == loaded.snapshot() and c.phase(game,"s1p0") == 2,"Loaded construction reaches identical shell stage")
	travel(game,"morrow")
	advance(game,5*30)
	check(game.sector.state.colonies.has("s1p0") and c.phase(game,"s1p0") == 3,"Colony completes while the player explores another world")
	check(game.sector.state.colonies.s1p0.population == 0 and game.sector.state.colonies.s1p0.cells.size() == 1,"Completion provides only the hub, not invented city population")
	check(c.state.outposts.s1p0.site == [site.x,site.y],"Original chosen footprint is persistent")
	check(c.install_reason(game,"s1p0","water").is_empty(),"Completed paid hub can commission an export facility")
	check(c.install(game,"s1p0","water").is_empty(),"Remote colony administration installs a paid export facility")
	var stock: int = c.state.outposts.s1p0.stock.water
	var idle := Session.new()
	idle.restore_snapshot(game.snapshot())
	idle.colonies.state.outposts.s1p0.module = ""
	advance(game,60)
	advance(idle,60)
	check(c.state.outposts.s1p0.stock.water == stock+2,"Frozen condensers produce two physical units per cycle while off-screen")
	check(is_equal_approx(idle.field.marks-game.field.marks,2.0) and is_equal_approx(idle.sector.state.colonies.s1p0.supplies-game.sector.state.colonies.s1p0.supplies,0.5),"One production cycle charges exactly two Marks and half a supply beyond ordinary colony operation")
	check(c.yield_for("s2p0","water") == 1 and c.yield_for("s2p0","glass") == 2,"Different worlds favor different export specializations")
	c.state.outposts.s1p0.stock.water = 16
	advance(game,60)
	check(c.state.outposts.s1p0.stock.water == 16 and c.state.outposts.s1p0.status.begins_with("Warehouse full"),"Capacity halts production instead of discarding goods")
	travel(game,"s1p0")
	var orbital: Vector3 = Field.service_position("orbit_tender")
	check(c.collect(game,"orbit_tender",orbital,"water",8).is_empty(),"Local dock transfers warehouse goods onto the real ship")
	check(c.state.outposts.s1p0.stock.water == 8 and game.commerce.quantity("water") == 8 and game.commerce.state.cargo[0].origin == "s1p0","Collection conserves quantities and provenance")
	before = game.snapshot()
	check(not c.collect(game,"orbit_tender",orbital,"water",1).is_empty() and game.snapshot() == before,"Full ship does not consume warehouse stock")
	check(game.save_to(path) == OK and loaded.load_from(path) == OK and loaded.snapshot() == game.snapshot(),"Operational outpost and carried product persist together")
	var bad: Dictionary = before.duplicate(true)
	bad.colonies.outposts.s1p0.stock.water = 99
	check(game.restore_snapshot(bad) != OK and game.snapshot() == before,"Invalid warehouse cannot half-load the campaign")
	bad = before.duplicate(true); bad.colonies.kit_source = "s0p0"
	check(game.restore_snapshot(bad) != OK and game.snapshot() == before,"Overfilled kit-plus-cargo save is rejected")
	var old: Dictionary = Session.new().snapshot(); old.version = 4; old.erase("colonies")
	check(loaded.restore_snapshot(old) == OK and loaded.colonies.reserved_space() == 0,"Older campaigns receive no free kits or outposts")
	var market: RefCounted = loaded.commerce
	market.state.markets.s1p0 = market.initial_market("s1p0")
	market.state.markets.s1p0.water.stock = 0; market.state.markets.s1p0.water.demand = 0
	advance(loaded,119)
	check(market.market("s1p0").water.stock == 0,"Market replenishment waits for real simulation time")
	advance(loaded,1)
	check(market.market("s1p0").water.stock == 1 and market.market("s1p0").water.demand == 1,"Local production and consumption restore bounded stock and demand")
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = game
	root.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false)
	scene.save_path = "res://artifacts/colony_scene.json"
	scene._change_flight_mode("surface")
	scene._update_outpost_visual()
	check(scene.outpost_visual != null and Vector2(scene.outpost_visual.position.x,scene.outpost_visual.position.z) == site,"Actual scene renders the saved colony at the selected site")
	scene._show_popup("colonies")
	await process_frame
	check(scene.popup_body.get_combined_minimum_size().x < 535,"Colony administration fits the supported panel width")
	scene.free()
	var placing := Session.new()
	check(placing.restore_snapshot(placement_snapshot) == OK,"Prepare a real carried-kit scene")
	scene = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = placing
	root.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false)
	scene.audio.muted = true
	scene.save_path = "res://artifacts/colony_placement.json"
	scene.distance = 65
	scene._update_camera(1)
	scene._select_colony_kit()
	scene._refresh_ui(); scene._update_visuals()
	check(scene.kit_mode and scene.use_button.text == "Cancel" and not scene.ring.visible,"Placement replaces old tool guidance and selection ring")
	var ground := Vector3(site.x,scene.terrain_height(site.x,site.y),site.y)
	var screen: Vector2 = scene.camera.unproject_position(ground)
	scene._pick(screen)
	check(scene.deploy_order and scene.navigating and placing.colonies.reserved_space() == 4,"Ground click orders physical approach without spending kit")
	scene._hud_action("use")
	check(not scene.deploy_order and not scene.navigating and placing.colonies.reserved_space() == 4 and placing.colonies.state.outposts.is_empty(),"Contextual Cancel keeps cargo and prevents construction")
	scene._select_colony_kit(); scene._pick(screen)
	for i: int in range(600):
		scene._physics_process(1.0/60.0)
		if not scene.navigating: break
	check(not scene.navigating and scene.deploy_order,"Ship reaches the chosen ground footprint through normal flight physics")
	scene._process(0.01)
	check(placing.colonies.reserved_space() == 0 and placing.sector.state.settlements.has("s1p0") and not scene.deploy_order,"Arrival unloads exactly once through the actual scene process")
	scene.free()
	print("Expedition colony assertions: %d; failures: %d" % [checks,failures])
	quit(1 if failures else 0)
