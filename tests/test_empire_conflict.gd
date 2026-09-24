extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
const War = preload("res://scripts/empire_conflict.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("FAIL: "+label)
func ticks(game: RefCounted, count: int) -> void:
	for i: int in range(count): game.tick()
func pilot() -> RefCounted:
	var game := Session.new(); game.field.marks = 2000
	game.field.change_flight_mode("orbit"); game.field.state.guardian_disabled = true; game.field.state.guardian_hull = 0.0
	game.field.state.position = [0.0,8.0,35.0]
	for id: String in War.data.factions: game.diplomacy.contact(game,id)
	game.sector.state.colonies.s0p0.materials = 500
	return game
func arrive(game: RefCounted) -> void:
	game.conflict.command(game,"directorate","declare"); ticks(game,91)
func run() -> void:
	var game: RefCounted = pilot(); ticks(game,240)
	check(game.conflict.state.raid.is_empty() and not game.conflict.at_war("directorate"),"Ordinary peaceful exploration causes no forced war")
	var enemy: Dictionary = game.sector.faction_by_id("directorate"); enemy.relation = -60
	game.tick(); var deadline: int = game.conflict.nation("directorate").warning
	check(deadline == game.field.state.time+90 and not game.conflict.at_war("directorate"),"Hostile diplomacy gives a visible 90-second warning")
	check(game.diplomacy.act(game,"directorate","reconcile") == "","Actual reconciliation is available before war")
	game.tick(); check(game.conflict.nation("directorate").warning == 0,"Improved relations avert war")
	enemy.relation = -60; game.sector.state.agreements.append("directorate:non_aggression"); ticks(game,95)
	check(not game.conflict.at_war("directorate") and game.conflict.nation("directorate").warning == 0,"Non-aggression prevents automatic escalation despite embargo")
	game.sector.state.agreements.erase("directorate:non_aggression"); ticks(game,91)
	check(game.conflict.at_war("directorate") and enemy.embargo,"Ignored warning leads to real war and embargo")
	game.tick(); check(game.conflict.state.raid.phase == "inbound","War produces a warned raid rather than instant damage")
	var restored := Session.new()
	check(restored.restore_snapshot(game.snapshot()) == OK and restored.snapshot() == game.snapshot(),"War and inbound threat restore atomically")
	var before: Dictionary = restored.snapshot(); var bad: Dictionary = game.snapshot(); bad.conflict.raid.hull = 10000
	check(restored.restore_snapshot(bad) != OK and restored.snapshot() == before,"Forged raid hull is rejected without partial restore")
	bad = game.snapshot(); bad.conflict.raid.faction = "unknown"
	check(restored.restore_snapshot(bad) != OK and restored.snapshot() == before,"Unknown attacker rejected")
	bad = game.snapshot(); bad.conflict.raid.phase = "attacking"
	check(restored.restore_snapshot(bad) != OK,"Impossible arrival phase rejected")
	bad = game.snapshot(); bad.conflict.sites.s0p0.ammo = 13
	check(restored.restore_snapshot(bad) != OK,"Excess battery ammunition rejected")
	bad = game.snapshot(); bad.sector.agreements.append("directorate:alliance")
	check(restored.restore_snapshot(bad) != OK,"Active war cannot preserve an alliance")
	var legacy: Dictionary = pilot().snapshot(); legacy.version = 15; legacy.erase("conflict")
	check(restored.restore_snapshot(legacy) == OK and restored.conflict.state.raid.is_empty(),"Old campaigns receive no invented war or rewards")
	game = pilot(); enemy = game.sector.faction_by_id("directorate"); enemy.relation = 70
	for action: String in ["trade","non_aggression","alliance"]: game.diplomacy.act(game,"directorate",action)
	game.field.state = Field.fresh("s6p0"); game.field.change_flight_mode("orbit"); game.configure_flagship(); game.commerce.state.badges.explorer = 1
	check(game.fleet.command(game,"directorate","recruit",Vector3.ZERO) == "","Alliance supplies a real escort before hostilities")
	check(game.conflict.command(game,"directorate","declare") == "","Explicit declaration is validated")
	check(game.sector.state.agreements.filter(func(s: String) -> bool: return s.begins_with("directorate:")).is_empty(),"War ends all three agreements")
	check(game.fleet.state.ships.directorate.status == "returned","Hostile ally recalls its actual escort")
	check(not game.diplomacy.reason(game,"directorate","gift").is_empty() and not game.diplomacy.reason(game,"directorate","reconcile").is_empty(),"Ordinary gifts and cheap reconciliation cannot bypass wartime peace")
	check(not game.commerce.access(game,"orbit_tender",Field.service_position("orbit_tender")).is_empty(),"Enemy dock access closes immediately")
	check(not game.freight.path_open(game,["s6"]),"War closes existing freight border access")
	game = pilot(); arrive(game)
	check(game.conflict.local(game) and game.conflict.state.raid.hull == 120,"Raid arrival presents a real local hostile hull")
	check(game.conflict.site("morrow").integrity == 100,"No port damage before bombardment warning elapses")
	var energy: float = game.field.state.energy
	check(not game.conflict.fire(game,Vector3(-70,50,-70)).is_empty() and game.field.state.energy == energy,"Out-of-range attack cannot spend energy or damage raider")
	check(game.conflict.fire(game,War.HOME+Vector3(0,0,10)) == "" and game.field.state.energy == energy-10,"Same paid ship weapon damages the raid")
	check(game.field.state.weapon_ready_at == game.field.state.time+Field.LANCE_COOLDOWN and game.field.state.weapon_shots == 1,"Raid fire shares the flagship cooldown and shot counter")
	check(game.conflict.state.raid.hull == 98 and not game.conflict.fire(game,War.HOME).is_empty(),"Weapon damage and cooldown prevent duplicate fire")
	var ship: Vector3 = War.HOME+Vector3(0,0,12)
	check(game.conflict.step(game,ship) == "aim","Raider telegraphs a future aim volume")
	ticks(game,2); var hull: float = game.field.state.hull
	check(game.conflict.step(game,ship+Vector3(12,0,0)) == "miss" and game.field.state.hull == hull,"Moving clear evades raid damage")
	ticks(game,5); game.conflict.step(game,ship); ticks(game,2)
	check(game.conflict.step(game,ship) == "hit" and game.field.state.hull == hull-14,"Remaining inside aim takes actual hull damage")
	check(game.save_to("res://artifacts/conflict-mid.fw") == OK and restored.load_from("res://artifacts/conflict-mid.fw") == OK and restored.snapshot() == game.snapshot(),"Mid-raid hull, aim and damage survive disk save")
	for i: int in range(5):
		ticks(game,2); game.conflict.fire(game,ship)
	check(game.conflict.state.raid.is_empty() and game.conflict.nation("directorate").victories == 1,"Personal interception ends the real raid")
	check(game.conflict.state.defended == ["s0p0"] and game.commerce.progress(game,"defender") == 2,"Distinct defended colony feeds earned progression")
	var victories: int = game.conflict.nation("directorate").victories
	game.conflict.damage(game,500)
	check(game.conflict.nation("directorate").victories == victories,"Ended raids cannot yield repeated wins")
	check(game.conflict.peace_cost("directorate") == 200,"Successful defense gives actual peace bargaining power")
	var marks: float = game.field.marks
	check(game.conflict.command(game,"directorate","peace") == "" and game.field.marks == marks-200,"Peace consumes its displayed price")
	check(not game.conflict.at_war("directorate") and not game.sector.faction_by_id("directorate").embargo,"Negotiated peace opens borders")
	check(not game.conflict.reason(game,"directorate","declare").is_empty(),"Truce prevents immediate redeclaration farming")
	check(restored.restore_snapshot(game.snapshot()) == OK,"Peace and cooldown state restore")
	game = pilot(); marks = game.field.marks; var materials: float = game.sector.state.colonies.s0p0.materials
	check(game.conflict.command(game,"s0p0","battery") == "" and game.field.marks == marks-180 and game.sector.state.colonies.s0p0.materials == materials-60,"Battery is a real paid investment")
	arrive(game); ticks(game,60)
	check(game.conflict.state.raid.is_empty() and game.conflict.site("morrow").ammo == 2,"Autonomous battery expends ten rounds to defeat this raid")
	check(game.conflict.site("morrow").integrity == 40,"Automated defense still incurs port damage before winning")
	check(game.conflict.command(game,"s0p0","repair") == "" and game.conflict.site("morrow").integrity == 100,"Repair restores the damaged port for a real cost")
	check(game.conflict.command(game,"s0p0","rearm") == "" and game.conflict.site("morrow").ammo == 12,"Finite ammunition can be replenished")
	game = pilot(); arrive(game)
	check(not game.conflict.reason(game,"s0p0","battery").is_empty(),"Cannot instantly commission defenses during active bombardment")
	ticks(game,75)
	check(game.conflict.state.raid.is_empty() and game.conflict.site("morrow").integrity == 0,"Undefended raid disables the port instead of silently vanishing")
	check(game.sector.state.colonies.has("s0p0") and game.sector.state.colonies.s0p0.population > 0,"Port raid does not invent population loss or erase ownership")
	check(not game.service_reason("orbit_tender",Field.service_position("orbit_tender"),"recharge").is_empty(),"Disabled home port cannot service the ship")
	check(not game.freight.market_access(game,"morrow").is_empty(),"Disabled destination rejects freight sales")
	check(game.conflict.command(game,"s0p0","repair") == "","After raiders leave a disabled port can be repaired")
	game.field.state.energy = 50; marks = game.field.marks
	check(game.purchase_service("orbit_tender",Field.service_position("orbit_tender"),"recharge") == "" and game.field.marks == marks and game.field.state.energy == 100,"Repaired home port again provides the promised free recharge")
	# Peace recalls the raid without repairing damage or awarding a defense win.
	game = pilot(); arrive(game); ticks(game,15); marks = game.field.marks
	check(game.conflict.command(game,"directorate","peace") == "" and game.field.marks == marks-250,"Peace during attack pays the unmodified price")
	check(game.conflict.state.raid.is_empty() and game.conflict.site("morrow").integrity == 80 and game.conflict.state.defended.is_empty(),"Peace recalls attacker, preserves damage, grants no combat reward")
	game = pilot(); arrive(game); var split: Dictionary = game.snapshot()
	check(restored.restore_snapshot(split) == OK,"Deterministic raid fixture restores")
	ticks(game,75); ticks(restored,75)
	check(game.snapshot() == restored.snapshot(),"Identical tick stream yields identical offscreen raid outcomes")
	# An actual founded outpost, warehouse and carrier suffer persistent remote damage.
	game = pilot(); game.field.change_flight_mode("surface")
	check(game.colonies.buy_kit(game,"basin_port",Field.service_position("basin_port")) == "","Load the real kit for the raid economy fixture")
	game.field.change_flight_mode("orbit"); game.begin_travel("s1p0")
	while game.traveling(): game.tick()
	game.field.start_survey(); ticks(game,12); game.field.change_flight_mode("surface")
	check(game.colonies.deploy(game,Vector2(-6,-18),Vector3(-6,8,-18)) == "","Deploy actual outpost before testing damage")
	ticks(game,540); game.colonies.install(game,"s1p0","water"); game.colonies.state.outposts.s1p0.stock.water = 12
	check(game.freight.configure(game,"s1p0","morrow","water",0) == "","Real carrier connects the outpost to home")
	game.field.change_flight_mode("orbit"); game.conflict.command(game,"consortium","declare"); game.tick()
	check(game.conflict.state.raid.planet == "s1p0","Consortium targets the actual larger warehouse")
	check(game.begin_travel("morrow") == "","Flagship can leave while the warning remains active")
	while game.traveling(): game.tick()
	ticks(game,165)
	check(game.field.state.planet_id == "morrow" and game.conflict.site("s1p0").integrity == 0,"Remote bombardment damages the same outpost while player is home")
	var stock: Dictionary = game.colonies.state.outposts.s1p0.stock.duplicate(true)
	var cargo: int = game.freight.state.routes.s1p0.cargo; var receipts: int = game.freight.state.routes.s1p0.receipts
	ticks(game,30)
	check(game.colonies.state.outposts.s1p0.stock == stock and game.colonies.state.outposts.s1p0.status.contains("disabled"),"Disabled export facility stops producing goods")
	check(game.freight.state.routes.s1p0.cargo == cargo and game.freight.state.routes.s1p0.receipts == receipts and game.freight.state.routes.s1p0.status.contains("disabled"),"Carrier retains its real cargo and cannot fabricate receipts through the outage")
	check(restored.restore_snapshot(game.snapshot()) == OK and restored.snapshot() == game.snapshot(),"Disabled outpost, carrier and war restore together")
	# Real allied hull and attack cooldowns are reused by raids.
	game = pilot(); game.sector.faction_by_id("consortium").relation = 50; game.diplomacy.act(game,"consortium","alliance"); game.tick()
	game.field.state.planet_id = "s7p0"; game.configure_flagship()
	check(game.fleet.command(game,"consortium","recruit",Vector3(0,8,35)) == "","Recruit real allied escort for raid defense")
	game.field.state.planet_id = "morrow"; game.configure_flagship(); arrive(game)
	ship = War.HOME+Vector3(0,0,-18); game.fleet.prepare(game,ship)
	hull = game.conflict.state.raid.hull; game.fleet.assist(game,"raid",true,ship)
	check(game.conflict.state.raid.hull < hull and not game.fleet.flashes.is_empty(),"Existing allied weapon damages selected raid with visible beam data")
	game.conflict.step(game,ship)
	var escort_hull: float = game.fleet.state.ships.consortium.hull
	ticks(game,2); game.conflict.step(game,ship)
	check(game.fleet.state.ships.consortium.hull == escort_hull-14,"Raider targets and damages the nearer allied ship")
	game.fleet.state.ships.consortium.hull = 10.0
	ticks(game,5); game.conflict.step(game,ship); ticks(game,2); game.conflict.step(game,ship)
	check(game.fleet.state.ships.consortium.status == "lost" and game.sector.faction_by_id("consortium").relation == 48,"Raid destroys escort through the existing loss and −7 relations path")
	check(restored.restore_snapshot(game.snapshot()) == OK,"Escort loss and current raid remain loadable together")
	# Actual scene integration: picking, orders, pause and confirmation boundaries.
	game = pilot(); arrive(game)
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); scene.campaign = game; root.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true; scene.save_path = "res://artifacts/conflict-scene.fw"
	scene.conflict_view.refresh(0)
	check(scene.conflict_view.actor.visible and scene.conflict_view.alert.visible,"Actual raid actor and threat alert are visible")
	scene._pick(scene.camera.unproject_position(scene.conflict_view.actor.global_position))
	check(scene.conflict_view.attacking,"Mouse targeting orders raid attack")
	scene.ship.position = War.HOME+Vector3(0,0,10); scene.navigating = true; scene.conflict_view.refresh(0.1)
	check(game.conflict.state.raid.hull == 98 and scene.conflict_view.beam.visible and not scene.navigating,"Visible ship beam and paid damage follow actual order")
	scene._show_popup("conflict"); before = game.snapshot(); scene._process(3)
	check(game.snapshot() == before and not scene.conflict_view.attacking,"Inspection pauses damage and cancels attack orders")
	check(scene.popup_kind == "conflict" and scene.popup.visible,"Defense button opens the real control panel")
	var peace_button: Button
	for b: Node in scene.popup_body.find_children("*","Button",true,false):
		if b.get_meta("conflict_action","") == "peace": peace_button = b
	check(peace_button != null and peace_button.tooltip_text.contains("300"),"Peace control explains the actual truce")
	if peace_button != null: peace_button.pressed.emit()
	check(not game.conflict.at_war("directorate"),"Actual peace button resolves war")
	scene.contacted_faction = "consortium"; scene.conflict_view.act("consortium","declare")
	check(not game.conflict.at_war("consortium") and scene.conflict_view.confirm_war == "consortium","First declaration click reviews consequences only")
	scene.conflict_view.act("consortium","declare")
	check(game.conflict.at_war("consortium"),"Second explicit declaration click commits")
	await process_frame
	check(scene.popup.position.x+scene.popup.size.x <= 1600,"Defense panel fits logical viewport")
	scene.free()
	print("Empire conflict assertions: %d; failures: %d" % [checks,failures]); quit(1 if failures else 0)
