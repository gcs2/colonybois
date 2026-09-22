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
	scene._select_tool("habitat")
	var before_materials: float = scene.sim.state.colonies.s0p0.materials
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = scene.camera.unproject_position(Vector3(8.5,0,2.5))
	scene._unhandled_input(press)
	check(not scene.sim.state.colonies.s0p0.cells.has("40,34"),"Dragging a zone does not construct before release")
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.position = scene.camera.unproject_position(Vector3(10.5,0,3.5))
	scene._unhandled_input(release)
	check(scene.sim.state.colonies.s0p0.cells.has("42,35") and scene.sim.state.colonies.s0p0.cells.has("40,34"),"Drag release designates the whole rectangle")
	check(scene.sim.state.colonies.s0p0.materials == before_materials,"UI zoning is free")
	scene.city_section = "ledger"
	scene._refresh_right()
	scene.city_section = "services"
	scene._refresh_right()
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
	check(scene.sim.state.settlements.has("s1p0"),"Landing project is visible before founding completes")
	for i: int in range(18): scene.sim.tick()
	check(is_instance_valid(scene.colony_site_marker) and scene.colony_site_marker.get_parent() == scene.overview_globe,"Site marker shares the globe transform")
	var local_site: Vector3 = scene.colony_site_marker.position
	scene.overview_globe.rotate_y(0.7)
	check(scene.colony_site_marker.position == local_site and scene.colony_site_marker.global_position.distance_to(local_site) > 1.0,"Rotating the globe carries the colony marker with its surface")
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
	check(scene.speed == 0 and scene.sim.state.urban.tutorial_step == 0,"Urban introduction begins paused at the observation step")
	check(not scene.build_panel.visible,"Construction drawer starts closed")
	scene._inspect_crossing()
	check(scene.overlay == "access" and scene.selected_cell == Vector2i(32,32),"Tutorial inspection selects the damaged tile and access layer")
	check(scene.sim.state.urban.tutorial_step == 1,"Inspection reveals the next tutorial step")
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
