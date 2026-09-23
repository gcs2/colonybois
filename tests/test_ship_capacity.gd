extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, explanation: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+explanation)
func journey(game: RefCounted, planet: String) -> void:
	game.field.change_flight_mode("orbit")
	check(game.begin_travel(planet).is_empty(),"Paid journey launches: "+planet)
	for i: int in range(60):
		if not game.traveling(): break
		game.tick()
func run() -> void:
	var game := Session.new()
	var dock: Vector3 = Field.service_position("orbit_tender")
	var before: Dictionary = game.snapshot()
	check(game.field.max_capacity("energy") == 100 and game.field.max_capacity("hull") == 100,"New ship retains baseline capacities")
	check(not game.commerce.eligible("energy_1") and not game.commerce.eligible("unknown"),"Unearned and unknown equipment are not eligible")
	check(not game.commerce.buy_upgrade(game,"orbit_tender",dock,"energy_1").is_empty() and game.snapshot() == before,"Remote/locked purchase leaves campaign untouched")
	check(game.commerce.export_alloy(game,"basin_port",Field.service_position("basin_port"),8).is_empty(),"Load construction stock for the peaceful upgrade voyage")
	journey(game,"s2p0")
	check(game.commerce.transact(game,"orbit_tender",dock,"alloy",8,false).is_empty(),"Foreign demand funds ship progression")
	var energy_before: float = game.field.state.energy
	var funds_before: float = game.field.marks
	check(game.commerce.buy_upgrade(game,"orbit_tender",dock,"energy_1").is_empty(),"Exploration and trade earn an actually affordable reservoir")
	check(game.field.max_capacity("energy") == 150 and game.field.state.energy == energy_before and game.field.marks == funds_before-180,"Purchase expands capacity without granting energy or hiding its price")
	before = game.snapshot()
	check(not game.field.recharge("orbit_tender",dock).is_empty() and game.snapshot() == before,"Foreign refill costs prevent a broke upgraded ship from recharging")
	journey(game,"morrow")
	check(game.field.recharge("orbit_tender",dock).is_empty() and game.field.state.energy == 150,"Home dock fills earned capacity for free")
	for i: int in range(120): game.tick()
	check(game.field.state.energy == 150,"Waiting creates no energy beyond earned capacity")
	game.field.state.energy = 112.0
	for i: int in range(120): game.tick()
	check(game.field.state.energy == 112,"Expanded reactor still never passively regenerates")
	# Funds fixture for structural tier/boundary checks; the first purchase above is earned end-to-end.
	game.field.marks = 20000
	game.commerce.state.badges.explorer = 5
	before = game.snapshot()
	check(not game.commerce.eligible("energy_3") and game.commerce.upgrade_reason(game,"orbit_tender",dock,"energy_3").contains("reservoir II"),"High badge level cannot skip prior installation; reason names it")
	check(not game.commerce.buy_upgrade(game,"orbit_tender",dock,"energy_3").is_empty() and game.snapshot() == before,"Skipped tier is rejected atomically")
	var expected: Array = [100,150,225,325,450]
	for family: String in ["hull","energy"]:
		for tier: int in range(1,5):
			var id: String = "%s_%d" % [family,tier]
			if id in game.commerce.state.upgrades: continue
			var current: float = game.field.state[family]
			check(game.commerce.buy_upgrade(game,"orbit_tender",dock,id).is_empty() and game.field.max_capacity(family) == expected[tier] and game.field.state[family] == current,"Sequential "+id+" changes maximum only")
	before = game.snapshot()
	check(not game.commerce.buy_upgrade(game,"orbit_tender",dock,"hull_4").is_empty() and game.snapshot() == before,"Duplicate installation cannot charge again or heal")
	game.field.state.energy_packs = 2
	game.field.state.energy = 350.0
	check(game.field.use_energy_pack().is_empty() and game.field.state.energy == 400,"Existing inventory pack restores exactly 50 above the old cap")
	for i: int in range(8): game.tick()
	game.field.state.energy = 430.0
	check(game.field.use_energy_pack().is_empty() and game.field.state.energy == 450,"Pack clamps to new cap without overflow")
	game.field.state.hull = 420.0
	check(game.field.repair(100).is_empty() and game.field.state.hull == 450 and game.field.state.energy == 420,"Repair reaches earned hull cap, consumes unchanged energy and clamps excess")
	before = game.snapshot()
	check(not game.field.repair(100).is_empty() and game.snapshot() == before,"Full upgraded hull cannot waste repairs")
	journey(game,"s2p0")
	game.field.state.energy = 400.0
	check(game.field.max_capacity("energy") == 450 and game.field.max_capacity("hull") == 450,"Upgrades travel with the personal ship")
	check(game.field.recharge_price("orbit_tender") == 45,"Foreign service bills missing units at local rate, including expanded capacity")
	funds_before = game.field.marks
	check(game.field.recharge("orbit_tender",dock).is_empty() and game.field.state.energy == 450 and game.field.marks == funds_before-45,"Quoted foreign charge is the amount actually paid")
	var loaded := Session.new()
	check(game.save_to("res://artifacts/ship_capacity.fw") == OK and loaded.load_from("res://artifacts/ship_capacity.fw") == OK and loaded.snapshot() == game.snapshot(),"Binary save preserves ownership, expanded reserves, worlds and history")
	before = loaded.snapshot()
	var invalid: Dictionary = before.duplicate(true)
	invalid.commerce.upgrades.erase("hull_2")
	check(loaded.restore_snapshot(invalid) != OK and loaded.snapshot() == before,"Broken prerequisite chain cannot partially replace campaign")
	invalid = before.duplicate(true); invalid.field.energy = 451.0
	check(loaded.restore_snapshot(invalid) != OK and loaded.snapshot() == before,"Overcapacity save is rejected atomically")
	invalid = before.duplicate(true)
	for tier: int in range(1,5): invalid.commerce.upgrades.erase("energy_%d" % tier)
	check(loaded.restore_snapshot(invalid) != OK and loaded.snapshot() == before,"Saved energy above 100 needs validated purchased equipment")
	var legacy: Dictionary = Session.new().snapshot()
	legacy.version = 7; legacy.field.energy = 18.0; legacy.field.hull = 37.0
	check(loaded.restore_snapshot(legacy) == OK and loaded.field.state.energy == 18 and loaded.field.state.hull == 37 and loaded.commerce.state.upgrades.is_empty(),"Version seven migration gifts neither reserves nor upgrades")
	var combat := Session.new()
	combat.commerce.state.badges.defender = 1
	check(combat.commerce.eligible("hull_1") and not combat.commerce.eligible("hull_2"),"Defense provides an alternate hull unlock, with prerequisites retained")
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = game
	root.add_child(scene); scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	scene.save_path = "res://artifacts/ship_capacity_ui.fw"
	scene.ship.position = dock
	scene.selected_service = "orbit_tender"
	scene._refresh_ui()
	check(scene.hud.energy_bar.max_value == 450 and scene.hud.hull_bar.max_value == 450 and scene.hud.energy_label.text.contains("450 / 450"),"HUD meters and numbers reflect installed capacities")
	scene._show_popup("systems"); await process_frame
	check(scene.system_energy.max_value == 450,"Systems meter uses same authoritative maximum")
	scene.dock_page = "upgrades"; scene.upgrade_family = "energy"; scene._show_popup("service"); await process_frame
	var tier_buttons: int = 0
	for button: Button in scene.popup_body.find_children("*","Button",true,false):
		if button.has_meta("upgrade_id"):
			tier_buttons += 1
			check(button.disabled and button.text == "Installed","Owned reactor tier renders its installed state")
	check(tier_buttons == 4 and scene.popup_body.get_combined_minimum_size().x < 555,"Shop family view shows all four tiers within supported width")
	# Exercise the real shop command, not just its rendered owned state.
	game.commerce.state.upgrades.erase("energy_4")
	game.field.installed_upgrades = game.commerce.state.upgrades
	game.field.state.energy = 200.0
	scene._show_popup("service"); await process_frame
	var purchased: bool = false
	funds_before = game.field.marks
	for button: Button in scene.popup_body.find_children("*","Button",true,false):
		if button.get_meta("upgrade_id","") == "energy_4" and not button.disabled:
			button.pressed.emit(); purchased = true; break
	check(purchased and game.field.max_capacity("energy") == 450 and game.field.state.energy == 200 and game.field.marks == funds_before-1300,"Actual dock purchase button installs the final reservoir without free energy")
	scene._refresh_ui()
	check(scene.hud.energy_bar.max_value == 450 and scene.hud.energy_bar.value == 200,"HUD updates immediately after purchase")
	scene.free()
	print("Ship capacity assertions: %d; failures: %d" % [checks,failures])
	quit(1 if failures else 0)
