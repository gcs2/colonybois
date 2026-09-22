extends SceneTree
const Sim = preload("res://scripts/simulation.gd")
var assertions: int = 0
var failures: int = 0

func check(condition: bool, description: String) -> void:
	assertions += 1
	if not condition:
		failures += 1
		printerr("FAIL: " + description)

func fresh() -> RefCounted:
	var sim = Sim.new()
	sim.new_game(2409,"urban")
	return sim

func ticks(sim: RefCounted, count: int) -> void:
	for i: int in range(count): sim.tick()

func _initialize() -> void:
	var a = fresh()
	var colony: Dictionary = a.state.colonies.s0p0
	check(Sim.Urban.population(a) == 120000,"City population is derived from editable and background districts")
	check(colony.population > 5000 and colony.cells.size() < 250,"Developed district uses bounded aggregate lots")
	check(Sim.Urban.isolated_population(a) > 2000,"Damaged link cuts off real occupied housing")
	check(colony.reasons["35,27"] == "No road connection","Isolated urban zones explain the access problem")
	check(a.save_path() == "user://urban_save.fw" and a.save_path(true) == "user://urban_autosave.fw","Urban saves do not replace frontier or sandbox saves")
	check(not a.command("cheat",{"ability":"credits"}).is_empty(),"Civic scenario does not silently enable cheats")
	check(not a.command("build",{"planet":"s0p0","x":15,"z":25,"type":"road"}).is_empty(),"Background districts are outside local construction authority")
	check(not a.command("build",{"planet":"s0p0","x":32,"z":32,"type":"road"}).is_empty(),"Damaged crossing requires a repair agreement")
	var before: String = JSON.stringify(a.state)
	check(not a.command("civic",{"choice":"mutual_aid"}).is_empty(),"Abilities unavailable before an agreement and repair")
	check(JSON.stringify(a.state) == before,"Rejected civic action changes no state")
	check(a.command("civic",{"choice":"public"}).is_empty(),"Public repair accepted")
	check(colony.materials == 200,"Public work charges exactly 60 materials")
	before = JSON.stringify(a.state)
	check(not a.command("civic",{"choice":"sponsor"}).is_empty(),"An agreement cannot be overwritten or repeatedly rewarded")
	check(JSON.stringify(a.state) == before,"Rejected second agreement does not charge")
	ticks(a,4)
	check(not a.state.urban.repaired,"Public works takes more time than sponsored repair")
	check(a.save_game("user://test_urban.fw") == OK,"Mid-project civic state saved")
	var restored = Sim.new()
	check(restored.load_game("user://test_urban.fw") == OK,"Mid-project civic state restored")
	ticks(a,4)
	ticks(restored,4)
	check(JSON.stringify(a.state) == JSON.stringify(restored.state),"Mid-project load preserves exact continuation and population scale")
	check(a.state.urban.repaired and Sim.Urban.isolated_population(a) == 0,"Completion repairs the actual road graph")
	check(a.state.colonies.s0p0.connected.has("35,27"),"Eastern homes reconnect to the hub")
	var supplies: float = colony.supplies
	var materials: float = colony.materials
	check(a.command("civic",{"choice":"mutual_aid"}).is_empty(),"Public agreement grants usable mutual aid")
	check(colony.supplies == supplies-30 and colony.materials == materials+20,"Mutual aid consumes actual stock")
	check(not a.command("civic",{"choice":"mutual_aid"}).is_empty(),"Crew cooldown prevents repeated instant grants")
	ticks(a,12)
	colony.supplies = 89
	check(not a.command("civic",{"choice":"mutual_aid"}).is_empty(),"Public commitment protects the supply reserve")
	check(not a.command("civic",{"choice":"priority","tile":"29,29"}).is_empty(),"Public agreement cannot use sponsored ability")
	var b = fresh()
	check(b.command("civic",{"choice":"sponsor"}).is_empty(),"Sponsored repair accepted")
	ticks(b,1)
	check(not b.state.urban.repaired,"Sponsored work is not instantaneous")
	ticks(b,1)
	check(b.state.urban.repaired and b.state.urban.fees_paid == 1,"Fast repair starts persistent concession payments")
	check(b.state.colonies.s0p0.reasons["29,29"] == "Ready to grow","Priority construction has a useful eligible initial target")
	var level: int = b.state.colonies.s0p0.cells["29,29"].level
	check(b.command("civic",{"choice":"priority","tile":"29,29"}).is_empty(),"Sponsored ability upgrades inspected eligible zone")
	check(b.state.colonies.s0p0.cells["29,29"].level == level+1,"Priority works changes a real building immediately")
	check(not b.command("civic",{"choice":"mutual_aid"}).is_empty(),"Sponsor cannot use mutual aid")
	ticks(b,4)
	before = JSON.stringify(b.state)
	check(not b.command("civic",{"choice":"priority","tile":"0,0"}).is_empty(),"Invalid priority target rejected")
	check(JSON.stringify(b.state) == before,"Invalid target charges nothing")
	check(b.state.urban.fees_paid == 5,"Concession persists after the initial repair")
	b.state.credits = 0
	Sim.Urban.tick(b)
	check(b.state.urban.fee_due == 1,"Unpaid fees remain obligations rather than vanishing")
	check(not b.command("civic",{"choice":"priority","tile":"29,35"}).is_empty(),"Unpaid concession suspends priority works")
	b.state.credits = 10
	Sim.Urban.tick(b)
	check(b.state.urban.fee_due == 0 and b.state.credits == 8,"Treasury clears arrears and current fee")
	var legacy = Sim.new()
	legacy.new_game()
	legacy.state.version = 1
	check(legacy.save_game("user://test_legacy_urban.fw") == OK,"Legacy-format snapshot fixture saved")
	check(restored.load_game("user://test_legacy_urban.fw") == OK and restored.state.version == Sim.SAVE_VERSION,"Version-one expeditions migrate to the new schema")
	check(not restored.state.has("urban") and restored.state.colonies.s0p0.population == 36,"Legacy migration preserves ordinary colonies")
	var c = fresh()
	var d = fresh()
	c.command("civic",{"choice":"public"})
	d.command("civic",{"choice":"public"})
	var started: int = Time.get_ticks_usec()
	ticks(c,120)
	var elapsed: float = float(Time.get_ticks_usec()-started)/1000.0
	ticks(d,120)
	check(JSON.stringify(c.state) == JSON.stringify(d.state),"Urban economy is reproducible over a longer session")
	check(c.state.colonies.s0p0.supplies > 0,"Restored district remains supplied over the first 120 days")
	print("URBAN PROFILE: %d cells / %d city residents: %.3f ms/tick" % [colony.cells.size(),Sim.Urban.population(c),elapsed/120])
	print("URBAN RESULT: %d assertions, %d failures" % [assertions,failures])
	quit(1 if failures else 0)
