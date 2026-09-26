extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
const Chart = preload("res://scripts/system_chart.gd")
var checks: int = 0
var failures: int = 0
var departures: Array = []
var sectors: int = 0
var returns: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+label)
func pilot() -> RefCounted:
	var game := Session.new(); game.field.state = Field.fresh("s2p0"); game.field.bind_account(game.sector.state); game.field.change_flight_mode("orbit")
	game.sector.system_by_id("s2").visited = true; game.configure_flagship(); game.climate.bind(game)
	return game
func press(scene: Node, code: Key) -> void:
	var event := InputEventKey.new(); event.physical_keycode = code; event.pressed = true; scene._unhandled_input(event)
func click(chart: Control, id: String) -> void:
	var event := InputEventMouseButton.new(); event.button_index = MOUSE_BUTTON_LEFT; event.pressed = true
	event.position = chart.camera.unproject_position(chart.bodies[id].position); chart._view_input(event)
func run() -> void:
	var home := Session.new(); home.field.state.flight_mode = "orbit"; home.configure_flagship()
	var home_chart := Chart.new(); root.add_child(home_chart); await process_frame
	check(home_chart.present(home) and home_chart.bodies.size() == 3,"The Morrow system presents two planets and its moon as actual chart bodies")
	check(home_chart.bodies.has_all(["morrow","s0p1","s0p2"]) and home_chart.bodies.s0p2.planet_definition.body_kind == "moon","Morrow's moon uses its own stable destination identity and body type")
	check(is_equal_approx(home_chart.bodies.s0p2.position.distance_to(home_chart.bodies.morrow.position),Chart.MOON_ORBIT_RADIUS),"The moon follows a local orbit around Morrow inside the system map")
	var local_offer: Dictionary = home.quote("s0p1")
	check(local_offer.reason.is_empty() and home.begin_travel("s0p1").is_empty(),"A new Morrow-system planet accepts a real in-system departure")
	for i: int in range(int(local_offer.seconds)): home.advance_travel()
	check(home.field.state.planet_id == "s0p1" and home.worlds.has("morrow"),"In-system arrival preserves Morrow as a separate revisitable world")
	var resumed := Session.new()
	check(resumed.restore_snapshot(home.snapshot()) == OK and resumed.field.state.planet_id == "s0p1" and resumed.worlds.has("morrow"),"New local destination and return world survive campaign save restoration")
	home_chart.free()
	var game: RefCounted = pilot(); var chart := Chart.new(); root.add_child(chart); await process_frame
	chart.travel_requested.connect(func(id: String) -> void: departures.append(id))
	chart.sector_requested.connect(func() -> void: sectors += 1)
	chart.orbit_requested.connect(func() -> void: returns += 1)
	var before: Dictionary = game.snapshot()
	check(chart.present(game) and chart.visible and chart.bodies.size() == 3,"Known system displays all three actual orbital bodies")
	check(game.snapshot() == before,"Opening and inspecting a system cannot reveal, spend or duplicate simulation state")
	check(chart.bodies.s2p0.planet_definition.id == "s2p0" and chart.bodies.s2p1.planet_definition.id == "s2p1","Each system body uses its own shared seeded geography")
	check(not chart.bodies.s2p0.site_marker.visible and not chart.details.text.contains("ecosystem"),"Unsurveyed worlds do not expose landing markers or ecological readings")
	game.field.state.survey_ticks = game.field.definition().survey_seconds; chart.refresh()
	check(chart.bodies.s2p0.site_marker.visible and chart.details.text.contains("ecosystem"),"Real completed survey reveals the known landing marker and conditions")
	chart.select_planet("s2p1")
	check(not chart.travel.disabled and "3 energy" in chart.travel.text and "2 seconds" in chart.travel.text,"In-system destination quote uses actual shared drive cost and time")
	check(chart.details.text.contains("Orbital destination") and not chart.bodies.s2p1.site_marker.visible,"Nonlandable planets remain real orbital destinations without fabricated surface sites")
	before = game.snapshot(); chart.select_planet("s2p2"); chart.refresh()
	check(game.snapshot() == before and not game.worlds.has("s2p2"),"Selection and repeated presentation cannot fabricate visits")
	check(not chart.present(game,"s8") and chart.system_id == "s2","Unknown system preview is rejected without replacing the visible system")
	game.sector.system_by_id("s8").charted = true
	check(chart.present(game,"s8") and chart.bodies.size() == 3 and not game.sector.system_by_id("s8").visited,"Diplomatic charts permit inspection without inventing a visit")
	chart.present(game,"s2"); chart.select_planet("s2p1")
	chart.locked = true; chart.refresh(); click(chart,"s2p1")
	check(departures.is_empty() and chart.travel.disabled,"Paused controls cannot issue departure commands")
	chart.locked = false; chart.refresh(); click(chart,"s2p1")
	check(departures == ["s2p1"],"One actual 3D body click requests exactly one destination")
	game.field.state.energy = 2; chart.refresh(); chart.activate_selected()
	check(departures.size() == 1 and chart.travel.disabled and "Need 3 energy" in chart.status.text,"Insufficient fuel is shown and blocks departure without a request")
	game.field.state.energy = 100; chart.select_planet("s2p0"); click(chart,"s2p0")
	check(returns == 1 and departures.size() == 1,"Clicking the current planet returns to the ship without charging a voyage")
	chart.key(KEY_KP_6); check(chart.selected_planet == "s2p1","Left-handed numpad selection reaches the next planet")
	chart.key(KEY_LEFT); check(chart.selected_planet == "s2p0","Arrow selection reaches the previous planet")
	chart.target_distance = 112; chart.zoom(1); check(sectors == 1,"Outward system zoom enters the sector hierarchy")
	chart.target_distance = 19; chart.zoom(-1); check(returns == 2,"Inward zoom into the current planet returns to orbital flight")
	chart.select_planet("s2p1"); chart.target_distance = 19; chart.zoom(-1)
	check(departures.size() == 1,"Camera zoom alone cannot charge travel to a different planet")
	chart.key(KEY_HOME); check(chart.target_distance == 110,"Home frames all three planets and the seeded asteroid belt")
	var press_drag := InputEventMouseButton.new(); press_drag.button_index = MOUSE_BUTTON_RIGHT; press_drag.pressed = true; chart._view_input(press_drag)
	var motion := InputEventMouseMotion.new(); motion.relative = Vector2(24,12); var yaw: float = chart.yaw; chart._view_input(motion)
	check(chart.yaw != yaw,"Right-drag rotates the actual 3D system camera")
	chart.hide(); check(chart.viewport.render_target_update_mode == SubViewport.UPDATE_DISABLED,"Hidden system view stops its separate rendering workload")
	chart.free()
	# Real flight controller, local transit, pause/save/load and destination reconstruction.
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); scene.name = "SystemFlight"; scene.campaign = pilot(); root.add_child(scene)
	await process_frame; scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true; scene.save_path = "res://artifacts/system_chart_scene.fw"
	scene.hud.system_button.pressed.emit()
	check(scene.system_map.visible and not scene.sector_map.visible and not scene.hud.navigation.visible,"HUD system control opens the correct scale without a surface local chart")
	before = scene.campaign.snapshot(); scene._process(2)
	check(scene.campaign.snapshot() == before,"Idle system inspection uses the existing explicit pause policy")
	scene._show_popup("menu"); scene.system_map.select_planet("s2p1"); scene.system_map.activate_selected(); scene._launch_journey("s2p1")
	check(not scene.campaign.traveling() and scene.model.state.energy == 100,"Fresh modal opening blocks both view and controller departures before a refresh")
	scene._close_popup()
	scene.system_map.select_planet("s2p1"); scene.system_map.travel.pressed.emit()
	check(scene.campaign.traveling() and scene.model.state.energy == 97 and scene.system_map.close.disabled,"Actual system departure charges once and locks return during transit")
	var origin: Vector3 = scene.system_map.ship_marker.position
	scene._process(1)
	check(scene.campaign.sector.state.flagship.remaining == 1 and scene.system_map.ship_marker.position != origin,"The same campaign clock advances the rendered interplanetary voyage")
	check(scene.hud.paused_badge.text == "IN TRANSIT","HUD does not mislabel the active travel clock as paused")
	press(scene,KEY_ESCAPE); var clock: int = scene.model.state.time; scene._process(2)
	check(scene.popup_kind == "menu" and scene.model.state.time == clock,"Escape opens pause/save during transit and stops the shared clock")
	scene._save(false)
	var loaded := Session.new(); var path: String = scene._campaign_path(true)
	check(loaded.load_from(path) == OK and loaded.sector.state.flagship.remaining == 1,"Mid-transfer autosave preserves the real remaining journey")
	scene._close_popup(); scene._process(4); await process_frame; await process_frame
	scene = root.get_node("SystemFlight"); scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	check(scene.model.state.planet_id == "s2p1" and scene.model.state.energy == 97 and scene.orbit.planet.planet_definition.id == "s2p1","Arrival rebuilds destination orbit without a second charge")
	check(scene.campaign.worlds.has("s2p0") and not scene.system_map.visible,"Arrival retains the old world and returns to playable orbital flight")
	scene.camera_distance_target = scene.ORBIT_ZOOM_MAX; scene._zoom_camera(1)
	check(scene.system_map.visible and not scene.sector_map.visible,"Orbital zoom out reaches the system before the sector")
	scene.system_map.target_distance = 115; scene.system_map.zoom(1)
	check(scene.sector_map.visible and not scene.system_map.visible,"System zoom out opens the sector and closes the previous scale")
	scene.sector_map.select_system("s2"); scene.sector_map.inspect_system.pressed.emit()
	check(scene.system_map.visible and scene.system_map.system_id == "s2","Known star's View system control enters its actual system view")
	press(scene,KEY_J); check(not scene.system_map.visible,"J closes the idle system view")
	scene._open_system_view("s9"); check(not scene.system_map.visible,"The controller also rejects previews of uncharted systems")
	scene._open_system_view("s2"); scene._toggle_pause(); var bank: float = scene.model.state.energy
	scene.system_map.select_planet("s2p2"); scene.system_map.activate_selected()
	check(not scene.campaign.traveling() and scene.model.state.energy == bank,"Explicit pause cannot be bypassed through the system controller")
	scene._toggle_pause(); scene._close_system_view()
	scene.free()
	scene = load("res://scenes/encounter.tscn").instantiate(); scene.campaign = Session.new(); root.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	scene._toggle_system_view()
	check(not scene.hud.navigation.visible,"System preview never exposes a surface local chart even when opened planetside")
	scene._close_system_view(); check(scene.hud.navigation.visible,"Closing the preview restores the local chart on the surface")
	scene.free()
	# Restored local voyages choose the system view automatically and continue normally.
	var restored_scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); restored_scene.campaign = loaded; root.add_child(restored_scene)
	restored_scene.set_process(false); restored_scene.set_physics_process(false); restored_scene.audio.muted = true
	check(restored_scene.system_map.visible and not restored_scene.sector_map.visible,"Restored in-system transfer resumes at the correct navigation scale")
	restored_scene.free()
	print("System chart assertions: %d; failures: %d" % [checks,failures]); quit(1 if failures else 0)
