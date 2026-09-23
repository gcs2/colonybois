extends SceneTree
const Model = preload("res://scripts/encounter_state.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+message)
func step(model: RefCounted, at: Vector3) -> String:
	model.tick(INF)
	return model.guardian_step(at)
func run() -> void:
	var m := Model.new()
	for i: int in range(8): step(m,Model.GUARDIAN_HOME)
	check(m.state.hull == 100 and m.state.guardian_alert == 0,"Surface has no orbital combat")
	m.change_flight_mode("orbit")
	for i: int in range(12): step(m,Vector3(0,8,35))
	check(m.state.hull == 100 and m.state.guardian_alert == 0,"Entry and tow position remain safe")
	var at: Vector3 = Model.GUARDIAN_HOME+Vector3(0,0,8)
	step(m,at); step(m,at)
	check(m.state.hull == 100 and m.state.guardian_alert == 2,"Custodian gives two warning ticks")
	check(step(m,at) == "guardian_hit" and m.state.hull == 90,"Third warning tick causes a real hit")
	for i: int in range(3): step(m,at)
	check(m.state.hull == 90,"Enemy cooldown prevents every-tick damage")
	step(m,Vector3(0,8,35))
	check(m.state.guardian_alert == 0 and m.state.hull == 90,"Retreat disengages the custodian")
	var before: Dictionary = m.state.duplicate(true)
	check(not m.fire_lance(Vector3(NAN,0,0)).is_empty() and m.state == before,"Invalid aim is rejected atomically")
	check(not m.fire_lance(Vector3.ZERO).is_empty() and m.state == before,"Out-of-range fire costs nothing")
	m.state.energy = 9
	before = m.state.duplicate(true)
	check(not m.fire_lance(at).is_empty() and m.state == before,"Insufficient energy cannot damage a target")
	m.state.energy = 100
	check(m.fire_lance(at).is_empty() and m.state.guardian_hull == 44 and m.state.energy == 90,"Lance trades energy for damage")
	before = m.state.duplicate(true)
	check(not m.fire_lance(at).is_empty() and m.state == before,"Weapon cooldown rejects duplicate shots")
	var path := "res://artifacts/combat_save.json"
	check(m.save_to(path) == OK,"Mid-combat save succeeds")
	var restored := Model.new()
	check(restored.load_from(path) == OK and restored.state == m.state,"Cooldowns and target state survive load")
	for i: int in range(10):
		step(m,at); step(restored,at)
	check(m.state == restored.state,"Restored AI continues deterministically")
	for shot: int in range(2):
		m.tick(INF); m.tick(INF); m.fire_lance(at)
	check(m.state.guardian_disabled and m.state.guardian_hull == 0,"Three successful shots disable the custodian")
	before = m.state.duplicate(true)
	check(not m.fire_lance(at).is_empty() and m.state == before,"Disabled target cannot be farmed")
	var hull: float = m.state.hull
	for i: int in range(12): step(m,at)
	check(m.state.hull == hull,"Disabled custodian stops firing")
	m = Model.new(); m.change_flight_mode("orbit")
	m.state.shroud_unlocked = true; m.state.shroud_on = true
	for i: int in range(3): step(m,at)
	check(m.state.hull == 97,"Shroud reduces a custodian hit to three hull")
	var invalid: Dictionary = m.state.duplicate(true)
	invalid.guardian_disabled = true
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify(invalid)); file.close()
	before = restored.state.duplicate(true)
	check(restored.load_from(path) == ERR_INVALID_DATA and restored.state == before,"Inconsistent disabled state cannot corrupt a live save")
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	scene._change_flight_mode("orbit")
	scene.ship.position = at
	scene.salvage_order = true; scene.navigating = true
	scene._command_guardian()
	check(scene.attack_order and not scene.salvage_order and not scene.navigating,"Attack replaces previous salvage and navigation")
	scene.model.state.energy = 0
	scene._command_guardian()
	check(not scene.attack_order,"Cancel remains available without weapon energy")
	scene.model.state.energy = 100
	scene._command_guardian(); scene._operate_attack()
	check(scene.model.state.guardian_hull == 44 and scene.weapon_flash > 0,"Scene order fires the actual weapon with a visible flash")
	scene._toggle_pause(); scene._operate_attack()
	check(not scene.attack_order and scene.model.state.guardian_hull == 44,"Pause cancels firing without extra hits")
	scene.free()
	print("Orbital combat assertions: ",checks,"; failures: ",failures)
	quit(0 if failures == 0 else 1)
