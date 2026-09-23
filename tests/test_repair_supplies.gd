extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+message)
func journey(game: RefCounted, planet: String) -> void:
	game.field.change_flight_mode("orbit")
	check(game.begin_travel(planet).is_empty(),"Supply voyage departs: "+planet)
	while game.traveling(): game.tick()
func run() -> void:
	var game := Session.new()
	var surface: Vector3 = Field.service_position("basin_port")
	var orbit: Vector3 = Field.service_position("orbit_tender")
	var before: Dictionary = game.snapshot()
	check(game.field.repair_pack_count() == 0,"No free starting repair items")
	check(not game.purchase_service("basin_port",surface,"repair_pack").is_empty() and game.snapshot() == before,"Home repair supplies require actual Marks")
	game.field.marks = 2000
	before = game.snapshot()
	check(not game.purchase_service("basin_port",Vector3(70,5,0),"repair_pack").is_empty() and game.snapshot() == before,"Remote buying is rejected atomically")
	check(not game.purchase_service("basin_port",Vector3(NAN,0,0),"repair_pack").is_empty() and game.snapshot() == before,"Invalid dock coordinates cannot buy supplies")
	check(game.service_reason("basin_port",surface,"mega_repair_pack").contains("Explorer 2"),"Full repair item requires accomplishment")
	check(not game.purchase_service("basin_port",surface,"mega_repair_pack").is_empty() and game.snapshot() == before,"Locked item cannot be bought despite enough funds")
	check(game.purchase_service("basin_port",surface,"repair_pack").is_empty() and game.field.marks == 1940 and game.field.state.repair_stock.basin_port.repair_pack == 2,"Purchase debits home stock and the quoted price")
	game.purchase_service("basin_port",surface,"repair_pack")
	game.sector.system_by_id("s1").visited = true; game.sector.system_by_id("s2").visited = true
	game.commerce.update_badges(game)
	check(game.purchase_service("basin_port",surface,"mega_repair_pack").is_empty() and game.field.repair_pack_count() == 3,"Peaceful exploration unlocks full repair and shares the locker")
	before = game.snapshot()
	check(not game.purchase_service("basin_port",surface,"repair_pack").is_empty() and game.snapshot() == before,"Mixed pack types cannot exceed three-slot capacity")
	check(not game.use_repair_pack("repair_pack").is_empty() and game.snapshot() == before,"Sound hull never wastes an inventory item")
	check(not game.use_repair_pack("unknown").is_empty() and game.snapshot() == before,"Unknown supplies cannot mutate ship state")
	game.field.state.hull = 20.0; game.field.state.energy = 0.0
	check(game.use_repair_pack("repair_pack").is_empty() and game.field.state.hull == 95 and game.field.state.energy == 0 and game.field.state.repair_packs.repair_pack == 1,"Basic pack consumes one item and restores 75 hull without energy")
	before = game.snapshot()
	check(not game.use_repair_pack("mega_repair_pack").is_empty() and game.snapshot() == before,"Different pack types share a cooldown and cannot be spammed")
	check(game.field.repair_reason(100).contains("cooling"),"Pack use also cools the energy-driven field cradle")
	for i: int in range(20): game.tick()
	check(game.field.state.hull == 95 and game.field.state.energy == 0,"Waiting changes neither hull nor energy")
	game.commerce.buy_upgrade(game,"basin_port",surface,"hull_1")
	game.commerce.buy_upgrade(game,"basin_port",surface,"hull_2")
	check(game.field.max_capacity("hull") == 225 and game.use_repair_pack("mega_repair_pack").is_empty() and game.field.state.hull == 225,"Full repair restores the purchased hull capacity")
	for i: int in range(20): game.tick()
	game.field.state.hull = 210.0
	check(game.use_repair_pack("repair_pack").is_empty() and game.field.state.hull == 225 and game.field.repair_pack_count() == 0,"Fixed repair clamps overflow and consumes its last item")
	check(game.purchase_service("basin_port",surface,"repair_pack").is_empty(),"Last basic shop unit can be purchased")
	before = game.snapshot()
	check(not game.purchase_service("basin_port",surface,"repair_pack").is_empty() and game.snapshot() == before,"Exhausted shop cannot manufacture inventory")
	check(not game.purchase_service("basin_port",surface,"mega_repair_pack").is_empty() and game.snapshot() == before,"Full repair stock is independently exhausted")
	check(game.purchase_service("basin_port",surface,"recharge").is_empty() and game.field.state.energy == 100,"Home recharge remains free through campaign validation")
	journey(game,"s1p0")
	check(game.field.state.repair_packs.repair_pack == 1 and game.field.state.repair_stock.orbit_tender.repair_pack == 2,"Carried supply travels; a new world's stock is separate")
	game.sector.system_by_id("s1").owner = "consortium"
	var owner: String = "consortium"
	game.sector.faction_by_id(owner).embargo = true
	before = game.snapshot()
	for action: String in ["recharge","pack","repair_pack","mega_repair_pack"]:
		check(game.purchase_service("orbit_tender",orbit,action).contains("embargo") and game.snapshot() == before,"Embargo covers dock service "+action)
	game.sector.faction_by_id(owner).embargo = false
	var balance: float = game.field.marks
	check(game.purchase_service("orbit_tender",orbit,"repair_pack").is_empty() and game.field.marks == balance-80,"Frozen-world price is charged exactly")
	check(game.save_to("res://artifacts/repair_supplies.fw") == OK,"Supply expedition saves")
	var loaded := Session.new()
	check(loaded.load_from("res://artifacts/repair_supplies.fw") == OK and loaded.snapshot() == game.snapshot(),"Counts, cooldown, stocks, upgrades and chronicle round-trip")
	journey(game,"morrow")
	check(game.field.state.repair_stock.basin_port.repair_pack == 0 and game.field.repair_pack_count() == 2,"Revisiting a world preserves exhausted stock and ship inventory")
	before = loaded.snapshot()
	for corrupt: String in ["overfill","fraction","negative","stock","missing"]:
		var invalid: Dictionary = before.duplicate(true)
		match corrupt:
			"overfill": invalid.field.repair_packs = {"repair_pack":2,"mega_repair_pack":2}
			"fraction": invalid.field.repair_packs.repair_pack = 0.5
			"negative": invalid.field.repair_packs.repair_pack = -1
			"stock": invalid.worlds.morrow.repair_stock.basin_port.repair_pack = 400
			"missing": invalid.field.repair_stock.orbit_tender.erase("mega_repair_pack")
		check(loaded.restore_snapshot(invalid) != OK and loaded.snapshot() == before,"Corrupt supply data rejected atomically: "+corrupt)
	var old: Dictionary = before.duplicate(true)
	old.version = 8; old.field.version = 7
	old.field.erase("repair_packs"); old.field.erase("repair_stock")
	for id: String in old.worlds: old.worlds[id].erase("repair_stock")
	check(loaded.restore_snapshot(old) == OK and loaded.field.repair_pack_count() == 0 and loaded.field.state.hull == before.field.hull and loaded.field.state.energy == before.field.energy,"Legacy migration adds shop offers but no free carried packs or restored resources")
	check(loaded.worlds.morrow.repair_stock.basin_port.repair_pack == 3,"Legacy inactive worlds receive valid new shop stock")
	# Real mouse controls: shop purchase, inventory consumption, hotbar cooldown and pause.
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = game; root.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	scene.save_path = "res://artifacts/repair_supplies_ui.fw"
	scene.ship.position = orbit; scene.selected_service = "orbit_tender"; scene.dock_page = "energy"
	scene._show_popup("service"); await process_frame
	var clicked: bool = false
	for button: Button in scene.popup_body.find_children("*","Button",true,false):
		if button.get_meta("purchase_supply","") == "repair_pack" and not button.disabled:
			button.pressed.emit(); clicked = true; break
	check(clicked and game.field.repair_pack_count() == 3,"Actual dock button purchases the last locker space")
	for i: int in range(20): game.tick()
	game.field.state.hull = 120.0
	scene._show_popup("cargo"); await process_frame
	clicked = false
	for button: Button in scene.popup_body.find_children("*","Button",true,false):
		if button.get_meta("supply_id","") == "repair_pack" and not button.disabled:
			check(not button.tooltip_text.is_empty() and button.icon != null,"Inventory item has explanatory tooltip and original icon")
			button.pressed.emit(); clicked = true; break
	check(clicked and game.field.state.hull == 195 and game.field.repair_pack_count() == 2,"Clicking the actual inventory item consumes it and repairs the ship")
	scene._close_popup(); scene._hud_action("category:Inventory"); scene._refresh_ui()
	check(scene.hud.item_buttons.repair_pack.disabled and scene.hud.count_labels.repair_pack.text.contains("20s"),"Hotbar shows shared cooldown and disables repeated consumption")
	for i: int in range(20): game.tick()
	scene._refresh_ui(); scene.hud.item_buttons.repair_pack.pressed.emit()
	check(game.field.state.hull == 225 and game.field.repair_pack_count() == 1,"Inventory hotbar icon dispatches the same consumable command")
	before = game.snapshot(); scene.paused = true
	scene._hud_action("repair_pack")
	check(game.snapshot() == before,"Explicit pause rejects consumable use")
	check(scene.popup_body.get_combined_minimum_size().x < 555,"Inventory supplies fit the supported panel width")
	scene.free()
	print("Repair supply assertions: %d; failures: %d" % [checks,failures])
	quit(1 if failures else 0)
