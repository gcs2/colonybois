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
func pilot(planet: String = "s1p0") -> RefCounted:
	var game := Session.new()
	game.field.state = Field.fresh(planet); game.field.bind_account(game.sector.state); game.configure_flagship()
	game.sector.system_by_id(game.system_of(planet)).visited = true
	game.field.marks = 1200
	return game
func purchase(game: RefCounted) -> void:
	game.commerce.state.badges.explorer = 2; game.commerce.state.badges.merchant = 2
	game.commerce.buy_upgrade(game,"basin_port",Field.service_position("basin_port"),"seeker")
	game.commerce.buy_upgrade(game,"basin_port",Field.service_position("basin_port"),"ground_bomb")
func run() -> void:
	var game: RefCounted = pilot()
	var at: Vector3 = Combat.home("s1p0","watcher")+Vector3(0,3,8)
	var before: Dictionary = game.snapshot()
	check(Combat.installed(game.field,"surface_laser") and not Combat.installed(game.field,"seeker"),"Defense laser is basic equipment; seeker needs a purchase")
	check(not game.combat.fire(game,"seeker","watcher",Vector3.ZERO,at).is_empty() and game.snapshot() == before,"Unavailable weapon cannot spend energy or invent projectiles")
	check(not game.combat.fire(game,"surface_laser","sentry_a",Vector3.ZERO,at+Vector3.UP*50).is_empty() and game.snapshot() == before,"Range uses full 3D distance")
	check(game.combat.fire(game,"surface_laser","watcher",Vector3.ZERO,at).is_empty() and game.field.state.energy == 95 and game.combat.world("s1p0").units.watcher.hull == 48,"Precise laser resolves immediately against one selected target")
	before = game.snapshot()
	check(not game.combat.fire(game,"surface_laser","watcher",Vector3.ZERO,at).is_empty() and game.snapshot() == before,"Cooldown prevents command spam")
	purchase(game); game.tick()
	before = game.snapshot()
	check(game.combat.fire(game,"seeker","sentry_a",Vector3.ZERO,at).contains("flying") and game.snapshot() == before,"Anti-air missile rejects ground targets atomically")
	check(game.combat.fire(game,"seeker","watcher",Vector3.ZERO,at).is_empty() and game.field.state.energy == 81,"Missile launch consumes its own cost")
	check(game.combat.world("s1p0").units.watcher.hull == 48 and game.combat.world("s1p0").shots.size() == 1,"Missile is genuinely in flight rather than an instant beam")
	var loaded := Session.new()
	check(game.save_to("res://artifacts/surface_projectile.fw") == OK and loaded.load_from("res://artifacts/surface_projectile.fw") == OK and loaded.snapshot() == game.snapshot(),"Mid-flight save preserves projectile timing and owned weapon")
	game.combat.state.worlds.s1p0.units.watcher.at[0] += 2.0
	game.tick(); check(game.combat.world("s1p0").units.watcher.hull == 48,"Missile does not arrive early")
	game.tick(); check(game.combat.world("s1p0").units.watcher.hull == 3 and game.combat.world("s1p0").shots.is_empty(),"Homing missile resolves against the moving target")
	for i: int in range(2): game.tick()
	game.field.state.energy = 100.0
	var point := Vector3(23,0,-21)
	check(game.combat.fire(game,"ground_bomb","",point,at).is_empty() and game.field.state.energy == 82,"Ground aim accepts a coordinate and consumes bomb energy")
	game.tick(); game.tick()
	var local: Dictionary = game.combat.world("s1p0")
	check(local.units.sentry_a.hull == 30 and local.units.sentry_b.hull == 30 and local.units.watcher.hull == 3,"Blast radius damages both ground targets and spares the flyer")
	for i: int in range(2): game.tick()
	game.combat.fire(game,"ground_bomb","",point,at)
	game.field.change_flight_mode("orbit")
	game.tick(); game.tick()
	check(game.combat.cleared() == 2 and game.commerce.state.badges.defender == 1,"Launched bomb resolves after ascent and contributes distinct defeats")
	check(game.combat.state.worlds.s1p0.units.sentry_a.fire_at == 0,"Leaving the surface clears enemy aim rather than attacking an invisible ship")
	before = game.snapshot()
	check(not game.combat.fire(game,"surface_laser","watcher",Vector3.ZERO,at).is_empty() and game.snapshot() == before,"Surface weapons cannot fire in orbit")
	game.field.change_flight_mode("surface"); game.tick(); game.tick()
	check(game.combat.fire(game,"surface_laser","watcher",Vector3.ZERO,at).is_empty(),"Laser finishes surviving flyer")
	check(game.combat.cleared() == 3 and game.commerce.state.badges.defender == 2,"Three unique surface targets advance Defender without respawning")
	local = game.combat.world("s1p0")
	check(loaded.restore_snapshot(game.snapshot()) == OK,"Defeated flyer can be saved after settling onto terrain")
	var wreck: Vector3 = Combat.position(local.units.watcher.at)
	check(not game.combat.salvage(game,"watcher",at+Vector3.UP*50).is_empty(),"Wreck recovery requires approach")
	check(game.combat.salvage(game,"watcher",wreck).is_empty() and game.commerce.quantity("glass") == 1,"Surface salvage loads real cargo with planet provenance")
	before = game.snapshot()
	check(not game.combat.salvage(game,"watcher",wreck).is_empty() and game.snapshot() == before,"Wreck cannot be harvested repeatedly")
	game.commerce.add_cargo("alloy",7,"s1p0")
	before = game.snapshot()
	check(not game.combat.salvage(game,"sentry_a",Combat.home("s1p0","sentry_a")).is_empty() and game.snapshot() == before,"Full hold preserves uncollected salvage")
	var danger: RefCounted = pilot()
	var danger_at: Vector3 = Combat.home("s1p0","watcher")
	check(danger.combat.step(danger,danger_at) == "aim" and danger.field.state.hull == 100,"Enemy announces a fixed aim volume before damage")
	for i: int in range(3): danger.tick(); danger.combat.step(danger,danger_at+Vector3.UP*16)
	check(danger.field.state.hull == 100,"Vertical movement clears the pending hit volumes")
	var doomed: RefCounted = pilot(); doomed.field.state.hull = 1.0
	doomed.combat.step(doomed,danger_at)
	var result: String = ""
	for i: int in range(3):
		doomed.tick(); result = doomed.combat.step(doomed,danger_at)
		if result == "tow": break
	check(result == "tow" and doomed.field.state.tow_count == 1 and doomed.field.state.hull == 35 and doomed.field.state.energy <= 15,"Lethal surface fire uses costly recoverable defeat")
	before = loaded.snapshot()
	var invalid: Dictionary = before.duplicate(true)
	invalid.combat.worlds.s1p0.units.watcher.hull = -1
	check(loaded.restore_snapshot(invalid) != OK and loaded.snapshot() == before,"Corrupt combat load is atomic")
	invalid = before.duplicate(true); invalid.combat.worlds.s1p0.units.sentry_a.at[0] = 0.0
	check(loaded.restore_snapshot(invalid) != OK and loaded.snapshot() == before,"Stationary defenses cannot teleport through a save")
	var old: Dictionary = Session.new().snapshot(); old.version = 9; old.erase("combat")
	check(loaded.restore_snapshot(old) == OK and loaded.combat.state.worlds.is_empty(),"Older campaigns migrate without free defeats or reward cargo")
	# Deterministic outcomes under the same explicit commands.
	var one: RefCounted = pilot(); var two: RefCounted = pilot()
	for peer: RefCounted in [one,two]:
		purchase(peer); peer.combat.fire(peer,"ground_bomb","",point,at)
		for i: int in range(8): peer.tick(); peer.combat.step(peer,at+Vector3.UP*10)
	check(one.snapshot() == two.snapshot(),"Identical commands and clocks reproduce combat, economy and history")
	# Actual scene mouse selection, approach, weapon use, stop, visual bounds and modal guards.
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = pilot(); root.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	scene.save_path = "res://artifacts/surface_scene.fw"
	scene.ship.position = Field.service_position("basin_port")
	scene.distance = 75; scene.camera_distance_target = 75; scene._update_camera(1)
	scene._hud_action("item:surface_laser")
	scene._pick(scene.camera.unproject_position(Combat.home("s1p0","watcher")))
	check(scene.surface_order and scene.navigating,"Mouse attack beyond range creates a real flight approach")
	for i: int in range(360):
		scene._physics_process(1.0/60); scene._operate_surface_attack()
		if scene.campaign.combat.state.fired > 0: break
	scene._operate_surface_attack(); scene._refresh_ui()
	check(scene.surface_selected == "watcher" and scene.campaign.combat.world("s1p0").units.watcher.hull == 48 and scene.weapon_flash > 0,"Mouse targeting fires selected laser with real damage and visible feedback")
	scene._hud_action("stop")
	check(not scene.surface_order,"Stop cancels continued surface fire")
	before = scene.campaign.snapshot(); scene._show_popup("cargo")
	scene._hud_action("item:surface_laser"); scene._order_surface_attack("watcher",Vector3.ZERO); scene._operate_surface_attack()
	check(scene.campaign.snapshot() == before,"Inventory inspection blocks attack commands")
	scene._close_popup(); purchase(scene.campaign)
	scene._hud_action("item:seeker"); scene._pick(scene.camera.unproject_position(Combat.home("s1p0","sentry_a")))
	check(not scene.surface_order,"Mouse selection refuses invalid missile target class")
	scene._hud_action("item:ground_bomb"); scene.campaign.tick()
	scene._pick(scene.camera.unproject_position(Vector3(23,scene.terrain_height(23,-21),-21)))
	scene._operate_surface_attack()
	check(scene.campaign.combat.world("s1p0").shots.size() == 1 and not scene.surface_order,"Mouse-ground bomb order launches once rather than endlessly spending energy")
	scene.surface_combat_visual.refresh(scene.campaign,"sentry_a",0.5,0.1,false)
	check(scene.surface_combat_visual.actors.size() == 3 and scene.surface_combat_visual.zones[0].visible,"Actual scene renders three bounded enemies and a bomb footprint")
	scene.free()
	print("Surface combat assertions: %d; failures: %d" % [checks,failures])
	quit(1 if failures else 0)
