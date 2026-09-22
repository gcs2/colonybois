extends SceneTree
var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, text: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + text)

func run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.speed = 0
	scene._update_camera(1)
	var count: int = scene.sim.state.colonies.s0p0.cells.size()
	scene.tool_buttons.road.pressed.emit()
	var screen: Vector2 = scene.camera.unproject_position(Vector3(6.5,0,-0.5))
	scene._click_colony(screen)
	check(scene.sim.state.colonies.s0p0.cells.size() == count+1,"Screen picking places a road on the intended tile")
	check(scene.sim.state.colonies.s0p0.cells.has("38,31"),"World-to-grid mapping is correct")
	var initial_credits: float = scene.sim.state.credits
	scene.view_buttons.galaxy.pressed.emit()
	check(scene.view == "galaxy","Galaxy navigation button changes view")
	scene.sim.tick()
	check(scene.sim.state.credits != initial_credits,"Economy continues outside colony view")
	scene._select_system("s1")
	scene._command("travel",{"system":"s1"})
	for i: int in range(6): scene.sim.tick()
	scene._select_planet("s1p0")
	check(scene.view == "planet","Planet selection opens survey")
	scene._command("colonize",{"planet":"s1p0"})
	scene.view_buttons.colony.pressed.emit()
	check(scene.view == "colony" and scene.planet_id == "s1p0","New colony accessible through UI")
	scene._set_overlay("access")
	check(scene.overlay == "access","Access overlay renders")
	scene._set_overlay("suitability")
	check(scene.overlay == "suitability","Suitability overlay renders")
	scene.speed_buttons[3].pressed.emit()
	check(scene.speed == 3,"Time controls work")
	scene.speed_buttons[0].pressed.emit()
	check(scene.speed == 0,"Pause works")
	scene._show_mode_menu()
	check(is_instance_valid(scene.mode_menu),"Mode menu can open during play")
	scene._start_mode("sandbox",false)
	check(scene.sim.state.mode == "sandbox" and not is_instance_valid(scene.mode_menu),"Sandbox can start from the menu")
	scene._command("cheat",{"ability":"reveal"})
	check(scene.sim.system_by_id("s11").visited,"Sandbox UI command reveals the galaxy")
	scene._show_mode_menu()
	scene._start_mode("expedition",false)
	check(scene.sim.state.mode == "expedition" and not scene.sim.is_revealed("s11"),"New expedition restores fog without cheat leakage")
	scene._start_mode("urban",false)
	check(scene.sim.state.mode == "urban" and scene.sim.state.has("urban"),"Urban scenario starts through the mode menu")
	scene._inspect_crossing()
	check(scene.overlay == "access" and scene.selected_cell == Vector2i(32,32),"Tutorial inspection selects the damaged tile and access layer")
	scene._command("civic",{"choice":"public"})
	scene._switch_view("galaxy")
	for i: int in range(8): scene.sim.tick()
	check(scene.sim.state.urban.repaired,"Civic work continues in galaxy view")
	scene._open_colony("s0p0")
	check(scene.sim.state.colonies.s0p0.connected.has("35,27"),"Returning to city preserves the repaired network")
	scene._start_mode("urban",false)
	scene._inspect_crossing()
	var access_before: String = scene.last_access_signature
	scene._command("civic",{"choice":"sponsor"})
	scene.sim.tick()
	scene.sim.tick()
	check(scene.last_access_signature != access_before,"Access layer invalidates on repair while the city remains visible")
	scene._inspect_growth_zone()
	var target: String = scene.Simulation.key(scene.selected_cell.x,scene.selected_cell.y)
	check(scene.sim.state.colonies.s0p0.reasons.get(target,"") == "Ready to grow","Tutorial helper selects an eligible priority target")
	await process_frame
	print("UI RESULT: %d failures" % failures)
	scene.queue_free()
	await process_frame
	quit(1 if failures else 0)
