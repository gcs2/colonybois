extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
const Climate = preload("res://scripts/planet_climate.gd")
const Geography = preload("res://scripts/planet_geography.gd")
const Generator = preload("res://scripts/planet_generator.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+title)
func pilot(planet: String = "s1p0") -> RefCounted:
	var game := Session.new()
	game.field.state = Field.fresh(planet); game.field.bind_account(game.sector.state)
	game.field.change_flight_mode("orbit"); game.configure_flagship(); game.climate.bind(game)
	game.sector.system_by_id(game.system_of(planet)).visited = true
	game.field.state.survey_ticks = game.field.definition().survey_seconds
	game.field.marks = 3000; game.commerce.state.badges.explorer = 2
	return game
func buy_tools(game: RefCounted) -> void:
	for id: String in ["heat_ray","cool_ray","cloud_accumulator","cloud_vacuum"]:
		game.commerce.buy_upgrade(game,"orbit_tender",Field.service_position("orbit_tender"),id)
func ticks(game: RefCounted, count: int) -> void:
	for i: int in range(count): game.tick()
func run() -> void:
	var game: RefCounted = pilot()
	var ship := Vector3(0,8,35)
	var dock: Vector3 = Field.service_position("orbit_tender")
	var before: Dictionary = game.snapshot()
	check(not game.climate.start(game,"heat_ray",ship).is_empty() and game.snapshot() == before,"Unowned energy tool cannot alter a world")
	buy_tools(game)
	check(game.field.installed_upgrades.size() == 4 and game.field.marks == 2040,"Four permanent tools are bought through actual shop eligibility and prices")
	game.field.state.survey_ticks = 0
	check(not game.climate.start(game,"heat_ray",ship).is_empty(),"Terraforming requires a completed orbital survey")
	game.field.state.survey_ticks = game.field.definition().survey_seconds
	check(not game.climate.start(game,"heat_ray",Vector3(200,0,0)).is_empty(),"Distant ship must approach the world")
	before = game.snapshot()
	check(game.climate.reason(game,"heat_ray",ship).is_empty() and game.snapshot() == before,"Previewing a tool does not create climate records or spend resources")
	check(game.climate.start(game,"heat_ray",ship).is_empty() and game.field.state.energy == 75,"Heat pulse spends its real energy upfront")
	check(game.climate.world("s1p0").temperature == 15,"A pulse does not instantly finish its effect")
	before = game.snapshot()
	check(not game.climate.start(game,"cool_ray",ship).is_empty() and game.snapshot() == before,"Overlapping pulses cannot bypass time or double-spend")
	game.tick()
	check(game.climate.world("s1p0").temperature == 16.25,"Shared simulation clock advances the climate gradually")
	var loaded := Session.new()
	check(game.save_to("res://artifacts/climate_midpulse.fw") == OK and loaded.load_from("res://artifacts/climate_midpulse.fw") == OK and loaded.snapshot() == game.snapshot(),"Mid-pulse save preserves charges, ownership, world axes and timing")
	ticks(game,7); ticks(loaded,7)
	check(game.snapshot() == loaded.snapshot() and game.climate.world("s1p0").temperature == 25,"Restored pulse resolves identically without replaying costs")
	check(game.climate.world("s1p0").atmosphere == 35,"Temperature tool leaves atmosphere unchanged")
	game.climate.start(game,"heat_ray",ship); ticks(game,8)
	check(Climate.score(game.climate.world("s1p0")) == 2,"Moving into a climate ring raises the real habitat potential")
	game.climate.start(game,"cloud_accumulator",ship); ticks(game,8)
	check(game.climate.world("s1p0").atmosphere == 45 and game.field.state.energy == 30,"Atmospheric tools consume energy and change their independent axis")
	game.climate.start(game,"heat_ray",ship); ticks(game,8)
	check(Climate.score(game.climate.world("s1p0")) == 3 and game.field.state.energy == 5,"Balanced axes reach T3 without free energy")
	before = game.snapshot()
	check(not game.climate.start(game,"cool_ray",ship).is_empty() and game.snapshot() == before,"An exhausted ship cannot use reusable tools")
	var at_completion: float = game.climate.world("s1p0").temperature
	ticks(game,29)
	check(game.climate.world("s1p0").temperature == at_completion,"Climate drift does not happen before its interval")
	game.tick()
	check(game.climate.world("s1p0").temperature == at_completion-1 and game.field.state.energy == 5,"Unstabilized axes drift toward native values; energy still does not regenerate")
	var supplies: RefCounted = pilot()
	var balance: float = supplies.field.marks
	check(supplies.climate.buy(supplies,"orbit_tender",dock,"atmosphere_charge").is_empty() and supplies.field.marks == balance-60,"Single-use unit is a finite paid inventory item")
	supplies.climate.buy(supplies,"orbit_tender",dock,"atmosphere_charge")
	before = supplies.snapshot()
	check(not supplies.climate.buy(supplies,"orbit_tender",dock,"atmosphere_charge").is_empty() and supplies.snapshot() == before,"Dock stock cannot be purchased below zero")
	supplies.field.state.energy = 0
	check(supplies.climate.start(supplies,"atmosphere_charge",ship).is_empty() and supplies.climate.state.charges.atmosphere_charge == 1 and supplies.field.state.energy == 0,"Owned charge works without energy and consumes exactly one unit")
	ticks(supplies,8)
	check(supplies.climate.world("s1p0").atmosphere == 45,"Consumable and energy equipment reach the same axis outcome")
	for id: String in ["heat_charge","cool_charge","vacuum_charge"]:
		for i: int in range(2): supplies.climate.buy(supplies,"orbit_tender",dock,id)
	check(supplies.climate.units() == 6,"Separate terraforming locker respects its six-unit cap")
	before = supplies.snapshot()
	check(not supplies.climate.buy(supplies,"orbit_tender",Vector3(99,99,99),"heat_charge").is_empty() and supplies.snapshot() == before,"Remote purchase cannot bypass dock access")
	var home: RefCounted = pilot("morrow"); buy_tools(home)
	check(not home.climate.start(home,"heat_ray",ship).is_empty(),"Starting homeworld remains protected")
	var reverse: RefCounted = pilot("s2p0"); buy_tools(reverse)
	reverse.climate.start(reverse,"cool_ray",ship); ticks(reverse,8)
	check(reverse.climate.world("s2p0").temperature == 70 and reverse.climate.world("s2p0").atmosphere == 25,"Cooling lowers temperature without changing atmosphere")
	reverse.climate.start(reverse,"cloud_vacuum",ship); ticks(reverse,8)
	check(reverse.climate.world("s2p0").atmosphere == 15 and reverse.field.state.energy == 55,"Vacuum lowers atmosphere with its own energy cost")
	reverse.climate.state.worlds.s2p0.temperature = 3.0
	reverse.climate.start(reverse,"cool_ray",ship); ticks(reverse,8)
	check(reverse.climate.world("s2p0").temperature == 0,"A cooling pulse stops at the lower axis bound")
	before = reverse.snapshot()
	check(not reverse.climate.start(reverse,"cool_ray",ship).is_empty() and reverse.snapshot() == before,"At the lower bound a rejected pulse spends nothing")
	reverse.climate.state.worlds.s2p0.atmosphere = 97.0
	reverse.climate.start(reverse,"cloud_accumulator",ship); ticks(reverse,8)
	check(reverse.climate.world("s2p0").atmosphere == 100,"An atmosphere pulse stops at the upper axis bound")
	before = reverse.snapshot()
	check(not reverse.climate.start(reverse,"cloud_accumulator",ship).is_empty() and reverse.snapshot() == before,"At the upper bound a rejected pulse spends nothing")
	var away: RefCounted = pilot(); buy_tools(away)
	away.climate.start(away,"heat_ray",ship)
	check(away.begin_travel("s2p0").is_empty(),"An already-deployed pulse permits an actual onward voyage")
	ticks(away,8)
	check(away.climate.world("s1p0").temperature == 25,"Inactive world's deployed climate pulse continues on the shared clock")
	var diplomacy: RefCounted = pilot("s7p0"); buy_tools(diplomacy)
	diplomacy.diplomacy.contact(diplomacy,"consortium"); diplomacy.diplomacy.contact(diplomacy,"commune")
	var owner_relation: int = diplomacy.sector.faction_by_id("consortium").relation
	var eco_relation: int = diplomacy.sector.faction_by_id("commune").relation
	diplomacy.climate.start(diplomacy,"heat_ray",ship); ticks(diplomacy,8)
	check(diplomacy.sector.faction_by_id("consortium").relation == owner_relation-20 and diplomacy.sector.faction_by_id("commune").relation == eco_relation-8,"Owner and ecological faction react to actual native-climate displacement")
	diplomacy.climate.start(diplomacy,"heat_ray",ship); ticks(diplomacy,8)
	check(diplomacy.sector.faction_by_id("consortium").relation == owner_relation-20,"Same native climate grievance cannot be repeatedly farmed or charged")
	# Climate has an actual colony/production consequence, preserving terrain and existing structures.
	game.sector._create_colony("s1p0")
	game.colonies.state.outposts["s1p0"] = {"site":[-6.0,-18.0],"module":"alloy","stock":{"alloy":0,"water":0,"glass":0},"status":"","online_recorded":true}
	game.climate.bind(game)
	var terrain: float = Geography.surface_height(game.field.definition(),12,-9)
	var cells: Dictionary = game.sector.state.colonies.s1p0.cells.duplicate(true)
	var temperate_power: float = game.sector.state.colonies.s1p0.power_used
	check(game.climate.effects("s1p0").tier == 3 and game.climate.effects("s1p0").population_cap == 120 and game.colonies.yield_for("s1p0","alloy",game) == 2,"T3 climate alone cannot bypass missing ecosystem tiers for population or export yield")
	game.climate.state.worlds.s1p0.temperature = 0.0; game.climate.state.worlds.s1p0.atmosphere = 0.0
	game.climate.bind(game); game.colonies.tick(game)
	check(game.colonies.state.outposts.s1p0.status == "Production suspended · T0 climate" and game.colonies.state.outposts.s1p0.stock.alloy == 0,"T0 suspends real outpost output")
	check(game.sector.state.colonies.s1p0.power_used > temperate_power,"Climate deterioration increases actual utility demand")
	check(game.sector.state.colonies.s1p0.cells == cells and Geography.surface_height(game.field.definition(),12,-9) == terrain,"Climate manipulation never deforms terrain or deletes structures")
	var restored: Error = loaded.restore_snapshot(game.snapshot())
	check(restored == OK and loaded.snapshot() == game.snapshot(),"Climate-derived colony conditions reproduce after load")
	before = loaded.snapshot(); var corrupt: Dictionary = before.duplicate(true)
	corrupt.climate.worlds.s1p0.temperature = NAN
	check(loaded.restore_snapshot(corrupt) != OK and loaded.snapshot() == before,"Nonfinite climate state cannot partially overwrite the live campaign")
	corrupt = before.duplicate(true); corrupt.climate.charges.heat_charge = 7
	check(loaded.restore_snapshot(corrupt) != OK,"Forged locker overflow is rejected")
	corrupt = supplies.snapshot(); corrupt.climate.worlds.s1p0.project = {"tool":"heat_ray","from":15,"to":95,"remaining":8}
	check(loaded.restore_snapshot(corrupt) != OK,"Forged pending tool or pulse size is rejected")
	var old: Dictionary = Session.new().snapshot(); old.version = 11; old.erase("climate")
	check(loaded.restore_snapshot(old) == OK and loaded.climate.state.worlds.is_empty() and loaded.climate.units() == 0,"Legacy campaign gains no fabricated terraforming progress or supplies")
	# Mouse input, active palette, shared materials, paused inspection and real dock purchase button.
	var view_game: RefCounted = pilot(); buy_tools(view_game)
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); scene.campaign = view_game
	root.add_child(scene); scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	scene.save_path = "res://artifacts/climate_scene.fw"
	check(scene.fleet_visual.actors.values().all(func(actor: Node3D) -> bool: return not actor.visible),"No unassigned escort appears before the first visual refresh")
	scene._hud_action("item:heat_ray")
	check(scene.climate_tool == "heat_ray" and scene.climate_chart.visible,"Hotbar selects global tool with its climate instrument")
	scene._pick(scene.camera.unproject_position(scene.orbit.planet.position))
	check(not view_game.climate.world("s1p0").project.is_empty() and view_game.field.state.energy == 75,"Clicking orbital globe applies selected climate tool instead of descending")
	ticks(view_game,4); scene._refresh_ui()
	check(scene.orbit.planet.material.get_shader_parameter("climate_active") == true and scene.orbit.planet.material.get_shader_parameter("temperature_delta") > 0,"Actual orbital material reads authoritative temperature changes")
	check(scene.planet_map.globe.material.get_shader_parameter("temperature_delta") == scene.orbit.planet.material.get_shader_parameter("temperature_delta"),"Map and orbital globe use the same current climate uniforms")
	check(scene.ground_material.get_shader_parameter("temperature") == 20,"Local surface material reads the same global temperature")
	var texture: Texture2D = scene.orbit.planet.material.get_shader_parameter("surface_map")
	ticks(view_game,4); scene._refresh_ui()
	check(scene.orbit.planet.material.get_shader_parameter("surface_map") == texture,"Climate ticks reuse geography textures instead of rebuilding planet maps")
	scene._show_popup("cargo"); before = view_game.snapshot(); scene._apply_climate(); scene._process(2.0)
	check(view_game.snapshot() == before,"Inventory inspection blocks tool commands and pauses pulse progression")
	scene._close_popup(); scene.ship.position = dock; scene.selected_service = "orbit_tender"; scene.dock_page = "climate"; scene._show_popup("service")
	var purchase: Button
	for button: Node in scene.popup_body.find_children("*","Button",true,false):
		if button.get_meta("climate_purchase","") == "heat_charge": purchase = button
	check(purchase != null and not purchase.disabled,"Dock exposes a valid finite terraform purchase")
	if purchase != null: purchase.pressed.emit()
	check(view_game.climate.state.charges.heat_charge == 1,"Actual shop button loads the shared locker")
	scene.free()
	print("Planet climate assertions: %d; failures: %d" % [checks,failures])
	quit(1 if failures else 0)
