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
	game.sector.system_by_id("s2").visited = true
	game.colonies.state.outposts.s1p0.stock.water = 12
	game.sector_clock = 0
	return game
func run() -> void:
	var game: RefCounted = fixture()
	var freight: RefCounted = game.freight
	var quote: Dictionary = freight.quote(game,"s1p0","s2p0","water",4)
	var before: Dictionary = game.snapshot()
	check(quote.reason.is_empty() and quote.days >= 2 and quote.fee > 0 and quote.net == quote.gross-quote.fee,"Contract quotes actual travel time and transport margin")
	check(game.snapshot() == before,"Quoting routes creates no goods, markets or contracts")
	for invalid: Array in [["morrow","s2p0","water",4],["s1p0","s1p0","water",4],["s1p0","s11p0","water",4],["s1p0","s2p0","unknown",4],["s1p0","s2p0","water",3]]:
		check(not freight.configure(game,invalid[0],invalid[1],invalid[2],invalid[3]).is_empty() and game.snapshot() == before,"Invalid source/destination/commodity/reserve cannot mutate state: "+str(invalid))
	game.field.marks = 0; before = game.snapshot()
	check(not freight.configure(game,"s1p0","s2p0","water",4).is_empty() and game.snapshot() == before,"Unaffordable charter changes nothing")
	game.field.marks = 600
	check(freight.configure(game,"s1p0","s2p0","water",4).is_empty() and game.field.marks == 520,"Charter costs exactly 80 Marks")
	check(game.colonies.state.outposts.s1p0.stock.water == 12 and freight.state.routes.s1p0.cargo == 0,"Signing does not fabricate or instantly sell cargo")
	var idle := Session.new(); idle.restore_snapshot(game.snapshot()); idle.freight.state.routes.clear()
	advance(game,30); advance(idle,30)
	var route: Dictionary = freight.state.routes.s1p0
	check(route.cargo == 4 and game.colonies.state.outposts.s1p0.stock.water == 8 and route.phase == "outbound","Dispatch moves four actual warehouse units into a carrier")
	check(is_equal_approx(idle.field.marks-game.field.marks,quote.fee) and route.fees == quote.fee,"Dispatch prepays round-trip transport apart from ordinary colony costs")
	check(game.commerce.quantity() == 0 and game.field.state.planet_id == "s1p0","Freight does not use or teleport the personal flagship")
	before = game.snapshot()
	check(not freight.configure(game,"s1p0","morrow","glass",0).is_empty() and game.snapshot() == before,"Cannot rewrite an in-flight consignment")
	check(freight.pause(game,"s1p0").is_empty() and route.paused,"Pause stops future departures without deleting carrier")
	var path: String = "res://artifacts/freight_midvoyage.fw"
	check(game.save_to(path) == OK,"Save carrier in transit")
	var loaded := Session.new()
	check(loaded.load_from(path) == OK and loaded.snapshot() == game.snapshot(),"Load restores cargo, booked itinerary, remaining time and contract")
	advance(game,quote.days*30); advance(loaded,quote.days*30)
	check(game.snapshot() == loaded.snapshot(),"Identical continued simulations preserve delivery outcome")
	check(route.phase == "returning" and route.cargo == 0 and route.delivered == 4 and route.receipts == quote.gross,"Delivery earns money only after reaching buyer")
	check(game.commerce.market("s2p0").water.demand == 12 and "s1p0>s2p0:water" in game.commerce.state.flows,"Sale consumes actual demand and records one distinct Merchant flow")
	check(game.sector.state.ledger.exports >= quote.gross,"Delivery appears in economy ledger")
	advance(game,quote.days*30)
	check(route.phase == "waiting" and route.cargo == 0 and route.trips == 1 and route.paused,"Carrier returns and honors paused departures")
	var treasury: float = game.field.marks
	check(freight.configure(game,"s1p0","s2p0","water",4).is_empty() and game.field.marks == treasury,"Existing idle carrier can be retasked without another charter")
	route = freight.state.routes.s1p0
	game.colonies.state.outposts.s1p0.stock.water = 7
	freight.tick(game)
	check(route.phase == "waiting" and game.colonies.state.outposts.s1p0.stock.water == 7,"Warehouse reserve blocks undersized surplus")
	game.colonies.state.outposts.s1p0.stock.water = 8
	game.commerce.state.markets.s2p0.water.demand = 3; freight.tick(game)
	check(route.phase == "waiting" and route.status.contains("demand"),"Known weak demand prevents pointless dispatch")
	game.commerce.state.markets.s2p0.water.demand = 16
	game.field.marks = 0; freight.tick(game)
	check(route.cargo == 0 and route.status.contains("Marks"),"Insufficient transport money preserves warehouse goods")
	game.field.marks = 500; freight.tick(game)
	game.commerce.state.markets.s2p0.water.demand = 1
	freight.pause(game,"s1p0")
	for i: int in range(quote.days): freight.tick(game)
	check(route.cargo == 3 and route.phase == "returning" and route.delivered == 5,"Changed demand permits partial sale and retains all unsold goods")
	check(game.commerce.market("s2p0").water.demand == 0 and game.commerce.state.flows.size() == 1,"Repeated route does not duplicate Merchant progress or oversell demand")
	game.colonies.state.outposts.s1p0.stock = {"water":0,"alloy":0,"glass":16}
	for i: int in range(quote.days): freight.tick(game)
	check(route.phase == "waiting" and route.cargo == 3 and route.status.contains("warehouse full"),"Full home warehouse keeps returned cargo aboard instead of deleting it")
	game.colonies.state.outposts.s1p0.stock.glass = 12; freight.tick(game)
	check(route.cargo == 0 and game.colonies.state.outposts.s1p0.stock.water == 3,"Returned goods unload when actual storage space opens")
	# Foreign sale access is separate from transit access, as in personal trade.
	for system: Dictionary in game.sector.state.systems: system.visited = true
	check(not freight.quote(game,"s1p0","s7p0","water",0).reason.is_empty(),"Foreign automatic sales require an actual trade agreement")
	game.diplomacy.contact(game,"consortium")
	game.diplomacy.act(game,"consortium","trade")
	check(freight.configure(game,"s1p0","s7p0","water",0).is_empty(),"Trade agreement enables a foreign carrier contract")
	route = freight.state.routes.s1p0
	game.colonies.state.outposts.s1p0.stock = {"water":8,"alloy":0,"glass":0}
	freight.tick(game)
	var foreign: Dictionary = game.sector.faction_by_id("consortium")
	foreign.embargo = true
	var remaining: int = route.remaining; var carried: int = route.cargo
	freight.tick(game)
	check(route.remaining == remaining and route.cargo == carried and route.status.begins_with("Blocked"),"Closed booked border holds carrier and preserves consignment")
	var event_count: int = game.diplomacy.state.events.size()
	freight.tick(game)
	check(game.diplomacy.state.events.size() == event_count,"Unchanged blockage does not flood the chronicle")
	game.sector.state.agreements.append("consortium:non_aggression")
	for i: int in range(remaining): freight.tick(game)
	check(route.phase == "returning" and route.cargo == carried and route.delivered == 5,"Transit pledge permits passage but cannot sell through an embargo")
	for i: int in range(route.duration): freight.tick(game)
	foreign.embargo = false
	freight.tick(game)
	check(route.phase == "outbound","Reopened diplomacy automatically resumes the contracted route")
	var fees: int = route.fees
	var outbound_elapsed: int = route.duration-route.remaining
	check(freight.recall(game,"s1p0").is_empty() and route.paused and route.phase == "returning" and route.cargo == 4,"Recall retains cargo and pauses new departures")
	check(route.remaining == outbound_elapsed,"Recall reverses actual progress without teleporting to destination")
	for i: int in range(route.duration): freight.tick(game)
	check(route.phase == "waiting" and route.cargo == 0 and route.fees == fees,"Prepaid return has no duplicate charge")
	freight.pause(game,"s1p0"); freight.tick(game)
	var receipts_before: int = route.receipts
	var expected_receipt: int = 4*game.commerce.price("s7p0","water",false,game)
	for i: int in range(route.duration): freight.tick(game)
	check(route.receipts-receipts_before == expected_receipt,"Foreign delivery uses the actual treaty-modified arrival price")
	check(game.diplomacy.state.events.back().cause == game.diplomacy.state.keys["pact:consortium:trade"],"Freight history links the actual pricing agreement")
	freight.pause(game,"s1p0")
	for i: int in range(route.duration): freight.tick(game)
	check(game.save_to(path) == OK and loaded.load_from(path) == OK and loaded.snapshot() == game.snapshot(),"Paused contract, receipts and returned warehouse survive load")
	before = game.snapshot()
	var bad: Dictionary = before.duplicate(true); bad.freight.routes.s1p0.cargo = 5
	check(game.restore_snapshot(bad) != OK and game.snapshot() == before,"Overcapacity freight save cannot partially load")
	bad = before.duplicate(true); bad.freight.routes.s1p0.destination = "s11p9"
	check(game.restore_snapshot(bad) != OK and game.snapshot() == before,"Nonexistent destination cannot load")
	bad = before.duplicate(true)
	bad.freight.routes.s1p0.merge({"phase":"outbound","destination":"s7p0","path":["s1","s7"],"duration":2,"remaining":2,"cargo":4},true)
	check(game.restore_snapshot(bad) != OK and game.snapshot() == before,"Save cannot invent an unconnected transit edge")
	var old: Dictionary = before.duplicate(true); old.version = 5; old.erase("freight")
	check(loaded.restore_snapshot(old) == OK and loaded.freight.state.routes.is_empty(),"V5 migration creates no free carriers")
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = game; root.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	scene.save_path = "res://artifacts/freight_ui.json"
	scene._show_popup("freight")
	await process_frame
	check(scene.popup_body.get_combined_minimum_size().x < 535,"Freight controls fit supported drawer width")
	var panel: Node = scene.popup_body.get_children().back()
	panel.destination = "morrow"; panel.commodity = "water"; panel.reserve = 4; panel.refresh_quote()
	check(not panel.confirm.disabled,"Reachable UI quotes an idle carrier change")
	panel.confirm.pressed.emit()
	check(game.freight.state.routes.s1p0.destination == "morrow" and not game.freight.state.routes.s1p0.paused,"Actual UI button commits the contract")
	scene.free()
	print("Expedition freight assertions: %d; failures: %d" % [checks,failures])
	quit(1 if failures else 0)
