extends PanelContainer
## Bounded 3D destination view; the shared campaign owns every journey and resource.
signal close_requested
signal sector_requested
signal orbit_requested
signal travel_requested(planet: String)
signal ui_cue(cue: String)
const Stage = preload("res://scripts/navigation_stage.gd")
const UI = preload("res://scripts/flight_interface.gd")
const Geography = preload("res://scripts/planet_geography.gd")
const Globe = preload("res://scripts/planet_globe.gd")
const Session = preload("res://scripts/expedition_session.gd")
const CargoIcon = preload("res://scripts/flight_cargo_icon.gd")
const Climate = preload("res://scripts/planet_climate.gd")
const Biosphere = preload("res://scripts/planet_biosphere.gd")
const MARK_ICON = preload("res://assets/ui/mark-symbol.svg")
const ORBIT_BASE_RADIUS: float = 22.0
const ORBIT_SPACING: float = 17.0
class RouteOverlay extends Control:
	var origin: Vector2 = Vector2.ZERO
	var destination: Vector2 = Vector2.ZERO
	var card_link_start: Vector2 = Vector2.ZERO
	var card_link_end: Vector2 = Vector2.ZERO
	var active: bool = false
	func set_route(from: Vector2, to: Vector2, link_from: Vector2, link_to: Vector2, enabled: bool) -> void:
		origin = from; destination = to; card_link_start = link_from; card_link_end = link_to; active = enabled; queue_redraw()
	func _draw() -> void:
		if not active: return
		var control: Vector2 = (origin+destination)*0.5+Vector2(0,-clampf(origin.distance_to(destination)*0.16,28,110))
		var points := PackedVector2Array()
		for i: int in range(49):
			var t: float = float(i)/48.0; var inverse: float = 1.0-t
			points.append(inverse*inverse*origin+2.0*inverse*t*control+t*t*destination)
		draw_polyline(points,Color(0.015,0.055,0.065,0.96),10,true)
		for i: int in range(24):
			if i % 3 == 2: continue
			var first: int = i*2; var last: int = mini(first+1,points.size()-1)
			draw_line(points[first],points[last],Color("64dbd5"),4,true)
		draw_circle(origin,8,Color("172a2c")); draw_arc(origin,10,0,TAU,32,Color("64dbd5"),2,true)
		draw_circle(destination,5,Color("f1cd55"))
		draw_line(card_link_start,card_link_end,Color(0.015,0.055,0.065,0.96),7,true)
		draw_line(card_link_start,card_link_end,Color("f1cd55"),2,true)
var campaign: RefCounted
var system_id: String = ""
var selected_planet: String = ""
var bodies: Dictionary = {}
var captions: Dictionary = {}
var world: Node3D
var planets_root: Node3D
var viewport: SubViewport
var preview: SubViewportContainer
var camera: Camera3D
var ship_marker: MeshInstance3D
var selection: MeshInstance3D
var route_overlay: RouteOverlay
var heading: Label
var details: Label
var status: Label
var instruction: Label
var travel: Button
var close: Button
var sector: Button
var progress: ProgressBar
var stage_root: Control
var destination_card: PanelContainer
var treasury: PanelContainer
var treasury_amount: Label
var inventory_pod: PanelContainer
var hull_meter: ProgressBar
var energy_meter: ProgressBar
var hull_readout: Label
var energy_readout: Label
var inventory_grid: GridContainer
var inventory_overflow: Label
var target_marks: Array[ColorRect] = []
var yaw: float = 0.15
var pitch: float = 0.75
var distance: float = 78
var target_distance: float = 78
var focus := Vector3.ZERO
var dragging: bool = false
var locked: bool = false
func text_label(text: String, font_size: int = 16) -> Label:
	var item := Label.new(); item.text = text; item.add_theme_font_size_override("font_size",font_size)
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE; return item
func button(text: String, icon: String, hint: String, action: Callable, parent: Node) -> Button:
	var item := Button.new(); item.text = text; item.custom_minimum_size = Vector2(52 if text.is_empty() else 120,44)
	UI.instrument(item,icon,UI.NAV); item.tooltip_text = hint
	item.pressed.connect(func() -> void: ui_cue.emit("ui_confirm"); action.call()); parent.add_child(item); return item
func _ready() -> void:
	var stage: Control = Stage.create(self)
	stage_root = stage
	var header: HBoxContainer = Stage.header(stage)
	header.z_index = 5
	heading = text_label("SYSTEM VIEW",24); heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL; header.add_child(heading)
	sector = button("Galaxy","systems","Zoom out to the galaxy [G]",func() -> void: sector_requested.emit(),header)
	close = button("Orbit","planet_map","Return to the ship's current planet [J / Esc]",func() -> void: close_requested.emit(),header)
	preview = SubViewportContainer.new(); preview.stretch = true
	preview.gui_input.connect(_view_input); preview.mouse_filter = Control.MOUSE_FILTER_STOP; Stage.world(stage,preview)
	viewport = SubViewport.new(); viewport.size = Vector2i(1600,900); viewport.own_world_3d = true; viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED; preview.add_child(viewport)
	world = Node3D.new(); viewport.add_child(world); planets_root = Node3D.new(); world.add_child(planets_root)
	var environment := WorldEnvironment.new(); var sky := Environment.new()
	sky.background_mode = Environment.BG_COLOR; sky.background_color = Color("050a15")
	sky.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; sky.ambient_light_color = Color("a1b5ca"); sky.ambient_light_energy = 0.45
	environment.environment = sky; world.add_child(environment)
	var light := OmniLight3D.new(); light.omni_range = 120; light.light_energy = 4; light.omni_attenuation = 0.45; world.add_child(light)
	add_starfield()
	var star := MeshInstance3D.new(); var sphere := SphereMesh.new(); sphere.radius = 3; sphere.height = 6; sphere.radial_segments = 32; sphere.rings = 16
	var stellar := ShaderMaterial.new(); stellar.shader = preload("res://assets/shaders/system_star.gdshader")
	star.mesh = sphere; star.material_override = stellar; world.add_child(star)
	ship_marker = MeshInstance3D.new(); var ship := PrismMesh.new(); ship.size = Vector3(1.1,1.9,1.1)
	ship_marker.mesh = ship; ship_marker.material_override = ink(UI.GOLD); world.add_child(ship_marker)
	selection = MeshInstance3D.new(); var torus := TorusMesh.new(); torus.inner_radius = 5.7; torus.outer_radius = 5.9; torus.rings = 48; torus.ring_segments = 6
	selection.mesh = torus; selection.material_override = ink(Color("a7dacc")); world.add_child(selection)
	camera = Camera3D.new(); camera.fov = 48; camera.far = 400; world.add_child(camera)
	route_overlay = RouteOverlay.new(); route_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE; route_overlay.z_index = 2; stage.add_child(route_overlay); route_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	destination_card = PanelContainer.new(); destination_card.custom_minimum_size = Vector2(310,0); destination_card.mouse_filter = Control.MOUSE_FILTER_STOP; destination_card.z_index = 4; stage.add_child(destination_card)
	var card_style := StyleBoxFlat.new(); card_style.bg_color = Color(0.025,0.045,0.065,0.96); card_style.border_color = Color("c1a94d"); card_style.set_border_width_all(1); card_style.set_content_margin_all(12)
	destination_card.add_theme_stylebox_override("panel",card_style)
	var card := VBoxContainer.new(); card.add_theme_constant_override("separation",8); destination_card.add_child(card)
	details = text_label(""); details.custom_minimum_size = Vector2(280,100); details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; card.add_child(details)
	travel = button("","ascend","Fly to this destination",activate_selected,card)
	travel.custom_minimum_size = Vector2(280,44)
	status = text_label("",15); status.custom_minimum_size = Vector2(280,34); status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; card.add_child(status)
	progress = ProgressBar.new(); progress.custom_minimum_size = Vector2(280,8); progress.show_percentage = false; UI.meter(progress,UI.GOLD); card.add_child(progress)
	for i: int in range(8):
		var mark := ColorRect.new(); mark.color = Color("f1cd55"); mark.mouse_filter = Control.MOUSE_FILTER_IGNORE; mark.z_index = 5; stage.add_child(mark); target_marks.append(mark)
	var controls: HBoxContainer = Stage.footer(stage)
	controls.z_index = 5
	button("","zoom_in","Zoom toward selected planet [Numpad +]",zoom.bind(-1),controls)
	button("","zoom_out","Zoom out; at the outer limit, open sector [Numpad −]",zoom.bind(1),controls)
	button("","system_view","Frame all planets [Home / Numpad 5]",reset_camera,controls)
	instruction = text_label("Wheel: zoom · Right-drag: rotate · Click a planet to fly",15)
	controls.add_child(instruction)
	_build_system_instruments(stage)
	visibility_changed.connect(func() -> void: viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if visible else SubViewport.UPDATE_DISABLED; dragging = false)
	hide()

func _build_system_instruments(stage: Control) -> void:
	# The flight HUD is intentionally suppressed while navigating. Keep its real treasury
	# and compact cargo/status readouts present on this separate full-screen chart.
	treasury = PanelContainer.new(); treasury.name = "SystemTreasury"; treasury.mouse_filter = Control.MOUSE_FILTER_IGNORE
	treasury.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT); treasury.offset_left = -238; treasury.offset_right = -24; treasury.offset_top = 84; treasury.offset_bottom = 132
	var money_style := StyleBoxFlat.new(); money_style.bg_color = Color("dedad0"); money_style.border_color = Color("8d8c80"); money_style.set_border_width_all(1); money_style.set_content_margin_all(8)
	treasury.add_theme_stylebox_override("panel",money_style); stage.add_child(treasury)
	var money_row := HBoxContainer.new(); money_row.add_theme_constant_override("separation",8); treasury.add_child(money_row)
	var mark_icon := TextureRect.new(); mark_icon.texture = MARK_ICON; mark_icon.custom_minimum_size = Vector2(26,26); mark_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; mark_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; mark_icon.modulate = Color("a98427"); money_row.add_child(mark_icon)
	treasury_amount = text_label("0 Marks",19); treasury_amount.add_theme_color_override("font_color",Color("1c2426")); treasury_amount.vertical_alignment = VERTICAL_ALIGNMENT_CENTER; money_row.add_child(treasury_amount)
	inventory_pod = PanelContainer.new(); inventory_pod.name = "SystemInventoryStatusPod"; inventory_pod.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inventory_pod.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT); inventory_pod.offset_left = -550; inventory_pod.offset_right = -24; inventory_pod.offset_top = -230; inventory_pod.offset_bottom = -72
	var pod_style := StyleBoxFlat.new(); pod_style.bg_color = Color("dedad0"); pod_style.border_color = Color("6e6c60"); pod_style.set_border_width_all(1); pod_style.set_content_margin_all(9)
	inventory_pod.add_theme_stylebox_override("panel",pod_style); stage.add_child(inventory_pod)
	var pod_row := HBoxContainer.new(); pod_row.add_theme_constant_override("separation",9); inventory_pod.add_child(pod_row)
	var cargo_column := VBoxContainer.new(); cargo_column.add_theme_constant_override("separation",6); cargo_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL; pod_row.add_child(cargo_column)
	var pod_title := text_label("CARRIED",12); pod_title.add_theme_color_override("font_color",Color("58646b")); cargo_column.add_child(pod_title)
	inventory_grid = GridContainer.new(); inventory_grid.columns = 6; inventory_grid.add_theme_constant_override("h_separation",5); inventory_grid.add_theme_constant_override("v_separation",3); cargo_column.add_child(inventory_grid)
	inventory_overflow = text_label("",11); inventory_overflow.add_theme_color_override("font_color",Color("58646b")); cargo_column.add_child(inventory_overflow)
	var status_column := VBoxContainer.new(); status_column.custom_minimum_size.x = 116; status_column.add_theme_constant_override("separation",3); pod_row.add_child(status_column)
	hull_readout = text_label("HULL  0%",11); hull_readout.add_theme_color_override("font_color",Color("1c2426")); status_column.add_child(hull_readout)
	hull_meter = _instrument_meter(Color("dd8565")); hull_meter.custom_minimum_size.x = 112; status_column.add_child(hull_meter)
	energy_readout = text_label("ENERGY  0%",11); energy_readout.add_theme_color_override("font_color",Color("1c2426")); status_column.add_child(energy_readout)
	energy_meter = _instrument_meter(Color("dca842")); energy_meter.custom_minimum_size.x = 112; status_column.add_child(energy_meter)
	_refresh_instruments()

func _instrument_meter(tint: Color) -> ProgressBar:
	var meter := ProgressBar.new(); meter.custom_minimum_size = Vector2(96,9); meter.min_value = 0; meter.max_value = 100; meter.show_percentage = false
	var back := StyleBoxFlat.new(); back.bg_color = Color("1c2426"); back.set_corner_radius_all(0)
	var fill := StyleBoxFlat.new(); fill.bg_color = tint; fill.set_corner_radius_all(0)
	meter.add_theme_stylebox_override("background",back); meter.add_theme_stylebox_override("fill",fill); return meter

func _campaign_inventory() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var climate_tools: Dictionary = Climate.data().tools
	for id: String in campaign.climate.state.charges:
		var spec: Dictionary = climate_tools[id] if climate_tools.has(id) else {}
		var count: int = int(campaign.climate.state.charges[id])
		if count > 0 and not spec.is_empty(): entries.append({"id":id,"title":str(spec.name),"count":count,"icon":id})
	var cargo: Dictionary = {}
	for lot: Dictionary in campaign.commerce.state.cargo:
		var id: String = str(lot.get("item","")); var count: int = int(lot.get("quantity",0))
		if count > 0 and campaign.commerce.catalog.goods.has(id): cargo[id] = int(cargo.get(id,0))+count
	var cargo_ids: Array = cargo.keys(); cargo_ids.sort()
	for id: String in cargo_ids: entries.append({"id":"cargo:"+id,"title":str(campaign.commerce.catalog.goods[id].name),"count":int(cargo[id]),"icon":"cargo"})
	if campaign.colonies.reserved_space() > 0: entries.append({"id":"cargo:colony_kit","title":"Colony landing kit","count":1,"icon":"badge_colonist"})
	var species_ids: Array = campaign.biosphere.state.cargo.keys(); species_ids.sort(); var species_catalog: Dictionary = Biosphere.data()
	for id: String in species_ids:
		var count: int = int(campaign.biosphere.state.cargo[id])
		if count > 0 and species_catalog.has(id): entries.append({"id":"specimen:"+str(id),"title":str(species_catalog[id].name),"count":count,"icon":"pod"})
	return entries

func _refresh_instruments() -> void:
	if campaign == null or not is_instance_valid(treasury): return
	treasury_amount.text = "%s Marks" % _format_marks(int(campaign.field.marks))
	var state: Dictionary = campaign.field.state
	var hull_max: float = maxf(1.0,campaign.field.max_capacity("hull")); var energy_max: float = maxf(1.0,campaign.field.max_capacity("energy"))
	hull_meter.value = 100.0*float(state.hull)/hull_max; energy_meter.value = 100.0*float(state.energy)/energy_max
	hull_readout.text = "HULL  %d%%" % int(hull_meter.value); energy_readout.text = "ENERGY  %d%%" % int(energy_meter.value)
	for child: Node in inventory_grid.get_children(): child.queue_free()
	var entries: Array[Dictionary] = _campaign_inventory(); var shown: int = mini(entries.size(),12)
	for i: int in range(shown):
		var entry: Dictionary = entries[i]; var slot := Panel.new(); slot.custom_minimum_size = Vector2(50,48); slot.tooltip_text = "%s × %d" % [entry.title,entry.count]; slot.clip_contents = true
		var slot_style := StyleBoxFlat.new(); slot_style.bg_color = Color("101618"); slot_style.border_color = Color("283437"); slot_style.set_border_width_all(1); slot_style.set_corner_radius_all(0); slot.add_theme_stylebox_override("panel",slot_style)
		inventory_grid.add_child(slot)
		var texture: Texture2D = CargoIcon.texture_for(str(entry.id))
		if texture == null: texture = UI.icon(str(entry.icon))
		if texture != null:
			var image := TextureRect.new(); image.texture = texture; image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; image.mouse_filter = Control.MOUSE_FILTER_IGNORE
			image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); image.offset_left = 3; image.offset_top = 2; image.offset_right = -3; image.offset_bottom = -11; slot.add_child(image)
		var count := text_label("×%d" % int(entry.count),10); count.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT); count.offset_left = -27; count.offset_top = -17; count.offset_right = -2; count.offset_bottom = -1; count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT; count.add_theme_color_override("font_color",Color("e9efe5")); count.add_theme_color_override("font_shadow_color",Color("101618")); count.add_theme_constant_override("shadow_offset_x",1); count.add_theme_constant_override("shadow_offset_y",1); slot.add_child(count)
	inventory_overflow.text = "+%d more carried items" % (entries.size()-shown) if entries.size() > shown else ("No carried items" if entries.is_empty() else "")

func _format_marks(value: int) -> String:
	var digits: String = str(value); var result := ""
	for i: int in range(digits.length()):
		if i > 0 and (digits.length()-i) % 3 == 0: result += ","
		result += digits[i]
	return result
func ink(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new(); material.albedo_color = color; material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; return material
func add_starfield() -> void:
	var stars := MultiMeshInstance3D.new(); var field := MultiMesh.new()
	field.transform_format = MultiMesh.TRANSFORM_3D; field.use_colors = true
	var speck := SphereMesh.new(); speck.radius = 0.25; speck.height = 0.5; speck.radial_segments = 8; speck.rings = 4
	field.mesh = speck; field.instance_count = 280
	var rng := RandomNumberGenerator.new(); rng.seed = 271828
	for i: int in range(field.instance_count):
		var direction := Vector3(rng.randf_range(-1,1),rng.randf_range(-1,1),rng.randf_range(-1,1)).normalized()
		var scale: float = rng.randf_range(0.55,1.7) if i % 23 != 0 else rng.randf_range(2.0,2.8)
		var position: Vector3 = direction*rng.randf_range(145,235)
		field.set_instance_transform(i,Transform3D(Basis.from_scale(Vector3.ONE*scale),position))
		var tint: Color = Color("b9cce0") if i % 17 != 0 else Color("e3c783")
		field.set_instance_color(i,tint*rng.randf_range(0.55,0.9))
	var material := StandardMaterial3D.new(); material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; material.vertex_color_use_as_albedo = true
	stars.multimesh = field; stars.material_override = material; world.add_child(stars)
func present(game: RefCounted, id: String = "") -> bool:
	var target: String = id if not id.is_empty() else game.sector.state.flagship.system
	var system: Dictionary = game.sector.system_by_id(target)
	if system.is_empty() or not (system.visited or system.get("charted",false)): return false
	campaign = game
	if system_id != target or bodies.is_empty():
		system_id = target; build_system(system); reset_camera()
	selected_planet = game.field.state.planet_id if bodies.has(game.field.state.planet_id) else str(bodies.keys()[0])
	if game.traveling() and bodies.has(game.sector.state.flagship.target_planet): selected_planet = game.sector.state.flagship.target_planet
	heading.text = system.name.to_upper()+" / SYSTEM"
	show(); refresh(); return true
func build_system(system: Dictionary) -> void:
	for child: Node in planets_root.get_children(): child.free()
	for caption: Node in captions.values(): caption.free()
	bodies.clear(); captions.clear()
	for i: int in range(system.planets.size()):
		var id: String = Session.local_id(system.planets[i]); var radius: float = orbital_radius(i)
		var orbit := MeshInstance3D.new(); var path := ImmediateMesh.new()
		path.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
		for j: int in range(129): path.surface_add_vertex(Vector3(cos(TAU*j/128)*radius,0,sin(TAU*j/128)*radius))
		path.surface_end(); orbit.mesh = path; orbit.material_override = ink(Color("40505d")); planets_root.add_child(orbit)
		var globe := Globe.new(); globe.radius = 4.6+float(i%2)*0.5; globe.planet_definition = Geography.definition(id); planets_root.add_child(globe)
		bodies[id] = globe
		var caption := text_label(globe.planet_definition.name,15); caption.add_theme_color_override("font_color",UI.PAPER); preview.add_child(caption); captions[id] = caption
	update_bodies()
func update_bodies() -> void:
	var index: int = 0
	for id: String in bodies:
		var angle: float = float(system_id.trim_prefix("s").to_int())*0.61+index*2.35+0.45
		bodies[id].position = Vector3(cos(angle),0,sin(angle))*orbital_radius(index)
		index += 1

func orbital_radius(index: int) -> float:
	return ORBIT_BASE_RADIUS+float(index)*ORBIT_SPACING

func reset_camera() -> void:
	var outer_orbit: float = orbital_radius(maxi(0,bodies.size()-1))
	yaw = 0.15; pitch = 0.75; distance = outer_orbit+28.0; target_distance = distance; focus = Vector3.ZERO; update_camera()
func update_camera() -> void:
	camera.position = focus+Vector3(sin(yaw)*cos(pitch),sin(pitch),cos(yaw)*cos(pitch))*distance
	camera.look_at(focus)
	for id: String in bodies:
		var at: Vector3 = bodies[id].position
		captions[id].visible = not camera.is_position_behind(at)
		var rim: Vector2 = camera.unproject_position(at+camera.global_basis.y*bodies[id].radius)
		var center: Vector2 = camera.unproject_position(at)
		captions[id].position = center+Vector2(-captions[id].size.x/2,center.distance_to(rim)+9)
func refresh() -> void:
	if campaign == null or not bodies.has(selected_planet): return
	var offer: Dictionary = campaign.quote(selected_planet)
	var definition: Dictionary = Geography.definition(selected_planet)
	var local: Dictionary = campaign.field.state if selected_planet == campaign.field.state.planet_id else campaign.worlds.get(selected_planet,{})
	var surveyed: bool = int(local.get("survey_ticks",0)) >= int(definition.survey_seconds)
	var inhabited: String = "Unknown allegiance"
	var owner: String = campaign.sector.state.planets["s0p0" if selected_planet == "morrow" else selected_planet].owner
	if owner == "player": inhabited = "Your territory"
	elif owner.is_empty(): inhabited = "Unclaimed"
	else:
		var faction: Dictionary = campaign.sector.faction_by_id(owner)
		if faction.get("contacted",false): inhabited = faction.name
	details.text = definition.name+"\n"+definition.archetype.capitalize()+" · "+inhabited+"\n"+("Landing region charted" if surveyed and not definition.sites.is_empty() else "Orbital survey complete" if surveyed else "Orbital survey pending")+" · "+("Surface access" if not definition.sites.is_empty() else "Orbital destination")
	if surveyed: details.text += "\nClimate T%d · ecosystem T%d" % [campaign.climate.score(campaign.climate.world(selected_planet)),campaign.biosphere.complete_tier(selected_planet)]
	var here: bool = selected_planet == campaign.field.state.planet_id
	travel.text = "Return to ship" if here else "Fly  ·  %d energy  ·  %d seconds" % [offer.energy,offer.seconds]
	travel.disabled = locked or campaign.traveling() or (not here and not offer.reason.is_empty())
	travel.tooltip_text = "Resume before navigating" if locked else "Return to the current planetary view" if here else offer.reason if not offer.reason.is_empty() else "Spend %d energy to reach %s." % [offer.energy,definition.name]
	status.text = "INSPECTION PAUSED" if here else offer.reason if not offer.reason.is_empty() else "Energy after departure: %d / %d" % [campaign.field.state.energy-offer.energy,campaign.field.max_capacity("energy")]
	progress.visible = campaign.traveling(); close.disabled = campaign.traveling()
	sector.disabled = locked
	if campaign.traveling():
		var ship: Dictionary = campaign.sector.state.flagship
		progress.value = 100*(1.0-float(ship.remaining)/maxf(1,ship.duration))
		status.text = ("TRAVEL PAUSED" if locked else "IN TRANSIT")+" · %d seconds\nEscape: pause / save" % ship.remaining
	selection.position = bodies[selected_planet].position
	for id: String in bodies:
		bodies[id].set_climate(campaign.climate.world(id),campaign.climate.baseline(id),campaign.climate.state.worlds.has(id))
		var visited: Dictionary = campaign.field.state if id == campaign.field.state.planet_id else campaign.worlds.get(id,{})
		bodies[id].site_marker.visible = not Geography.definition(id).sites.is_empty() and int(visited.get("survey_ticks",0)) >= int(Geography.definition(id).survey_seconds)
		captions[id].add_theme_color_override("font_color",UI.GOLD if id == campaign.field.state.planet_id else UI.NAV if id == selected_planet else UI.PAPER)
	update_ship(); update_camera(); update_target_overlay(); _refresh_instruments()
	details.add_theme_color_override("font_color",UI.PAPER)
func update_ship() -> void:
	var record: Dictionary = campaign.sector.state.flagship
	ship_marker.visible = bodies.has(record.planet) or (campaign.traveling() and bodies.has(record.target_planet))
	if not ship_marker.visible: return
	var from: Vector3 = bodies[record.planet].position if bodies.has(record.planet) else Vector3(-40,0,-40)
	var to: Vector3 = bodies[record.target_planet].position if campaign.traveling() and bodies.has(record.target_planet) else Vector3(40,0,40)
	var fraction: float = 1.0-float(record.remaining)/maxf(1,record.duration)
	ship_marker.position = (from.lerp(to,fraction) if campaign.traveling() else from)+Vector3(0,5+(sin(fraction*PI)*4 if campaign.traveling() else 0),0)

func update_target_overlay() -> void:
	if not is_instance_valid(destination_card) or not is_instance_valid(camera) or not bodies.has(selected_planet): return
	var body: Globe = bodies[selected_planet]
	var screen_scale: Vector2 = preview.size/Vector2(viewport.size)
	var center: Vector2 = camera.unproject_position(body.position)*screen_scale
	var rim: Vector2 = camera.unproject_position(body.position+camera.global_basis.y*body.radius)*screen_scale
	var radius: float = maxf(20,center.distance_to(rim)+8)
	var viewport_size: Vector2 = stage_root.size
	var panel_width: float = destination_card.custom_minimum_size.x
	var panel_height: float = maxf(destination_card.size.y,destination_card.custom_minimum_size.y)
	var left: float = center.x+radius+18
	if left+panel_width > viewport_size.x-24: left = center.x-radius-panel_width-18
	destination_card.position = Vector2(clampf(left,24,viewport_size.x-panel_width-24),clampf(center.y-panel_height*0.5,92,viewport_size.y-panel_height-92))
	var card_rect := Rect2(destination_card.position,destination_card.size)
	if card_rect.intersects(Rect2(viewport_size.x-250,78,230,62)):
		destination_card.position.y = clampf(142,92,viewport_size.y-panel_height-92)
		card_rect.position = destination_card.position
	var pod_rect := Rect2(viewport_size.x-550,viewport_size.y-230,526,158)
	if card_rect.intersects(pod_rect):
		var alternate_x: float = center.x-radius-panel_width-18 if left > center.x else center.x+radius+18
		destination_card.position.x = clampf(alternate_x,24,viewport_size.x-panel_width-24)
		card_rect.position = destination_card.position
		if card_rect.intersects(pod_rect):
			destination_card.position.x = clampf(viewport_size.x-panel_width-568,24,viewport_size.x-panel_width-24)
			card_rect.position = destination_card.position
			if card_rect.intersects(pod_rect): destination_card.position.y = clampf(viewport_size.y-panel_height-220,142,viewport_size.y-panel_height-92)
	var x0: float = center.x-radius; var x1: float = center.x+radius
	var y0: float = center.y-radius; var y1: float = center.y+radius
	var arm: float = 16; var thick: float = 2
	var rects: Array[Rect2] = [Rect2(x0,y0,arm,thick),Rect2(x0,y0,thick,arm),Rect2(x1-arm,y0,arm,thick),Rect2(x1-thick,y0,thick,arm),Rect2(x0,y1-thick,arm,thick),Rect2(x0,y1-arm,thick,arm),Rect2(x1-arm,y1-thick,arm,thick),Rect2(x1-thick,y1-arm,thick,arm)]
	var active: bool = visible and not camera.is_position_behind(body.position)
	for i: int in range(target_marks.size()):
		target_marks[i].visible = active
		if active: target_marks[i].position = rects[i].position; target_marks[i].size = rects[i].size
	var ship_visible: bool = is_instance_valid(ship_marker) and ship_marker.visible and not camera.is_position_behind(ship_marker.global_position)
	var origin: Vector2 = camera.unproject_position(ship_marker.global_position)*screen_scale if ship_visible else camera.unproject_position(bodies[campaign.field.state.planet_id].position+Vector3(0,5,0))*screen_scale if bodies.has(campaign.field.state.planet_id) else center
	card_rect = Rect2(destination_card.position,destination_card.size)
	var card_left: bool = destination_card.position.x > center.x
	var card_bottom: float = maxf(card_rect.end.y,card_rect.position.y+16)
	var card_y: float = clampf(center.y,card_rect.position.y+8,card_bottom-8)
	var card_edge: Vector2 = Vector2(card_rect.position.x,card_y) if card_left else Vector2(card_rect.end.x,card_y)
	var enabled: bool = visible and active and selected_planet != campaign.field.state.planet_id and origin.distance_to(center) > 18
	route_overlay.set_route(origin,center,center,card_edge,enabled)
func select_planet(id: String) -> void:
	if not bodies.has(id) or campaign.traveling(): return
	selected_planet = id; refresh()
func activate_selected() -> void:
	if locked or campaign == null or campaign.traveling(): return
	if selected_planet == campaign.field.state.planet_id: orbit_requested.emit()
	elif campaign.quote(selected_planet).reason.is_empty(): travel_requested.emit(selected_planet)
	else: ui_cue.emit("error"); refresh()
func pick(at: Vector2) -> String:
	var best: String = ""; var distance_to: float = INF
	for id: String in bodies:
		if camera.is_position_behind(bodies[id].position): continue
		var center: Vector2 = camera.unproject_position(bodies[id].position)
		var rim: Vector2 = camera.unproject_position(bodies[id].position+camera.global_basis.y*bodies[id].radius)
		var gap: float = center.distance_to(at)
		if gap <= maxf(32,center.distance_to(rim)) and gap < distance_to: distance_to = gap; best = id
	return best
func zoom(steps: float) -> void:
	if locked or campaign == null or campaign.traveling(): return
	if steps > 0 and target_distance >= 112: sector_requested.emit(); return
	target_distance = clampf(target_distance*pow(1.16,steps),18,115)
	if steps < 0 and target_distance <= 18 and selected_planet == campaign.field.state.planet_id: orbit_requested.emit()
func key(code: Key) -> void:
	if locked or campaign == null or campaign.traveling(): return
	if code in [KEY_LEFT,KEY_KP_4,KEY_RIGHT,KEY_KP_6]:
		var ids: Array = bodies.keys(); var offset: int = -1 if code in [KEY_LEFT,KEY_KP_4] else 1
		select_planet(ids[posmod(ids.find(selected_planet)+offset,ids.size())])
	elif code in [KEY_KP_ADD,KEY_UP]: zoom(-1)
	elif code in [KEY_KP_SUBTRACT,KEY_DOWN]: zoom(1)
	elif code in [KEY_HOME,KEY_KP_5]: reset_camera()
	elif code in [KEY_ENTER,KEY_KP_ENTER]: activate_selected()
func _view_input(event: InputEvent) -> void:
	if locked or campaign == null: return
	if event is InputEventMouseMotion:
		if dragging:
			yaw -= event.relative.x*0.006; pitch = clampf(pitch+event.relative.y*0.004,0.25,1.35); update_camera()
		else:
			var id: String = pick(event.position)
			if not id.is_empty() and id != selected_planet: select_planet(id)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT: dragging = event.pressed
		elif event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP: zoom(-1)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN: zoom(1)
			elif event.button_index == MOUSE_BUTTON_LEFT:
				var id: String = pick(event.position)
				if not id.is_empty(): select_planet(id); activate_selected()
	preview.accept_event()
func _process(delta: float) -> void:
	if not visible or campaign == null: return
	distance = lerpf(distance,target_distance,minf(1,delta*8))
	var target: Vector3 = bodies[selected_planet].position*(1.0-smoothstep(22,60,distance)) if bodies.has(selected_planet) else Vector3.ZERO
	focus = focus.lerp(target,minf(1,delta*5)); update_camera(); update_target_overlay()
