extends Node3D
## Ship-side specimen interaction and bounded visual representatives.
const Bio = preload("res://scripts/planet_biosphere.gd")
const UI = preload("res://scripts/flight_interface.gd")
var flight: Node3D
var actors: Dictionary = {}
var limbs: Dictionary = {}
var selected: String = ""
var deploy_id: String = ""
var action: String = ""
var progress: float = 0
var point: Vector3
var phase: float = 0
var beam: MeshInstance3D
var marker: MeshInstance3D
func setup(scene: Node3D) -> void:
	flight = scene
	for id: String in Bio.data():
		actors[id] = make_actor(id); actors[id].visible = false
	beam = MeshInstance3D.new(); var ray := CylinderMesh.new()
	ray.top_radius = 0.045; ray.bottom_radius = 0.16; ray.height = 1
	beam.mesh = ray; beam.material_override = ink("c1dfbd",true); beam.visible = false; add_child(beam)
	marker = MeshInstance3D.new(); var ring := TorusMesh.new()
	ring.inner_radius = 1.65; ring.outer_radius = 1.75; ring.rings = 32; ring.ring_segments = 6
	marker.mesh = ring; marker.material_override = ink("efcf8d",true); marker.visible = false; add_child(marker)
	refresh(0,true)
func ink(color: String, glow: bool = false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new(); material.albedo_color = Color(color); material.roughness = 0.95
	if glow: material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material
func pod(parent: Node3D, at: Vector3, size: Vector3, material: Material) -> Node3D:
	var item := MeshInstance3D.new(); var mesh := SphereMesh.new()
	mesh.radius = 1; mesh.height = 2; mesh.radial_segments = 12; mesh.rings = 6
	item.mesh = mesh; item.position = at; item.scale = size; item.material_override = material
	parent.add_child(item); return item
func make_actor(id: String) -> Node3D:
	var spec: Dictionary = Bio.data()[id]
	var actor := Node3D.new(); add_child(actor); limbs[id] = []
	var shell: Material = ink(spec.color); var shadow: Material = ink("344452"); var eye: Material = ink("eee8c6")
	var variant: float = spec.shape
	if spec.role in ["small","medium","large"]:
		var height: float = 0.55 if spec.role == "small" else 1.4 if spec.role == "medium" else 3.3
		pod(actor,Vector3(0,height*0.5,0),Vector3(0.25+variant*0.08,height*0.5,0.25),shadow)
		for i: int in range(3+int(variant)):
			var pivot := Node3D.new(); actor.add_child(pivot); limbs[id].append(pivot)
			pivot.position.y = height*0.65; pivot.rotation.y = TAU*i/(3+variant)
			pod(pivot,Vector3(0.55,height*0.12,0),Vector3(0.9,height*0.4,0.2+variant*0.12),shell)
			pod(pivot,Vector3(0.9,height*0.15,0),Vector3(0.12,0.16,0.12),eye)
	else:
		pod(actor,Vector3.ZERO,Vector3(0.8+variant*0.15,0.5,1.1),shell)
		pod(actor,Vector3(0,0.08,-0.95),Vector3(0.54,0.35,0.23),shadow)
		for side: float in [-1.0,1.0]:
			pod(actor,Vector3(side*0.29,0.23,-1.1),Vector3(0.15,0.18,0.1),eye)
			pod(actor,Vector3(side*0.29,0.24,-1.19),Vector3(0.05,0.1,0.02),shadow)
			var limb := Node3D.new(); actor.add_child(limb); limbs[id].append(limb); limb.position.x = side*0.6
			var size := Vector3(0.9,0.1,0.6) if spec.shape == 0 else Vector3(0.18,0.65,0.25) if spec.shape == 1 else Vector3(0.55,0.25,0.95)
			pod(limb,Vector3(side*0.45,-0.35,0),size,shell)
		if spec.role == "predator": pod(actor,Vector3(0,0.42,-0.6),Vector3(0.85,0.28,0.7),shell)
	return actor
func cancel() -> void:
	action = ""; selected = ""; deploy_id = ""; progress = 0
	if beam != null: beam.hide(); marker.hide()
func select_specimen(id: String) -> void:
	if flight.paused or int(flight.campaign.biosphere.state.cargo.get(id,0)) <= 0: return
	flight._close_popup(); flight._select_tool("seed"); deploy_id = id
	flight._toast("Choose a habitat for "+str(Bio.data()[id].name)); flight._refresh_ui()
func pick(screen: Vector2) -> bool:
	if not flight.surface_weapon.is_empty() or flight.model.state.flight_mode != "surface": return false
	if not deploy_id.is_empty():
		var ground: Variant = flight._surface_point(screen)
		if ground is Vector2: order(deploy_id,"release",Vector3(ground.x,flight.terrain_height(ground.x,ground.y)+1.5,ground.y))
		return true
	if flight.tool not in ["scan","collect"]: return false
	var closest: float = 24
	var found: String = ""
	for id: String in actors:
		var actor: Node3D = actors[id]
		if not actor.visible or flight.camera.is_position_behind(actor.position): continue
		var gap: float = flight.camera.unproject_position(actor.position).distance_to(screen)
		if gap < closest: closest = gap; found = id
	if found.is_empty(): return false
	order(found,flight.tool,flight.campaign.biosphere.site(flight.model.state.planet_id,found))
	return true
func order(id: String, operation: String, at: Vector3) -> void:
	if flight.paused or flight._inspection_open(): return
	var blocked: String = flight.campaign.biosphere.reason(flight.campaign,id,operation,at,at)
	flight._cancel_orders(); selected = id; point = at
	if not blocked.is_empty(): flight._toast(blocked); flight.audio.play("error"); flight._refresh_ui(); return
	action = operation; progress = 0
	flight.destination = point+Vector3(0,5,3); flight.navigating = true
	flight.audio.play("target_lock")
func refresh(delta: float, paused: bool) -> void:
	var game: RefCounted = flight.campaign
	var planet: String = game.field.state.planet_id
	var local_species: Array = game.biosphere.species(planet)
	if not paused: phase += delta
	for id: String in actors:
		var actor: Node3D = actors[id]; actor.visible = id in local_species
		if not actor.visible: continue
		actor.position = game.biosphere.site(planet,id)
		var animal: bool = Bio.data()[id].role in ["herbivore","predator"]
		if not animal: actor.position.y -= 1.5
		var offset: float = Bio.data().keys().find(id)*0.7
		if animal: actor.position.y += sin(phase*1.3+offset)*0.14; actor.rotation.y = sin(phase*0.25+offset)*0.6
		for i: int in range(limbs[id].size()): limbs[id][i].rotation.z = sin(phase*1.6+offset+i*PI)*0.14
	marker.visible = not selected.is_empty() and game.field.state.flight_mode == "surface"
	if marker.visible: marker.position = point-Vector3(0,1.2,0)
	beam.visible = not action.is_empty() and not flight.navigating
	if beam.visible:
		var from: Vector3 = flight.ship.position; var axis: Vector3 = point-from
		var y: Vector3 = axis.normalized(); var x: Vector3 = y.cross(Vector3.FORWARD).normalized()
		if x.length() < 0.1: x = y.cross(Vector3.RIGHT).normalized()
		beam.position = (from+point)*0.5; beam.basis = Basis(x,y*axis.length(),x.cross(y))
	if paused or action.is_empty() or flight.navigating: return
	var blocked: String = game.biosphere.reason(game,selected,action,flight.ship.position,point)
	if not blocked.is_empty(): action = ""; flight._toast(blocked); flight.audio.play("error"); return
	progress += delta
	if progress < 1.5: return
	var result: String = game.biosphere.act(game,selected,action,flight.ship.position,point)
	flight._toast(result if not result.is_empty() else str(Bio.data()[selected].name)+(" catalogued" if action == "scan" else " collected" if action == "collect" else " established"))
	flight.audio.play("error" if not result.is_empty() else "scan_complete" if action == "scan" else "cargo")
	action = ""; progress = 0; beam.hide(); flight._save(false); flight._refresh_ui()
func refresh_hud() -> void:
	var local: Dictionary = flight.campaign.biosphere.world(flight.model.state.planet_id)
	if local.stress > 0: flight.hud.danger_label.text = "HABITAT LOSS IN %d s · RESTORE CLIMATE" % (30-local.stress)
	if flight.model.state.flight_mode != "surface": return
	if not deploy_id.is_empty():
		flight.subject.text = Bio.data()[deploy_id].name; flight.explanation.text = "Click a habitat to release · 5 energy"
		flight.hud.action_state.text = "CHOOSE HABITAT"; flight.use_button.disabled = true
	elif not selected.is_empty():
		flight.subject.text = Bio.data()[selected].name
		flight.hud.action_state.text = "APPROACHING" if flight.navigating else action.to_upper() if not action.is_empty() else "SPECIMEN"
		flight.explanation.text = "%s · local specimens %d · %s" % [Bio.data()[selected].role,flight.campaign.biosphere.world(flight.model.state.planet_id).stock.get(selected,0),"catalogued" if selected in flight.campaign.biosphere.state.catalogued else "unidentified"]
		flight.progress_bar.value = progress/1.5; flight.use_button.disabled = true
func build_inventory() -> void:
	var game: RefCounted = flight.campaign
	flight._panel_copy("SPECIMEN HOLD · %d / %d" % [game.biosphere.used(),Bio.HOLD],UI.CARGO)
	flight._button("Planet ecosystem",flight._show_popup.bind("biosphere"),flight.popup_body).icon = UI.icon("category_life")
	var grid := GridContainer.new(); grid.columns = 3; flight.popup_body.add_child(grid)
	for id: String in game.biosphere.state.cargo:
		var spec: Dictionary = Bio.data()[id]
		var button: Button = flight._button("%s × %d" % [spec.name,game.biosphere.state.cargo[id]],select_specimen.bind(id),grid)
		button.custom_minimum_size = Vector2(158,90); button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.icon = load("res://assets/specimens/"+id+".png")
		button.add_theme_constant_override("icon_max_width",58)
		button.add_theme_color_override("icon_normal_color",Color.WHITE)
		button.add_theme_color_override("icon_hover_color",Color.WHITE)
		button.tooltip_text = "%s · %s. Select, then click surface to release. 5 energy; consumes one specimen." % [spec.name,spec.role]
		button.set_meta("specimen_id",id); button.disabled = flight.paused
	if game.biosphere.state.cargo.is_empty(): flight._panel_copy("Scan lifeforms, then select the tractor and click to collect.")
func build_ecosystem() -> void:
	var game: RefCounted = flight.campaign; var planet: String = game.field.state.planet_id
	var local: Dictionary = game.biosphere.world(planet)
	flight._panel_copy("Climate T%d · plants T%d · ecosystem T%d" % [game.climate.score(game.climate.world(planet)),game.biosphere.plant_tier(planet),game.biosphere.complete_tier(planet)],UI.GOLD)
	if local.stress > 0: flight._panel_copy("Habitat loss in %d s · restore climate" % (30-local.stress),Color("efa484"))
	for i: int in range(3):
		flight._panel_copy("TIER %d" % (i+1),UI.NAV)
		var grid := GridContainer.new(); grid.columns = 6; flight.popup_body.add_child(grid)
		for slot: String in Bio.SLOTS:
			var id: String = local.layers[i][slot]
			var cell := VBoxContainer.new(); cell.custom_minimum_size = Vector2(78,90); grid.add_child(cell)
			var role: String = "herbivore" if slot.begins_with("herbivore") else slot
			var image_id: String = id if not id.is_empty() else str(Bio.data().keys().filter(func(key: String) -> bool: return Bio.data()[key].role == role)[0])
			var portrait := TextureRect.new(); portrait.texture = load("res://assets/specimens/"+image_id+".png")
			portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; portrait.custom_minimum_size = Vector2(70,48)
			portrait.modulate = Color(0.4,0.45,0.5,0.4) if id.is_empty() else Color.WHITE
			portrait.tooltip_text = slot.replace("_"," ")+(" · Empty" if id.is_empty() else " · "+str(Bio.data()[id].name)); cell.add_child(portrait)
			var label: Label = flight._label(role if id.is_empty() else str(Bio.data()[id].name),11,UI.MUTED if id.is_empty() else Color(Bio.data()[id].color))
			label.custom_minimum_size.x = 76; label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; cell.add_child(label)
	flight._panel_copy("Three plant sizes stabilize each climate tier. Two distinct herbivores and a predator complete it; finish that food chain before starting the next tier.")
	flight._button("Open specimen inventory",flight._cargo_tab.bind("specimens"),flight.popup_body).icon = UI.icon("inventory")
