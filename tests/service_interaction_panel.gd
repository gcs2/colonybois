extends "res://tests/service_study_panel.gd"
## Isolated review controls call real campaign commands; never saves or ticks.
var inventory_open: bool=false
var closed: bool=false
var notice: String=""
var tooltip: String=""
var controls: Dictionary={}
func _ready() -> void:
	super._ready()
	var ids: Array[String]=["pack","repair_pack","mega_repair_pack"]
	for i: int in range(ids.size()):
		var id: String=ids[i]
		make_button(id,Rect2(680+(i%2)*132,468+(i/2)*116,116,104),"Energy pack" if id=="pack" else game.field.repair_items()[id].name,func() -> void: selected=id; notice=""; refresh())
	make_button("buy",Rect2(1310,654,140,34),"Buy selected supply",buy)
	make_button("use",Rect2(1310,654,140,34),"Use selected supply",use_supply)
	make_button("refuel",Rect2(1323,342,137,34),"Refuel at this dock",refuel)
	make_button("inventory",Rect2(1176,750,140,32),"Open Inventory",func() -> void: inventory_open=not inventory_open; notice=""; refresh(); controls[selected].grab_focus())
	make_button("exit",Rect2(1336,750,140,32),"Undock",func() -> void: closed=true; hide())
	refresh()
func make_button(key: String, rect: Rect2, title: String, action: Callable) -> void:
	var button:=Button.new(); button.position=rect.position; button.size=rect.size; button.flat=true
	for style: String in ["normal","hover","pressed","focus","disabled"]: button.add_theme_stylebox_override(style,StyleBoxEmpty.new())
	button.mouse_entered.connect(func() -> void: tooltip="Back to dock [Esc]" if key=="inventory" and inventory_open else title; queue_redraw())
	button.mouse_exited.connect(func() -> void: tooltip=""; queue_redraw())
	button.focus_entered.connect(func() -> void: tooltip="Back to dock [Esc]" if key=="inventory" and inventory_open else title; queue_redraw())
	button.focus_exited.connect(func() -> void: tooltip=""; queue_redraw())
	button.pressed.connect(action); add_child(button); controls[key]=button
func use_reason() -> String:
	return game.field.pack_reason() if selected=="pack" else game.field.repair_pack_reason(selected)
func refresh() -> void:
	controls.buy.visible=not inventory_open; controls.use.visible=inventory_open; controls.refuel.visible=not inventory_open
	controls.buy.disabled=not game.service_reason("orbit_tender",scene.ship.position,selected).is_empty()
	controls.refuel.disabled=not game.service_reason("orbit_tender",scene.ship.position,"recharge").is_empty()
	controls.use.disabled=not use_reason().is_empty()
	queue_redraw()
func buy() -> void:
	var reason: String=game.purchase_service("orbit_tender",scene.ship.position,selected)
	notice=reason if not reason.is_empty() else "Last purchase: one pack added to Inventory; ship condition unchanged."
	refresh()
func refuel() -> void:
	var reason: String=game.purchase_service("orbit_tender",scene.ship.position,"recharge")
	notice=reason if not reason.is_empty() else "Refueling complete · energy full."
	refresh()
func use_supply() -> void:
	var reason: String=game.field.use_energy_pack() if selected=="pack" else game.field.use_repair_pack(selected)
	notice=reason if not reason.is_empty() else "Used one pack · ship condition updated."
	refresh()
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:
		if inventory_open: inventory_open=false; refresh(); controls.inventory.grab_focus()
		else: closed=true; hide()
		get_viewport().set_input_as_handled()
func _get_tooltip(_at: Vector2) -> String: return ""
func _draw() -> void:
	if not inventory_open: super._draw()
	else:
		panel(Rect2(650,230,850,570),IVORY)
		text(Vector2(674,267),"INVENTORY / SHIP SUPPLIES",24,DARK)
		text(Vector2(1265,267),"%d Marks" % game.field.marks,23,DARK)
		text(Vector2(680,306),"HULL %d / 100     ENERGY %d / 100" % [game.field.state.hull,game.field.state.energy],19,DARK)
		text(Vector2(680,353),"Use supplies already aboard.",21,DARK)
		text(Vector2(680,386),"Using a pack costs no Marks.",18,DARK)
		var ids: Array[String]=["pack","repair_pack","mega_repair_pack"]
		for i: int in range(3):
			var id: String=ids[i]; var r: Rect2=Rect2(controls[id].position,controls[id].size)
			panel(r,DARK); icon("energy_pack" if id=="pack" else id,Rect2(r.position+Vector2(26,12),Vector2(64,64)))
			text(r.position+Vector2(10,94),"Aboard %d" % (game.field.state.energy_packs if id=="pack" else game.field.state.repair_packs[id]),16)
			if id==selected: corners(r.grow(3),AMBER)
		panel(Rect2(990,440,480,264),DARK)
		text(Vector2(1008,470),"Energy pack" if selected=="pack" else game.field.repair_items()[selected].name,24)
		text(Vector2(1008,502),"Restore up to 50 energy." if selected=="pack" else "Restore up to 75 hull." if selected=="repair_pack" else "Restore all missing hull.",19)
		text(Vector2(1008,535),"Consumes one pack; excess restoration is lost.",18)
		var instruction: String=use_reason() if not use_reason().is_empty() else "Ready to use"
		if selected=="pack" and game.field.state.energy_packs==0: instruction="Back to dock to buy an energy pack."
		var lines:=wrap_reason(instruction)
		for i: int in range(lines.size()): text(Vector2(1008,588+i*23),lines[i],18,AMBER)
		panel(Rect2(1310,654,140,34),IVORY if use_reason().is_empty() else Color("727c75")); text(Vector2(1327,679),"Use one",18,DARK)
		panel(Rect2(1336,750,140,32),DARK); text(Vector2(1361,774),"Undock",18)
	panel(Rect2(24,20,1090,36),DARK); text(Vector2(38,45),"INPUT STUDY · ISOLATED CAMPAIGN / FIXED SHIP · NOT PRODUCTION",18)
	panel(Rect2(1176,750,140,32),DARK); text(Vector2(1190,774),"Back to dock" if inventory_open else "Inventory",18)
	if not notice.is_empty():
		panel(Rect2(670,716,808,28),IVORY); text(Vector2(680,737),notice,18,DARK)
	for b: Button in controls.values():
		if b.visible and b.has_focus(): draw_rect(Rect2(b.position,b.size).grow(3),Color("c28235"),false,2)
	if not tooltip.is_empty():
		panel(Rect2(680,180,796,36),DARK); text(Vector2(695,206),tooltip,19)
