extends SceneTree
## Actor continuity and real command feedback; not an art or acting acceptance test.
const Session = preload("res://scripts/expedition_session.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1; printerr("FAIL: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = Session.new()
	scene.save_path = "res://artifacts/contact-presentation-test.json"
	root.add_child(scene)
	scene.save_path = "res://artifacts/contact-presentation-test.json"
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	for id: String in ["consortium","directorate"]: scene.campaign.diplomacy.contact(scene.campaign,id)
	scene.campaign.field.marks = 300
	scene._contact_select("consortium")
	var actor: Control = scene.contact_portrait
	check(actor != null and actor.speaking == 0,"Opening contact creates a listening actor")
	actor.clock = 9.0
	var before: Dictionary = scene.campaign.snapshot()
	for page: String in ["exchange","fleet","conflict","agreements"]:
		scene.contact_page = page; scene._show_popup("contact")
		check(scene.contact_portrait == actor and actor.clock == 9.0,"Drawer keeps the actor and presentation clock: "+page)
	check(scene.campaign.snapshot() == before,"Browsing does not advance or mutate campaign state")
	scene._contact_action("gift")
	check(scene.campaign.field.marks == 180 and actor.mood == "pleased" and actor.speaking > 0,"Committed grant spends actual Marks and produces acceptance")
	actor._process(1.0)
	var remaining: float = actor.speaking
	scene.contact_page = "exchange"; scene._show_popup("contact")
	check(scene.contact_portrait == actor and actor.speaking == remaining,"Drawer refresh does not restart the response")
	actor._process(3.0)
	scene._show_popup("contact")
	check(actor.speaking == 0,"Completed response stays complete after refresh")
	before = scene.campaign.snapshot()
	scene._contact_action("gift")
	check(scene.campaign.snapshot() == before and not scene.contact_accepted and actor.mood == "wary","Rejected repeat grant has no economic mutation and signals refusal")
	actor._process(3.0); scene._show_popup("contact")
	check(actor.speaking == 0,"Refusal is not replayed on tab refresh")
	scene._close_popup()
	check(scene.contact_portrait == null and scene.contact_reply.is_empty(),"Closing clears the response and actor reference immediately")
	scene._show_popup("contact")
	check(scene.contact_portrait != actor and scene.contact_portrait.speaking == 0,"Reopening creates a fresh listening encounter without stale acceptance")
	actor = scene.contact_portrait
	scene._contact_select("directorate")
	check(scene.contact_portrait != actor and scene.contact_portrait.faction_id == "directorate","A different faction gets its own representative")
	scene._show_popup("cargo")
	check(scene.contact_portrait == null and scene.contact_reply.is_empty(),"Leaving communications clears its presentation")
	scene._contact_select("consortium"); scene.popup.hide()
	check(scene.contact_portrait == null,"Direct panel dismissal also releases the actor")
	await process_frame
	scene.free()
	print("Contact presentation: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
