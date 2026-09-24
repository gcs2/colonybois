extends SceneTree
## Actual scene integration: coverage, controls, modal ordering and surface docking.
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("FAIL: "+text)
func run() -> void:
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = Session.new(); root.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	scene.save_path = "res://artifacts/fullscreen-test.json"
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3440,1440)]:
		root.size = resolution
		for mode: String in ["planet","system","sector"]:
			scene.planet_map.hide(); scene.system_map.hide(); scene.sector_map.hide()
			scene.model.change_flight_mode("orbit"); scene._apply_flight_mode()
			var view: Control
			var world: Control
			if mode == "planet": scene._toggle_planet_map(); view = scene.planet_map; world = view.preview
			elif mode == "system": scene._open_system_view("s0"); view = scene.system_map; world = view.preview
			else: scene._toggle_sector_map(); view = scene.sector_map; world = view.graph
			await process_frame; await process_frame; scene._refresh_ui()
			var canvas_size: Vector2 = scene.hud.get_parent().size
			check(view.position.is_equal_approx(Vector2.ZERO) and view.size.is_equal_approx(canvas_size),"Navigation covers canvas: %s %s" % [mode,resolution])
			check(world.get_global_rect().is_equal_approx(view.get_global_rect()),"World canvas fills view, not a smaller preview: "+mode)
			check(not scene.hud.visible and not scene.hud.navigation.is_visible_in_tree(),"Flight controls/local radar hidden in "+mode)
			var stage: Control = view.get_node("NavigationStage")
			for child: Node in stage.get_children():
				if (child is PanelContainer or child is HBoxContainer) and child.is_visible_in_tree():
					check(view.get_global_rect().grow(1).encloses(child.get_global_rect()),"Navigation instruments stay inside full screen: "+mode)
			scene._show_popup("menu"); await process_frame
			check(scene.popup.z_index > view.z_index and scene.menu_shade.z_index > view.z_index,"Escape menu renders above full-screen map")
			scene._close_popup()
	scene.sector_map.present(scene.campaign); await process_frame
	var graph: Control = scene.sector_map.graph
	var anchor: Vector2 = graph.point(scene.campaign.sector.system_by_id("s0"))
	var wheel := InputEventMouseButton.new(); wheel.position = anchor; wheel.button_index = MOUSE_BUTTON_WHEEL_UP; wheel.pressed = true
	graph._gui_input(wheel)
	check(graph.magnification > 1 and graph.point(scene.campaign.sector.system_by_id("s0")).distance_to(anchor) < 0.01,"Galaxy wheel zoom anchors the star under the cursor")
	var right := InputEventMouseButton.new(); right.button_index = MOUSE_BUTTON_RIGHT; right.pressed = true; graph._gui_input(right)
	var motion := InputEventMouseMotion.new(); motion.relative = Vector2(45,-30); var pan: Vector2 = graph.pan; graph._gui_input(motion)
	check(graph.yaw != 0 and graph.pitch != 0.58,"Galaxy right-drag orbits around the galactic plane")
	right.shift_pressed = true; graph._gui_input(right); graph._gui_input(motion)
	check(graph.pan == pan+motion.relative,"Shift-right-drag pans independently of orbit")
	graph.reset_view(); check(graph.pan == Vector2.ZERO and graph.magnification == 1,"Frame sector restores a usable overview")
	# The original interaction had an untyped ternary Array that threw before flying.
	scene.sector_map.hide(); scene.system_map.hide(); scene.planet_map.hide()
	scene.model.change_flight_mode("surface"); scene._apply_flight_mode(); scene._restore_ship()
	scene._approach_service("basin_port")
	check(scene.navigating and scene.service_order == "basin_port","Surface docking starts an actual approach without a typed-array exception")
	for i: int in range(900): scene._physics_process(1.0/60)
	check(scene.popup.visible and scene.popup_kind == "service" and scene.ship.position.distance_to(Field.service_position("basin_port")) < 5,"Surface docking reaches the port and opens real services")
	scene._close_popup(); scene._refresh_ui()
	check(scene.hud.visible,"Flight HUD returns after leaving full-screen navigation")
	scene.free()
	print("Full-screen navigation assertions: %d; failures: %d" % [checks,failures]); quit(1 if failures else 0)
