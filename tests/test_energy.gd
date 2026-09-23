extends SceneTree
const Model = preload("res://scripts/encounter_state.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+label)
func run() -> void:
	var m := Model.new()
	m.state.energy = 7
	for i: int in range(600): m.tick()
	check(m.state.energy == 7,"Waiting on the surface never regenerates energy")
	m.change_flight_mode("orbit")
	for i: int in range(600): m.tick()
	check(m.state.energy == 7,"Waiting in orbit never regenerates energy")
	var before: Dictionary = m.state.duplicate(true)
	check(not m.recharge("basin_port",Model.service_position("basin_port")).is_empty() and m.state == before,"Remote surface service cannot be used from orbit")
	check(not m.recharge("orbit_tender",Vector3(0,8,35)).is_empty() and m.state == before,"Opening a shop remotely cannot recharge the ship")
	check(m.recharge("orbit_tender",Model.service_position("orbit_tender")).is_empty() and m.state.energy == 100 and m.state.marks == 0,"Homeworld docking restores energy free of charge")
	m.state.energy = 20
	m.state.homeworld_id = "another_homeworld"
	check(m.recharge_price("basin_port") == 36 and m.recharge_price("orbit_tender") == 60,"Away from home, providers quote their own rates for missing energy")
	before = m.state.duplicate(true)
	check(not m.recharge("orbit_tender",Model.service_position("orbit_tender")).is_empty() and m.state == before,"Unaffordable service is rejected atomically")
	m.state.marks = 100
	check(m.recharge("orbit_tender",Model.service_position("orbit_tender")).is_empty() and m.state.marks == 40,"Paid recharge debits the displayed total once")
	before = m.state.duplicate(true)
	check(not m.recharge("orbit_tender",Model.service_position("orbit_tender")).is_empty() and m.state == before,"Full energy cannot trigger another purchase")
	m.state.marks = 200
	check(m.buy_energy_pack("orbit_tender",Model.service_position("orbit_tender")).is_empty() and m.state.energy_packs == 1 and m.state.marks == 162 and m.state.service_stock.orbit_tender == 1,"Buying a pack consumes real shop stock and Marks")
	before = m.state.duplicate(true)
	check(not m.use_energy_pack().is_empty() and m.state == before,"A full battery does not waste a pack")
	m.state.energy = 30
	check(m.use_energy_pack().is_empty() and m.state.energy == 80 and m.state.energy_packs == 0,"Pack consumption restores exactly 50 energy")
	m.buy_energy_pack("orbit_tender",Model.service_position("orbit_tender"))
	before = m.state.duplicate(true)
	check(not m.use_energy_pack().is_empty() and m.state == before,"Pack cooldown prevents instant combat spam")
	for i: int in range(8): m.tick()
	check(m.state.energy == 80,"Cooldown does not conceal regeneration")
	check(m.use_energy_pack().is_empty() and m.state.energy == 100,"Excess pack capacity is lost instead of overflowing the battery")
	before = m.state.duplicate(true)
	check(not m.buy_energy_pack("orbit_tender",Model.service_position("orbit_tender")).is_empty() and m.state == before,"Exhausted shop stock cannot supply infinite reserves")
	var path := "res://artifacts/energy_save.json"
	m.save_to(path)
	var loaded := Model.new()
	check(loaded.load_from(path) == OK and loaded.state == m.state,"Energy, consumables, cooldowns, homeworld and stock persist")
	var old: Dictionary = Model.fresh()
	old.version = 5; old.energy = 13; old.marks = 29
	for key: String in ["homeworld_id","energy_packs","pack_ready_at","service_stock"]: old.erase(key)
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify(old)); file.close()
	check(loaded.load_from(path) == OK and loaded.state.energy == 13 and loaded.state.marks == 29 and loaded.state.energy_packs == 0,"Version 5 migration preserves scarcity without free energy or packs")
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	root.add_child(scene); await process_frame
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	scene._change_flight_mode("orbit")
	scene.model.state.energy = 0
	scene._hud_action("dock")
	check(scene.navigating and scene.service_order == "orbit_tender","Recharge control commands actual docking travel")
	for i: int in range(900): scene._physics_process(1.0/60)
	check(scene.popup.visible and scene.popup_kind == "service" and scene.model.state.energy == 0,"Docking opens services without auto-filling energy")
	scene._service_action(false)
	check(scene.model.state.energy == 100,"Docked homeworld recharge works through the actual interface")
	scene.free()
	print("Energy economy assertions: ",checks,"; failures: ",failures)
	quit(0 if failures == 0 else 1)
