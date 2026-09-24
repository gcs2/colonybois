extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: "+message)
func _initialize() -> void: call_deferred("run")
func travel(game: RefCounted, id: String) -> void:
	game.field.change_flight_mode("orbit")
	check(game.begin_travel(id).is_empty(),"Reach next system through real travel: "+id)
	for i: int in range(60):
		if not game.traveling(): break
		game.tick()
func run() -> void:
	check_greetings()
	var game := Session.new()
	var d: RefCounted = game.diplomacy
	var before: Dictionary = game.snapshot()
	check(not d.act(game,"consortium","trade").is_empty() and game.snapshot() == before,"Cannot negotiate with an unknown faction")
	game.commerce.export_alloy(game,"basin_port",Field.service_position("basin_port"),8)
	travel(game,"s2p0")
	game.commerce.transact(game,"orbit_tender",Field.service_position("orbit_tender"),"alloy",8,false)
	travel(game,"s4p0")
	travel(game,"s7p0")
	check(game.sector.faction_by_id("consortium").contacted and d.state.keys.has("contact:consortium"),"Actual arrival establishes contact and records it once")
	check("consortium" in d.unread(),"First contact remains visibly pending until the channel is opened")
	var contact_count: int = d.state.events.size()
	d.contact(game,"consortium"); d.contact(game,"consortium")
	check(d.state.events.size() == contact_count,"Repeated hail does not repeat first contact")
	var base_buy: int = game.commerce.price("s7p0","glass",true,game)
	var base_sell: int = game.commerce.price("s7p0","glass",false,game)
	check(d.act(game,"consortium","trade").is_empty(),"Encountered faction accepts an eligible agreement")
	check(game.commerce.price("s7p0","glass",true,game) < base_buy and game.commerce.price("s7p0","glass",false,game) > base_sell,"Agreement changes actual transaction prices")
	check(game.commerce.price("s7p0","glass",true,game) > game.commerce.price("s7p0","glass",false,game),"Preferred prices retain a spread, preventing local arbitrage")
	check(game.commerce.price("s2p0","glass",true,game) == game.commerce.price("s2p0","glass",true),"Treaty prices apply only in the partner's territory")
	var quoted: int = game.commerce.price("s7p0","glass",true,game)
	var trade_balance: float = game.field.marks
	check(game.commerce.transact(game,"orbit_tender",Field.service_position("orbit_tender"),"glass",1,true).is_empty() and game.field.marks == trade_balance-quoted,"Transaction debits the treaty quote, not the old base price")
	check(d.state.events.back().cause == d.state.keys["pact:consortium:trade"],"Completed trade links to the agreement that set its price")
	before = game.snapshot()
	check(not d.act(game,"consortium","trade").is_empty() and game.snapshot() == before,"Signing twice cannot farm trust")
	check(not d.act(game,"consortium","alliance").is_empty(),"Alliance has a real trust threshold")
	var money: float = game.field.marks
	check(d.act(game,"consortium","gift").is_empty() and game.field.marks == money-120,"Goodwill is funded by the preceding cargo sale")
	before = game.snapshot()
	check(not d.act(game,"consortium","gift").is_empty() and game.snapshot() == before,"Grant cannot be spammed for trust")
	check(not game.sector.system_by_id("s11").get("charted",false) and not game.sector.system_by_id("s11").visited,"Detected frontier star initially has no detailed planetary chart")
	check(d.act(game,"consortium","alliance").is_empty() and game.sector.is_revealed("s11"),"Alliance supplies usable navigation knowledge")
	check(not game.sector.system_by_id("s11").visited and game.quote("s11p0").reason.is_empty(),"Shared chart permits travel without falsely awarding a visit")
	check(d.act(game,"consortium","non_aggression").is_empty(),"Transit pledge is signable after contact")
	var f: Dictionary = game.sector.faction_by_id("consortium")
	f.relation = -20; f.embargo = true
	check(not game.sector.route_between("s4","s7",true).is_empty(),"Transit pledge survives a trade embargo")
	before = game.snapshot()
	check(not game.commerce.transact(game,"orbit_tender",Field.service_position("orbit_tender"),"glass",1,true).is_empty() and game.snapshot() == before,"Embargo still blocks trade despite transit rights")
	check(d.act(game,"consortium","cancel_non_aggression").is_empty() and game.sector.route_between("s4","s7",true).is_empty(),"Withdrawing transit agreement closes embargoed passage")
	var last: Dictionary = d.state.events.back()
	check(last.cause > 0 and d.state.events[last.cause-1].outcome.action == "non_aggression","Breach history refers to the agreement actually withdrawn")
	check(last.outcome.relation_before == -20 and last.outcome.relation_after == -40,"Historical outcome preserves its before/after values")
	game.field.marks = 100
	check(d.act(game,"consortium","reconcile").is_empty() and game.field.marks == 20 and not f.embargo,"Reconciliation spends real money and reopens access")
	travel(game,"s4p0")
	check(not d.act(game,"consortium","chart").is_empty(),"Cannot license an uncharted world")
	check(game.field.start_survey().is_empty(),"Commission real orbital survey with remaining energy")
	for i: int in range(12): game.tick()
	check(d.state.keys.has("survey:s4p0"),"Survey completion records an exploration event")
	money = game.field.marks
	check(d.act(game,"consortium","chart").is_empty() and game.field.marks == money+25,"Completed survey can be licensed for a real return")
	d.contact(game,"commune")
	before = game.snapshot()
	check(not d.act(game,"commune","chart").is_empty() and game.snapshot() == before,"Exclusive chart cannot be sold to another partner")
	var path: String = "res://artifacts/diplomacy.fw"
	check(game.save_to(path) == OK,"Save the diplomatic journey")
	var loaded := Session.new()
	check(loaded.load_from(path) == OK and loaded.snapshot() == game.snapshot(),"Agreements, charts, gifts, exclusivity, history and cause IDs survive save/load")
	var original_name: String = d.state.events[d.state.keys["contact:consortium"]-1].actor.name
	f.name = "Renamed government"
	check(d.state.events[d.state.keys["contact:consortium"]-1].actor.name == original_name,"Later renaming cannot rewrite historical identity")
	before = game.snapshot()
	var invalid: Dictionary = before.duplicate(true)
	invalid.diplomacy.events[0].cause = 999
	check(game.restore_snapshot(invalid) != OK and game.snapshot() == before,"Malformed causal history fails atomically")
	invalid = before.duplicate(true); invalid.diplomacy.next_id = 1
	check(game.restore_snapshot(invalid) != OK and game.snapshot() == before,"Invalid event sequence fails without replacing campaign")
	var old: Dictionary = Session.new().snapshot()
	old.version = 3; old.erase("diplomacy")
	check(loaded.restore_snapshot(old) == OK and loaded.diplomacy.state.events.size() == 1 and loaded.diplomacy.state.events[0].kind == "archive","Older saves gain an honest recording boundary, not invented past decisions")
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = game
	root.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false)
	scene.save_path = "res://artifacts/diplomacy_ui.json"
	scene.contacted_faction = "commune"
	scene._show_popup("contact")
	scene.contact_page = "agreements"; scene._show_popup("contact")
	await process_frame
	var acted: bool = false
	for button: Button in scene.popup_body.find_children("*","Button",true,false):
		if button.text.begins_with("Trade agreement"):
			button.pressed.emit(); acted = true; break
	check(acted and "commune:trade" in game.sector.state.agreements,"Native contact button executes a validated pact")
	check("commune" not in d.unread(),"Opening the channel acknowledges that contact only")
	var game_time: int = game.field.state.time
	var portraits: Array = scene.popup_body.find_children("*","Control",true,false).filter(func(node: Node) -> bool: return node.get_script() == preload("res://scripts/alien_portrait.gd"))
	check(portraits.size() == 1,"Contact includes the original species portrait")
	if portraits.size() == 1:
		var portrait: Control = portraits[0]
		var clock_before: float = portrait.clock
		portrait._process(0.25)
		check(portrait.clock > clock_before and game.field.state.time == game_time,"Portrait animation does not advance paused simulation")
	check(scene.popup_body.get_combined_minimum_size().x < scene.popup.size.x-20,"Contact screen fits the desktop panel width")
	scene._show_popup("journal")
	await process_frame
	check(scene.popup_body.get_combined_minimum_size().x <= 535,"Chronicle filters fit the panel width")
	scene.free()
	print("Expedition diplomacy assertions: %d; failures: %d" % [checks,failures])
	quit(1 if failures else 0)

func check_greetings() -> void:
	var legacy := Session.new()
	legacy.sector.faction_by_id("consortium").contacted = true
	check(legacy.diplomacy.answer(legacy,"consortium") and legacy.diplomacy.state.keys.has("read:consortium") and not legacy.diplomacy.state.keys.has("contact:consortium"),"Legacy known civilization remembers the call without fabricating first contact")
	var snapshot: Dictionary = legacy.snapshot()
	check(not legacy.diplomacy.answer(legacy,"consortium") and legacy.snapshot() == snapshot,"Repeated acknowledgment never duplicates history")
	check(not legacy.diplomacy.answer(legacy,"commune") and legacy.snapshot() == snapshot,"Uncontacted civilization cannot be acknowledged remotely")
	for id: String in ["directorate","consortium","commune"]:
		var game := Session.new()
		var d: RefCounted = game.diplomacy
		d.contact(game,id)
		var profile: Dictionary = d.profiles[id]
		var faction: Dictionary = game.sector.faction_by_id(id)
		faction.relation = 50
		var before: Dictionary = game.snapshot()
		check(d.greeting(game,id) == profile.greeting and game.snapshot() == before,"First greeting identifies the speaker even with high relations: "+id)
		d.acknowledge(id)
		check(d.greeting(game,id) == profile.friendly,"Previously answered friendly contact recognizes the player: "+id)
		faction.relation = 0
		check(d.greeting(game,id) == profile.repeat,"Neutral repeat does not introduce the speaker again: "+id)
		check(d.act(game,id,"trade").is_empty() and d.greeting(game,id) == profile.trading,"Signed trade agreement changes the next greeting: "+id)
		faction.relation = 50
		check(d.act(game,id,"alliance").is_empty() and d.greeting(game,id) == profile.allied,"Alliance greeting takes precedence over trade: "+id)
		var restored := Session.new()
		check(restored.restore_snapshot(game.snapshot()) == OK and restored.diplomacy.greeting(restored,id) == profile.allied,"Acknowledgment and contextual greeting survive restore: "+id)
		faction.embargo = true
		check(d.greeting(game,id) == profile.hostile,"Closed markets cannot offer a warm trading greeting: "+id)
		check(game.conflict.command(game,id,"declare").is_empty() and d.greeting(game,id) == profile.war,"Actual war replaces peaceful greetings: "+id)
