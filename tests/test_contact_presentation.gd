extends SceneTree
## Actor continuity and real command feedback; not an art or acting acceptance test.
const Session = preload("res://scripts/expedition_session.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1; printerr("FAIL: "+message)
func _initialize() -> void: call_deferred("run")
func catalogue(scene: Node) -> Node:
	for child: Node in scene.popup_body.find_children("*","HBoxContainer",true,false):
		if child.get_script() == preload("res://scripts/upgrade_shop.gd"): return child
	return null
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
	check(actor.texture.resource_path.ends_with("tavi-portrait-v1.png"),"Tavi uses the concept-derived runtime portrait")
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
	scene.model.change_flight_mode("orbit")
	scene.ship.position = Vector3(0,8,8)
	scene._contact_select("consortium")
	var dock: Dictionary = scene._contact_dock_context()
	check(dock.id == "orbit_tender" and not dock.docked and dock.reason.is_empty(),"Remote channel offers an approach to the actual local orbital provider")
	before = scene.campaign.snapshot()
	scene._contact_dock()
	check(not scene.popup.visible and scene.service_order == "orbit_tender" and scene.campaign.snapshot() == before,"Approach closes the inspection and issues navigation without teleporting or charging")
	scene.ship.position = scene.Model.service_position("orbit_tender")
	scene._contact_select("consortium")
	dock = scene._contact_dock_context()
	check(dock.docked and str(dock.label).begins_with("Dock services"),"Within reach the same action offers dock services")
	scene._contact_dock()
	check(scene.popup.visible and scene.popup_kind == "service" and scene.selected_service == "orbit_tender","Docked contact opens the real service panel")
	scene.model.state.planet_id = "s7p0"
	scene.campaign.sector.faction_by_id("consortium").embargo = true
	scene._contact_select("consortium")
	dock = scene._contact_dock_context()
	check("embargo" in str(dock.reason),"Embargo explains why local services cannot be used")
	before = scene.campaign.snapshot()
	scene._contact_dock()
	check(scene.popup_kind == "contact" and scene.campaign.snapshot() == before,"Blocked dock action keeps contact open and leaves campaign untouched")
	scene.campaign.sector.faction_by_id("consortium").embargo = false
	scene._show_popup("contact")
	actor = scene.contact_portrait
	actor.clock = 7.0
	scene._contact_dock()
	check(scene.popup_kind == "service" and scene.contact_portrait == actor and actor.clock == 7.0,"Local representative persists from contact into the dock shop")
	for page: String in ["upgrades","energy","warehouse","fleet","climate","market"]:
		scene.dock_page = page; scene._show_popup("service")
		check(scene.contact_portrait == actor and actor.clock == 7.0,"Shop drawer retains the representative: "+page)
		if page == "energy":
			var labels: Array = []
			for button: Node in scene.popup_body.find_children("*","Button",true,false): labels.append(button.text)
			check("Energy full" in labels and not labels.any(func(label: String) -> bool: return "HOMEWORLD" in label),"Full energy at a foreign dock is not mislabeled free homeworld service")
	scene.dock_page = "upgrades"
	before = scene.campaign.snapshot()
	for family: String in ["ship","hull","energy","support"]:
		scene.upgrade_family = family; scene._show_popup("service")
		var browser: Node = catalogue(scene)
		check(browser != null and not browser.entries.is_empty(),"Catalogue exposes equipment family: "+family)
		for id: String in browser.entries:
			browser.entries[id].pressed.emit()
			check(browser.purchase_button.get_meta("purchase_upgrade_id") == id and scene.upgrade_preview == id,"Selecting equipment updates its purchase target: "+id)
	check(scene.campaign.snapshot() == before,"Browsing all equipment leaves the campaign untouched")
	scene.upgrade_family = "ship"; scene.upgrade_preview = "hold"
	scene.campaign.commerce.state.badges.merchant = 1
	scene.campaign.field.marks = 1000
	scene._show_popup("service")
	var browser: Node = catalogue(scene)
	check(browser.selected_id == "hold" and not browser.purchase_button.disabled,"Eligible equipment opens selected and purchasable")
	scene.campaign.field.marks = 0
	before = scene.campaign.snapshot()
	browser.purchase_button.pressed.emit()
	check(scene.campaign.snapshot() == before,"Purchase revalidates funds after the displayed quote becomes stale")
	scene.campaign.field.marks = 1000; scene._show_popup("service")
	var price: float = scene.campaign.commerce.catalog.upgrades.hold.price
	catalogue(scene).purchase_button.pressed.emit()
	check(scene.campaign.commerce.capacity() == 16 and scene.campaign.field.marks == 1000-price,"Catalogue purchase installs the real upgrade and charges its price")
	check(catalogue(scene).selected_id == "hold" and catalogue(scene).purchase_button.disabled,"Purchased equipment stays selected and cannot be bought twice")
	scene.dock_page = "market"; scene._show_popup("service")
	var cargo_before: int = scene.campaign.commerce.quantity("water")
	scene.trade_amount = 1
	scene._commerce_action("buy","water")
	check(scene.campaign.commerce.quantity("water") == cargo_before+1 and actor.speaking > 0 and actor.mood == "pleased","Real purchase adds cargo and gives a single positive response")
	actor._process(3.0); scene._show_popup("service")
	check(actor.speaking == 0,"Shopping refresh does not repeat acceptance")
	scene.campaign.field.marks = 0
	before = scene.campaign.snapshot()
	scene._commerce_action("buy","water")
	check(scene.campaign.snapshot() == before and actor.mood == "wary","Unaffordable purchase cannot mutate cargo or funds and gives refusal")
	scene._show_popup("contact")
	check(scene.contact_portrait == actor,"Returning from shop to communications retains the local actor")
	scene.model.state.planet_id = "s12p0"
	dock = scene._contact_dock_context()
	check(dock.id.is_empty() and not str(dock.reason).is_empty(),"World without a provider offers an explicit unavailable state")
	check(not scene.model.service_reason("orbit_tender",scene.ship.position).is_empty(),"Direct service query on an unserviced world safely refuses")
	scene._show_popup("service")
	check(scene.popup.visible,"Stale provider selection produces an unavailable panel without crashing")
	await process_frame
	scene.free()
	print("Contact presentation: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
