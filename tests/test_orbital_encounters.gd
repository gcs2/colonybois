extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+message)
func step(model: RefCounted, at: Vector3) -> String:
	model.tick(); return model.guardian_step(at)
func at_world(id: String) -> RefCounted:
	var field := Field.new(); field.state = Field.fresh(id); field.change_flight_mode("orbit")
	return field
func advance(game: RefCounted, seconds: int) -> void:
	for i: int in range(seconds): game.tick()
func run() -> void:
	for id: String in ["s1p0","s2p0"]:
		var model: RefCounted = at_world(id)
		var profile: Dictionary = model.enemy_profile()
		check(model.has_guardian() and not model.has_wreck() and model.state.guardian_hull == profile.hull,"Different world loads its own intact hostile: "+id)
		for i: int in range(12): step(model,Vector3(0,8,8))
		check(model.state.hull == 100 and model.state.guardian_alert == 0,"Arrival stays outside the threat envelope: "+id)
		var at: Vector3 = Field.GUARDIAN_HOME+Vector3(0,0,8)
		step(model,at); step(model,at)
		check(model.state.hull == 100 and model.state.guardian_fire_at == 0,"Initial warning does not inflict damage: "+id)
		check(step(model,at) == "guardian_aim" and model.state.hull == 100,"Enemy telegraphs a strike before firing: "+id)
		var aim: Array = model.state.guardian_aim.duplicate()
		var result: String = ""
		for i: int in range(int(profile.windup)): result = step(model,at+Vector3(0,float(profile.radius)+1,0))
		check(result == "guardian_miss" and model.state.hull == 100 and model.state.guardian_aim == aim,"Vertical movement evades the fixed aim volume: "+id)
		for i: int in range(4): result = step(model,at)
		check(result == "guardian_aim","Cooldown ends in a new warning, not instant damage: "+id)
		var path: String = "res://artifacts/encounter_windup.json"
		check(model.save_to(path) == OK,"Active warning saves: "+id)
		var loaded := Field.new()
		check(loaded.load_from(path) == OK and loaded.state == model.state,"Active aim position and countdown restore: "+id)
		for i: int in range(int(profile.windup)): step(model,at); step(loaded,at)
		check(model.state == loaded.state and model.state.hull == 100-profile.damage,"Waiting in the marker takes exact damage after loading: "+id)
		step(model,Vector3(0,8,35))
		check(model.state.guardian_alert == 0 and model.state.guardian_fire_at == 0,"Retreat breaks contact and cancels pending fire: "+id)
		model.state.hull = 1
		for i: int in range(8):
			result = step(model,at)
			if result == "tow": break
		check(result == "tow" and model.state.hull == 35 and model.state.energy <= 15,"Defeat uses existing costly emergency recovery: "+id)
	var mobile: RefCounted = at_world("s1p0")
	var anchored: RefCounted = at_world("s2p0")
	for i: int in range(3): step(mobile,Field.GUARDIAN_HOME+Vector3(0,0,18)); step(anchored,Field.GUARDIAN_HOME+Vector3(0,0,18))
	check(mobile.guardian_position() != Field.GUARDIAN_HOME and anchored.guardian_position() == Field.GUARDIAN_HOME,"Raider pursues while sentry remains anchored")
	var game := Session.new()
	game.field.change_flight_mode("orbit")
	check(game.begin_travel("s1p0").is_empty(),"Reach the raider through actual personal travel")
	while game.traveling(): game.tick()
	check(game.field.state.guardian_hull == 88,"Arrival initializes destination-specific hull")
	var before: Dictionary = game.snapshot()
	check(not game.salvage_enemy(Field.GUARDIAN_HOME).is_empty() and game.snapshot() == before,"Live enemies cannot be looted")
	for i: int in range(4): game.fire_weapon(Field.GUARDIAN_HOME); advance(game,2)
	check(game.field.state.guardian_disabled and game.commerce.state.badges.defender == 1,"Distinct encounter defeat earns Defender shop eligibility")
	check(game.diplomacy.state.keys.has("defeat:s1p0"),"Actual defeat records one persistent chronicle event")
	check(game.commerce.eligible("emitter") and game.field.lance_damage() == 22,"Badge unlocks purchase rather than granting a free weapon")
	game.field.marks = 180
	check(game.commerce.buy_upgrade(game,"orbit_tender",Field.service_position("orbit_tender"),"emitter").is_empty() and game.field.marks == 0 and game.field.lance_damage() == 33,"Paid emitter changes actual damage without free money")
	game.commerce.add_cargo("water",7,"morrow")
	before = game.snapshot()
	check(not game.salvage_enemy(Field.GUARDIAN_HOME).is_empty() and game.snapshot() == before,"Full hold leaves salvage recoverable")
	game.commerce.state.cargo.clear()
	check(game.salvage_enemy(Field.GUARDIAN_HOME).is_empty() and game.commerce.quantity("alloy") == 2,"Wreck yields physical cargo with capacity and origin")
	before = game.snapshot()
	check(not game.salvage_enemy(Field.GUARDIAN_HOME).is_empty() and game.snapshot() == before,"Salvage cannot be farmed")
	game.begin_travel("morrow"); while game.traveling(): game.tick()
	check(game.commerce.progress(game,"defender") == 1,"Inactive-world defeat contributes once")
	game.begin_travel("s1p0"); while game.traveling(): game.tick()
	check(game.field.state.guardian_disabled and game.field.state.guardian_salvaged,"Returning preserves the cleared encounter")
	var path: String = "res://artifacts/encounter_campaign.fw"
	var loaded := Session.new()
	check(game.save_to(path) == OK and loaded.load_from(path) == OK and loaded.snapshot() == game.snapshot() and loaded.field.lance_damage() == 33,"Campaign persists combat, salvage and functional purchased emitter")
	var bad: Dictionary = game.snapshot(); bad.field.guardian_aim = [NAN,0,0]
	before = game.snapshot()
	check(game.restore_snapshot(bad) != OK and game.snapshot() == before,"Malformed aim cannot corrupt live campaign")
	var old := Session.new().snapshot(); old.version = 6; old.field.version = 6
	for key: String in ["guardian_aim","guardian_fire_at","guardian_salvaged"]: old.field.erase(key)
	old.commerce.badges.erase("defender")
	check(loaded.restore_snapshot(old) == OK and loaded.field.state.guardian_fire_at == 0 and loaded.commerce.state.badges.defender == 0,"V6 campaign migrates without invented combat rewards")
	old = game.snapshot(); old.version = 6; old.field.version = 6
	old.field.guardian_disabled = false; old.field.guardian_hull = 66.0
	old.commerce.upgrades.erase("emitter"); old.commerce.badges.erase("defender")
	for key: String in ["guardian_aim","guardian_fire_at","guardian_salvaged"]:
		old.field.erase(key)
		for id: String in old.worlds: old.worlds[id].erase(key)
	check(loaded.restore_snapshot(old) == OK and loaded.field.state.guardian_hull == 88 and loaded.worlds.morrow.guardian_hull == 66 and loaded.field.lance_damage() == 22,"Legacy visited-world records migrate with appropriate enemy profiles and no free upgrade")
	var peaceful := Session.new()
	peaceful.sector.system_by_id("s1").visited = true; peaceful.sector.system_by_id("s2").visited = true
	peaceful.commerce.update_badges(peaceful)
	check(peaceful.commerce.eligible("emitter") and peaceful.commerce.state.badges.defender == 0,"Exploration remains an alternative to fighting for shop unlocks")
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = game; root.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	scene.save_path = "res://artifacts/encounter_scene.json"
	scene.ship.position = Field.GUARDIAN_HOME+Vector3(0,2,8)
	scene._update_camera(1); scene._refresh_ui()
	check(scene.orbit.hostile_visual != null and scene.orbit.guardian.visible,"Foreign orbit instantiates its distinct authored mesh")
	scene._pick(scene.camera.unproject_position(game.field.guardian_position()))
	scene._refresh_ui()
	check(scene.orbital_target == "guardian" and scene.hud.action_state.text == "CLEARED","Mouse selection uses persistent hostile status in the actual HUD")
	game.field.state = Field.fresh("s1p0"); game.field.bind_account(game.sector.state)
	game.field.change_flight_mode("orbit"); game.configure_flagship()
	scene._select_weapon(); scene._pick(scene.camera.unproject_position(game.field.guardian_position()))
	scene._operate_attack()
	check(game.field.state.guardian_hull == 55 and game.field.state.energy == 90 and scene.weapon_flash > 0,"Mouse weapon order applies upgraded damage and real energy with visible firing feedback")
	for i: int in range(3): step(game.field,scene.ship.position)
	scene._update_visuals()
	check(scene.orbit.aim_marker.visible and scene.orbit.aim_marker.scale == Vector3.ONE*6,"Actual warning geometry matches the raider's damage volume")
	scene._hud_action("stop")
	check(not scene.attack_order,"Stop cancels continued fire against foreign hostiles")
	scene.free()
	print("Orbital encounter assertions: %d; failures: %d" % [checks,failures])
	quit(1 if failures else 0)
