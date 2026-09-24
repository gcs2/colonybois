extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
const Bio = preload("res://scripts/planet_biosphere.gd")
const Geography = preload("res://scripts/planet_geography.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+title)
func ticks(game: RefCounted, count: int) -> void:
	for i: int in range(count): game.tick()
func dock(game: RefCounted) -> Vector3: return Field.service_position("orbit_tender" if game.field.state.flight_mode == "orbit" else "basin_port")
func recharge(game: RefCounted) -> void:
	if game.field.state.energy < 100: game.purchase_service("orbit_tender" if game.field.state.flight_mode == "orbit" else "basin_port",dock(game),"recharge")
func collect_set(game: RefCounted) -> void:
	for id: String in Bio.native_species(game.field.state.planet_id):
		var at: Vector3 = game.biosphere.site(game.field.state.planet_id,id)
		game.biosphere.act(game,id,"scan",at)
		check(game.biosphere.act(game,id,"collect",at).is_empty(),"Collect distinct native species "+id)
func travel(game: RefCounted, planet: String) -> void:
	game.field.change_flight_mode("orbit")
	check(game.begin_travel(planet).is_empty(),"Begin paid voyage to "+planet)
	for i: int in range(120):
		if not game.traveling(): break
		game.tick()
	check(game.field.state.planet_id == planet,"Arrive with shared specimen hold at "+planet)
	game.field.change_flight_mode("surface")
func release_point(planet: String, index: int) -> Vector3:
	var flat := Vector2(-10+index*1.5,10)
	return Vector3(flat.x,Geography.surface_height(Geography.definition(planet),flat.x,flat.y)+1.5,flat.y)
func run() -> void:
	var game := Session.new(); game.field.marks = 5000; game.commerce.state.badges.explorer = 2
	check(Bio.data().size() == 18 and game.biosphere.used() == 0 and game.biosphere.complete_tier("morrow") == 1,"Fresh campaign has native roles and no fabricated collected specimens")
	var before: Dictionary = game.snapshot()
	check(not game.biosphere.act(game,"moss_lantern","collect",Bio.position("morrow","moss_lantern")).is_empty() and game.snapshot() == before,"Unscanned collection is rejected without mutation")
	check(not game.biosphere.act(game,"moss_lantern","scan",Vector3(100,100,100)).is_empty(),"Scanning requires real proximity")
	collect_set(game)
	check(game.biosphere.used() == 6 and game.field.state.energy == 70,"Six distinct captures use six hold units and thirty energy")
	before = game.snapshot()
	check(not game.biosphere.act(game,"moss_lantern","scan",Bio.position("morrow","moss_lantern")).is_empty() and game.snapshot() == before,"Repeated scans cannot farm new history")
	travel(game,"s1p0"); collect_set(game)
	check(game.biosphere.used() == 12,"Specimens from two worlds fill the shared hold")
	before = game.snapshot()
	check(not game.biosphere.act(game,"glass_moss","collect",game.biosphere.site("s1p0","glass_moss")).is_empty() and game.snapshot() == before,"Full cargo rejects collection without losing native stock")
	recharge(game); travel(game,"s2p0"); recharge(game)
	game.field.change_flight_mode("orbit")
	for id: String in ["cool_ray","cloud_accumulator"]: check(game.commerce.buy_upgrade(game,"orbit_tender",dock(game),id).is_empty(),"Buy usable climate equipment "+id)
	check(game.field.start_survey().is_empty(),"Pay for a real orbital survey")
	ticks(game,12)
	for id: String in ["cool_ray","cool_ray","cool_ray","cloud_accumulator","cloud_accumulator"]:
		recharge(game); check(game.climate.start(game,id,Vector3(0,8,0)).is_empty(),"Deploy paid pulse "+id); ticks(game,8)
	game.field.change_flight_mode("surface"); recharge(game)
	check(game.climate.effects("s2p0").tier == 3 and game.climate.effects("s2p0").ecological_tier == 1,"Climate potential does not grant unbuilt ecosystem tiers")
	var at: Vector3 = release_point("s2p0",0)
	before = game.snapshot()
	check(not game.biosphere.act(game,"veil_maw","release",at,at).is_empty() and game.snapshot() == before,"Predator cannot establish before its food chain")
	var first: Array = Bio.native_species("morrow")
	for i: int in range(first.size()):
		at = release_point("s2p0",i)
		check(game.biosphere.act(game,first[i],"release",at,at).is_empty(),"Release first transported food-chain member "+str(first[i]))
		if i == 2: check(game.biosphere.plant_tier("s2p0") == 2 and game.biosphere.complete_tier("s2p0") == 1,"Three plants stabilize T2 before the animal chain is complete")
	check(game.biosphere.complete_tier("s2p0") == 2 and game.climate.effects("s2p0").population_cap == 240,"Completed second food chain changes real colony capacity")
	var saved: Dictionary = game.snapshot(); var loaded := Session.new()
	check(loaded.restore_snapshot(saved) == OK and loaded.snapshot() == saved,"Snapshot retains cross-world cargo, introductions, selected sites and earned outcomes")
	var second: Array = Bio.native_species("s1p0")
	for i: int in range(second.size()):
		at = release_point("s2p0",6+i)
		check(game.biosphere.act(game,second[i],"release",at,at).is_empty(),"Release final transported food-chain member "+str(second[i]))
	check(game.biosphere.used() == 0 and game.biosphere.complete_tier("s2p0") == 3 and game.biosphere.state.completed.size() == 2,"Distinct ecological milestones occur once as cargo is consumed")
	check(game.climate.effects("s2p0").population_cap == 360 and game.colonies.yield_for("s2p0","glass",game) == 4,"Full ecosystem supplies real T3 population and production capacity")
	ticks(game,900)
	check(game.climate.score(game.climate.world("s2p0")) == 3 and game.biosphere.complete_tier("s2p0") == 3,"Plant-complete climate cannot drift out of its established T3 ring")
	# Active damage still breaks a stabilized ring, then kills unsupported tiers after warning time.
	game.climate.state.worlds.s2p0.temperature = 0.0; game.climate.state.worlds.s2p0.atmosphere = 0.0
	ticks(game,29)
	check(game.biosphere.world("s2p0").stress == 29 and game.biosphere.species("s2p0").size() == 18,"Species receive a grace period while climate is unsuitable")
	game.tick()
	check(game.biosphere.species("s2p0").is_empty() and game.biosphere.plant_tier("s2p0") == 0,"Sustained hostile climate removes unsupported life and stabilization")
	check(game.diplomacy.state.events.any(func(e: Dictionary) -> bool: return e.kind == "ecology" and e.summary.begins_with("Habitat loss")),"Actual habitat loss enters the chronicle")
	check(loaded.restore_snapshot(game.snapshot()) == OK,"Extinction remains loadable with bounded empty ecological slots")
	before = loaded.snapshot(); var corrupt: Dictionary = before.duplicate(true)
	corrupt.biosphere.cargo["invented"] = 1
	check(loaded.restore_snapshot(corrupt) != OK and loaded.snapshot() == before,"Unknown species cannot partially replace the campaign")
	corrupt = saved.duplicate(true); corrupt.biosphere.worlds.s2p0.layers[1].small = "veil_maw"
	check(loaded.restore_snapshot(corrupt) != OK,"Wrong ecological roles and duplicated species are rejected")
	corrupt = saved.duplicate(true); corrupt.biosphere.worlds.s2p0.sites.moss_lantern = [NAN,0,0]
	check(loaded.restore_snapshot(corrupt) != OK,"Nonfinite release positions are rejected")
	corrupt = saved.duplicate(true); corrupt.biosphere.cargo.glass_moss = 13
	check(loaded.restore_snapshot(corrupt) != OK,"Forged hold overflow is rejected")
	var legacy: Dictionary = Session.new().snapshot(); legacy.version = 12; legacy.erase("biosphere")
	check(loaded.restore_snapshot(legacy) == OK and loaded.biosphere.used() == 0,"Legacy campaigns receive no free cargo or completed introductions")
	var remote := Session.new()
	remote.biosphere.state.worlds["s1p0"] = Bio.fresh("s1p0")
	remote.biosphere.state.worlds.s1p0.stress = 29
	remote.climate.state.worlds["s1p0"] = {"temperature":0.0,"atmosphere":0.0,"disturbed":true,"drift_clock":0,"project":{}}
	remote.climate.bind(remote); remote.tick()
	check(remote.diplomacy.state.events.back().location == "s1p0" and remote.field.state.planet_id == "morrow","Off-screen extinction is attributed to its actual world in the chronicle")
	# Scene: actual pick, arrival/beam operation, stop, inspection, inventory selection and release.
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); scene.campaign = Session.new(); root.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true; scene.save_path = "res://artifacts/biosphere_scene.fw"
	var bio: Node3D = scene.biosphere_view; var id := "moss_lantern"
	at = scene.campaign.biosphere.site("morrow",id); scene.ship.position = at+Vector3(0,5,3); scene._update_camera(1)
	scene._select_tool("scan"); bio.refresh(0,true)
	scene._pick(scene.camera.unproject_position(bio.actors[id].position))
	check(bio.action == "scan","Clicking a visible organism starts the selected scanner")
	for i: int in range(120): scene._physics_process(1.0/60); bio.refresh(1.0/60,false)
	check(id in scene.campaign.biosphere.state.catalogued,"Scene approach and timed scan catalogue the organism")
	scene._select_tool("collect"); bio.order(id,"collect",at); scene._stop(); bio.refresh(3,false)
	check(scene.campaign.biosphere.used() == 0,"Stop cancels collection before spending or adding cargo")
	bio.order(id,"collect",at); scene._show_popup("cargo"); bio.refresh(3,true)
	check(scene.campaign.biosphere.used() == 0,"Inspection cancels the pending operation without a background capture")
	scene._close_popup(); bio.order(id,"collect",at)
	for i: int in range(120): scene._physics_process(1.0/60); bio.refresh(1.0/60,false)
	check(scene.campaign.biosphere.used() == 1 and scene.model.state.energy == 95,"Completed scene tractor operation spends five energy and loads one specimen")
	scene._cargo_tab("specimens")
	var specimen: Button
	for button: Node in scene.popup_body.find_children("*","Button",true,false):
		if button.get_meta("specimen_id","") == id: specimen = button
	check(specimen != null,"Inventory exposes the actual carried species")
	if specimen != null: specimen.pressed.emit()
	check(bio.deploy_id == id and not scene.popup.visible and scene.campaign.biosphere.used() == 1,"Inventory selection equips release without consuming the specimen")
	var held_phase: float = bio.phase; bio.refresh(2,true)
	check(bio.phase == held_phase,"Inspection freezes specimen animation")
	scene._show_popup("biosphere")
	check(scene.popup.visible and scene.popup_kind == "biosphere","Ecosystem slot inspection is integrated into the real flight UI")
	scene.free()
	var release_game := Session.new(); release_game.restore_snapshot(saved)
	var release_scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); release_scene.campaign = release_game
	root.add_child(release_scene); release_scene.set_process(false); release_scene.set_physics_process(false); release_scene.audio.muted = true
	release_scene.save_path = "res://artifacts/biosphere_release_scene.fw"
	var release_view: Node3D = release_scene.biosphere_view
	at = release_point("s2p0",8); release_scene.ship.position = at+Vector3(0,5,3); release_scene._update_camera(1)
	release_view.select_specimen("glass_moss")
	var count_before: int = release_game.biosphere.used()
	release_scene._pick(release_scene.camera.unproject_position(at-Vector3(0,1.5,0)))
	check(release_view.action == "release" and release_game.biosphere.used() == count_before,"Terrain click begins release without prematurely spending cargo")
	for i: int in range(120): release_scene._physics_process(1.0/60); release_view.refresh(1.0/60,false)
	check(release_game.biosphere.used() == count_before-1 and "glass_moss" in release_game.biosphere.species("s2p0"),"Arriving and completing the beam establishes the selected carried species")
	release_view.refresh(0,true)
	check(release_view.actors.glass_moss.visible and (release_view.actors.glass_moss.position+Vector3(0,1.5,0)).distance_to(release_game.biosphere.site("s2p0","glass_moss")) < 0.01,"Released plant is rooted at the persisted chosen surface site")
	check(loaded.restore_snapshot(release_game.snapshot()) == OK and loaded.biosphere.site("s2p0","glass_moss") == release_game.biosphere.site("s2p0","glass_moss"),"Actual mouse release location survives save and load")
	release_scene.free()
	print("Planet biosphere assertions: %d; failures: %d" % [checks,failures]); quit(1 if failures else 0)
