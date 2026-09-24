extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
const Combat = preload("res://scripts/surface_combat.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+text)
func pilot(planet: String = "s7p0") -> RefCounted:
	var game := Session.new()
	game.field.state = Field.fresh(planet); game.field.bind_account(game.sector.state)
	game.field.change_flight_mode("orbit"); game.configure_flagship()
	game.sector.system_by_id(game.system_of(planet)).visited = true
	game.field.marks = 400
	return game
func ally(game: RefCounted, id: String = "consortium") -> void:
	game.diplomacy.contact(game,id); game.sector.faction_by_id(id).relation = 50
	game.diplomacy.act(game,id,"alliance")
func escort(game: RefCounted) -> void:
	ally(game); game.commerce.state.badges.explorer = 1
	game.fleet.command(game,"consortium","recruit",Vector3(0,8,35))
func run() -> void:
	var game: RefCounted = pilot()
	var at := Vector3(0,8,35)
	var before: Dictionary = game.snapshot()
	check(not game.fleet.command(game,"consortium","recruit",at).is_empty() and game.snapshot() == before,"Unknown/unallied nation cannot supply an escort")
	ally(game)
	var untraveled := Session.new(); ally(untraveled)
	check(untraveled.fleet.capacity(untraveled) == 0,"Alliance alone does not create an unearned fleet slot; a visited second system earns Explorer normally")
	game.commerce.state.badges.merchant = 1
	check(game.fleet.capacity(game) == 1,"Peaceful trade progression unlocks fleet capacity")
	game.field.change_flight_mode("surface") # This world has no surface: stay in orbit.
	game.field.state.flight_mode = "surface"
	check(not game.fleet.reason(game,"consortium","recruit").is_empty(),"Recruitment needs the ally's orbit")
	game.field.state.flight_mode = "orbit"
	var money: float = game.field.marks
	check(game.fleet.command(game,"consortium","recruit",at).is_empty() and game.field.marks == money,"First allied ship is a loan, not an unexplained debit")
	check(game.fleet.active_ids() == ["consortium"],"Exactly one persistent escort is assigned")
	before = game.snapshot()
	check(not game.fleet.command(game,"consortium","recruit",at).is_empty() and game.snapshot() == before,"Repeated requests cannot duplicate or heal the escort")
	game.fleet.prepare(game,at)
	check(game.fleet.positions(game)[0].distance_to(at) > 5,"Escort has its own formation position")
	game.fleet.hit_volume(game,game.fleet.positions(game)[0],1,25)
	check(game.fleet.state.ships.consortium.hull == 55 and game.field.state.hull == 100,"A strike on an escort changes its own hull")
	check(game.fleet.command(game,"consortium","dismiss").is_empty() and game.fleet.positions(game).is_empty(),"Dismissal removes the local ship")
	game.fleet.command(game,"consortium","recruit",at)
	check(game.fleet.state.ships.consortium.hull == 55,"Dismiss/recruit cannot manufacture free repairs")
	before = game.snapshot()
	check(not game.fleet.command(game,"consortium","repair",at).is_empty() and game.snapshot() == before,"Repairs require real dock proximity")
	var dock: Vector3 = Field.service_position("orbit_tender")
	var quote: int = game.fleet.repair_cost("consortium")
	check(game.fleet.command(game,"consortium","repair",dock).is_empty() and game.field.marks == money-quote and game.fleet.state.ships.consortium.hull == 80,"Dock repairs debit the exact missing-hull quote")
	var relation: int = game.sector.faction_by_id("consortium").relation
	game.fleet.hit_volume(game,at,2,100)
	check(game.fleet.state.ships.consortium.status == "lost" and game.sector.faction_by_id("consortium").relation == relation-7,"Destroyed escort persists and costs its ally seven relations")
	var events: int = game.diplomacy.state.events.size()
	game.fleet.hit_volume(game,at,100,100)
	check(game.diplomacy.state.events.size() == events,"Already-lost ship cannot apply another diplomatic penalty")
	check(not game.fleet.reason(game,"consortium","recruit").is_empty(),"Replacement cannot arrive instantly")
	for i: int in range(60): game.tick()
	game.field.marks = 119
	check(not game.fleet.reason(game,"consortium","recruit").is_empty(),"Replacement requires its real contribution")
	game.field.marks = 200
	check(game.fleet.command(game,"consortium","recruit",at).is_empty() and game.field.marks == 80,"Prepared replacement spends 120 Marks and returns a new hull")
	game.fleet.hit_volume(game,at,1,10)
	var loaded := Session.new()
	check(game.save_to("res://artifacts/fleet.fw") == OK and loaded.load_from("res://artifacts/fleet.fw") == OK and loaded.snapshot() == game.snapshot(),"Save/load preserves losses, replacement, damage and diplomacy together")
	game.diplomacy.act(game,"consortium","cancel_alliance")
	check(game.fleet.active_ids().is_empty() and game.fleet.state.ships.consortium.hull == 70,"Alliance withdrawal recalls a damaged escort immediately")
	before = loaded.snapshot(); var bad: Dictionary = before.duplicate(true)
	bad.fleet.ships.consortium.hull = 900
	check(loaded.restore_snapshot(bad) != OK and loaded.snapshot() == before,"Invalid fleet hull cannot partially overwrite a campaign")
	bad = before.duplicate(true); bad.sector.agreements.erase("consortium:alliance")
	check(loaded.restore_snapshot(bad) != OK,"Active escort cannot be loaded without its alliance")
	bad = before.duplicate(true)
	for badge: String in bad.commerce.badges: bad.commerce.badges[badge] = 0
	bad.recognition.queue.clear()
	check(loaded.restore_snapshot(bad) != OK,"Saved active roster cannot exceed earned command capacity")
	var old: Dictionary = Session.new().snapshot(); old.version = 10; old.erase("fleet")
	check(loaded.restore_snapshot(old) == OK and loaded.fleet.active_ids().is_empty(),"Old campaigns migrate without free allied ships")
	# Surface support uses the same target records, costs and defeat counters as personal weapons.
	var surface: RefCounted = pilot(); escort(surface)
	surface.field.state = Field.fresh("s1p0"); surface.field.bind_account(surface.sector.state); surface.configure_flagship()
	var enemy: Vector3 = Combat.home("s1p0","watcher")
	surface.fleet.prepare(surface,enemy+Vector3(0,1,10))
	for i: int in range(3): surface.tick()
	var energy: float = surface.field.state.energy
	surface.fleet.assist(surface,"watcher",true,enemy)
	check(surface.combat.world("s1p0").units.watcher.hull == 56 and surface.field.state.energy == energy,"Escort fires at engaged target using its own weapon, not flagship energy")
	surface.fleet.assist(surface,"watcher",true,enemy)
	check(surface.combat.world("s1p0").units.watcher.hull == 56,"Repeated command cannot bypass escort cooldown")
	surface.fleet.set_assist(surface,false)
	for i: int in range(3): surface.tick()
	surface.fleet.assist(surface,"watcher",true,enemy)
	check(surface.combat.world("s1p0").units.watcher.hull == 56,"Follow-only stance holds fire")
	surface.fleet.set_assist(surface,true)
	surface.fleet.assist(surface,"watcher",false,enemy)
	check(surface.combat.world("s1p0").units.watcher.hull == 56,"Escorts do not start an unsolicited fight")
	surface.combat.state.worlds.s1p0.units.watcher.hull = 8.0
	surface.fleet.assist(surface,"watcher",true,enemy)
	check(surface.combat.cleared() == 1 and surface.commerce.state.badges.defender == 1,"Allied final hit contributes one persistent encounter defeat")
	surface.combat.step(surface,enemy)
	var local: Dictionary = surface.combat.state.worlds.s1p0
	local.units.sentry_a.aim = surface.fleet.state.ships.consortium.at.duplicate()
	local.units.sentry_a.fire_at = int(surface.field.state.time)+1
	var hull: float = surface.fleet.state.ships.consortium.hull
	surface.tick(); surface.combat.step(surface,enemy+Vector3.UP*30)
	check(surface.fleet.state.ships.consortium.hull < hull,"Actual surface warning resolves damage against an escort while flagship evades")
	# Travel and orbital assistance keep hull and results in one campaign.
	var orbital: RefCounted = pilot(); escort(orbital)
	orbital.field.state = Field.fresh("s1p0"); orbital.field.bind_account(orbital.sector.state)
	orbital.field.change_flight_mode("orbit"); orbital.configure_flagship()
	var enemy_at: Vector3 = orbital.field.guardian_position()
	orbital.fleet.prepare(orbital,enemy_at+Vector3(0,0,12))
	for i: int in range(3): orbital.tick()
	orbital.field.state.guardian_hull = 8.0
	orbital.fleet.assist(orbital,"guardian",true,enemy_at)
	check(orbital.field.state.guardian_disabled and orbital.commerce.state.badges.defender == 1 and orbital.diplomacy.state.keys.has("defeat:s1p0"),"Allied orbital kill preserves the normal salvage and badge path")
	var threat: RefCounted = pilot(); escort(threat)
	threat.field.state = Field.fresh("s2p0"); threat.field.bind_account(threat.sector.state)
	threat.field.change_flight_mode("orbit"); threat.configure_flagship()
	enemy_at = threat.field.guardian_position()
	var distant_ship: Vector3 = enemy_at+Vector3(0,0,20)
	threat.fleet.state.ships.consortium.at = Combat.packed(enemy_at+Vector3(0,0,5))
	threat.field.state.guardian_alert = 3
	threat.field.guardian_step(distant_ship,threat.fleet.positions(threat))
	check(Combat.position(threat.field.state.guardian_aim).distance_to(threat.fleet.positions(threat)[0]) < 0.1,"Orbital enemy can aim directly at the closer allied ship")
	for i: int in range(3):
		var shots: int = threat.field.state.guardian_shots
		threat.tick(); threat.field.guardian_step(distant_ship,threat.fleet.positions(threat))
		threat.fleet.orbit_hits(threat,shots,0)
	check(threat.fleet.state.ships.consortium.hull == 52 and threat.field.state.hull == 100,"Orbital telegraph damages its actual escort target and spares the distant flagship")
	check(loaded.restore_snapshot(threat.snapshot()) == OK,"Save preserves an escort damaged by an actual orbital strike")
	var replay: RefCounted = pilot(); escort(replay)
	var twin := Session.new(); twin.restore_snapshot(replay.snapshot())
	for peer: RefCounted in [replay,twin]:
		for i: int in range(12): peer.tick(); peer.fleet.prepare(peer,at+Vector3(i,0,0))
	check(replay.snapshot() == twin.snapshot(),"Same clock and commands yield the same fleet, formation and diplomacy")
	before = replay.snapshot(); replay.fleet.prepare(replay,at+Vector3(60,0,0))
	check(replay.snapshot() == before,"Repeated scene step cannot advance the formation twice in one tick")
	var slots: RefCounted = pilot(); slots.commerce.state.badges.explorer = 5
	check(slots.fleet.capacity(slots) == 3,"Fleet slots have a bounded three-ship cap")
	var nations: Array = ["consortium","directorate","commune"]
	for id: String in nations:
		ally(slots,id)
		for system: Dictionary in slots.sector.state.systems:
			if system.owner != id: continue
			slots.field.state = Field.fresh(system.id+"p0"); slots.field.bind_account(slots.sector.state)
			slots.field.change_flight_mode("orbit"); slots.configure_flagship(); break
		check(slots.fleet.command(slots,id,"recruit",at).is_empty(),"Recruit distinct allied nation into its own available slot: "+id)
	slots.fleet.prepare(slots,at)
	check(slots.fleet.active_ids().size() == 3 and slots.fleet.positions(slots)[0] != slots.fleet.positions(slots)[1],"Three escorts occupy distinct bounded formation slots")
	check(loaded.restore_snapshot(slots.snapshot()) == OK,"Full three-ally roster saves and restores")
	var travel: RefCounted = pilot(); escort(travel)
	travel.fleet.state.ships.consortium.hull = 37.0
	check(travel.begin_travel("s4p0").is_empty() and travel.fleet.active(travel).is_empty(),"Escorts leave local combat during actual interstellar travel")
	while travel.traveling(): travel.tick()
	check(travel.field.state.planet_id == "s4p0" and travel.fleet.state.ships.consortium.hull == 37,"Escort survives travel without a heal or duplicate")
	travel.sector.faction_by_id("consortium").embargo = true; travel.fleet.reconcile(travel)
	check(travel.fleet.active_ids().is_empty(),"Embargo recalls the escort rather than preserving an invalid active ally")
	# Real scene integration: roster, button command, pause, visible formation and firing clock.
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = pilot(); ally(scene.campaign); scene.campaign.commerce.state.badges.explorer = 1
	root.add_child(scene); scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	scene.save_path = "res://artifacts/fleet_scene.fw"
	scene.contacted_faction = "consortium"; scene.contact_page = "fleet"; scene._show_popup("contact")
	var request: Button
	for node: Node in scene.popup_body.find_children("*","Button",true,false):
		if node.get_meta("fleet_action","") == "consortium:recruit": request = node
	check(request != null and not request.disabled and not request.tooltip_text.is_empty(),"Contact fleet tab exposes a valid explained recruitment control")
	if request != null: request.pressed.emit()
	check(scene.campaign.fleet.active_ids() == ["consortium"],"Actual contact button recruits into shared campaign state")
	scene._close_popup(); scene._refresh_ui()
	check(scene.fleet_strip.visible and scene.fleet_bars.consortium.visible,"Flight roster shows the real assigned hull")
	scene.paused = true; before = scene.campaign.snapshot(); scene._fleet_action("consortium","dismiss")
	check(scene.campaign.snapshot() == before,"Pause blocks fleet mutations")
	scene.paused = false; scene.campaign.fleet.prepare(scene.campaign,scene.ship.position)
	scene.fleet_visual.refresh(scene.campaign,0.1,false)
	check(scene.fleet_visual.actors.consortium.visible and not scene.fleet_visual.actors.commune.visible,"Scene instantiates only the recruited faction's escort")
	scene.free()
	var joined: RefCounted = pilot(); escort(joined)
	joined.field.state = Field.fresh("s1p0"); joined.field.bind_account(joined.sector.state)
	joined.field.change_flight_mode("orbit"); joined.configure_flagship()
	for i: int in range(3): joined.tick()
	scene = load("res://scenes/encounter.tscn").instantiate(); scene.campaign = joined; root.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	scene.save_path = "res://artifacts/fleet_scene_combat.fw"
	scene.ship.position = joined.field.guardian_position()+Vector3(0,0,12)
	for i: int in range(3): scene._process(1.0)
	scene._select_weapon(); scene._command_guardian()
	var target_hull: float = joined.field.state.guardian_hull
	scene._process(1.01)
	check(joined.field.state.guardian_hull < target_hull-joined.field.lance_damage() and not joined.fleet.flashes.is_empty(),"Real scene clock combines mouse-ordered flagship fire with allied support")
	scene._stop(); target_hull = joined.field.state.guardian_hull
	for i: int in range(3): scene._process(1.0)
	check(joined.field.state.guardian_hull == target_hull,"Stop cancels allied as well as personal attack orders")
	scene._show_popup("fleet"); before = joined.snapshot(); scene._process(4.0)
	check(joined.snapshot() == before,"Fleet inspection pauses combat, formation and the shared clock")
	scene.free()
	print("Allied fleet assertions: %d; failures: %d" % [checks,failures])
	quit(1 if failures else 0)
