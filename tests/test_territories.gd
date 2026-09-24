extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
const C = preload("res://scripts/surface_combat.gd")
const Catalog = preload("res://scripts/territory_catalog.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("FAIL: "+text)
func pilot(id: String = "s6p0") -> RefCounted:
	var game := Session.new(); game.field.state = Field.fresh(id); game.field.bind_account(game.sector.state)
	game.configure_flagship(); game.field.marks = 900
	for s: Dictionary in game.sector.state.systems: s.visited = true
	if Catalog.catalog.has(id): game.diplomacy.contact(game,Catalog.catalog[id].owner)
	return game
func ticks(game: RefCounted, amount: int) -> void:
	for i: int in range(amount): game.tick()
func hit(game: RefCounted, part: String, times: int) -> void:
	var at: Vector3 = C.home(game.field.state.planet_id,part)+Vector3(0,7,8)
	for i: int in range(times):
		var result: String = game.combat.fire(game,"surface_laser",part,C.home(game.field.state.planet_id,part),at)
		if not result.is_empty(): push_error("Unexpected shot refusal: "+result); failures += 1
		game.tick()
func surrender(game: RefCounted) -> void:
	game.conflict.command(game,Catalog.catalog[game.field.state.planet_id].owner,"declare"); hit(game,"civic",10)
func run() -> void:
	var game: RefCounted = pilot(); var id: String = "s6p0"; var at: Vector3 = C.home(id,"civic")+Vector3(0,7,8)
	check(not game.field.definition().sites.is_empty() and C.profiles(id).size() == 6,"Foreign holding has a real landing site and six combat structures/guards")
	var before: Dictionary = game.snapshot()
	check(not game.combat.fire(game,"surface_laser","civic",Vector3.ZERO,at).is_empty() and game.snapshot() == before,"Peace prevents accidental hostile fire without spending energy")
	check(game.combat.step(game,at) == "","Friendly colony guards hold fire")
	game.conflict.command(game,"directorate","declare")
	check(game.combat.step(game,at) == "aim","War activates real colony defenses")
	ticks(game,2); var hull: float = game.field.state.hull; game.combat.step(game,at)
	check(game.field.state.hull < hull,"Colony weapons damage the existing flagship hull")
	game = pilot(); var energy: float = game.field.state.energy; surrender(game)
	check(game.territory.world(id).phase == "surrendered" and game.combat.world(id).units.civic.hull == 80,"Ten precise hits force surrender with the civic hall intact")
	check(game.field.state.energy == energy-50,"Surrender uses actual purchased/finite ship energy")
	check(game.combat.step(game,at) == "","Surrendered defenses cease fire")
	before = game.snapshot()
	check(not game.combat.fire(game,"surface_laser","civic",Vector3.ZERO,at).is_empty() and game.snapshot() == before,"Surrender stops the attack instead of automatically destroying the colony")
	var saved := Session.new()
	check(game.save_to("res://artifacts/surrender.fw") == OK and saved.load_from("res://artifacts/surrender.fw") == OK and saved.snapshot() == game.snapshot(),"Damaged structures, surrender, war and paid energy round-trip through disk")
	var owner_before: String = game.owner_of(id)
	check(not game.territory.command(game,id,"annex",Vector3(70,50,70)).is_empty() and game.owner_of(id) == owner_before,"Annexation requires actual proximity")
	var marks: float = game.field.marks; energy = game.field.state.energy
	check(game.territory.command(game,id,"annex",at) == "","Accept the colony's surrender")
	check(game.sector.state.planets[id].owner == "player" and game.sector.state.colonies.has(id),"Annexation changes actual planet ownership and colony administration")
	check(game.colonies.state.outposts[id].module == "alloy" and game.colonies.state.outposts[id].stock.alloy == 8,"Surviving factory and finite reserve become the player's real outpost")
	check(game.territory.world(id).stock == 0 and game.field.marks == marks and game.field.state.energy == energy,"Capture transfers rather than duplicates stock and grants no money or recharge")
	check(game.conflict.site(id).integrity == 33,"Port inherits actual hall damage")
	check(game.commerce.progress(game,"defender") == 0,"Damaging civilian infrastructure grants no Defender kills")
	check(game.commerce.state.badges.conqueror == 1 and game.commerce.progress(game,"colonist") == 0,"Distinct annexation earns Conqueror without also counting as founding a colony")
	check(game.territory.eliminated("directorate") and not game.conflict.at_war("directorate"),"Losing its last holding ends that government's war")
	check(game.diplomacy.state.keys.has("eliminated:directorate") and game.conflict.state.raid.is_empty(),"Final territorial defeat is recorded and its expeditionary raid withdraws")
	before = game.snapshot()
	check(not game.territory.command(game,id,"annex",at).is_empty() and game.snapshot() == before,"Capture cannot be repeated for another reserve or colony")
	check(saved.restore_snapshot(game.snapshot()) == OK and saved.snapshot() == game.snapshot(),"Annexed economy, damaged port and territorial defeat restore together")
	game.field.change_flight_mode("orbit")
	check(game.commerce.access(game,"orbit_tender",Field.service_position("orbit_tender")) == "","Captured planet's dock no longer obeys its old owner's embargo")
	for badge: String in game.commerce.state.badges:
		if badge != "conqueror": game.commerce.state.badges[badge] = 0
	marks = game.field.marks; hull = game.field.state.hull
	check(game.commerce.buy_upgrade(game,"orbit_tender",Field.service_position("orbit_tender"),"hull_1") == "" and game.field.marks == marks-160,"Conqueror alone opens the real paid hull upgrade")
	check(game.field.state.hull == hull,"Buying the unlocked hull does not repair battle damage")
	check(game.colonies.collect(game,"orbit_tender",Field.service_position("orbit_tender"),"alloy",2) == "" and game.colonies.state.outposts[id].stock.alloy == 6,"Inherited warehouse supplies actual cargo through the existing collection action")
	var reserve: int = game.colonies.state.outposts[id].stock.alloy; ticks(game,60)
	check(game.colonies.state.outposts[id].stock.alloy > reserve,"Captured works continue aggregate production")
	# Mixed systems retain each neighboring planet's true market owner.
	game = pilot("s7p0"); surrender(game)
	check(game.territory.command(game,"s7p0","annex",C.home("s7p0","civic")) == "","Capture one world of a multi-world empire")
	check(game.owner_of("s7p0") == "" and game.owner_of("s7p1") == "consortium" and game.sector.system_by_id("s7").contested,"Ownership is planetary; neighboring hostile holding remains distinct")
	check(not game.territory.eliminated("consortium") and game.conflict.at_war("consortium"),"One captured colony does not erase a surviving empire")
	check(game.freight.market_access(game,"s7p0") == "" and not game.freight.market_access(game,"s7p1").is_empty(),"Freight access respects friendly and hostile ports in the same system")
	# Intentional refusal reopens battle; final destruction has a different persistent result.
	game = pilot(); surrender(game); game.diplomacy.contact(game,"commune")
	var relation: int = game.sector.faction_by_id("commune").relation
	check(game.territory.command(game,id,"refuse",at) == "" and game.territory.world(id).refused,"Refusing surrender is a deliberate recorded choice")
	hit(game,"civic",5)
	check(game.territory.world(id).phase == "ruined" and game.sector.state.planets[id].owner == "","Further weapon damage destroys the hall and leaves unclaimed ruins")
	check(not game.sector.state.colonies.has(id) and not game.colonies.state.outposts.has(id) and game.territory.world(id).stock == 0,"Destruction awards neither colony nor duplicate cargo")
	check(game.sector.faction_by_id("commune").relation == relation-25,"Other contacted societies react to destroyed infrastructure")
	game.field.change_flight_mode("orbit")
	check(not game.service_reason("orbit_tender",Field.service_position("orbit_tender"),"recharge").is_empty() and not game.freight.market_access(game,id).is_empty(),"Ruin closes services and freight market")
	check(saved.restore_snapshot(game.snapshot()) == OK and saved.snapshot() == game.snapshot(),"Ruin, lost ownership and diplomatic reactions are durable")
	before = saved.snapshot(); var bad: Dictionary = game.snapshot(); bad.territory.worlds[id].phase = "annexed"
	check(saved.restore_snapshot(bad) != OK and saved.snapshot() == before,"Contradictory captured/ruined save is rejected atomically")
	bad = game.snapshot(); bad.territory.ruined.append(id)
	check(saved.restore_snapshot(bad) != OK,"Duplicate territory outcomes rejected")
	bad = game.snapshot(); bad.territory.worlds[id].stock = 8
	check(saved.restore_snapshot(bad) != OK,"Destroyed warehouse cannot reappear through loading")
	var legacy: Dictionary = pilot().snapshot(); legacy.version = 16; legacy.erase("territory"); legacy.commerce.badges.erase("conqueror")
	check(saved.restore_snapshot(legacy) == OK and saved.territory.state.captured.is_empty() and saved.commerce.state.badges.conqueror == 0,"v16 campaigns migrate without invented conquests or badge rewards")
	game = pilot(); surrender(game)
	bad = game.snapshot(); bad.combat.worlds[id].units.civic.hull = 240
	check(saved.restore_snapshot(bad) != OK,"A surrender save needs actual damage, not just a chronicle key")
	bad = game.snapshot(); bad.territory.worlds.erase(id)
	check(saved.restore_snapshot(bad) != OK,"Dropping the territorial record cannot erase an existing surrender")
	game.sector._create_colony("s1p0",false)
	game.sector.state.settlements.s2p0 = {"source":"s0p0","remaining":18,"duration":18,"delivered":true}
	before = game.snapshot()
	check(not game.territory.command(game,id,"annex",at).is_empty() and game.snapshot() == before,"Both completed colonies and committed construction reserve the three-site cap")
	# Destroyed industry stays absent after capture until a paid replacement is installed.
	game = pilot(); game.conflict.command(game,"directorate","declare"); hit(game,"industry",6); hit(game,"civic",4)
	check(game.territory.world(id).phase == "surrendered" and game.combat.world(id).units.industry.hull == 0,"Surrounding infrastructure damage contributes to surrender pressure")
	check(game.territory.command(game,id,"annex",at) == "" and game.colonies.state.outposts[id].module == "","Annexing a destroyed factory does not invent a working export module")
	marks = game.field.marks
	check(game.colonies.install(game,id,"alloy") == "" and game.field.marks == marks-60 and game.combat.world(id).units.industry.hull == 96,"Paid replacement restores the physical factory and production together")
	check(saved.restore_snapshot(game.snapshot()) == OK,"Repaired captured industry survives save validation")
	# Ruins accept an actually purchased kit and the existing timed construction project.
	game = pilot("morrow"); marks = game.field.marks
	check(game.colonies.buy_kit(game,"basin_port",Field.service_position("basin_port")) == "" and game.field.marks == marks-300,"Reconstruction starts with a paid, cargo-reserving home kit")
	game.field.state = Field.fresh(id); game.field.bind_account(game.sector.state); game.configure_flagship(); game.diplomacy.contact(game,"directorate"); surrender(game)
	game.territory.command(game,id,"refuse",at); hit(game,"civic",5)
	game.field.change_flight_mode("orbit"); game.field.start_survey(); ticks(game,12); game.field.change_flight_mode("surface")
	var deployment: String = game.colonies.deploy(game,Vector2(-6,-18),C.home(id,"civic")+Vector3(0,5,0))
	check(deployment == "" and not game.sector.state.colonies.has(id),"Destroyed world requires a survey and physical kit deployment, not instant reconstruction: "+deployment)
	ticks(game,540)
	check(game.sector.state.colonies.has(id) and game.sector.state.planets[id].owner == "player" and game.colonies.state.outposts[id].module == "","Eighteen colony days rebuild only the paid hub, not the ruined industrial settlement")
	check(game.territory.port_reason(game,id) == "" and game.territory.state.captured.is_empty(),"Rebuilt services reopen without granting Conqueror")
	var rebuilt_save: Error = saved.restore_snapshot(game.snapshot())
	check(rebuilt_save == OK and saved.snapshot() == game.snapshot(),"Reconstruction preserves the earlier ruin, new colony, costs and survey: "+error_string(rebuilt_save))
	# Military flight may enter a hostile destination; freight cannot borrow that permission.
	game = pilot("s3p0"); game.field.change_flight_mode("orbit"); game.diplomacy.contact(game,"directorate"); game.conflict.command(game,"directorate","declare")
	check(game.quote(id).reason == "" and game.sector.route_between("s3","s6",true).is_empty(),"War permits an explicit flagship incursion while civilian border remains closed")
	energy = game.field.state.energy
	check(game.begin_travel(id) == "" and game.field.state.energy < energy,"Incursion uses the real paid journey")
	while game.traveling(): game.tick()
	check(game.field.state.planet_id == id and game.field.change_flight_mode("surface"),"Hostile journey arrives and permits real descent")
	# Large area damage can destroy multiple structures; paid precise fire can preserve them.
	game = pilot(); game.commerce.state.upgrades.append("ground_bomb"); game.field.installed_upgrades = game.commerce.state.upgrades; game.conflict.command(game,"directorate","declare")
	var point: Vector3 = C.home(id,"civic")
	check(game.combat.fire(game,"ground_bomb","",point,point+Vector3(0,10,0)) == "","Existing purchased bomb can target enemy colony ground")
	check(game.combat.world(id).units.civic.hull == 240,"Bomb launch does not instantly apply damage")
	ticks(game,2)
	check(game.combat.world(id).units.civic.hull == 190 and game.combat.world(id).units.industry.hull == 46,"Real blast radius damages multiple structures after its flight delay")
	# Real scene actor, click and surrender controls, preserving inspection pause.
	game = pilot(); surrender(game)
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); scene.campaign = game; root.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true; scene.save_path = "res://artifacts/territory-scene.fw"
	scene.ship.position = at; scene.surface_combat_visual.refresh(game,"civic",0,0,true); scene._update_camera(1)
	check(scene.surface_combat_visual.actors.size() == 6,"Scene renders the actual colony and defensive units")
	scene._pick(scene.camera.unproject_position(C.home(id,"civic")))
	check(scene.popup_kind == "territory" and scene.popup.visible,"Clicking surrendered hall opens colony terms")
	before = game.snapshot(); scene._process(5)
	check(game.snapshot() == before,"Terms inspection pauses shared combat and economy")
	var annex: Button
	for b: Node in scene.popup_body.find_children("*","Button",true,false):
		if b.get_meta("territory_action","") == "annex": annex = b
	check(annex != null and not annex.disabled and annex.tooltip_text.contains("three"),"Actual annex button explains administration capacity")
	if annex != null: annex.pressed.emit()
	check(game.territory.world(id).phase == "annexed" and game.sector.state.colonies.has(id),"Actual button transfers the colony")
	scene._update_outpost_visual()
	check(scene.outpost_visual == null,"Capture does not spawn a second prefab over the existing hall")
	scene.free()
	for holding: String in Catalog.catalog:
		game = pilot(holding); surrender(game)
		check(game.territory.command(game,holding,"annex",C.home(holding,"civic")) == "" and saved.restore_snapshot(game.snapshot()) == OK,"Authored colony footprint and capture restore: "+holding)
	ticks(game,61); ticks(saved,61)
	check(saved.snapshot() == game.snapshot(),"Restored territorial economy and conflict continue deterministically")
	print("Territory assertions: %d; failures: %d" % [checks,failures]); quit(1 if failures else 0)
