extends SceneTree
const Equipment = preload("res://scripts/equipment_catalog.gd")
const Model = preload("res://scripts/encounter_state.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1; printerr("FAIL: "+message)

func run() -> void:
	var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(Equipment.PATH))
	check(Equipment.validate(source).is_empty(),"Authored catalog resolves its actual icons and handlers")
	check(Equipment.ids() == ["scan","collect","warm","seed"],"Existing hotbar order remains stable")
	for broken: Variant in [null, [], {"version":2,"tools":[]}, {"version":1,"tools":[null]}]:
		check(not Equipment.validate(broken).is_empty(),"Malformed document is rejected without a parser crash")
	for change: Dictionary in [{"id":"scan"},{"id":"fake_weapon"},{"seconds":0},{"reach":-1},{"energy":"free"},{"samples":0.5},{"icon":"res://missing.svg"},{"color":"no-color"},{"targets":["unknown"]},{"requires_scan":"yes"}]:
		var broken: Dictionary = source.duplicate(true)
		broken.tools[1].merge(change,true)
		check(not Equipment.validate(broken).is_empty(),"Reject invalid tool fields: "+str(change))
	var copy: Dictionary = Equipment.definition("scan")
	copy.targets.clear()
	copy.energy = 90
	var groups: Dictionary = Equipment.groups()
	groups.Survey.clear()
	check(Equipment.value("scan","targets").size() == 4 and Equipment.energy("scan") == 0 and Equipment.groups().Survey.size() == 1,"Public catalog data cannot mutate cached rules")
	var model := Model.new()
	var before: Dictionary = model.state.duplicate(true)
	check(not model.act("fake_weapon","relay",1).is_empty() and model.state == before,"Unsupported tools cannot mutate saves or spend resources")
	check(not model.act("scan","relay",13.01).is_empty() and model.act("scan","relay",13).is_empty(),"Exact catalog range boundary is enforced")
	# Change authored tuning in memory, then verify independent consumers use it.
	# Restore the cache before ending; no source or user save is changed.
	var original: Dictionary = Equipment.definition("warm")
	Equipment._entries.warm.energy = 31.0
	Equipment._entries.warm.seconds = 4.0
	Equipment._entries.warm.reach = 18.0
	model.act("scan","bed",1)
	model.state.energy = 30
	before = model.state.duplicate(true)
	check(model.act("warm","bed",17).begins_with("Need 31 energy") and model.state == before,"Changed catalog cost rejects atomically at the new reach")
	model.state.energy = 100
	check(model.act("warm","bed",17).is_empty() and model.state.energy == 69,"Command spends the catalog cost exactly once")
	check(not model.act("warm","bed",17).is_empty() and model.state.energy == 69,"Repeated action cannot spend twice")
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	scene.set_physics_process(false)
	scene.audio.muted = true
	scene._select_tool("warm")
	check("18 m" in scene.hud.tool_spec.text and "31 energy" in scene.hud.tool_spec.text,"HUD displays changed command costs and reach")
	scene.selected = "bed"
	scene.model.act("scan","bed",0)
	scene.ship.position = scene._target_position()+Vector3(0,8,0)
	scene.held = true
	scene._operate(1.0)
	check(is_equal_approx(scene.progress,0.25) and scene.model.state.energy == 100,"Tool cycle uses catalog timing and charges only on completion")
	scene._stop()
	check(scene.model.state.energy == 100 and not scene.model.state.warm,"Cancellation before completion keeps energy and target intact")
	scene._select_tool("missing")
	check(scene.tool == "warm","Invalid equipment selection leaves the working tool intact")
	Equipment._entries.warm = original
	scene._select_tool("warm")
	check("25 energy" in scene.hud.tool_spec.text,"Original tuning restored for later tests")
	scene.queue_free()
	await process_frame
	print("Equipment checks: %d, failures: %d" % [checks,failures])
	quit(1 if failures else 0)
