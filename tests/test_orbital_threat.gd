extends SceneTree
const Model = preload("res://scripts/encounter_state.gd")
const Orbit = preload("res://scripts/orbital_scene.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+label)

func run() -> void:
	var model := Model.new()
	var before: Dictionary = model.state.duplicate(true)
	check(not model.salvage(0).is_empty() and model.state == before,"Surface salvage is unavailable and free of side effects")
	for i: int in range(8): model.tick(0)
	check(model.state.hull == 100 and model.state.threat_clock == 0,"Orbital danger cannot damage a ship on the surface")
	model.change_flight_mode("orbit")
	check(not model.salvage(0).is_empty(),"Wreck reward requires charting before approach")
	for i: int in range(6): model.tick(25)
	check(model.state.hull == 100,"Telegraphed warning band causes no hull damage")
	for i: int in range(5): model.tick(0)
	check(model.state.hull == 100 and model.state.threat_clock == 5,"Core counts down before a pulse")
	check(model.tick(0) == "pulse" and model.state.hull == 82,"Unshielded pulse damages once on its sixth tick")
	for i: int in range(4): model.tick(0)
	model.tick(40)
	check(model.state.threat_clock == 0,"Retreat immediately clears exposure rather than causing delayed hits")
	for i: int in range(6): model.tick(40)
	check(model.state.hull == 82,"Leaving the field stops pulse damage")
	check(model.start_survey().is_empty(),"Orbital chart can be started during the encounter")
	for i: int in range(12): model.tick(40)
	check(not model.salvage(11).is_empty(),"Salvage checks physical reach")
	model.state.energy = 19
	before = model.state.duplicate(true)
	check(not model.salvage(8).is_empty() and model.state == before,"Low energy cannot acquire equipment")
	model.state.energy = 100
	check(model.salvage(8).is_empty() and model.state.shroud_unlocked and model.state.energy == 80,"Salvage spends energy and unlocks a usable shroud")
	model.change_flight_mode("surface")
	before = model.state.duplicate(true)
	check(not model.toggle_shroud().is_empty() and model.state == before,"Orbit-only shield cannot drain power on the surface")
	model.change_flight_mode("orbit")
	before = model.state.duplicate(true)
	check(not model.salvage(8).is_empty() and model.state == before,"Wreck cannot be farmed for repeat rewards")
	check(model.toggle_shroud().is_empty() and model.state.shroud_on,"Recovered shroud can be engaged by command")
	for i: int in range(6): model.tick(0)
	check(model.state.hull == 77,"Active shroud reduces pulse damage from 18 to 5")
	check(model.state.energy < 80,"Shielding drains actual energy over time")
	model.state.energy = 0
	model.tick(40)
	check(not model.state.shroud_on,"Shroud disengages when remaining energy cannot cover upkeep")
	before = model.state.duplicate(true)
	check(not model.repair(0).is_empty() and model.state == before,"Repair cannot be used inside the pulse field")
	check(not model.repair(NAN).is_empty() and model.state == before,"Invalid ship position cannot bypass repair safety")
	model.state.energy = 100
	check(model.repair(40).is_empty() and model.state.hull == 100 and model.state.energy == 70,"Safe repair consumes energy and restores bounded hull")
	model.state.hull = 50
	before = model.state.duplicate(true)
	check(not model.repair(40).is_empty() and model.state == before,"Cooldown prevents repeat repair")
	for i: int in range(Model.REPAIR_COOLDOWN): model.tick(40)
	check(model.repair(40).is_empty() and model.state.hull == 85,"Repair becomes available after fixed cooldown")
	model.state.hull = 15
	model.state.energy = 100
	for i: int in range(6): model.tick(0)
	check(model.state.tow_count == 1 and model.state.hull == 35 and model.state.energy <= 15,"Defeat triggers a costly, recoverable emergency tow")
	check(model.state.position == [0.0,8.0,35.0],"Emergency tow returns the ship to a safe orbit position")
	var path: String = "res://artifacts/orbital_threat.json"
	model.save_to(path)
	var restored := Model.new()
	check(restored.load_from(path) == OK and restored.state == model.state,"Hull, shroud, repair timer and losses persist through save/load")
	for i: int in range(20): restored.tick(40)
	check(not restored.repair(40).is_empty(),"Waiting after defeat does not refill repair energy")
	restored.recharge("orbit_tender",Model.service_position("orbit_tender"))
	check(restored.repair(40).is_empty() and restored.state.hull == 70,"Docking supplies energy needed to repair after defeat")
	var legacy: Dictionary = Model.fresh()
	legacy.version = 3
	for key: String in ["hull","shroud_unlocked","shroud_on","threat_clock","tow_count","last_repair_at"]: legacy.erase(key)
	legacy.marks = 72
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	check(restored.load_from(path) == OK and restored.state.hull == 100 and restored.state.marks == 72,"Version 3 saves migrate without losing currency or past field progress")
	var invalid: Dictionary = restored.state.duplicate(true)
	invalid.shroud_on = true
	file = FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify(invalid))
	file.close()
	before = restored.state.duplicate(true)
	check(restored.load_from(path) == ERR_INVALID_DATA and restored.state == before,"Invalid equipment ownership cannot overwrite current save")
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	scene.set_physics_process(false)
	scene.audio.muted = true
	scene.model = Model.new()
	scene.model.state.survey_ticks = 12
	scene._change_flight_mode("orbit")
	scene._refresh_ui()
	check(scene.hud.navigation.wreck_known and scene.hud.use_button.text == "Salvage","Completed chart exposes a clickable salvage contact")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = scene.hud.navigation.project(Vector2(Orbit.WRECK_POSITION.x,Orbit.WRECK_POSITION.z))
	scene.hud.navigation._gui_input(click)
	check(scene.salvage_order and scene.navigating,"Wreck click orders actual ship travel")
	scene._hud_action("stop")
	check(not scene.salvage_order and scene.salvage_progress == 0,"Stop cancels approach without acquiring salvage")
	scene._command_wreck()
	for i: int in range(720):
		scene._physics_process(1.0/60)
		scene._process(1.0/60)
		if scene.model.state.shroud_unlocked: break
	check(scene.model.state.shroud_unlocked and not scene.salvage_order,"Physical approach and work acquire the shroud once")
	check(scene.model.state.hull < 100,"Recovery path exposes the scout to danger during approach")
	scene._hud_action("shroud")
	check(scene.model.state.shroud_on,"Clickable ship control engages acquired equipment")
	scene._toggle_pause()
	before = scene.model.state.duplicate(true)
	scene._hud_action("shroud")
	scene._hud_action("repair")
	check(scene.model.state == before,"Paused ship controls cannot change hull, energy or equipment")
	scene._toggle_pause()
	scene._refresh_ui()
	scene._update_visuals()
	check(scene.hud.hull_bar.value == scene.model.state.hull and scene.model.state.shroud_on and scene.shroud_ring.visible,"Ship instruments reflect actual danger and defense state")
	scene.queue_free()
	await process_frame
	print("Orbital threat checks: %d, failures: %d" % [checks,failures])
	quit(1 if failures else 0)
