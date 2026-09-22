extends SceneTree
const Sim = preload("res://scripts/simulation.gd")
var failures: int = 0
var assertions: int = 0

func check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures += 1
		printerr("FAIL: "+message)

func _initialize() -> void:
	var sim = Sim.new()
	sim.new_game()
	sim.state.flagship.system = "s1"
	var treasury: float = sim.state.credits
	var depot: Dictionary = sim.state.colonies.s0p0
	var materials: float = depot.materials
	var supplies: float = depot.supplies
	check(sim.command("colonize",{"planet":"s1p0"}).is_empty(),"Sufficient funds and cargo authorize landing")
	check(sim.state.credits == treasury-300 and depot.materials == materials-100 and depot.supplies == supplies-80,"All landing costs are debited once from real stocks")
	check(sim.state.settlements.s1p0.remaining == 18 and not sim.state.colonies.has("s1p0"),"Landing is a timed project with no instant buildings")
	var snapshot: String = JSON.stringify(sim.state)
	check(not sim.command("colonize",{"planet":"s1p0"}).is_empty(),"Duplicate landing rejected")
	check(snapshot == JSON.stringify(sim.state),"Rejected duplicate changes no stocks")
	for i: int in range(7): sim.tick()
	check(Sim.Settlement.phase(sim.state.settlements.s1p0) == "Assembling the landing hub","Landing reports its construction phase")
	check(sim.save_game("user://test_landing.fw") == OK,"In-progress landing saved")
	var loaded = Sim.new()
	check(loaded.load_game("user://test_landing.fw") == OK,"In-progress landing loaded")
	for i: int in range(10):
		sim.tick()
		loaded.tick()
	check(not sim.state.colonies.has("s1p0"),"Hub unavailable until the final day")
	sim.tick()
	loaded.tick()
	check(JSON.stringify(sim.state) == JSON.stringify(loaded.state),"Landing continuation is deterministic after loading")
	var colony: Dictionary = sim.state.colonies.s1p0
	check(colony.cells.size() == 1 and colony.cells["30,30"].type == "spaceport" and colony.population == 0,"Completion yields only a hub, no fabricated occupied town")
	check(colony.materials == 70 and colony.supplies == 60,"Pad construction consumes part of the committed cargo")
	sim.state.flagship.system = "s2"
	depot.materials = 99
	snapshot = JSON.stringify(sim.state)
	check(not sim.command("colonize",{"planet":"s2p0"}).is_empty(),"Insufficient cargo rejects founding")
	check(snapshot == JSON.stringify(sim.state),"Cargo failure does not take money")
	# A capital as source makes its embargo cut every outgoing cargo route.
	sim.state.flagship.system = "s7"
	sim._create_colony("s7p0")
	sim.state.flagship.system = "s2"
	sim.state.credits = 1000
	sim.state.colonies.s7p0.materials = 200
	sim.state.colonies.s7p0.supplies = 200
	sim.state.colonies.erase("s1p0")
	check(sim.command("colonize",{"planet":"s2p0","source":"s7p0"}).is_empty(),"An established depot can supply a landing")
	# Block the destination capital in a separate valid project fixture.
	sim.state.systems[2].owner = "consortium"
	sim.faction_by_id("consortium").embargo = true
	var remaining: int = sim.state.settlements.s2p0.remaining
	sim.tick()
	check(sim.state.settlements.s2p0.remaining == remaining and sim.state.settlements.s2p0.blocked,"Lost route access pauses construction")
	var legacy = Sim.new()
	legacy.new_game(2409,"urban")
	legacy.state.version = 2
	legacy.state.erase("settlements")
	legacy.state.urban.erase("tutorial_step")
	check(legacy.save_game("user://test_landing_legacy.fw") == OK,"Prior urban save fixture written")
	check(loaded.load_game("user://test_landing_legacy.fw") == OK,"Version-two urban save remains loadable")
	check(loaded.state.settlements.is_empty() and loaded.state.urban.tutorial_step == 0 and Sim.Urban.population(loaded) == 120000,"Migration preserves population and initializes missing project/tutorial fields")
	print("LANDING RESULT: %d assertions, %d failures" % [assertions,failures])
	quit(1 if failures else 0)
