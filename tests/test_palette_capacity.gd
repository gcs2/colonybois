extends SceneTree
const HUD = preload("res://scripts/flight_hud.gd")
const Fixture = preload("res://tests/palette_fixture.gd")
var checks: int = 0
var failures: int = 0
var actions: Array[String] = []
func _initialize() -> void: call_deferred("run")
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1; printerr("FAIL: "+message)
func run() -> void:
	var hud := HUD.new()
	root.add_child(hud)
	await process_frame
	Fixture.populate(hud)
	hud.action_requested.connect(func(action: String) -> void: actions.append(action))
	check(hud.item_buttons.values().filter(func(button: Button) -> bool: return button.visible).size() == 18,"A dense category shows exactly one 18-item page")
	check(hud.page_next.visible and not hud.page_next.disabled and hud.page_previous.disabled,"Paging advertises overflow and disables the unavailable direction")
	var rectangles: Array[Rect2] = []
	var fits: bool = true
	for button: Button in hud.item_buttons.values():
		if not button.visible: continue
		var rect: Rect2 = button.get_rect()
		fits = fits and Rect2(760,744,542,117).encloses(rect)
		for previous: Rect2 in rectangles: fits = fits and not previous.intersects(rect)
		rectangles.append(rect)
	check(fits,"All 18 controls fit the item area without overlap or clipping")
	hud.activate_slot(9)
	check(actions.back() == "item:layout_fixture_07" and hud.slot_labels.layout_fixture_07.text == "Ctrl+1","Second-row shortcut selects the corresponding visible item")
	hud._internal_action("page_next")
	check(hud.palette_page == 1 and hud.page_next.disabled and not hud.page_previous.disabled,"Last page is reachable and bounded")
	check(hud.item_buttons.values().filter(func(button: Button) -> bool: return button.visible).size() == 9,"A partial final page hides entries from the previous page")
	hud.activate_slot(0)
	check(actions.back() == "item:layout_fixture_16","Page-relative slot 1 dispatches the correct stable item ID")
	var count: int = actions.size()
	hud.activate_slot(9)
	check(actions.size() == count,"Empty second-row slots on the final page cannot activate hidden items")
	hud._internal_action("palette_toggle")
	hud.activate_slot(0)
	check(actions.size() == count and not hud.page_next.visible and hud.energy_bar.visible,"Collapsing a dense category disables slots and hides page controls, retaining ship status")
	hud._internal_action("category:Weapons")
	check(hud.palette_page == 0 and hud.weapon_button.visible and not hud.page_next.visible,"Changing category resets pagination without stale overflow controls")
	hud.set_orbital_mode(true)
	check(not hud.navigation.visible and not hud.chart_backing.visible and not hud.chart_heading.visible,"Orbital flight has no local terrain chart")
	hud.set_orbital_mode(false)
	check(hud.navigation.visible and hud.chart_backing.visible,"Entering a planet restores its local chart")
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3840,2160)]:
		root.size = resolution
		await process_frame
		check(hud.energy_bar.get_rect().end.x <= 1600 and hud.navigation.get_rect().end.y <= 900 and root.size == resolution,"HUD design bounds fit scaled viewport %s" % resolution)
	hud.free()
	print("Palette capacity assertions: ",checks,"; failures: ",failures)
	quit(0 if failures == 0 else 1)
