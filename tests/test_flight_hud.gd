extends SceneTree
## Command integration through HUD controls, not an assertion of native-input/art approval.
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1; printerr("FAIL: "+message)
func click_chart(chart: Control, at: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = at
	chart._gui_input(event)
func press(scene: Node, key: Key, shift: bool = false, ctrl: bool = false) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.pressed = true
	event.shift_pressed = shift
	event.ctrl_pressed = ctrl
	scene._unhandled_input(event)
func run() -> void:
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	scene.set_physics_process(false)
	scene.audio.muted = true
	var hud: Control = scene.hud
	scene._activate_selected()
	var state: Dictionary = scene.model.state.duplicate(true)
	var subject: String = scene.selected
	press(scene,KEY_TAB)
	check(hud.active_group == "Environment" and scene.selected == subject and scene.approach_subject,"Tab browses palettes without cycling targets or cancelling the active order")
	press(scene,KEY_TAB,true)
	check(hud.active_group == "Main tools" and scene.tool == "scan" and scene.model.state == state,"Shift-Tab reverses browsing without spending or selecting")
	var bar_position: Vector2 = hud.energy_bar.position
	hud.collapse_button.pressed.emit()
	check(not hud.palette_expanded and not hud.toolbar[0].visible and hud.energy_bar.visible and hud.energy_bar.position == bar_position,"Collapse hides items while keeping ship condition fixed")
	press(scene,KEY_2)
	check(scene.tool == "scan" and scene.approach_subject,"Collapsed item shortcuts cannot accidentally select invisible tools")
	hud.category_buttons.Environment.pressed.emit()
	check(hud.palette_expanded and hud.toolbar[2].visible and hud.slot_labels.warm.text == "1" and hud.slot_labels.seed.text == "2","Opening a category labels its own visible slots")
	press(scene,KEY_9)
	press(scene,KEY_1,false,true)
	check(scene.tool == "scan" and scene.approach_subject,"Empty first- and second-row slots do nothing")
	hud.category_buttons.Environment.pressed.emit()
	check(scene.tool == "scan" and scene.approach_subject,"Browsing a category preserves active tool and approach")
	check(scene.model.state == state and not scene._inspection_open(),"Palette browsing neither mutates nor pauses the simulation")
	hud.toolbar[2].pressed.emit()
	check(scene.tool == "warm" and not scene.approach_subject,"Equipping a new tool cancels the previous operation")
	check(scene.model.state == state,"Equipping consumes no energy or cargo")
	scene._select_tool("scan")
	hud.category_buttons.Environment.pressed.emit()
	press(scene,KEY_1)
	check(scene.tool == "warm" and hud.selected_tool == "warm" and scene.model.state == state,"Visible slot 1 selects the same thermal tool as clicking its icon")
	scene._show_popup("systems")
	scene._equip_from_panel("collect")
	check(scene.tool == "collect" and not scene.popup.visible,"Selecting installed equipment from inspection returns to flight and actually equips it")
	scene._select_tool("scan")
	scene._refresh_ui()
	click_chart(hud.navigation,hud.navigation.project(hud.navigation.points.relay))
	check(scene.selected == "relay" and scene.approach_subject,"Chart contact click issues the real approach/tool command")
	for i: int in range(600):
		scene._physics_process(1.0/60)
		scene._operate(1.0/60)
	scene._refresh_ui()
	check("relay" in scene.model.state.scanned and hud.action_state.text == "COMPLETE","Completed chart scan records discovery and shows completion")
	check(scene.progress_bar.value == 1,"Completion leaves a filled confirmation meter briefly")
	scene._update_camera(1)
	scene._pick(scene.camera.unproject_position(scene._target_position("pod")))
	check(scene.selected == "pod" and (scene.approach_subject or scene.held),"A new subject click after completion starts the next survey without an extra cancel click")
	scene._stop()
	click_chart(hud.navigation,hud.navigation.project(Vector2(-24,22)))
	check(scene.navigating and scene.destination.x < -23 and scene.destination.z > 21,"Open chart click navigates to the corresponding terrain coordinate")
	scene._stop()
	scene._refresh_ui()
	check(hud.action_state.text == "CANCELLED" and not scene.navigating,"Cancel is a distinct, truthful order state")
	scene._toggle_pause()
	click_chart(hud.navigation,hud.navigation.project(Vector2(20,20)))
	check(not scene.navigating,"Chart commands are rejected during pause even before the next HUD refresh")
	scene._toggle_pause()
	scene._show_popup("cargo")
	click_chart(hud.navigation,hud.navigation.project(Vector2(20,20)))
	check(not scene.navigating,"Inspection also blocks chart navigation")
	scene.popup.hide()
	scene.model.state.scanned.append("bed")
	scene.model.state.energy = 10
	scene.selected = "bed"
	scene._select_tool("warm")
	scene._refresh_ui()
	check(hud.action_state.text == "UNAVAILABLE" and "25 required" in scene.explanation.text,"Shortage appears before committing an operation")
	scene.use_button.pressed.emit()
	check(not scene.held and not scene.model.state.warm and scene.model.state.energy == 10,"Insufficient-energy use cannot execute or consume resources")
	scene.model.state.scanned.append("pod")
	scene.model.state.samples = 2
	scene.selected = "pod"
	scene._select_tool("collect")
	scene._refresh_ui()
	scene.use_button.pressed.emit()
	check("full" in scene.explanation.text and scene.model.state.native_stock == 3,"Full cargo rejects collection without losing native stock")
	check("Cargo: 2 / 2" in hud.quick_cargo.tooltip_text,"Quick cargo reflects actual onboard capacity")
	scene._change_flight_mode("orbit")
	scene._refresh_ui()
	check(scene.use_button.disabled and scene.toolbar.all(func(b: Button) -> bool: return b.disabled),"Surface equipment is unavailable in orbit")
	hud.category_buttons.Environment.pressed.emit()
	var orbit_tool: String = scene.tool
	press(scene,KEY_1)
	check(scene.tool == orbit_tool and "atmosphere" in hud.toolbar[2].tooltip_text,"Wrong-view equipment explains why it is unavailable and cannot be selected")
	hud.category_buttons.Weapons.pressed.emit()
	click_chart(hud.navigation,hud.navigation.project(hud.navigation.planet_at))
	check(scene.landing and scene.navigating and scene.model.state.flight_mode == "orbit","Orbital chart planet issues landing approach without teleportation")
	check(scene.energy_bar.size.y <= 12,"Energy instrument does not overlap equipment controls")
	scene._stop()
	var before_select: Dictionary = scene.model.state.duplicate(true)
	hud.weapon_button.pressed.emit()
	check(scene.weapon_selected and not scene.attack_order and scene.model.state == before_select,"Selecting a weapon does not attack, move or consume energy")
	scene.weapon_selected = false
	press(scene,KEY_1)
	check(scene.weapon_selected and not scene.attack_order and scene.model.state == before_select,"Weapon keyboard selection follows the visible slot and does not fire")
	scene._command_target("guardian")
	check(scene.attack_order,"Clicking a target with the selected weapon issues combat")
	scene._stop()
	var escape := InputEventKey.new()
	escape.physical_keycode = KEY_ESCAPE
	escape.pressed = true
	scene._unhandled_input(escape)
	check(scene.popup.visible and scene.popup_kind == "menu" and scene.menu_shade.visible,"Escape opens a modal game menu")
	var category: String = hud.active_group
	press(scene,KEY_TAB)
	hud.category_buttons.Inventory.pressed.emit()
	hud.item_buttons.pack.pressed.emit()
	check(hud.active_group == category and scene.model.state == before_select,"Fresh modal guards block palette and item commands before another render")
	var at: Vector3 = scene.ship.position
	scene._physics_process(1)
	check(scene.ship.position == at and scene._inspection_open(),"Game menu pauses flight")
	var slot := InputEventKey.new()
	slot.physical_keycode = KEY_5; slot.pressed = true
	scene.weapon_selected = false
	scene._unhandled_input(slot)
	check(not scene.weapon_selected,"Gameplay hotkeys cannot act behind the menu")
	scene._menu_page("audio")
	scene._unhandled_input(escape)
	check(scene.popup_kind == "menu" and scene.popup.visible,"Escape from menu settings returns to the menu")
	scene._unhandled_input(escape)
	check(not scene.popup.visible and not scene.menu_shade.visible and not scene.paused,"Escape closes menu and restores unpaused state")
	scene._toggle_pause()
	scene._unhandled_input(escape); scene._unhandled_input(escape)
	check(scene.paused,"Closing the menu preserves a prior explicit pause")
	scene._toggle_pause()
	scene.model.state.energy = 20
	scene.model.state.energy_packs = 1
	scene._show_popup("cargo")
	var pack: Button
	for child: Node in scene.popup_body.get_children():
		if child is Button and child.text.begins_with("Energy pack ×"): pack = child
	check(pack != null and not pack.disabled,"Inventory exposes the real usable pack item")
	pack.pressed.emit()
	check(scene.model.state.energy == 70 and scene.model.state.energy_packs == 0 and scene.popup_kind == "cargo" and scene.popup.visible,"Inventory item consumes exactly one pack and refreshes the inventory")
	scene.popup.hide()
	scene.model.state.energy_packs = 2
	scene.model.state.energy = 10
	scene.model.state.pack_ready_at = scene.model.state.time
	hud.category_buttons.Inventory.pressed.emit()
	scene._refresh_ui()
	check(hud.count_labels.pack.text == "× 2" and not hud.item_buttons.pack.disabled,"Quick inventory shows the actual owned stack")
	var selected_item: String = hud.selected_tool
	press(scene,KEY_1)
	hud.item_buttons.pack.pressed.emit()
	check(scene.model.state.energy == 60 and scene.model.state.energy_packs == 1,"Keyboard then repeated click consumes only one pack during cooldown")
	check(hud.selected_tool == selected_item and not scene.attack_order,"Self-use preserves the equipped weapon and never creates a target order")
	scene._refresh_ui()
	check(hud.item_buttons.pack.disabled and "8s" in hud.count_labels.pack.text and "Ready in 8 s" in hud.item_buttons.pack.tooltip_text,"Remaining count and cooldown belong to the inventory item")
	scene._toggle_pause()
	var before_pause: Dictionary = scene.model.state.duplicate(true)
	hud.category_buttons.Weapons.pressed.emit()
	press(scene,KEY_1)
	check(scene.model.state == before_pause and hud.active_group == "Inventory","Explicit pause blocks both palette browsing and item use")
	scene._toggle_pause()
	var utility_buttons: int = 0
	for child: Node in hud.get_children():
		if child is Button and child.text in ["Save","Load","Audio","Controls","Menu","Recharge","SHROUD ON"]: utility_buttons += 1
	check(utility_buttons == 0,"Flight HUD contains no utility footer or direct recharge/shroud button")
	scene.free()
	print("Flight HUD assertions: ",checks,"; failures: ",failures)
	quit(0 if failures == 0 else 1)
