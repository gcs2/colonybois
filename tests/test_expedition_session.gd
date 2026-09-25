extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
var checks: int = 0
var failures: int = 0

func check(ok: bool, explanation: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: "+explanation)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game := Session.new()
	check(game.field.marks == 0 and not game.field.state.has("marks"),"One zero-Mark treasury; no duplicate field balance")
	game.sector.state.credits = 100.75
	check(game.field.buy_energy_pack("basin_port",Field.service_position("basin_port")).is_empty(),"Field purchase uses the sector treasury")
	var price: int = Field.services().basin_port.pack_price
	check(game.sector.state.credits == 100.75-price and game.field.marks == game.sector.state.credits,"Purchase debits once and preserves fractional colony income")
	game.field.state.produce = 1
	game.field.sell()
	check(game.sector.state.credits == 118.75-price,"Field sale credits the same treasury")
	game.field.state.energy = 11.0
	for i: int in range(29): game.tick()
	check(game.sector.state.tick == 0 and game.field.state.time == 29,"Local seconds and strategic days use an explicit shared cadence")
	game.tick()
	check(game.sector.state.tick == 1 and game.field.state.time == 30 and game.sector_clock == 0,"Exactly one colony tick per 30 active seconds")
	check(game.field.state.energy == 11,"Background economy never regenerates energy")
	check(game.field.marks == game.sector.state.ledger.closing,"Colony ledger and ship show the same closing balance")
	game.field.state.energy = 100.0
	check(not game.mining_reason(4).is_empty() and game.field.state.ore_remaining == Field.MINERAL_DEPOSIT_UNITS,"Mining requires a scan and leaves the deposit untouched on refusal")
	check(game.field.act("scan","vein",4).is_empty(),"Surface scanner can locate the resonant seam")
	game.commerce.add_cargo("alloy",game.commerce.capacity(),"test")
	var full_hold_energy: float = game.field.state.energy
	check(not game.extract_surface_crystal(4).is_empty() and game.field.state.ore_remaining == Field.MINERAL_DEPOSIT_UNITS and game.field.state.energy == full_hold_energy,"A full hold blocks the cut before charging energy or depleting the seam")
	game.commerce.state.cargo.clear()
	for i: int in range(Field.MINERAL_DEPOSIT_UNITS): check(game.extract_surface_crystal(4).is_empty(),"Valid cutter cycle returns one crystal to real ship cargo")
	check(game.commerce.quantity("glass") == Field.MINERAL_DEPOSIT_UNITS and game.field.state.ore_remaining == 0,"Four finite pieces enter the shared cargo ledger")
	var mined_energy: float = game.field.state.energy
	var mined_snapshot: Dictionary = game.snapshot()
	check(not game.extract_surface_crystal(4).is_empty() and game.field.state.energy == mined_energy and game.snapshot() == mined_snapshot,"Spent mineral seam cannot be harvested twice")
	var mined_restore := Session.new()
	check(mined_restore.restore_snapshot(mined_snapshot) == OK and mined_restore.snapshot() == mined_snapshot,"Campaign save/load preserves cargo, extracted resource, and chronicle")
	var marks_before_sale: float = game.field.marks
	var demand_before_sale: int = game.commerce.market("morrow").glass.demand
	check(game.commerce.transact(game,"basin_port",Field.service_position("basin_port"),"glass",1,false).is_empty(),"Mined crystals can be sold at the real planetary market")
	check(game.commerce.quantity("glass") == Field.MINERAL_DEPOSIT_UNITS-1 and game.field.marks > marks_before_sale and game.commerce.market("morrow").glass.demand == demand_before_sale-1,"Sale pays the shared Marks treasury and consumes finite market demand")
	var legacy_campaign_snapshot: Dictionary = Session.new().snapshot()
	legacy_campaign_snapshot.version = 19
	legacy_campaign_snapshot.field.version = 9
	legacy_campaign_snapshot.field.erase("ore_remaining")
	var legacy_campaign_restore := Session.new()
	check(legacy_campaign_restore.restore_snapshot(legacy_campaign_snapshot) == OK and legacy_campaign_restore.field.state.ore_remaining == Field.MINERAL_DEPOSIT_UNITS,"Version 19 campaign save gains the unmined deposit when loading the new feature")
	var before_view: Dictionary = game.snapshot()
	game.field.change_flight_mode("orbit")
	game.field.change_flight_mode("surface")
	check(game.sector.state.tick == before_view.sector.tick and game.field.marks == before_view.sector.credits,"View transitions cannot duplicate economy ticks or money")
	for i: int in range(17): game.tick()
	game.sector.state.agreements.append("consortium:trade")
	game.sector.state.discoveries["session_test"] = {"resolved":true}
	game.sector.state.planets.s0p0.project = true
	game.field.state.samples = 1
	game.field.state.energy_packs = 2
	var path: String = "res://artifacts/campaign_test.fw"
	check(game.save_to(path) == OK,"Campaign atomic save succeeds")
	var loaded := Session.new()
	var load_error: Error = loaded.load_from(path)
	check(load_error == OK and loaded.snapshot() == game.snapshot(),"Full sector, ship, cargo, project, agreement and partial clock survive save/load")
	check(loaded.field.account == loaded.sector.state,"Restored field uses the restored treasury")
	for i: int in range(90): game.tick(); loaded.tick()
	check(loaded.snapshot() == game.snapshot(),"Save continuation reproduces both simulations deterministically")
	var before: Dictionary = loaded.snapshot()
	var invalid: Dictionary = before.duplicate(true)
	invalid.field.energy = -1
	check(loaded.restore_snapshot(invalid) != OK and loaded.snapshot() == before,"Invalid ship data cannot half-load the sector")
	invalid = before.duplicate(true)
	invalid.sector.erase("colonies")
	check(loaded.restore_snapshot(invalid) != OK and loaded.snapshot() == before,"Invalid sector leaves the ship and economy intact")
	invalid = before.duplicate(true)
	invalid.field.marks = 999
	check(loaded.restore_snapshot(invalid) != OK,"Conflicting duplicated balances are rejected")
	invalid = before.duplicate(true)
	invalid.sector_clock = 30
	check(loaded.restore_snapshot(invalid) != OK,"Invalid partial clock cannot manufacture a day")
	var legacy := Field.new()
	legacy.state.marks = 72
	legacy.state.energy = 9.0
	legacy.state.hull = 43.0
	legacy.state.energy_packs = 1
	legacy.state.time = 123
	legacy.state.samples = 2
	legacy.note("old","An existing discovery")
	var old_path: String = "res://artifacts/legacy_campaign_test.json"
	legacy.save_to(old_path)
	var old_bytes: PackedByteArray = FileAccess.get_file_as_bytes(old_path)
	var migrated := Session.new()
	check(migrated.import_legacy(old_path) == OK,"Legacy field progress imports")
	check(migrated.field.snapshot() == legacy.state and migrated.sector.state.credits == 72,"Migration preserves all ship progress without adding starter Marks or energy")
	check(FileAccess.get_file_as_bytes(old_path) == old_bytes,"Migration leaves the original save untouched")
	check(Session.newest_save(path,"res://artifacts/no_such_save.fw") == path,"Resume finds a manual-only campaign")
	var empty_path: String = "res://artifacts/broken_campaign.fw"
	var broken := FileAccess.open(empty_path,FileAccess.WRITE)
	broken.store_string("FWEXP001")
	broken.close()
	check(loaded.load_from(empty_path) != OK and loaded.snapshot() == before,"Truncated save is rejected without replacing progress")
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = Session.new()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	scene.set_physics_process(false)
	scene.save_path = "res://artifacts/session_scene.json"
	scene.campaign.sector.state.credits = 67.25
	scene.model.state.energy = 17.0
	scene.tick_clock = 0
	scene.paused = true
	scene._process(31)
	check(scene.model.state.time == 0 and scene.campaign.sector.state.tick == 0,"Pause freezes both models")
	scene.paused = false
	scene._show_popup("journal")
	scene._process(31)
	check(scene.model.state.time == 0 and scene.campaign.sector.state.tick == 0,"Inspection freezes both models")
	scene._close_popup()
	scene._process(30)
	check(scene.model.state.time == 30 and scene.campaign.sector.state.tick == 1,"Real flight process drives the sector exactly once")
	scene._save()
	var saved: Dictionary = scene.campaign.snapshot()
	scene.model.marks = 999
	scene.model.state.energy = 99.0
	scene._load()
	check(scene.campaign.snapshot() == saved and scene.model == scene.campaign.field,"Flight save/load keeps the scene attached to the shared campaign")
	scene._refresh_ui()
	check(scene.stats.text.begins_with("%d Marks" % scene.campaign.sector.state.credits),"HUD reads the authoritative balance")
	var seam: Vector3 = scene._target_position("vein")
	scene.ship.position = seam+Vector3(0,3,3)
	scene.selected = "vein"
	scene._select_tool("scan")
	scene.held = true
	scene._operate(2)
	check("vein" in scene.model.state.scanned,"Surface HUD scan action can identify the resource node")
	scene._select_tool("mine")
	scene.held = true
	scene._operate(3)
	scene._update_visuals()
	scene._refresh_ui()
	check(scene.campaign.commerce.quantity("glass") == 1 and scene.model.state.ore_remaining == Field.MINERAL_DEPOSIT_UNITS-1,"Mouse-selected cutter visibly transfers one mineral into cargo")
	check(scene.mineral_crystals.filter(func(gem: MeshInstance3D) -> bool: return gem.visible).size() == Field.MINERAL_DEPOSIT_UNITS-1,"Collected crystal disappears from the finite surface seam")
	check(scene.operation_feedback == "SECURED" and scene.status_icon.visible and scene.status.text.begins_with("+1 Resonant glass"),"Mining reward uses the item icon and concise cargo receipt")
	check(scene.status_icon.size.x <= 56 and scene.status_icon.size.y <= 56,"Reward icon remains a small HUD pictogram, not a full-size image")
	check(scene.subject.text == "Resonant glass seam" and scene.hud.action_state.text == "SECURED" and scene.explanation.text.begins_with("+1 Resonant glass"),"Target card reports the delivered item without distance/status overlap")
	check(scene.ring.position.y > scene.terrain_height(scene.ring.position.x,scene.ring.position.z),"Selected target ring sits visibly above the surface")
	scene.persistence_blocked = true
	var safe_bytes: PackedByteArray = FileAccess.get_file_as_bytes(scene._campaign_path(false))
	scene.model.marks = 999
	scene._save()
	check(FileAccess.get_file_as_bytes(scene._campaign_path(false)) == safe_bytes,"Failed-start protection prevents overwriting saved progress")
	scene.free()
	print("Expedition session assertions: ",checks,"; failures: ",failures)
	quit(0 if failures == 0 else 1)
