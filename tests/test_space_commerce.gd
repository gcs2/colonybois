extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, explanation: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+explanation)
func _initialize() -> void: call_deferred("run")
func journey(game: RefCounted, planet: String) -> void:
	game.field.change_flight_mode("orbit")
	check(game.begin_travel(planet).is_empty(),"Journey launches with earned resources: "+planet)
	for i: int in range(60):
		if not game.traveling(): break
		game.tick()
func run() -> void:
	var game := Session.new()
	var c: RefCounted = game.commerce
	var surface: Vector3 = Field.service_position("basin_port")
	var orbit: Vector3 = Field.service_position("orbit_tender")
	var before: Dictionary = game.snapshot()
	check(not c.transact(game,"basin_port",surface,"water",1,true).is_empty() and game.snapshot() == before,"Cannot buy with zero Marks; failure is atomic")
	check(c.market("morrow") == c.market("morrow") and game.snapshot() == before,"Reading quotes creates no state or stock")
	check(not c.export_alloy(game,"basin_port",Vector3(70,5,0),8).is_empty() and game.snapshot() == before,"Must physically approach a dock")
	check(not c.export_alloy(game,"orbit_tender",orbit,8).is_empty(),"Surface ship cannot remotely use orbital services")
	check(c.export_alloy(game,"basin_port",surface,8).is_empty(),"Bulk colony export works without a farming mission")
	check(c.quantity() == 8 and game.sector.state.colonies.s0p0.materials == before.sector.colonies.s0p0.materials-32 and game.field.marks == 0,"Export consumes actual construction stock, not imaginary money")
	check(c.state.cargo[0].origin == "morrow","Cargo records its source planet")
	before = game.snapshot()
	check(not c.export_alloy(game,"basin_port",surface).is_empty() and game.snapshot() == before,"Full hold prevents stock loss")
	check(not c.transact(game,"basin_port",surface,"alloy",-1,false).is_empty() and game.snapshot() == before,"Negative quantities cannot manufacture money")
	journey(game,"s2p0")
	check(c.quantity() == 8 and c.state.badges.explorer == 1,"Cargo travels and first new system earns exploration tier")
	check(c.eligible("drive") and "drive" not in c.state.upgrades,"Badge unlocks eligibility without gifting the upgrade")
	check(not c.buy_upgrade(game,"orbit_tender",orbit,"drive").is_empty(),"Eligible but broke cannot buy an upgrade")
	var balance: float = game.field.marks
	check(c.transact(game,"orbit_tender",orbit,"alloy",8,false).is_empty(),"Remote market buys real ship cargo")
	check(c.quantity() == 0 and game.field.marks == balance+192 and c.market("s2p0").alloy.demand == 8,"Sale consumes cargo and demand and pays quoted Marks")
	check(c.state.badges.merchant == 1 and c.state.flows.size() == 1,"One distinct delivery awards Merchant once")
	check(c.buy_upgrade(game,"orbit_tender",orbit,"hold").is_empty() and c.capacity() == 16,"Earned and purchased hold actually expands capacity")
	before = game.snapshot()
	check(not c.buy_upgrade(game,"orbit_tender",orbit,"hold").is_empty() and game.snapshot() == before,"Owned upgrades cannot be charged twice")
	check(c.transact(game,"orbit_tender",orbit,"glass",3,true).is_empty(),"Profits buy the local export commodity")
	check(c.state.cargo[0].origin == "s2p0" and c.market("s2p0").glass.stock == 9,"Purchased stock and new provenance are real")
	var path: String = "res://artifacts/commerce.fw"
	check(game.save_to(path) == OK,"Commerce campaign saves")
	var loaded := Session.new()
	check(loaded.load_from(path) == OK and loaded.snapshot() == game.snapshot(),"Cargo, finite markets, badges and paid upgrades round-trip")
	journey(game,"s1p0")
	check(c.transact(game,"orbit_tender",orbit,"glass",3,false).is_empty(),"Arid exports sell to a cold-world market")
	check(c.transact(game,"orbit_tender",orbit,"water",8,true).is_empty(),"Frozen water gives the return voyage useful cargo")
	journey(game,"s2p0")
	check(c.transact(game,"orbit_tender",orbit,"water",8,false).is_empty(),"Dry world's water demand funds further expansion")
	check(c.buy_upgrade(game,"orbit_tender",orbit,"drive").is_empty() and c.drive_range() == 5,"Peaceful multi-market loop funds an earned drive upgrade")
	journey(game,"s1p0")
	check(game.field.state.energy < 100 and not game.field.state.warm and not game.field.state.seeded,"Loop uses finite energy and requires no planting")
	for system: Dictionary in game.sector.state.systems: system.visited = true
	c.state.upgrades.erase("drive")
	check(not game.quote("s11p0").reason.is_empty(),"Base drive rejects the known four-link journey")
	c.state.upgrades.append("drive")
	check(game.quote("s11p0").reason.is_empty() and game.quote("s11p0").energy == 32,"Purchased drive opens the longer route without discounting energy")
	c.update_badges(game)
	var history_size: int = game.field.state.history.size()
	c.update_badges(game); c.update_badges(game)
	check(history_size == game.field.state.history.size(),"Repeated updates do not duplicate awards")
	game.sector.state.credits = 1000
	var old_balance: float = game.field.marks
	c.transact(game,"orbit_tender",orbit,"water",1,true)
	c.transact(game,"orbit_tender",orbit,"water",1,false)
	check(game.field.marks < old_balance and c.state.flows.size() == 3,"Local round trips lose money and cannot farm delivery badges")
	var owner: Dictionary = game.sector.system_by_id("s1")
	owner.owner = "consortium"
	game.sector.state.planets.s1p0.owner = "consortium"
	game.sector.faction_by_id("consortium")["embargo"] = true
	before = game.snapshot()
	check(not c.transact(game,"orbit_tender",orbit,"water",1,true).is_empty() and game.snapshot() == before,"Embargo rejects trade atomically")
	game.sector.faction_by_id("consortium").embargo = false
	var stock: int = c.market("s1p0").water.stock
	check(c.transact(game,"orbit_tender",orbit,"water",stock,true).is_empty(),"Can purchase all available stock in expanded hold")
	check(not c.transact(game,"orbit_tender",orbit,"water",1,true).is_empty(),"Exhausted stock stays exhausted")
	game.field.change_flight_mode("surface")
	check(not c.transact(game,"basin_port",surface,"water",1,true).is_empty(),"Changing docks does not reset planetary stock")
	game.field.change_flight_mode("orbit")
	var demand: int = c.market("s1p0").water.demand
	# Load water from a separate producer to exercise exhausted demand after local stock runs out.
	c.add_cargo("water",8,"s4p0")
	check(c.transact(game,"orbit_tender",orbit,"water",demand,false).is_empty(),"Demand accepts only its remaining amount")
	before = game.snapshot()
	check(not c.transact(game,"orbit_tender",orbit,"water",1,false).is_empty() and game.snapshot() == before,"Exhausted demand leaves remaining cargo untouched")
	var invalid: Dictionary = before.duplicate(true)
	invalid.commerce.cargo[0].quantity = -1
	check(game.restore_snapshot(invalid) != OK and game.snapshot() == before,"Corrupt cargo cannot partially replace a campaign")
	invalid = before.duplicate(true)
	invalid.commerce.markets.s1p0.water.stock = 9000
	check(game.restore_snapshot(invalid) != OK and game.snapshot() == before,"Corrupt market inflation is rejected")
	var old: Dictionary = Session.new().snapshot()
	old.version = 2; old.erase("commerce")
	check(loaded.restore_snapshot(old) == OK and loaded.commerce.quantity() == 0 and loaded.commerce.state.upgrades.is_empty(),"Version two migration grants no cargo or upgrades")
	var reserve := Session.new()
	reserve.sector.state.colonies.s0p0.materials = 83
	check(not reserve.commerce.export_alloy(reserve,"basin_port",surface).is_empty(),"Home exports preserve the building reserve")
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = Session.new()
	root.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false)
	scene.save_path = "res://artifacts/commerce_ui.json"
	scene.selected_service = "basin_port"
	scene.trade_amount = 4
	scene._show_popup("service")
	await process_frame
	var buttons: Array = scene.popup_body.find_children("*","Button",true,false)
	var export_found: bool = false
	for button: Button in buttons:
		if button.text.begins_with("Load 4 alloy"):
			export_found = true; button.pressed.emit(); break
	check(export_found and scene.campaign.commerce.quantity() == 4,"Actual dock button loads selected bulk quantity")
	scene._refresh_ui()
	check("Cargo 4/8" in scene.stats.text and "Specimens 0/12" in scene.stats.text,"HUD distinguishes freight capacity from the expedition specimen hold")
	scene._show_popup("cargo"); await process_frame
	check(scene.popup_body.get_combined_minimum_size().x < 555,"Inventory remains within its supported panel width")
	scene._show_popup("badges"); await process_frame
	check(scene.popup_body.find_children("*","ProgressBar",true,false).size() == scene.campaign.commerce.catalog.badges.size()+1,"Badge case presents every implemented family plus master-rank progress")
	scene.dock_page = "upgrades"; scene._show_popup("service"); await process_frame
	check(scene.popup_body.get_combined_minimum_size().x < 555,"Shop requirements wrap within the panel")
	scene.free()
	print("Space commerce assertions: %d; failures: %d" % [checks,failures])
	quit(1 if failures else 0)
