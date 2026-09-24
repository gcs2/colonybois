extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
const Signals = preload("res://scripts/space_signals.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+message)
func pilot(planet: String) -> RefCounted:
	var game := Session.new()
	game.field.state = Field.fresh(planet); game.field.bind_account(game.sector.state)
	game.configure_flagship(); game.field.change_flight_mode("orbit"); game.climate.bind(game)
	game.sector.system_by_id(game.system_of(planet)).visited = true
	game.field.marks = 200
	return game
func ticks(game: RefCounted, count: int) -> void:
	for i: int in range(count): game.tick()
func survey(game: RefCounted) -> void:
	check(game.field.start_survey().is_empty(),"Real orbital survey starts")
	ticks(game,12)
func run() -> void:
	var game: RefCounted = pilot("s1p0")
	game.tick()
	check(game.signals.state.encounters.is_empty(),"Unsurveyed worlds do not expose encounter contents")
	survey(game)
	check(game.signals.local_ids(game) == ["convoy"] and game.signals.state.encounters.convoy.status == "offered","Survey discovers the local signal")
	var before: Dictionary = game.snapshot()
	game.signals.discover(game)
	check(game.snapshot() == before,"Repeated discovery creates no duplicates or rewards")
	ticks(game,200)
	check(game.signals.state.encounters.convoy.status == "offered","Unaccepted encounter does not impose an emergency timer")
	var event_count: int = game.diplomacy.state.events.size()
	check(not game.signals.act(game,"registry","license",Vector3.ZERO).is_empty() and game.diplomacy.state.events.size() == event_count,"Unknown remote encounter cannot award money")
	check(game.signals.act(game,"convoy","defend",Vector3.ZERO).is_empty(),"Escort commitment begins")
	var deadline: int = game.signals.state.encounters.convoy.deadline
	check(deadline == game.field.state.time+180,"Accepted departure has a fixed deadline")
	before = game.snapshot()
	check(not game.signals.act(game,"convoy","defend",Vector3.ZERO).is_empty() and game.snapshot() == before,"Repeated acceptance cannot reset deadline")
	game.field.state.energy = 100
	for i: int in range(4):
		check(game.field.fire_lance(game.field.guardian_position()).is_empty(),"Real weapon damages the convoy's attacker")
		ticks(game,2)
	check(game.field.state.guardian_disabled and game.signals.state.encounters.convoy.status == "resolved","Neutralizing the real cutter resolves the escort")
	check(game.signals.state.encounters.convoy.choice == "defend" and game.signals.completed() == 1 and game.commerce.state.badges.captain == 1,"Distinct success earns Captain recognition")
	check(game.commerce.eligible("energy_1"),"Encounter recognition is an alternate paid shop prerequisite")
	before = game.snapshot()
	check(not game.signals.act(game,"convoy","passage",Signals.position("convoy")).is_empty() and game.snapshot() == before,"Resolved escort cannot award or charge twice")
	var loaded := Session.new()
	check(game.save_to("res://artifacts/signals-complete.fw") == OK and loaded.load_from("res://artifacts/signals-complete.fw") == OK and loaded.snapshot() == game.snapshot(),"Completed choice, rewards, badges and chronicle survive disk save")
	var paid: RefCounted = pilot("s1p0"); survey(paid)
	before = paid.snapshot()
	check(not paid.signals.act(paid,"convoy","passage",Vector3(-60,0,-60)).is_empty() and paid.snapshot() == before,"Passage requires actual proximity")
	paid.field.marks = 59
	check(not paid.signals.act(paid,"convoy","passage",Signals.position("convoy")).is_empty(),"Cannot buy passage without its cost")
	paid.field.marks = 200
	var relation: int = paid.sector.faction_by_id("consortium").relation
	check(paid.signals.act(paid,"convoy","passage",Signals.position("convoy")).is_empty() and paid.field.marks == 140,"Peaceful solution pays 60 Marks with no hidden cash reward")
	check(paid.sector.faction_by_id("consortium").relation == relation+8 and not paid.field.state.guardian_disabled,"Passage improves trust but leaves the raider dangerous")
	var failed: RefCounted = pilot("s1p0"); survey(failed)
	failed.signals.act(failed,"convoy","defend",Vector3.ZERO)
	check(failed.begin_travel("s2p0").is_empty(),"Can leave an accepted commitment")
	ticks(failed,100)
	check(loaded.restore_snapshot(failed.snapshot()) == OK and loaded.snapshot() == failed.snapshot(),"Offworld accepted deadline survives load")
	ticks(failed,80); ticks(loaded,80)
	check(loaded.snapshot() == failed.snapshot() and failed.signals.state.encounters.convoy.status == "failed","Deadline expires deterministically offscreen")
	check(failed.signals.completed() == 0 and failed.commerce.state.badges.captain == 0,"Failure does not earn recognition")
	check(failed.diplomacy.state.events.any(func(e: Dictionary) -> bool: return e.outcome.get("choice","") == "failed" and e.outcome.relations.consortium == -4),"Broken commitment records its concrete relationship penalty")
	var declined: RefCounted = pilot("s1p0"); survey(declined)
	relation = declined.sector.faction_by_id("consortium").relation
	declined.signals.act(declined,"convoy","decline",Vector3.ZERO)
	check(declined.signals.state.encounters.convoy.status == "declined" and declined.sector.faction_by_id("consortium").relation == relation,"Declining before acceptance has no penalty")
	var abandoned: RefCounted = pilot("s1p0"); survey(abandoned)
	abandoned.signals.act(abandoned,"convoy","defend",Vector3.ZERO)
	relation = abandoned.sector.faction_by_id("consortium").relation
	abandoned.signals.act(abandoned,"convoy","abandon",Vector3.ZERO)
	check(abandoned.signals.state.encounters.convoy.status == "failed" and abandoned.sector.faction_by_id("consortium").relation == relation-4,"Explicit withdrawal applies the promised cost without a reward")
	var registry: RefCounted = pilot("s2p0"); survey(registry)
	var at: Vector3 = Signals.position("registry")
	before = registry.snapshot()
	check(not registry.signals.act(registry,"registry","license",at).is_empty() and registry.snapshot() == before,"Evidence must be obtained before either political outcome")
	registry.field.state.position = [at.x,at.y,at.z]
	check(registry.signals.act(registry,"registry","inspect",at).is_empty() and registry.field.state.energy == 72,"Close-range scan costs eight actual energy")
	ticks(registry,3)
	check(loaded.restore_snapshot(registry.snapshot()) == OK,"Mid-scan snapshot restores")
	ticks(registry,3); ticks(loaded,3)
	check(registry.snapshot() == loaded.snapshot() and registry.signals.state.encounters.registry.status == "decision","Six shared-clock seconds unlock the decision identically after restore")
	var alternate := Session.new(); alternate.restore_snapshot(registry.snapshot())
	var marks: float = registry.field.marks
	registry.signals.act(registry,"registry","publish",at)
	alternate.signals.act(alternate,"registry","license",at)
	check(registry.field.marks == marks+20 and alternate.field.marks == marks+100,"Mutually exclusive evidence outcomes have different payoffs")
	check(registry.sector.faction_by_id("commune").relation > alternate.sector.faction_by_id("commune").relation and registry.sector.faction_by_id("directorate").relation < alternate.sector.faction_by_id("directorate").relation,"The choice has opposite real diplomatic consequences")
	before = registry.snapshot()
	check(not registry.signals.act(registry,"registry","license",at).is_empty() and registry.snapshot() == before,"Cannot sell evidence after publishing it")
	# Prove the encounter path itself qualifies; other earned paths are disabled in this fixture.
	for badge: String in registry.commerce.state.badges:
		if badge != "captain": registry.commerce.state.badges[badge] = 0
	var energy_before: float = registry.field.state.energy
	check(registry.commerce.buy_upgrade(registry,"orbit_tender",Field.service_position("orbit_tender"),"energy_1").is_empty() and registry.field.max_capacity("energy") == 150,"Captain alone qualifies a real paid reactor purchase")
	check(registry.field.marks == marks+20-180 and registry.field.state.energy == energy_before,"Reward-funded installation pays the price and grants no free recharge")
	# Restore the consistent history fixture used by corruption tests below.
	registry.restore_snapshot(before)
	var interrupted: RefCounted = pilot("s2p0"); survey(interrupted)
	interrupted.field.state.position = [at.x,at.y,at.z]; interrupted.signals.act(interrupted,"registry","inspect",at); ticks(interrupted,2)
	interrupted.field.state.position = [0.0,8.0,35.0]; interrupted.tick()
	check(not interrupted.signals.state.encounters.registry.channeling and interrupted.signals.state.encounters.registry.progress == 0 and interrupted.field.state.energy == 72,"Leaving range breaks scan without refund or remote completion")
	interrupted.field.state.position = [at.x,at.y,at.z]; interrupted.signals.act(interrupted,"registry","inspect",at)
	check(interrupted.field.state.energy == 64,"Restarting a broken scan pays for a new attempt")
	for mode: String in ["missing","unknown","progress","deadline","choice","journal"]:
		var invalid: Dictionary = registry.snapshot()
		match mode:
			"missing": invalid.erase("signals")
			"unknown": invalid.signals.encounters["invented"] = invalid.signals.encounters.registry
			"progress": invalid.signals.encounters.registry.progress = NAN
			"deadline": invalid.signals.encounters.registry.deadline = 999
			"choice": invalid.signals.encounters.registry.choice = "defend"
			"journal": invalid.diplomacy.keys.erase("signal_end:registry")
		before = loaded.snapshot()
		check(loaded.restore_snapshot(invalid) != OK and loaded.snapshot() == before,"Invalid encounter save rejected atomically: "+mode)
	var legacy: Dictionary = Session.new().snapshot(); legacy.version = 14; legacy.erase("signals"); legacy.commerce.badges.erase("captain")
	check(loaded.restore_snapshot(legacy) == OK and loaded.signals.state.encounters.is_empty() and loaded.commerce.state.badges.captain == 0,"v14 receives no invented encounters or rewards")
	# Native scene commands and real button wiring; these checks do not approve art or feel.
	var visual: RefCounted = pilot("s2p0"); survey(visual)
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); scene.campaign = visual; root.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true; scene.save_path = "res://artifacts/signals-scene.json"
	scene.signal_view.refresh(0,true); scene._refresh_ui()
	scene._pick(scene.camera.unproject_position(Signals.position("registry")))
	check(scene.popup_kind == "signals" and scene.popup.visible,"Clicking the physical contact opens its encounter")
	var scan_button: Button
	for button: Node in scene.popup_body.find_children("*","Button",true,false):
		if button.get_meta("signal_action","") == "inspect": scan_button = button
	check(scan_button != null and not scan_button.disabled and scan_button.tooltip_text.contains("8 energy"),"Actual scan button exposes its cost")
	if scan_button != null: scan_button.pressed.emit()
	check(scene.navigating and scene.signal_view.pending == "inspect" and not scene.popup.visible,"Mouse choice orders approach and returns to flight")
	scene.ship.position = at+Vector3(0,3,-7); scene.navigating = false; scene.signal_view.refresh(0.1,false)
	check(visual.signals.state.encounters.registry.channeling,"Arrival starts the validated scan")
	scene._process(2)
	check(visual.signals.state.encounters.registry.progress == 2 and scene.signal_view.beam.visible,"Visible beam and shared progress follow actual ship position")
	var resuming := Session.new(); check(resuming.restore_snapshot(visual.snapshot()) == OK,"Live scene's scan state validates")
	var resumed_scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); resumed_scene.campaign = resuming; root.add_child(resumed_scene)
	resumed_scene.set_process(false); resumed_scene.set_physics_process(false); resumed_scene.audio.muted = true
	check(resuming.signals.state.encounters.registry.channeling and resuming.signals.state.encounters.registry.progress == 2,"Scene initialization preserves a loaded scan")
	resumed_scene._process(1)
	check(resuming.signals.state.encounters.registry.progress == 3,"Reloaded flight resumes at its saved ship position")
	resumed_scene.free()
	scene._show_popup("signals"); before = visual.snapshot(); scene._process(3)
	check(visual.snapshot() == before and visual.signals.state.encounters.registry.channeling,"Inspection pauses and preserves an in-progress scan")
	scene._close_popup(); scene._process(4)
	check(visual.signals.state.encounters.registry.status == "decision","Closing inspection resumes the scan")
	scene._show_popup("signals")
	var publish: Button
	for button: Node in scene.popup_body.find_children("*","Button",true,false):
		if button.get_meta("signal_action","") == "publish": publish = button
	check(publish != null and not publish.disabled,"Evidence exposes real decision controls")
	if publish != null: publish.pressed.emit()
	check(visual.signals.state.encounters.registry.choice == "publish","Decision button records the selected outcome")
	await process_frame
	check(scene.popup.position.x+scene.popup.size.x <= 1600 and scene.popup.size.y <= 690,"Encounter panel fits the game's logical viewport")
	scene.free()
	print("Space signal assertions: %d; failures: %d" % [checks,failures]); quit(1 if failures else 0)
