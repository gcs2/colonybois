extends SceneTree
const Sim = preload("res://scripts/simulation.gd")
var failures: int = 0
var assertions: int = 0
func check(value: bool, label: String) -> void:
	assertions += 1
	if not value: failures += 1; printerr("FAIL: "+label)
func fresh() -> RefCounted:
	var sim = Sim.new()
	sim.new_game(2409)
	var colony: Dictionary = sim.state.colonies.s0p0
	colony.cells = {"30,30":{"type":"spaceport","level":1},"30,31":{"type":"road","level":1},"29,31":{"type":"road","level":1},"28,31":{"type":"road","level":1},"28,30":{"type":"power","level":1}}
	colony.materials = 500
	colony.supplies = 500
	sim.refresh_colony("s0p0")
	return sim
func _initialize() -> void:
	var sim = fresh()
	var colony: Dictionary = sim.state.colonies.s0p0
	var before: float = colony.materials
	check(sim.command("zone_rect",{"planet":"s0p0","type":"habitat","x0":28,"x1":30,"z0":32,"z1":33}).is_empty(),"Rectangle designation succeeds")
	check(colony.materials == before and colony.cells.size() == 11,"Six reserved tiles cost nothing")
	sim.state.tick = 6
	Sim.City.grow(sim,"s0p0")
	check(colony.cells["28,32"].get("width",1) == 3 and colony.cells["28,32"].get("depth",1) == 2,"Development assembles a six-tile lot")
	check(colony.materials == before-36,"Materials consumed only at actual development")
	check(colony.population == 72,"Population counts full lot area")
	check(colony.occupied["30,33"] == "28,32","Footprint maps every tile to its building")
	check(not sim.command("build",{"planet":"s0p0","type":"power","x":30,"z":33}).is_empty(),"Cannot build through another lot")
	colony.cells.erase("28,31")
	colony.cells.erase("29,31")
	sim.refresh_colony("s0p0")
	check(colony.connected.has("28,32"),"Road at far edge serves entire footprint")
	colony.cells.erase("30,31")
	sim.refresh_colony("s0p0")
	check(not colony.connected.has("28,32"),"Removing final frontage disconnects entire lot")
	colony.cells["30,31"] = {"type":"road","level":1}
	colony.cells["31,31"] = {"type":"road","level":1}
	colony.cells["31,30"] = {"type":"power","level":1}
	colony.cells["31,32"] = {"type":"fire","level":1}
	colony.cells["32,31"] = {"type":"police","level":1}
	colony.cells["30,29"] = {"type":"transit","level":1}
	sim.refresh_colony("s0p0")
	check(Sim.City.coverage(colony,"transit",Vector2(30,30)) == 0,"One stop does not create a network")
	colony.cells["29,30"] = {"type":"transit","level":1}
	sim.refresh_colony("s0p0")
	check(Sim.City.coverage(colony,"transit",Vector2(30,30)) > 0.5,"Two powered connected stops provide transit")
	var protected_fire: float = colony.fire_risk
	var protected_crime: float = colony.crime
	colony.cells.erase("31,32")
	colony.cells.erase("32,31")
	sim.refresh_colony("s0p0")
	check(colony.fire_risk > protected_fire and colony.crime > protected_crime,"Service removal raises local risks")
	colony.cells["31,32"] = {"type":"service","level":2,"damaged_until":50}
	sim.refresh_colony("s0p0")
	sim.tick()
	var damaged_output: float = colony.supply_rate
	check(sim.command("city_policy",{"planet":"s0p0","action":"repair","tile":"31,32"}).is_empty(),"Emergency repair consumes resources and restores building")
	sim.tick()
	check(colony.supply_rate > damaged_output,"Fire damage stops output until repaired")
	var ledger: Dictionary = sim.state.ledger
	check(is_equal_approx(ledger.closing-ledger.opening,ledger.tax+ledger.exports-ledger.crime_loss-ledger.upkeep-ledger.sponsor+ledger.adjustment),"Ledger income and expenses reconcile to treasury movement")
	check(sim.command("city_policy",{"planet":"s0p0","action":"tax","rate":1.25}).is_empty(),"Tax policy validated")
	check(sim.save_game("user://test_city.fw") == OK,"City save written")
	var restored = Sim.new()
	check(restored.load_game("user://test_city.fw") == OK,"City save loads")
	check(restored.state.colonies.s0p0.occupied == colony.occupied and restored.state.ledger == sim.state.ledger,"Lots, tax policy and ledger persist")
	var refund: float = colony.materials
	check(sim.command("build",{"planet":"s0p0","type":"bulldoze","x":30,"z":33}).is_empty(),"Bulldozing part of a footprint removes its whole lot")
	check(not colony.cells.has("28,32") and colony.materials < refund+36,"Demolition cannot refund more than development cost")
	var a = fresh()
	var b = fresh()
	for game: RefCounted in [a,b]:
		game.state.colonies.s0p0.cells["29,30"] = {"type":"industry","level":2}
		for day: int in range(300): game.tick()
	check(JSON.stringify(a.state) == JSON.stringify(b.state),"Risk events and economy reproduce from the same seed")
	print("CITY RESULT: %d assertions, %d failures" % [assertions,failures])
	quit(1 if failures else 0)
