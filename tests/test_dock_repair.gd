extends SceneTree

const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")

var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: " + message)

func journey(game: RefCounted, planet: String) -> void:
	game.field.change_flight_mode("orbit")
	check(game.begin_travel(planet).is_empty(), "Supply voyage departs: " + planet)
	while game.traveling():
		game.tick()

func run() -> void:
	var game := Session.new()
	var surface: Vector3 = Field.service_position("basin_port")
	var orbit: Vector3 = Field.service_position("orbit_tender")
	var before: Dictionary = game.snapshot()

	# 1. Full hull rejection
	check(game.field.state.hull == 100.0, "Flagship begins at baseline 100 hull")
	check(game.dock_repair_price("basin_port") == 0, "Full hull quote is 0 Marks")
	check(game.service_reason("basin_port", surface, "repair") == "Hull is sound.", "Service reason identifies sound hull")
	check(not game.purchase_service("basin_port", surface, "repair").is_empty() and game.snapshot() == before, "Full hull repair rejected atomically without state mutation")

	# 2. Damage ship, audit quote and insufficient funds rejection
	game.field.state.hull = 60.0
	game.field.marks = 0
	# 40 missing hull at basin_port (rate 0.5) = 20 Marks
	check(game.dock_repair_price("basin_port") == 20, "Missing 40 hull quotes 20 Marks at home basin port (rate 0.5)")
	check(game.dock_repair_price("orbit_tender") == 32, "Missing 40 hull quotes 32 Marks at home orbit tender (rate 0.8)")
	check(game.service_reason("basin_port", surface, "repair").contains("20 Marks"), "Refusal message displays the exact required fee")
	before = game.snapshot()
	check(not game.purchase_service("basin_port", surface, "repair").is_empty() and game.snapshot() == before, "Insufficient Marks rejects repair atomically")

	# 3. Location, flight mode, and reach validation
	game.field.marks = 500
	before = game.snapshot()
	check(not game.purchase_service("basin_port", Vector3(70, 5, 0), "repair").is_empty() and game.snapshot() == before, "Remote repair rejected atomically")
	check(not game.purchase_service("basin_port", Vector3(NAN, 0, 0), "repair").is_empty() and game.snapshot() == before, "Invalid coordinates cannot trigger repair")
	check(not game.purchase_service("orbit_tender", surface, "repair").is_empty() and game.snapshot() == before, "Surface flight mode cannot dock at orbital tender")
	check(not game.purchase_service("unknown_port", surface, "repair").is_empty() and game.snapshot() == before, "Unknown port cannot provide repair")

	# 4. Successful repair at home surface port
	var energy_before: float = game.field.state.energy
	var packs_before: Dictionary = game.field.state.repair_packs.duplicate(true)
	var energy_packs_before: int = game.field.state.energy_packs
	var cooldown_before: int = int(game.field.state.last_repair_at)
	var marks_before: float = game.field.marks

	var err: String = game.purchase_service("basin_port", surface, "repair")
	check(err.is_empty(), "Direct dock repair succeeds when docked with funds")
	check(game.field.state.hull == 100.0, "Hull restored to full baseline capacity")
	check(game.field.marks == marks_before - 20, "Exact 20 Marks deducted for 40 missing hull")
	check(game.field.state.energy == energy_before, "Energy remains completely unchanged")
	check(game.field.state.repair_packs == packs_before, "Carried repair supplies remain unchanged")
	check(game.field.state.energy_packs == energy_packs_before, "Carried energy packs remain unchanged")
	check(game.field.state.last_repair_at == cooldown_before, "Repair cradle cooldown is untouched by dock service")

	# 5. Chronicle verification
	var events: Array = game.diplomacy.state.events
	check(not events.is_empty() and events.back().summary.contains("Hull repair") and events.back().summary.contains("20 Marks"), "Chronicle records authoritative hull repair event and cost")

	# 6. Purchased hull capacity tiers
	game.sector.system_by_id("s1").visited = true
	game.sector.system_by_id("s2").visited = true
	game.sector.system_by_id("s3").visited = true
	game.commerce.update_badges(game)
	game.field.marks = 3000
	game.commerce.buy_upgrade(game, "basin_port", surface, "hull_1")
	check(game.field.max_capacity("hull") == 150.0, "Purchased tier 1 hull capacity is 150")
	# Ship is still at 100 hull out of 150 capacity
	check(game.field.state.hull == 100.0, "Upgrade installation preserves current hull without free repair")
	# 50 missing hull at orbit tender (rate 0.8) = 40 Marks
	game.field.change_flight_mode("orbit")
	check(game.dock_repair_price("orbit_tender") == 40, "Missing 50 hull quotes 40 Marks at orbit tender")
	marks_before = game.field.marks
	err = game.purchase_service("orbit_tender", orbit, "repair")
	check(err.is_empty(), "Orbit tender repairs expanded hull capacity")
	check(game.field.state.hull == 150.0, "Hull restored to expanded 150 capacity")
	check(game.field.marks == marks_before - 40, "Exact 40 Marks charged at orbital rate")

	# Buy tier 2 hull upgrade (225 capacity)
	game.commerce.buy_upgrade(game, "orbit_tender", orbit, "hull_2")
	check(game.field.max_capacity("hull") == 225.0, "Purchased tier 2 hull capacity is 225")
	game.field.state.hull = 25.0
	# 200 missing hull at basin_port (rate 0.5) = 100 Marks
	game.field.change_flight_mode("surface")
	check(game.dock_repair_price("basin_port") == 100, "Missing 200 hull quotes 100 Marks at basin port")
	marks_before = game.field.marks
	check(game.purchase_service("basin_port", surface, "repair").is_empty(), "Basin port repairs up to 225 capacity")
	check(game.field.state.hull == 225.0 and game.field.marks == marks_before - 100, "Hull reaches 225 and charges exact 100 Marks")

	# 7. Foreign world repair and pricing
	journey(game, "s1p0")
	# s1p0 is frozen world (marks_per_hull = 0.7)
	game.field.state.hull = 125.0 # missing 100 hull
	check(game.dock_repair_price("orbit_tender") == 70, "Frozen world quotes 70 Marks for 100 missing hull (rate 0.7)")
	marks_before = game.field.marks
	check(game.purchase_service("orbit_tender", orbit, "repair").is_empty(), "Foreign dock executes repair at foreign rate")
	check(game.field.state.hull == 225.0 and game.field.marks == marks_before - 70, "Foreign world charges exact local rate")

	# 8. Embargo enforcement
	game.sector.system_by_id("s1").owner = "consortium"
	game.sector.state.planets.s1p0.owner = "consortium"
	game.sector.faction_by_id("consortium").embargo = true
	game.field.state.hull = 200.0
	before = game.snapshot()
	check(game.service_reason("orbit_tender", orbit, "repair").contains("embargo"), "Embargo closes dock hull repair service")
	check(not game.purchase_service("orbit_tender", orbit, "repair").is_empty() and game.snapshot() == before, "Embargo rejects dock repair transaction atomically")
	game.sector.faction_by_id("consortium").embargo = false

	# 9. Travel / movement restriction
	check(game.begin_travel("morrow").is_empty(), "Initiated travel to Morrow")
	check(game.traveling(), "Ship is in transit")
	check(game.service_reason("orbit_tender", orbit, "repair").contains("journey"), "Cannot repair while traveling")
	while game.traveling():
		game.tick()
	check(not game.traveling(), "Arrived at destination")

	# 10. Persistence roundtrip
	game.field.state.hull = 180.0
	check(game.save_to("res://artifacts/dock_repair_session.fw") == OK, "Dock repair session saves successfully")
	var loaded := Session.new()
	check(loaded.load_from("res://artifacts/dock_repair_session.fw") == OK, "Dock repair session loads successfully")
	check(loaded.field.state.hull == 180.0, "Saved damaged hull amount preserved")
	check(loaded.dock_repair_price("orbit_tender") == int(ceil((225.0 - 180.0) * 0.8)), "Restored session quotes exact price from loaded state")
	check(loaded.purchase_service("orbit_tender", orbit, "repair").is_empty(), "Restored session can execute dock repair")
	check(loaded.field.state.hull == 225.0, "Restored session repairs to full purchased capacity")

	# 11. Real UI encounter test
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = game
	root.add_child(scene)
	scene.set_process(false)
	scene.set_physics_process(false)
	scene.audio.muted = true
	scene.save_path = "res://artifacts/dock_repair_ui.fw"

	# Set up damaged ship in orbit at orbit_tender
	game.field.state.hull = 175.0 # missing 50 hull out of 225 capacity
	game.field.marks = 0
	scene.ship.position = orbit
	scene.selected_service = "orbit_tender"
	scene.dock_page = "energy"
	scene._show_popup("service")
	await process_frame

	var repair_btn: Button = null
	for btn: Button in scene.popup_body.find_children("*", "Button", true, false):
		if btn.get_meta("dock_action", "") == "repair":
			repair_btn = btn
			break

	check(repair_btn != null, "Dock service popup contains direct hull repair button")
	check(repair_btn.text.contains("+50") and repair_btn.text.contains("40 Marks"), "UI button displays exact missing hull (+50) and quoted price (40 Marks)")
	check(repair_btn.disabled, "UI button is disabled when player has insufficient Marks")
	check(repair_btn.tooltip_text.contains("costs 40 Marks"), "Tooltip communicates price shortfall reason")

	# Fund Marks and check button enabled
	game.field.marks = 500
	scene._show_popup("service")
	await process_frame
	for btn: Button in scene.popup_body.find_children("*", "Button", true, false):
		if btn.get_meta("dock_action", "") == "repair":
			repair_btn = btn
			break

	check(not repair_btn.disabled, "UI button is enabled when player has sufficient Marks")

	# Invariant checks before click
	energy_before = game.field.state.energy
	packs_before = game.field.state.repair_packs.duplicate(true)
	energy_packs_before = game.field.state.energy_packs
	marks_before = game.field.marks

	# Click the repair button
	repair_btn.pressed.emit()
	await process_frame

	check(game.field.state.hull == 225.0, "UI button click repairs hull to full purchased capacity (225)")
	check(game.field.marks == marks_before - 40, "UI button click debits exact quoted 40 Marks")
	check(game.field.state.energy == energy_before, "UI dock repair leaves energy completely unchanged")
	check(game.field.state.repair_packs == packs_before, "UI dock repair leaves carried repair supplies completely unchanged")
	check(game.field.state.energy_packs == energy_packs_before, "UI dock repair leaves energy packs completely unchanged")

	# Check UI refreshed to sound state
	for btn: Button in scene.popup_body.find_children("*", "Button", true, false):
		if btn.get_meta("dock_action", "") == "repair":
			repair_btn = btn
			break

	check(repair_btn != null and repair_btn.text == "Hull sound" and repair_btn.disabled, "After repair, UI updates to 'Hull sound' and disables button")
	check(scene.popup_body.get_combined_minimum_size().x < 555, "Dock service popup fits supported width")

	scene.free()

	print("Dock repair assertions: %d; failures: %d" % [checks, failures])
	quit(1 if failures else 0)
