extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
const Combat = preload("res://scripts/surface_combat.gd")
const War = preload("res://scripts/empire_conflict.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("FAIL: "+title)
func pilot(id: String = "morrow") -> RefCounted:
	var game := Session.new(); game.field.state = Field.fresh(id); game.field.bind_account(game.sector.state); game.configure_flagship(); game.field.marks = 2000
	for system: Dictionary in game.sector.state.systems: system.visited = true
	return game
func equip(game: RefCounted) -> void:
	game.commerce.state.badges.defender = 3
	for id: String in ["shield","rally_call"]:
		check(game.commerce.buy_upgrade(game,"basin_port",Field.service_position("basin_port"),id) == "","Real paid equipment purchase: "+id)
func ticks(game: RefCounted, count: int) -> void:
	for i: int in range(count): game.tick()
func ally(game: RefCounted) -> void:
	game.field.change_flight_mode("orbit"); game.diplomacy.contact(game,"consortium"); game.sector.faction_by_id("consortium").relation = 50
	game.diplomacy.act(game,"consortium","alliance"); game.commerce.state.badges.explorer = 1
	check(game.fleet.command(game,"consortium","recruit",Vector3(0,8,35)) == "","Actual ally supplies an escort")
func run() -> void:
	var game: RefCounted = pilot(); var before: Dictionary = game.snapshot()
	check(not game.use_support("shield").is_empty() and game.snapshot() == before,"Unowned shield cannot be activated")
	check(not game.commerce.buy_upgrade(game,"basin_port",Field.service_position("basin_port"),"shield").is_empty() and game.snapshot() == before,"Marks alone do not bypass earned eligibility")
	equip(game)
	check(game.field.marks == 1140 and game.field.state.energy == 100 and game.field.state.hull == 100,"Purchase costs 860 Marks and restores no ship reserves")
	game.field.state.energy = 29; before = game.snapshot()
	check(not game.use_support("shield").is_empty() and game.snapshot() == before,"Insufficient energy refuses atomically")
	game.field.state.energy = 100
	check(game.use_support("shield") == "" and game.field.state.energy == 70,"Activation pays thirty energy exactly once")
	before = game.snapshot()
	check(not game.use_support("shield").is_empty() and game.snapshot() == before,"Repeated activation cannot refresh duration or charge twice")
	check(not game.field.receive_damage(200) and game.field.state.hull == 100,"Active shield blocks a lethal flagship strike")
	ticks(game,9)
	check(game.field.Support.active(game.field,"shield") and game.field.state.energy == 70,"Shield lasts through tick nine with no energy regeneration")
	ticks(game,1)
	check(not game.field.Support.active(game.field,"shield") and game.field.receive_damage(14) and game.field.state.hull == 86,"Protection expires exactly at tick ten")
	before = game.snapshot()
	check(game.use_support("shield").contains("Cooling") and game.snapshot() == before,"Expired shield remains unavailable until cooldown ends")
	ticks(game,35)
	check(game.use_support("shield") == "" and game.field.state.energy == 40,"Reusing the shield after forty-five seconds pays again")
	# Active/cooling clocks and ownership survive disk and standalone JSON without reset.
	var loaded := Session.new()
	check(game.save_to("res://artifacts/support.fw") == OK and loaded.load_from("res://artifacts/support.fw") == OK and loaded.snapshot() == game.snapshot(),"Campaign reload preserves active effect, costs and cooldown")
	ticks(game,12); ticks(loaded,12)
	check(game.snapshot() == loaded.snapshot(),"Loaded timers and economy continue deterministically")
	var field := Field.new(); field.installed_upgrades = ["shield"]; field.Support.use(field,"shield")
	var standalone := Field.new(); standalone.installed_upgrades = ["shield"]
	check(field.save_to("res://artifacts/support-field.json") == OK and standalone.load_from("res://artifacts/support-field.json") == OK and standalone.snapshot() == field.snapshot(),"Legacy standalone JSON preserves integral support clocks")
	before = loaded.snapshot(); var bad: Dictionary = game.snapshot(); bad.field.support.shield.until = bad.field.time+100
	check(loaded.restore_snapshot(bad) != OK and loaded.snapshot() == before,"Overlong active timer rejected atomically")
	bad = game.snapshot(); bad.commerce.upgrades.erase("shield")
	check(loaded.restore_snapshot(bad) != OK,"Unowned effect history cannot be forged")
	bad = game.snapshot(); bad.field.support.shield.uses = 0.5
	check(loaded.restore_snapshot(bad) != OK,"Fractional activation counts rejected")
	var legacy: Dictionary = pilot().snapshot(); legacy.version = 17; legacy.field.version = 8; legacy.field.erase("support")
	check(loaded.restore_snapshot(legacy) == OK and loaded.field.state.support == Field.Support.fresh() and loaded.commerce.state.upgrades.is_empty(),"v17 migration creates no free equipment or active support")
	# Real surface enemy telegraph/impact pipeline.
	game = pilot("s1p0"); equip(game); game.use_support("shield")
	var at: Vector3 = Combat.home("s1p0","watcher")
	game.combat.step(game,at); ticks(game,2)
	check(game.combat.step(game,at) == "shield_block" and game.field.state.hull == 100,"Actual surface strike is blocked with explicit feedback")
	game.field.change_flight_mode("orbit"); game.field.state.guardian_aim = Combat.packed(at); game.field.state.guardian_fire_at = game.field.state.time
	# Orbit attacker needs a target within its real patrol area.
	at = Field.WRECK_POSITION; game.field.state.guardian_aim = Combat.packed(at)
	check(game.field.guardian_step(at) == "shield_block" and game.field.state.hull == 100,"Actual orbital attacker also obeys the shield")
	game = pilot(); equip(game); game.field.change_flight_mode("orbit"); game.use_support("shield")
	for i: int in range(5): game.tick(0)
	check(game.tick(0) == "shield_block" and game.field.state.hull == 100,"Wreck pulse field cannot bypass protection")
	# War continues against infrastructure even during personal invulnerability.
	game = pilot(); equip(game); game.field.change_flight_mode("orbit"); game.diplomacy.contact(game,"directorate"); game.conflict.command(game,"directorate","declare"); ticks(game,91)
	game.use_support("shield"); game.conflict.step(game,War.HOME); ticks(game,2)
	check(game.conflict.step(game,War.HOME) == "shield_block" and game.field.state.hull == 100,"A real orbital raid strike is blocked")
	game.conflict.state.raid.bombard = int(game.field.state.time)+1; game.tick()
	check(game.conflict.site("morrow").integrity == 80,"Flagship shield does not prevent colony bombardment")
	# Real ally remains vulnerable; rally modifies the existing assist shot.
	game = pilot("s7p0"); equip(game); ally(game); game.use_support("shield"); game.use_support("rally_call")
	game.fleet.hit_volume(game,Combat.position(game.fleet.state.ships.consortium.at),1,20)
	check(game.fleet.state.ships.consortium.hull == 60,"Personal shield does not protect an escort")
	game.field.state = Field.fresh("s1p0"); game.field.bind_account(game.sector.state); game.configure_flagship(); game.use_support("rally_call")
	at = Combat.home("s1p0","watcher"); game.fleet.state.ships.consortium.at = Combat.packed(at); game.fleet.state.ships.consortium.ready = 0
	var old_hull: float = game.combat.world("s1p0").units.watcher.hull
	game.fleet.assist(game,"watcher",true,at)
	check(game.combat.world("s1p0").units.watcher.hull == old_hull-game.fleet.catalog.consortium.damage*2,"Rally doubles an actual escort attack without an extra simulation")
	old_hull = game.combat.world("s1p0").units.watcher.hull
	check(game.combat.fire(game,"surface_laser","watcher",Vector3.ZERO,at) == "" and game.combat.world("s1p0").units.watcher.hull == old_hull-32,"Rally doubles precise surface fire")
	game.field.change_flight_mode("orbit")
	check(game.field.lance_damage() == 44,"Rally doubles orbital lance damage too")
	# A missile keeps its launch multiplier after expiry; late activation cannot buff it retroactively.
	game = pilot("s1p0"); equip(game); game.commerce.state.upgrades.append("seeker"); game.field.installed_upgrades = game.commerce.state.upgrades
	game.use_support("rally_call"); ticks(game,11); at = Combat.home("s1p0","watcher")
	game.combat.fire(game,"seeker","watcher",Vector3.ZERO,at)
	check(loaded.restore_snapshot(game.snapshot()) == OK,"Boosted airborne projectile persists with its launch multiplier")
	ticks(game,2); ticks(loaded,2)
	check(not game.field.Support.active(game.field,"rally_call") and game.combat.world("s1p0").units.watcher.hull == 0 and game.snapshot() == loaded.snapshot(),"Launched boost survives expiration and reload, killing the sixty-four-hull flyer")
	game = pilot("s1p0"); equip(game); game.commerce.state.upgrades.append("seeker"); game.field.installed_upgrades = game.commerce.state.upgrades
	game.combat.fire(game,"seeker","watcher",Vector3.ZERO,at); game.use_support("rally_call"); ticks(game,2)
	check(game.combat.world("s1p0").units.watcher.hull == 19,"Activating after launch does not retroactively boost a missile")
	game.field._emergency_tow()
	check(not game.field.Support.active(game.field,"rally_call") and game.field.state.support.rally_call.ready == 60,"Tow cancels active effects without clearing cooldown")
	# Travel and switching scenes never restart the shared clocks.
	game = pilot(); equip(game); game.field.change_flight_mode("orbit"); game.use_support("shield"); game.use_support("rally_call")
	check(game.begin_travel("s1p0") == "","Support does not prevent ordinary paid travel")
	before = game.snapshot()
	check(not game.use_support("shield").is_empty() and game.snapshot() == before,"No support activation during interstellar transit")
	while game.traveling(): game.tick()
	check(game.field.Support.active(game.field,"shield") and game.field.state.support.shield.until-game.field.state.time == 8 and game.field.state.support.shield.ready == 45,"Short journey consumes elapsed duration without resetting effect or cooldown")
	ticks(game,8)
	check(not game.field.Support.active(game.field,"shield"),"Shield still expires at its original absolute deadline")
	# Actual hotbar/inspection controls and feedback at native layout scale.
	game = pilot(); equip(game)
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); scene.campaign = game; root.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true; scene.save_path = "res://artifacts/support-ui.fw"
	scene._select_surface_weapon("surface_laser"); scene.hud.show_group("Weapons"); scene._refresh_ui()
	scene.hud.item_buttons.shield.pressed.emit(); scene.hud.item_buttons.rally_call.pressed.emit(); scene._update_visuals()
	check(game.field.state.energy == 45 and scene.surface_weapon == "surface_laser","Actual icon activation spends energy without replacing the selected weapon")
	check(scene.hud.support_badges.shield.visible and scene.hud.item_buttons.shield.tooltip_text.contains("seconds") and scene.support_visual.shell.visible and scene.support_visual.halo.visible,"Named hover help, active timers and ship effects read actual state")
	scene._show_popup("systems"); before = game.snapshot(); scene._process(7)
	check(game.snapshot() == before,"Equipment inspection freezes effect duration along with the simulation")
	scene.ship.position = Field.service_position("basin_port"); scene.selected_service = "basin_port"; scene.dock_page = "upgrades"; scene.upgrade_family = "support"
	scene._show_popup("service"); await process_frame; await process_frame
	var choices: int = 0
	for button: Node in scene.popup_body.find_children("*","Button",true,false):
		if button.get_meta("upgrade_id","") in ["shield","rally_call"]:
			choices += 1
			check(button.icon != null and button.get_global_rect().end.y < scene.popup.get_global_rect().end.y,"Support purchase has its icon and fits without scrolling: "+str(button.get_meta("upgrade_id")))
	check(choices == 2,"Dedicated Support shop shows both real equipment entries")
	scene._close_popup(); scene.paused = true; ticks(game,60); before = game.snapshot(); scene._hud_action("shield")
	check(game.snapshot() == before,"Pause blocks support activation")
	scene.free()
	print("Ship support assertions: %d; failures: %d" % [checks,failures]); quit(1 if failures else 0)
