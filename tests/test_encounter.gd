extends SceneTree
const Model = preload("res://scripts/encounter_state.gd")
var failures: int = 0
var checks: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1; printerr("FAIL: "+message)

func grow(model: RefCounted) -> void:
	model.act("scan","pod",4)
	model.act("collect","pod",4)
	model.act("scan","bed",4)
	model.act("warm","bed",4)
	model.act("seed","bed",4)
	for i: int in range(21): model.tick()

func run() -> void:
	var model := Model.new()
	var initial: Dictionary = model.state.duplicate(true)
	check(not model.act("collect","pod",4).is_empty(),"Unknown biology cannot be sampled")
	check(not model.act("scan","pod",14).is_empty(),"Tools enforce reach")
	check(not model.act("scan","pod",NAN).is_empty(),"Nonfinite distance is rejected")
	check(model.state == initial,"Rejected actions do not mutate anything")
	check(model.act("scan","pod",4).is_empty(),"Scan succeeds in range")
	check(not model.act("scan","pod",4).is_empty() and model.state.history.size() == 1,"Repeat scan cannot duplicate chronicle rewards")
	model.act("collect","pod",4)
	model.act("collect","pod",4)
	check(model.state.samples == 2 and model.state.native_stock == 1,"Sampling conserves seed stock")
	check(not model.act("collect","pod",4).is_empty(),"Last wild feeding reserve is protected")
	model.act("scan","bed",4)
	check(not model.act("seed","bed",4).is_empty(),"Cold soil rejects deployment without spending samples")
	model.state.energy = 24
	check(not model.act("warm","bed",4).is_empty() and not model.state.warm,"Thermal action enforces energy cost")
	model.state.energy = 100
	model.act("warm","bed",4)
	check(model.state.energy == 75,"Warming spends 25 energy once")
	check(not model.act("warm","bed",4).is_empty() and model.state.energy == 75,"Repeat warming cannot double spend")
	model.act("seed","bed",4)
	check(model.state.samples == 1 and model.state.seeded,"Planting consumes an actual sample")
	check(not model.set_route(true).is_empty(),"Immature harvest cannot start a contract")
	var other := Model.new()
	other.state = model.state.duplicate(true)
	for i: int in range(60): model.tick(); other.tick()
	check(model.state == other.state,"Fixed ticks reproduce ecology and stock")
	check(model.state.growth == 1 and model.state.produce > 0,"Growth completes and produces usable goods")
	check(model.set_route(true).is_empty(),"Mature cultivation enables a standing order")
	for i: int in range(200): model.tick()
	check(model.state.marks == 108 and model.state.buyer_remaining == 0,"Six actual deliveries pay exactly six times 18 Marks")
	check(not model.state.route and model.state.produce >= 1,"Finite order ends and preserves local reserve")
	check(model.state.produce <= 8,"Harvest storage is bounded")
	check(not model.sell().is_empty() and model.state.marks == 108,"No sales after demand exhaustion")
	var path: String = "res://artifacts/encounter_test.json"
	check(model.save_to(path) == OK,"Snapshot writes")
	var restored := Model.new()
	check(restored.load_from(path) == OK and restored.state == model.state,"Snapshot preserves routes, ecology, stock and history")
	for i: int in range(30): model.tick(); restored.tick()
	check(restored.state == model.state,"Save continuation stays deterministic")
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string('{"version":1}')
	file.close()
	var before: Dictionary = restored.state.duplicate(true)
	check(restored.load_from(path) == ERR_INVALID_DATA and before == restored.state,"Malformed saves leave current progress intact")
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	scene.set_physics_process(false)
	scene.model = Model.new()
	scene.save_path = "res://artifacts/field_ui_test.json"
	scene.ship.position = scene._target_position("pod")+Vector3(0,3,3)
	scene._update_camera(1)
	scene._pick(scene.camera.unproject_position(scene._target_position("pod")))
	check(scene.selected == "pod","Screen picking selects the intended subject")
	scene.held = true
	scene._operate(0.5)
	check(not ("pod" in scene.model.state.scanned) and scene.progress > 0,"Partial tool hold makes progress without committing")
	scene.held = false
	scene._operate(0.1)
	check(scene.progress == 0 and scene.model.state.scanned.is_empty(),"Releasing cancels operation without side effects")
	scene.held = true
	scene._operate(2)
	check("pod" in scene.model.state.scanned,"Completed tool hold commits through validation")
	scene._select_tool("collect")
	scene.use_button.pressed.emit()
	scene._operate(2)
	check(scene.model.state.samples == 1,"Accessible operate button activates the selected tool")
	scene._operate(2)
	check(scene.model.state.samples == 1,"Completed hold cannot collect repeatedly")
	scene._select_tool("scan")
	scene.selected = "bed"
	scene.ship.position = scene._target_position("bed")+Vector3(0,3,3)
	scene.held = true
	scene._operate(2)
	scene._select_tool("warm")
	scene.held = true
	scene._operate(4)
	scene._select_tool("seed")
	scene.held = true
	scene._operate(2)
	for i: int in range(25): scene.model.tick()
	scene._update_visuals()
	check(scene.relay_light.visible and scene.grown_plants[0].visible and scene.grown_plants[0].scale.x > 0.5,"Real ecology state drives visible bloom and relay response")
	scene._save()
	scene.model.state.marks = 999
	scene._load()
	check(scene.model.state.marks == 0,"UI manual restore restores economy")
	scene._show_popup("contact")
	check(scene.popup.visible and scene.popup_body.get_child_count() >= 5,"Contact exposes actual order terms")
	scene._show_popup("journal")
	check(scene.popup.visible,"Journal renders committed history")
	var motion: RefCounted = scene.grazer_motion[0]
	check(motion.eyes.size() == 3 and is_instance_valid(motion.fin_left),"Export retains independent eye and fin pivots")
	var at: Vector3 = motion.actor.position
	motion.alarm = 0
	motion.advance(0.1,at+Vector3(0,0,7))
	check(motion.mode == "curious","Grazer notices a nearby scout")
	motion.react("warm",motion.actor.position)
	motion.advance(0.1,at+Vector3(0,0,7))
	check(motion.mode == "startled" and motion.curl > 0,"Thermal tool causes recoil and tendril curl")
	for i: int in range(360): motion.advance(1.0/60.0,Vector3(60,20,60))
	check(motion.mode == "foraging","Grazer settles after disturbance expires")
	check(motion.actor.position.distance_to(at) < 25,"Ambient movement stays bounded")
	check(motion.tendril_material != scene.grazer_motion[1].tendril_material,"Characters have independent animation uniforms")
	motion.blink_start = motion.age
	motion.next_blink = motion.age+5
	motion.advance(0.1,Vector3(60,20,60))
	check(motion.eyes[0].scale.y < 0.3,"Blink closes an independent eye")
	var frozen_age: float = motion.age
	motion.advance(0,Vector3.ZERO)
	check(motion.age == frozen_age,"Zero-time update does not advance animation")
	scene.free()
	var main: Node3D = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main.speed = 0
	var campaign: Dictionary = main.sim.state.duplicate(true)
	main._open_field()
	await process_frame
	check(not main.is_inside_tree(),"Entering isolated field suspends original session")
	var field: Node = root.get_child(root.get_child_count()-1)
	check(field.get_script() == load("res://scripts/encounter.gd"),"Menu loads the field scene")
	field.leave.emit()
	await process_frame
	check(main.is_inside_tree() and main.sim.state == campaign,"Return preserves original campaign exactly")
	main.free()
	print("Encounter assertions: ",checks,"; failures: ",failures)
	quit(0 if failures == 0 else 1)
