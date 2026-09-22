extends SceneTree
const Sim = preload("res://scripts/simulation.gd")
var failures: int = 0
var assertions: int = 0

func check(condition: bool, description: String) -> void:
	assertions += 1
	if not condition:
		failures += 1
		printerr("FAIL: " + description)

func fresh() -> RefCounted:
	var sim = Sim.new()
	sim.new_game(2409)
	return sim

func ticks(sim: RefCounted, count: int) -> void:
	for i: int in range(count): sim.tick()

func build(sim: RefCounted, pid: String, x: int, z: int, type: String) -> String:
	return sim.command("build",{"planet":pid,"x":x,"z":z,"type":type})

func travel(sim: RefCounted, sid: String) -> void:
	var route: Array = sim.route_between(sim.state.flagship.system,sid)
	for i: int in range(1,route.size()):
		check(sim.command("travel",{"system":route[i]}).is_empty(),"Frontier travel accepted: " + route[i])
		while not str(sim.state.flagship.destination).is_empty(): sim.tick()

func _initialize() -> void:
	var a = fresh()
	var b = fresh()
	check(a.state.systems.size() == 12,"Scenario has 12 systems")
	check(a.state.discoveries.size() == 6,"Scenario has six seeded discoveries")
	check(a.is_revealed("s1") and not a.is_revealed("s7"),"Fog reveals only the immediate frontier")
	check(not a.command("travel",{"system":"s7"}).is_empty(),"Unrevealed destinations cannot be targeted")
	check(not a.command("cheat",{"ability":"credits"}).is_empty(),"Expedition rejects sandbox abilities")
	for system: Dictionary in a.state.systems:
		check(not a.route_between("s0",system.id).is_empty(),"Galaxy graph connected: " + system.id)
		check(system.planets.size() >= 1 and system.planets.size() <= 3,"One to three planets per system")
	build(a,"s0p0",33,32,"habitat")
	build(b,"s0p0",33,32,"habitat")
	ticks(a,240)
	ticks(b,240)
	check(JSON.stringify(a.state) == JSON.stringify(b.state),"Same seed and commands yield identical outcomes")
	check(a.state.colonies.s0p0.population > 36,"Starting colony grows without grinding")
	check(a.state.credits > 650,"Starting colony earns a surplus")
	var c = fresh()
	check(build(c,"s0p0",45,45,"habitat").is_empty(),"Disconnected zone can be designated")
	ticks(c,18)
	check(c.state.colonies.s0p0.cells["45,45"].level == 0,"Disconnected zone cannot grow")
	check(c.state.colonies.s0p0.reasons["45,45"] == "No road connection","Disconnected zone explains failure")
	check(not build(c,"s0p0",30,30,"bulldoze").is_empty(),"Spaceport cannot be removed")
	check(not build(c,"s0p0",-1,20,"road").is_empty(),"Out-of-bounds construction rejected")
	check(not build(c,"s0p0",0,20,"road").is_empty(),"Unsuitable terrain rejected")
	var before: float = c.state.colonies.s0p0.materials
	check(not build(c,"s0p0",30,30,"road").is_empty(),"Occupied tile rejected")
	check(c.state.colonies.s0p0.materials == before,"Rejected command doesn't charge resources")
	c.state.colonies.s0p0.materials = 0
	check(not build(c,"s0p0",33,32,"industry").is_empty(),"Insufficient materials rejected")
	c.state.colonies.s0p0.materials = 300
	for x: int in range(26,38):
		if x != 31: build(c,"s0p0",x,32,"extractor")
	check(c.state.colonies.s0p0.power_used > c.state.colonies.s0p0.power,"Utility load creates real power constraint")
	check("Growth limited by power" in c.state.colonies.s0p0.reasons.values(),"Power shortfall blocks growth visibly")
	var d = fresh()
	check(not d.command("colonize",{"planet":"s1p0"}).is_empty(),"Remote colonization rejected")
	travel(d,"s1")
	check(d.command("colonize",{"planet":"s1p0"}).is_empty(),"Visited harsh world can be colonized")
	check(not d.state.colonies.has("s1p0") and d.state.settlements.has("s1p0"),"A paid landing expedition starts before the colony exists")
	ticks(d,18)
	check(d.state.colonies.size() == 2,"Second colony persists")
	var feature: Dictionary = d.features("s1p0")[0]
	check(d.suitability("s1p0",feature.x,feature.z) > d.suitability("s1p0",48,48),"Geothermal location improves frozen suitability")
	var old_frozen_pop: int = d.state.colonies.s1p0.population
	ticks(d,30)
	check(d.state.colonies.s1p0.population >= old_frozen_pop,"Inactive colony continues operating")
	check(d.command("import",{"planet":"s1p0","source":"s0p0"}).is_empty(),"Internal logistics configuration accepted")
	d.state.colonies.s1p0.supplies = 10
	d.state.colonies.s0p0.supplies = 100
	d._tick_trade()
	check(d.state.colonies.s1p0.supplies > 10 and d.state.colonies.s0p0.supplies < 100,"Internal logistics conserve and transfer actual stock")
	travel(d,"s7")
	check(d.faction_by_id("consortium").contacted,"Arrival establishes alien contact")
	check(d.command("diplomacy",{"faction":"consortium","pact":"trade"}).is_empty(),"Trade treaty signed")
	check(d.command("trade",{"planet":"s0p0","faction":"consortium","resource":"materials"}).is_empty(),"Automatic export configured")
	d.state.colonies.s0p0.materials = 60.2
	var credits: float = d.state.credits
	d._tick_trade()
	check(is_equal_approx(d.state.colonies.s0p0.materials,60.0),"Exports preserve local reserve")
	check(d.state.credits > credits,"Export credits reflect delivered stock")
	credits = d.state.credits
	d._tick_trade()
	check(d.state.credits == credits,"No stock means no export income")
	d.state.colonies.s0p0.materials = 100
	d.faction_by_id("consortium")["embargo"] = true
	credits = d.state.credits
	d._tick_trade()
	check(d.state.colonies.s0p0.materials == 100 and d.state.credits == credits,"Embargo stops resource movement and payment")
	check(d.route_between("s0","s7").is_empty(),"Embargo blocks capital access")
	d.faction_by_id("consortium").embargo = false
	var resolved_sid: String = str(d.state.discoveries.keys()[0])
	d.system_by_id(resolved_sid).visited = true
	check(d.command("discover",{"system":resolved_sid,"choice":0}).is_empty(),"Discovery accepts consequential choice")
	check(not d.command("discover",{"system":resolved_sid,"choice":0}).is_empty(),"Discovery rewards cannot be farmed")
	d.state.colonies.s1p0.materials = 400
	d.state.colonies.s1p0.supplies = 150
	d.state.credits = 500
	for x: int in range(30,38): build(d,"s1p0",x,31,"road")
	check(build(d,"s1p0",36,30,"terraformer").is_empty(),"Climate array constructed")
	check(build(d,"s1p0",37,30,"power").is_empty(),"Climate array power supplied")
	var relation: int = d.faction_by_id("commune").relation
	check(d.command("terraform",{"planet":"s1p0"}).is_empty(),"Climate recovery starts")
	check(d.faction_by_id("commune").relation == relation-18,"Terraforming affects ecological diplomacy")
	ticks(d,10)
	check(d.state.planets.s1p0.terraform > 0,"Climate project progresses")
	var progress: float = d.state.planets.s1p0.terraform
	d.state.colonies.s1p0.materials = 0
	d._tick_project("s1p0")
	check(d.state.planets.s1p0.terraform == progress,"Climate project pauses during shortages")
	d.state.colonies.s1p0.materials = 400
	check(d.save_game("user://test_frontier.json") == OK,"Versioned snapshot saved")
	var e = Sim.new()
	check(e.load_game("user://test_frontier.json") == OK,"Versioned snapshot restored")
	# Recalculate both because caches are deliberately rebuilt on load.
	for pid: String in d.state.colonies: d.refresh_colony(pid)
	check(JSON.stringify(e.state) == JSON.stringify(d.state),"Round trip preserves routes, relations, projects and discoveries")
	if JSON.stringify(e.state) != JSON.stringify(d.state):
		var expected := FileAccess.open("res://artifacts/expected.json",FileAccess.WRITE)
		expected.store_string(JSON.stringify(d.state,"\t",true,true))
		var actual := FileAccess.open("res://artifacts/actual.json",FileAccess.WRITE)
		actual.store_string(JSON.stringify(e.state,"\t",true,true))
	check(e.terrain("s1p0",30,30) == "land","Loaded numeric seed works in terrain generation")
	ticks(d,200)
	ticks(e,200)
	check(JSON.stringify(e.state) == JSON.stringify(d.state),"Loaded game continues deterministically")
	check(e.state.planets.s1p0.terraform == 1.0,"Terraforming completes")
	check(e.state.colonies.s1p0.cells.has("36,30"),"Terraforming preserves buildings")
	check(e.state.rank >= 1,"Peaceful actions advance rank")
	var invalid := FileAccess.open("user://test_invalid.json",FileAccess.WRITE)
	invalid.store_string('{"version":999}')
	invalid.close()
	var snapshot: String = JSON.stringify(e.state)
	check(e.load_game("user://test_invalid.json") != OK,"Unsupported snapshot rejected")
	check(JSON.stringify(e.state) == snapshot,"Failed load leaves current state intact")
	var sandbox = Sim.new()
	sandbox.new_game(2409,"sandbox")
	check(sandbox.save_path() != a.save_path(),"Sandbox and expedition use separate manual saves")
	check(sandbox.save_path(true) != a.save_path(true),"Sandbox and expedition use separate autosaves")
	check(sandbox.command("cheat",{"ability":"free_build"}).is_empty(),"Sandbox enables free construction")
	sandbox.state.colonies.s0p0.materials = 0
	check(build(sandbox,"s0p0",33,32,"habitat").is_empty(),"Free construction works with zero stock")
	check(sandbox.command("cheat",{"ability":"reveal"}).is_empty(),"Sandbox can reveal and survey galaxy")
	check(sandbox.system_by_id("s11").visited,"Map cheat removes fog")
	sandbox.command("cheat",{"ability":"instant_travel"})
	check(sandbox.command("travel",{"system":"s11"}).is_empty(),"Instant travel accepted")
	check(sandbox.state.flagship.system == "s11" and sandbox.state.flagship.destination == "","Instant travel reaches destination immediately")
	check(sandbox.save_game("user://test_sandbox.fw") == OK,"Sandbox save created")
	var restored_sandbox = Sim.new()
	check(restored_sandbox.load_game("user://test_sandbox.fw") == OK,"Sandbox save restored")
	check(restored_sandbox.state.mode == "sandbox" and restored_sandbox.state.cheats.free_build,"Sandbox mode and abilities persist")
	var profile = fresh()
	profile.state.credits = 2000
	profile.state.colonies.s0p0.materials = 500
	profile.state.colonies.s0p0.supplies = 400
	profile.state.flagship.system = "s1"
	profile.command("colonize",{"planet":"s1p0"})
	ticks(profile,18)
	profile.state.flagship.system = "s2"
	profile.command("colonize",{"planet":"s2p0"})
	ticks(profile,18)
	for pid: String in profile.state.colonies:
		profile.state.colonies[pid].materials = 9999
		for x: int in range(15,49):
			build(profile,pid,x,40,"road")
			build(profile,pid,x,39,"habitat")
		for z: int in range(32,41): build(profile,pid,30,z,"road")
	var start: int = Time.get_ticks_usec()
	ticks(profile,300)
	var elapsed: float = float(Time.get_ticks_usec()-start)/1000.0
	print("PROFILE: 12 systems / 3 colonies / %d cells: 300 ticks in %.2f ms (%.3f ms/tick)" % [profile.state.colonies.s0p0.cells.size()*3,elapsed,elapsed/300])
	print("RESULT: %d assertions, %d failures" % [assertions,failures])
	quit(1 if failures else 0)
