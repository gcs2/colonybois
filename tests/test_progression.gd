extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Recognition = preload("res://scripts/expedition_progression.gd")
const Climate = preload("res://scripts/planet_climate.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+label)
func run() -> void:
	var game := Session.new()
	check(game.commerce.state.badges.size() == 10 and Recognition.points(game.commerce.state.badges) == 0,"Fresh campaign starts with ten empty accomplishment families and no free recognition")
	for id: String in ["moss_lantern","ribbon_bush","hollow_crown"]:
		check(game.biosphere.act(game,id,"scan",game.biosphere.site("morrow",id)).is_empty(),"Real specimen scan accepted: "+id)
	check(game.commerce.state.badges.naturalist == 1 and game.commerce.eligible("hold"),"Distinct local observations unlock a peaceful hold path without travel or deliveries")
	check(game.commerce.state.upgrades.is_empty() and game.field.state.energy == 100,"Recognition never grants free equipment or spends energy for scans")
	var points: int = Recognition.points(game.commerce.state.badges); var events: int = game.diplomacy.state.events.size()
	game.biosphere.act(game,"moss_lantern","scan",game.biosphere.site("morrow","moss_lantern")); game.commerce.update_badges(game)
	check(Recognition.points(game.commerce.state.badges) == points and game.diplomacy.state.events.size() == events,"Repeat scans and evaluation cannot farm points or chronicle awards")
	var dock: Vector3 = game.field.service_position("basin_port")
	check(game.commerce.buy_upgrade(game,"basin_port",dock,"hold") == "Insufficient Marks.","Badge eligibility is not a free purchase")
	game.field.marks = 120
	check(not game.commerce.buy_upgrade(game,"basin_port",Vector3(100,100,100),"hold").is_empty(),"The badge path still requires physical dock access")
	check(game.commerce.buy_upgrade(game,"basin_port",dock,"hold").is_empty() and game.field.marks == 0 and game.commerce.capacity() == 16,"Earned alternate path purchases and uses real expanded hold")
	game.field.change_flight_mode("orbit")
	check(game.field.start_survey().is_empty(),"Real orbital survey begins")
	for i: int in range(12): game.tick()
	check(game.commerce.state.badges.surveyor == 1,"Actual survey completion earns Cartographer once")
	var faction: Dictionary = game.sector.state.factions[0]; var id: String = faction.id
	faction.contacted = true; faction.relation = 70; faction.embargo = false
	check(game.diplomacy.act(game,id,"trade").is_empty() and game.commerce.state.badges.trader == 1,"Actual distinct trade agreement earns Trade Envoy")
	check(game.diplomacy.act(game,id,"alliance").is_empty() and game.commerce.state.badges.diplomat == 1,"Actual alliance earns Diplomat immediately")
	points = Recognition.points(game.commerce.state.badges)
	check(Recognition.rank(game.commerce.state.badges) >= 1 and game.diplomacy.state.keys.has("rank:1"),"Varied peaceful deeds earn a recorded master promotion")
	game.diplomacy.act(game,id,"cancel_alliance"); faction.relation = 70
	game.diplomacy.act(game,id,"alliance")
	check(Recognition.points(game.commerce.state.badges) == points and game.commerce.progress(game,"diplomat") == 1,"Breaking and re-signing the same alliance cannot earn more points")
	# Climate pulse completion, not oscillation or a transient intermediate sample.
	var world: Dictionary = Climate.fresh("s1p0")
	world.temperature = 25.0; world.project = {"tool":"heat_ray","from":25.0,"to":35.0,"remaining":8}
	game.climate.state.worlds["s1p0"] = world
	for i: int in range(8): game.tick()
	check(game.recognition.state.climate_highs.get("s1p0",0) == 2 and game.commerce.state.badges.terraformer == 1,"Completed off-screen pulse records a native-relative climate improvement")
	points = Recognition.points(game.commerce.state.badges)
	game.recognition.climate_completed("s1p0",1); game.recognition.climate_completed("s1p0",2); game.commerce.update_badges(game)
	check(Recognition.points(game.commerce.state.badges) == points,"Cooling and reheating to an old high does not generate more recognition")
	game.recognition.climate_completed("s1p0",3); game.commerce.update_badges(game)
	check(game.commerce.progress(game,"terraformer") == 2 and game.commerce.state.badges.terraformer == 2,"A genuinely higher climate tier contributes only its new improvement")
	game.biosphere.state.completed = ["s1p0:2","s1p0:3"]; game.commerce.update_badges(game)
	check(game.commerce.state.badges.zoologist == 2,"Existing durable ecosystem completions feed their own badge family")
	game.colonies.state.outposts["s2p0"] = {"online_recorded":false}; game.commerce.update_badges(game)
	check(game.commerce.state.badges.colonist == 0,"An unfinished landing site awards no colony recognition")
	game.colonies.state.outposts.s2p0.online_recorded = true; game.commerce.update_badges(game)
	check(game.commerce.state.badges.colonist == 1,"A completed landing hub earns Colonist")
	game.colonies.state.outposts.erase("s2p0")
	game.commerce.update_badges(game)
	check(game.commerce.state.badges.colonist == 1,"Previously earned recognition survives loss of the site")
	var rank_only := Session.new(); rank_only.commerce.state.badges.naturalist = 5
	check(Recognition.points(rank_only.commerce.state.badges) == 30 and Recognition.rank(rank_only.commerce.state.badges) == 3 and rank_only.commerce.eligible("drive"),"Master-rank alternate unlock follows cumulative tier points")
	for n: int in range(10):
		var tiers: Dictionary = {}; var left: int = Recognition.catalog.rank_points[n]
		# Ten families at tier five cap at 300; use exact nearby point totals.
		for j: int in range(10): tiers[str(j)] = 5 if j < int(ceil(float(left)/30)) else 0
		check(Recognition.rank(tiers) >= n+1,"Promotion threshold is recognized for master rank %d" % (n+1))
	game.recognition.state.pinned = "terraformer"
	var saved: Dictionary = game.snapshot(); var loaded := Session.new()
	check(loaded.restore_snapshot(saved) == OK and loaded.snapshot() == saved,"Version 14 roundtrip preserves tiers, climate highs, pin, pending awards and chronicle")
	events = loaded.diplomacy.state.events.size(); points = Recognition.points(loaded.commerce.state.badges)
	loaded.commerce.update_badges(loaded)
	check(loaded.diplomacy.state.events.size() == events and Recognition.points(loaded.commerce.state.badges) == points,"Reload cannot duplicate earned badges or promotions")
	for mode: String in ["missing","pin","queue","duplicate","climate","badge"]:
		var invalid: Dictionary = saved.duplicate(true)
		match mode:
			"missing": invalid.erase("recognition")
			"pin": invalid.recognition.pinned = "unknown"
			"queue": invalid.recognition.queue.append({"kind":"rank","id":"","tier":99})
			"duplicate": invalid.recognition.queue.append(invalid.recognition.queue[0])
			"climate": invalid.recognition.climate_highs.morrow = 3
			"badge": invalid.commerce.badges.erase("naturalist")
		var before: Dictionary = loaded.snapshot()
		check(loaded.restore_snapshot(invalid) == ERR_INVALID_DATA and loaded.snapshot() == before,"Atomic rejection: "+mode)
	var legacy: Dictionary = saved.duplicate(true); legacy.version = 13; legacy.erase("recognition")
	for badge: String in Recognition.catalog.badges: legacy.commerce.badges.erase(badge)
	var migrated := Session.new()
	check(migrated.restore_snapshot(legacy) == OK and migrated.recognition.state.queue.is_empty() and migrated.recognition.state.climate_highs.is_empty(),"Legacy saves gain no fabricated past climate deeds or celebration queue")
	check(migrated.commerce.state.upgrades == saved.commerce.upgrades,"Migration preserves paid equipment")
	# Actual scene controls, bounded case and non-blocking animation.
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); scene.campaign = loaded; root.add_child(scene); await process_frame
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true; scene.save_path = "res://artifacts/progression_scene.json"
	scene.recognition_button.pressed.emit(); await process_frame
	check(scene.popup_kind == "badges" and scene.popup_body.get_combined_minimum_size().x < 885,"HUD promotion control opens the wide, bounded badge case")
	var case: Node = scene.popup_body.get_children().back()
	case.selected = "naturalist"; case.rebuild(); await process_frame
	var pin: Button
	for node: Node in case.get_children():
		if node is Button and node.text.begins_with("Pin progress"): pin = node
	pin.pressed.emit(); await process_frame
	check(loaded.recognition.state.pinned == "naturalist" and "Naturalist" in scene.recognition_button.text,"Real pin button updates durable HUD tracking")
	case.shop_requested.emit("hold"); await process_frame
	var purchases: Array = scene.popup_body.find_children("*","Button",true,false).filter(func(b: Button) -> bool: return b.has_meta("upgrade_id"))
	check(scene.popup_kind == "service" and purchases[0].get_meta("upgrade_id") == "hold","Badge reward link brings its real shop entry first")
	check(scene.popup.position.x+scene.popup.size.x <= 1600 and scene.popup.size.x < 580,"Wide badge case shrinks back to a shop that stays inside the viewport")
	scene._close_popup(); scene.paused = false
	var pending: int = loaded.recognition.state.queue.size(); scene._process(0.1)
	check(scene.recognition_notice.visible and loaded.recognition.state.queue.size() == pending-1,"Flight consumes one persisted award for its non-blocking celebration")
	scene._process(0.3); check(scene.recognition_notice.modulate.a > 0.5,"Recognition animates into view")
	var left: float = scene.recognition_notice.remaining; scene._show_popup("menu"); scene._process(2)
	check(scene.recognition_notice.remaining == left,"Inspection pauses celebration without silently discarding awards")
	scene.free()
	print("Progression assertions: %d; failures: %d" % [checks,failures]); quit(1 if failures else 0)
