extends Node3D
## Orbital contacts and mouse orders. All encounter progress belongs to SpaceSignals.
const Signals = preload("res://scripts/space_signals.gd")
const UI = preload("res://scripts/flight_interface.gd")
var flight: Node3D
var actors: Dictionary = {}
var ready_for_orders: bool = false
var selected: String = ""
var pending: String = ""
var phase: float = 0
var beam: MeshInstance3D
var signal_button: Button
func setup(owner_view: Node3D) -> void:
	flight = owner_view
	for id: String in Signals.catalog:
		if Signals.catalog[id].planet != flight.model.state.planet_id: continue
		var actor := Node3D.new(); add_child(actor); actors[id] = actor
		actor.position = Signals.position(id)
		var shell := SphereMesh.new(); shell.radius = 1; shell.height = 2; shell.radial_segments = 24; shell.rings = 12
		var outer: Material = flight._mat(Color("7ba9a7") if id == "convoy" else Color("9499b4"))
		var inner: Material = flight._mat(Color("243f51"))
		var light: Material = flight._mat(Color("f1d98b"),true)
		var body: MeshInstance3D = flight._mesh(shell,Vector3.ZERO,outer,actor)
		body.scale = Vector3(1.3,0.85,2.5) if id == "convoy" else Vector3(0.65,2.3,0.65)
		var visor: MeshInstance3D = flight._mesh(shell,Vector3(0,0.2,-1.85) if id == "convoy" else Vector3(0,0,0),inner,actor)
		visor.scale = Vector3(1.0,0.45,0.55) if id == "convoy" else Vector3(0.9,1.0,0.9)
		for side: float in [-1.0,1.0]:
			var pod: MeshInstance3D = flight._mesh(shell,Vector3(side*1.6,-0.35,0.5),outer,actor); pod.scale = Vector3(0.65,0.6,1.8)
			var engine: MeshInstance3D = flight._mesh(shell,Vector3(side*1.6,-0.35,2.1),light,actor); engine.scale = Vector3(0.32,0.32,0.2)
		var ring_mesh := TorusMesh.new(); ring_mesh.inner_radius = 3.0; ring_mesh.outer_radius = 3.06; ring_mesh.rings = 48; ring_mesh.ring_segments = 6
		flight._mesh(ring_mesh,Vector3(0,-1.2,0),light,actor)
	var line := CylinderMesh.new(); line.height = 1; line.top_radius = 0.035; line.bottom_radius = 0.12
	beam = flight._mesh(line,Vector3.ZERO,flight._mat(Color("9bdfc3"),true),self); beam.hide()
func setup_ui(parent: Control) -> void:
	signal_button = flight._button("",flight._show_popup.bind("signals"),parent,"ui_open")
	signal_button.position = Vector2(1508,133); signal_button.size = Vector2(48,44)
	UI.instrument(signal_button,"signal",UI.GOLD)
	signal_button.tooltip_text = "Orbital signals · encounters, commitments and outcomes"
	signal_button.hide()
func cancel(preserve_scan: bool = false) -> void:
	pending = ""
	if not preserve_scan and ready_for_orders: flight.campaign.signals.cancel_scan()
func pick(screen: Vector2) -> bool:
	if flight.model.state.flight_mode != "orbit": return false
	for id: String in actors:
		var actor: Node3D = actors[id]
		if actor.visible and not flight.camera.is_position_behind(actor.global_position) and flight.camera.unproject_position(actor.global_position).distance_to(screen) < 26:
			selected = id; flight._show_popup("signals"); return true
	return false
func order(id: String, action: String) -> void:
	if flight.paused: return
	if action in ["inspect","passage"]:
		var blocked: String = flight.campaign.signals.reason(flight.campaign,id,action,Signals.position(id))
		if not blocked.is_empty(): flight._toast(blocked); flight.audio.play("error"); return
		flight._close_popup(); flight._navigate(Signals.position(id)+Vector3(0,3,-7))
		selected = id; pending = action
		flight._toast("Approaching orbital contact"); return
	var blocked: String = flight.campaign.signals.act(flight.campaign,id,action,flight.ship.position)
	flight._toast(blocked if not blocked.is_empty() else "Decision recorded")
	flight.audio.play("error" if not blocked.is_empty() else "ui_confirm")
	if blocked.is_empty(): flight._save(false)
	if action == "defend" and blocked.is_empty():
		flight._close_popup(); flight._select_weapon(); flight._target_guardian()
	else: flight._show_popup("signals")
	flight._refresh_ui()
func refresh(delta: float, suspended: bool) -> void:
	var game: RefCounted = flight.campaign
	if not suspended: phase += delta
	for id: String in actors:
		var item: Dictionary = game.signals.state.encounters.get(id,{})
		var actor: Node3D = actors[id]
		actor.visible = not item.is_empty() and item.status not in ["declined","failed"]
		actor.position = Signals.position(id)+Vector3(0,sin(phase*0.8)*0.2,0)
		actor.rotation.z = sin(phase*0.6)*0.03
		if not item.is_empty() and item.status == "resolved" and id == "convoy":
			var elapsed: float = float(game.field.state.time-item.resolved_at)
			actor.position.z -= elapsed*elapsed*2.0; actor.visible = elapsed < 5
	if not suspended and not pending.is_empty() and not flight.navigating:
		var blocked: String = game.signals.act(game,selected,pending,flight.ship.position)
		flight._toast(blocked if not blocked.is_empty() else "Registry scan started" if pending == "inspect" else "Passage paid")
		flight.audio.play("error" if not blocked.is_empty() else "scan_complete")
		pending = ""; flight._save(false); flight._refresh_ui()
	beam.visible = false
	for id: String in actors:
		var item: Dictionary = game.signals.state.encounters.get(id,{})
		if not item.get("channeling",false): continue
		beam.visible = true
		var at: Vector3 = Signals.position(id); var axis: Vector3 = at-flight.ship.position
		var y: Vector3 = axis.normalized(); var x: Vector3 = y.cross(Vector3.FORWARD).normalized()
		if x.length() < 0.1: x = y.cross(Vector3.RIGHT).normalized()
		beam.position = (at+flight.ship.position)*0.5; beam.basis = Basis(x,y*axis.length(),x.cross(y))
func refresh_hud() -> void:
	if signal_button == null: return
	var game: RefCounted = flight.campaign
	var open: Array = game.signals.open_ids()
	signal_button.visible = not game.signals.state.encounters.is_empty() and not flight._inspection_open()
	signal_button.disabled = flight.paused
	signal_button.tooltip_text = "Orbital signals · %d open · click for decisions and outcomes" % open.size()
	for id: String in open:
		var item: Dictionary = game.signals.state.encounters[id]
		if item.status == "active" and Signals.catalog[id].kind == "convoy":
			signal_button.tooltip_text += "\nConvoy: %d seconds left to disable the cutter" % maxi(0,item.deadline-int(game.field.state.time))
			flight.objective.text = "Convoy departure · %d s · disable the cutter" % maxi(0,item.deadline-int(game.field.state.time))
		if item.channeling:
			flight.subject.text = "Registry scan"; flight.explanation.text = "%d / 6 s · hold position" % item.progress
			flight.progress_bar.value = float(item.progress)/6; flight.use_button.disabled = true
func copy(parent: Control, text: String, tint: Color = UI.PAPER) -> void:
	var label: Label = flight._label(text,16,tint); label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL; parent.add_child(label)
func build_panel() -> void:
	var game: RefCounted = flight.campaign
	var ids: Array = game.signals.state.encounters.keys()
	if ids.is_empty(): flight._panel_copy("Survey other worlds from orbit to locate optional signals."); return
	if selected not in ids: selected = str(ids[0])
	var tabs := HBoxContainer.new(); flight.popup_body.add_child(tabs)
	for id: String in ids:
		var button: Button = flight._button(Signals.catalog[id].title,func() -> void: selected = id; flight._show_popup("signals"),tabs)
		button.disabled = selected == id; button.icon = UI.icon("signal")
		button.tooltip_text = Signals.catalog[id].planet+" · "+str(game.signals.state.encounters[id].status)
	var spec: Dictionary = Signals.catalog[selected]; var item: Dictionary = game.signals.state.encounters[selected]
	var introduction := HBoxContainer.new(); introduction.add_theme_constant_override("separation",18); flight.popup_body.add_child(introduction)
	var portrait := preload("res://scripts/alien_portrait.gd").new(); portrait.faction_id = spec.faction
	portrait.custom_minimum_size = Vector2(210,155); introduction.add_child(portrait)
	var dialogue := VBoxContainer.new(); dialogue.size_flags_horizontal = Control.SIZE_EXPAND_FILL; introduction.add_child(dialogue)
	copy(dialogue,game.diplomacy.profiles[spec.faction].speaker+" · "+game.field.Geography.definition(spec.planet).name,UI.GOLD)
	copy(dialogue,spec.briefing)
	if item.status in ["resolved","failed","declined"]:
		copy(flight.popup_body,spec.outcomes[item.choice].summary)
		copy(flight.popup_body,"Outcome saved in Chronicle. This encounter cannot be repeated.",UI.MUTED)
		return
	copy(flight.popup_body,"Evidence recovered. Choose who receives it." if item.status == "decision" else spec.summary,UI.MUTED)
	var actions: Array = ["defend","passage","decline"] if spec.kind == "convoy" else ["inspect","decline"]
	if spec.kind == "convoy" and item.status == "active":
		copy(flight.popup_body,"Departure window: %d seconds · disable the Rake cutter" % maxi(0,item.deadline-int(game.field.state.time)),UI.GOLD)
		actions = ["passage","abandon"]
	elif item.status == "decision": actions = ["publish","license","decline"]
	elif item.channeling:
		copy(flight.popup_body,"Scan paused at %d / 6 seconds. Close inspection to continue." % item.progress,UI.GOLD)
		actions = ["decline"]
	for action: String in actions:
		var offer: Dictionary = spec.choices.get(action,{"label":"Abandon escort commitment","icon":"decline","hint":"Convoy turns back; −4 consortium relations. No reward.","detail":"−4 consortium relations · no reward"})
		var at: Vector3 = Signals.position(selected) if action in ["inspect","passage"] else flight.ship.position
		var blocked: String = game.signals.reason(game,selected,action,at)
		var button: Button = flight._button(offer.label,order.bind(selected,action),flight.popup_body)
		UI.instrument(button,offer.icon,UI.GOLD if action in ["defend","inspect"] else UI.NAV)
		button.set_meta("signal_action",action); button.disabled = flight.paused or not blocked.is_empty()
		button.tooltip_text = offer.hint+("\n"+blocked if not blocked.is_empty() else "")
		copy(flight.popup_body,blocked if not blocked.is_empty() else offer.detail,UI.MUTED)
