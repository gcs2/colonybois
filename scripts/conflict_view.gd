extends Node3D
## Shared raid state presented as an orbital actor, mouse target and defense/transmission panel.
const War = preload("res://scripts/empire_conflict.gd")
const C = preload("res://scripts/surface_combat.gd")
const UI = preload("res://scripts/flight_interface.gd")
var flight: Node3D
var actor: Node3D
var aim: MeshInstance3D
var beam: MeshInstance3D
var port: Node3D
var port_shell: MeshInstance3D
var port_light: MeshInstance3D
var port_guns: Array = []
var hull_label: Label
var alert: Button
var button: Button
var attacking: bool = false
var actor_faction: String = ""
var confirm_war: String = ""
var selected_site: String = "s0p0"
var flash: float = 0
var last_tick: int = -1
func setup(view: Node3D) -> void:
	flight = view
	var ball := SphereMesh.new(); ball.radius = 4; ball.height = 8; ball.radial_segments = 24; ball.rings = 12
	var warning: StandardMaterial3D = flight._mat(Color("e88870"),true)
	warning.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA; warning.albedo_color.a = 0.16; warning.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	aim = flight._mesh(ball,Vector3.ZERO,warning,self); aim.hide()
	var line := CylinderMesh.new(); line.height = 1; line.top_radius = 0.07; line.bottom_radius = 0.12
	beam = flight._mesh(line,Vector3.ZERO,flight._mat(Color("efb090"),true),self); beam.hide()
	port = Node3D.new(); add_child(port); port.position = War.Field.service_position("orbit_tender")+Vector3(0,2,0)
	var kit := preload("res://scripts/hostile_vessel.gd").new()
	var armor: Material = kit.ink("789997"); var recess: Material = kit.ink("263b43")
	var cargo: Material = kit.ink("c8c4a2"); var light: Material = kit.ink("b9e6c8",true)
	port_shell = kit.pod(port,Vector3.ZERO,Vector3(2.1,0.8,2.5),armor)
	kit.pod(port,Vector3(0,0.7,-0.5),Vector3(1.2,0.3,1.1),recess)
	port_light = kit.pod(port,Vector3(0,1.2,-0.5),Vector3(0.35,0.4,0.35),light)
	for side: float in [-1.0,1.0]:
		var arm: MeshInstance3D = kit.pod(port,Vector3(side*2.6,-0.3,0.8),Vector3(1.9,0.35,0.8),armor); arm.rotation.y = side*0.45
		kit.pod(port,Vector3(side*2.1,0.2,1.3),Vector3(0.65,0.55,1.5),cargo)
		kit.pod(port,Vector3(side*3.5,-0.25,-0.15),Vector3(0.2,0.18,0.25),light)
		port_guns.append(kit.pod(port,Vector3(side*1.1,0.35,-2.2),Vector3(0.3,0.3,0.9),recess))
	kit.free()
func setup_ui(root: Control) -> void:
	button = flight._button("",flight._show_popup.bind("conflict"),root,"ui_open")
	button.position = Vector2(1450,133); button.size = Vector2(48,44); UI.instrument(button,"defense",UI.CARGO)
	button.tooltip_text = "Colony defense · threats, port repairs, batteries and peace negotiations"
	alert = flight._button("",flight._show_popup.bind("conflict"),root,"ui_open")
	alert.position = Vector2(530,140); alert.size = Vector2(520,44); UI.instrument(alert,"defense",UI.CARGO); alert.hide()
	hull_label = flight._label("",14,UI.CARGO); root.add_child(hull_label); hull_label.mouse_filter = Control.MOUSE_FILTER_IGNORE; hull_label.hide()
func cancel() -> void: attacking = false
func pick(screen: Vector2) -> bool:
	if actor == null or not actor.visible or flight.camera.is_position_behind(actor.global_position): return false
	if flight.camera.unproject_position(actor.global_position).distance_to(screen) > 30: return false
	flight._cancel_orders(); flight._select_weapon()
	if flight.ship.position.distance_to(actor.position) > 22: flight._navigate(actor.position)
	attacking = true; flight.audio.play("target_lock"); return true
func line(from: Vector3, to: Vector3) -> void:
	var axis: Vector3 = to-from; var y: Vector3 = axis.normalized(); var x: Vector3 = y.cross(Vector3.FORWARD).normalized()
	if x.length() < 0.1: x = y.cross(Vector3.RIGHT).normalized()
	beam.position = (from+to)*0.5; beam.basis = Basis(x,y*axis.length(),x.cross(y)); flash = 0.3
func refresh(delta: float) -> void:
	var game: RefCounted = flight.campaign; var war: RefCounted = game.conflict
	var suspended: bool = flight.paused or flight._inspection_open()
	var present: bool = war.local(game)
	port.visible = game.sector.state.colonies.has(War.strategic(game.field.state.planet_id)) and game.field.state.flight_mode == "orbit"
	var condition: Dictionary = war.site(game.field.state.planet_id)
	var ink: StandardMaterial3D = port_shell.material_override
	ink.albedo_color = Color("795e59") if condition.integrity < 100 else Color("789997")
	var lamp: StandardMaterial3D = port_light.material_override
	lamp.emission = Color("d36f5e") if condition.integrity == 0 else Color("b9e6c8")*0.7
	for gun: MeshInstance3D in port_guns: gun.visible = condition.battery
	if present and actor_faction != war.state.raid.faction:
		if actor != null: actor.free()
		actor = preload("res://scripts/hostile_vessel.gd").new(); add_child(actor)
		actor_faction = war.state.raid.faction
		actor.build({"chase":3,"color":War.data.factions[actor_faction].color})
	if actor != null:
		actor.visible = present
		if present:
			actor.position = C.position(war.state.raid.at)
			var direction: Vector3 = flight.ship.position-actor.position
			if direction.length() > 0.1: actor.rotation.y = atan2(-direction.x,-direction.z)
			if not suspended: actor.advance(delta)
	aim.visible = present and war.state.raid.fire_at > 0 and not suspended
	if aim.visible: aim.position = C.position(war.state.raid.aim)
	if not suspended: flash = maxf(0,flash-delta)
	if last_tick != game.field.state.time:
		last_tick = game.field.state.time
		for event: Dictionary in war.flashes:
			if not port.visible or event.planet != War.strategic(game.field.state.planet_id): continue
			line(C.position(event.at) if event.kind == "bombard" else port.position,port.position if event.kind == "bombard" else C.position(event.at))
			flight.audio.play("scan_complete" if event.kind == "battery" else "error")
	if attacking and present and not suspended and flight.navigating and flight.ship.position.distance_to(C.position(war.state.raid.at)) <= War.Field.LANCE_RANGE*0.85:
		flight.navigating = false; flight.velocity = Vector3.ZERO
	if attacking and not suspended and not flight.navigating:
		if not present: attacking = false
		else:
			var target: Vector3 = C.position(war.state.raid.at)
			var blocked: String = war.fire_reason(game,flight.ship.position)
			if blocked == "Approach within 24 m.": flight._navigate(target); attacking = true
			elif blocked == "":
				war.fire(game,flight.ship.position); line(flight._ship_socket("WeaponEmitter"),target); flight.audio.play("scan_complete")
			elif blocked != "Weapon cooling down.": attacking = false; flight._toast(blocked); flight.audio.play("error")
	beam.visible = flash > 0 and not suspended and game.field.state.flight_mode == "orbit"
	present = war.local(game)
	hull_label.visible = present and not suspended and not flight.camera.is_position_behind(actor.global_position)
	if hull_label.visible:
		hull_label.position = flight.camera.unproject_position(actor.global_position)+Vector2(12,-24)
		hull_label.text = "%s · %d hull" % [War.data.factions[actor_faction].name,war.state.raid.hull]
	refresh_hud()
func refresh_hud() -> void:
	if button == null: return
	var game: RefCounted = flight.campaign; var war: RefCounted = game.conflict
	button.visible = not flight._inspection_open(); button.disabled = flight.paused
	var text: String = ""
	if not war.state.raid.is_empty():
		var r: Dictionary = war.state.raid
		text = str(game.sector.state.planets[r.planet].name)+(" · raid in %d s" % (r.arrival-game.field.state.time) if r.phase == "inbound" else " · port %d%% · under attack" % war.site(r.planet).integrity)
	else:
		for id: String in war.state.nations:
			if war.nation(id).warning > 0: text = "%s · war warning · %d s" % [game.sector.faction_by_id(id).name,war.nation(id).warning-game.field.state.time]; break
	if text.is_empty():
		for id: String in war.state.sites:
			if war.site(id).integrity == 0: text = str(game.sector.state.planets[id].name)+" · port disabled · repairs needed"; break
	alert.text = text; alert.visible = not text.is_empty() and not flight._inspection_open(); alert.disabled = flight.paused
	alert.tooltip_text = "Review the threat, travel to its orbit, prepare local defenses or negotiate peace."
func act(id: String, action: String) -> void:
	if flight.paused: return
	if action == "declare" and confirm_war != id: confirm_war = id; flight._show_popup("conflict"); return
	confirm_war = ""
	var blocked: String = flight.campaign.conflict.command(flight.campaign,id,action)
	flight.audio.play("error" if not blocked.is_empty() else "ui_confirm"); flight._toast(blocked if not blocked.is_empty() else "Order recorded")
	if blocked.is_empty(): flight._save(false)
	flight._show_popup("conflict")
func action(parent: Control, label: String, id: String, order: String, icon: String, tip: String) -> void:
	var blocked: String = flight.campaign.conflict.reason(flight.campaign,id,order)
	var control: Button = flight._button(label,act.bind(id,order),parent)
	UI.instrument(control,icon,UI.CARGO); control.disabled = flight.paused or not blocked.is_empty()
	control.tooltip_text = tip+("\n"+blocked if not blocked.is_empty() else ""); control.set_meta("conflict_action",order)
func travel() -> void:
	var game: RefCounted = flight.campaign
	if game.conflict.state.raid.is_empty() or flight.paused: return
	var id: String = War.field_id(game.conflict.state.raid.planet)
	flight._close_popup(); flight._open_system_view(game.system_of(id)); flight.system_map.select_planet(id)
	flight._toast("Choose "+str(game.sector.state.planets[War.strategic(id)].name)+" to review the journey cost")
func build_panel() -> void:
	var game: RefCounted = flight.campaign; var war: RefCounted = game.conflict
	if not war.state.raid.is_empty():
		var r: Dictionary = war.state.raid
		flight._panel_copy("%s → %s · %s\nPort %d%% · intercept the raider or negotiate peace. Each bombardment removes 20 integrity." % [game.sector.faction_by_id(r.faction).name,game.sector.state.planets[r.planet].name,"arrival in %d s" % (r.arrival-game.field.state.time) if r.phase == "inbound" else "attacking",war.site(r.planet).integrity],UI.CARGO)
		var go: Button = flight._button("Plot response route",travel,flight.popup_body); UI.instrument(go,"system_view",UI.NAV); go.disabled = flight.paused
	var nations := HBoxContainer.new(); flight.popup_body.add_child(nations)
	var known: Array = []
	for f: Dictionary in game.sector.state.factions:
		if not f.get("contacted",false): continue
		known.append(f.id)
		var tab: Button = flight._button(f.name,func() -> void: flight.contacted_faction = f.id; confirm_war = ""; flight._show_popup("conflict"),nations)
		tab.disabled = f.id == flight.contacted_faction
	if not known.is_empty():
		if flight.contacted_faction not in known: flight.contacted_faction = known[0]
		var id: String = flight.contacted_faction; var n: Dictionary = war.nation(id)
		flight._panel_copy(game.sector.faction_by_id(id).name+" · "+("AT WAR" if n.war else "PEACE")+(" · warning expires in %d s" % (n.warning-game.field.state.time) if n.warning > 0 else ""),UI.PAPER)
		if n.war: action(flight.popup_body,"Negotiate peace · %d Marks" % war.peace_cost(id),id,"peace","comms","Recall their current raid; a 300-second truce follows. Past treaties stay ended; damaged ports need repair.")
		else:
			action(flight.popup_body,"Confirm war · end all treaties" if confirm_war == id else "Review declaration of war",id,"declare","defense","Ends trade, transit and alliance; their escort is recalled. Expect warned raids against your colonies.")
			if confirm_war == id: flight._panel_copy("War closes trade and transit, recalls their escort and exposes your ports to raids. Click Confirm war to commit.",UI.CARGO)
	var sites := HBoxContainer.new(); flight.popup_body.add_child(sites)
	for id: String in game.sector.state.colonies:
		var tab: Button = flight._button(game.sector.state.planets[id].name,func() -> void: selected_site = id; flight._show_popup("conflict"),sites); tab.disabled = selected_site == id
	if not game.sector.state.colonies.has(selected_site): selected_site = str(game.sector.state.colonies.keys()[0])
	var s: Dictionary = war.site(selected_site)
	flight._panel_copy("Port integrity %d%% · %s\nA disabled port cannot export or service ships. Defenses operate while you explore; ammunition is finite." % [s.integrity,"battery %d / 12 rounds" % s.ammo if s.battery else "no defense battery"],UI.PAPER)
	if not s.battery: action(flight.popup_body,"Commission battery · 180 Marks / 60 materials",selected_site,"battery","defense","Local defense: 12 damage every 6 seconds, 12 rounds. Uses local materials and shared Marks.")
	else: action(flight.popup_body,"Rearm battery · 60 Marks / 20 materials",selected_site,"rearm","cargo","Restores ammunition to 12; current rounds are retained only up to this cap.")
	action(flight.popup_body,"Repair port · 80 Marks / 20 materials",selected_site,"repair","repair_pack","Restores port integrity to 100. Work cannot proceed during an active attack.")
