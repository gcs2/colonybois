extends Node3D
## Bounded field encounter. Detailed presentation is independent of the saved model.
signal leave
var suspended_session: Node = null
const Model = preload("res://scripts/encounter_state.gd")
const Sound = preload("res://scripts/flight_audio.gd")
const FlightControls = preload("res://scripts/flight_controls.gd")
const OrbitalScene = preload("res://scripts/orbital_scene.gd")
const GrazerMotion = preload("res://scripts/grazer_motion.gd")
const Instruments = preload("res://scripts/flight_interface.gd")
const PlanetMap = preload("res://scripts/planet_map.gd")
const Geography = preload("res://scripts/planet_geography.gd")
const FlightHUD = preload("res://scripts/flight_hud.gd")
const FlightEffects = preload("res://scripts/flight_effects.gd")
const SURFACE_ZOOM_MIN := 12.0
const SURFACE_ZOOM_MAX := 110.0
const ORBIT_ZOOM_MIN := 18.0
const ORBIT_ZOOM_MAX := 320.0
const TITLES := {"pod":"Lantern pods", "grazer":"Bell grazer", "bed":"Cold mineral bed", "relay":"Silent relay"}
const Equipment = preload("res://scripts/equipment_catalog.gd")
var TOOLS: Array[String] = Equipment.ids()
var COLORS: Array[Color] = Equipment.colors()
var model := Model.new()
var save_path: String = "user://field_encounter.json"
var ship: Node3D
var camera := Camera3D.new()
var targets: Dictionary = {}
var grown_plants: Array[Node3D] = []
var wild_plants: Array[Node3D] = []
var grazers: Array[Node3D] = []
var grazer_motion: Array[RefCounted] = []
var bed_material: StandardMaterial3D
var relay_light: MeshInstance3D
var ring: MeshInstance3D
var beam: MeshInstance3D
var beam_material: StandardMaterial3D
var selected: String = "relay"
var tool: String = "scan"
var progress: float = 0.0
var held: bool = false
var latched: bool = false
var elapsed: float = 0.0
var tick_clock: float = 0.0
var yaw: float = 0.0
var pitch: float = 0.72
var distance: float = 29.0
var camera_distance_target: float = 29.0
var zoom_ascent: bool = false
var arrival_fade: float = 0.0
var transition_veil: ColorRect
var transition_caption: Label
var ship_locator: Label
var planet_locator: Label
var effects := FlightEffects.new()
var velocity := Vector3.ZERO
var paused: bool = false
var camera_focus := Vector3.ZERO
var audio := Sound.new()
var stats: Label
var objective: Label
var subject: Label
var explanation: Label
var status: Label
var progress_bar: ProgressBar
var toolbar: Array[Button] = []
var labels: Dictionary = {}
var popup: PanelContainer
var popup_kind: String = ""
var popup_body: VBoxContainer
var toast_time: float = 0.0
var ui_clock: float = 0.0
var frame_samples: Array[float] = []
var capture_step: int = 0
var capture_clock: float = 0.0
var use_button: Button
var surface_root := Node3D.new()
var orbit: Node3D
var surface_environment: WorldEnvironment
var surface_environment_resource: Environment
var destination := Vector3.ZERO
var navigating: bool = false
var approach_subject: bool = false
var landing: bool = false
var vertical_button: float = 0.0
var altitude_order: float = -1.0
var location_label: Label
var flight_readout: Label
var energy_bar: ProgressBar
var departure_button: Button
var guide_arrow: Label
var navigation_marker: MeshInstance3D
var pause_button: Button
var heard_guides: Dictionary = {}
var guide_caption: Label
var caption_time: float = 0.0
var previewing_audio: bool = false
var cargo_location: String = "ship"
var inspected_system: String = "scan"
var cargo_quantity: Label
var system_energy: ProgressBar
var system_buttons: Dictionary = {}
var planet_map: PanelContainer
var hud: Control
var operation_feedback: String = ""
var operation_feedback_until: float = 0.0
var salvage_order: bool = false
var salvage_progress: float = 0.0
var wreck_label: Label
var shroud_ring: MeshInstance3D

func _exit_tree() -> void:
	if is_instance_valid(suspended_session) and not suspended_session.is_inside_tree():
		suspended_session.free()

func _ready() -> void:
	if DisplayServer.get_name() != "headless": Engine.max_fps = 60
	if "--playtest" in OS.get_cmdline_user_args() or "--field-capture" in OS.get_cmdline_user_args() or "--flight-capture" in OS.get_cmdline_user_args(): save_path = "user://review_field_encounter.json"
	var testing: bool = "--script" in OS.get_cmdline_args()
	if testing: save_path = "res://artifacts/field_test_session.json"
	var resume_path: String = save_path.replace(".json","_auto.json")
	if not FileAccess.file_exists(resume_path): resume_path = save_path
	if not testing and "--field-capture" not in OS.get_cmdline_user_args() and "--flight-capture" not in OS.get_cmdline_user_args() and FileAccess.file_exists(resume_path):
		var error: Error = model.load_from(resume_path)
		if error != OK: push_warning("Field save rejected; starting an isolated new encounter.")
	FlightControls.install()
	add_child(audio)
	_make_world()
	var shield_mesh := TorusMesh.new()
	shield_mesh.inner_radius = 2.1
	shield_mesh.outer_radius = 2.17
	shield_mesh.rings = 48
	shield_mesh.ring_segments = 6
	shroud_ring = MeshInstance3D.new()
	shroud_ring.mesh = shield_mesh
	shroud_ring.material_override = _mat(Color("b898dc"),true)
	shroud_ring.position.y = 0.45
	ship.add_child(shroud_ring)
	# Keep the ship and camera while swapping surface/orbit presentation.
	add_child(surface_root)
	for child: Node in get_children():
		if child is WorldEnvironment:
			surface_environment = child
			surface_environment_resource = child.environment
		elif child is Node3D and child not in [surface_root,ship,camera] and not child is Light3D:
			child.reparent(surface_root)
	orbit = OrbitalScene.new()
	add_child(orbit)
	add_child(effects)
	effects.setup(ship)
	var nav_mesh := TorusMesh.new()
	nav_mesh.inner_radius = 0.6
	nav_mesh.outer_radius = 0.72
	navigation_marker = _mesh(nav_mesh,Vector3.ZERO,_mat(Color("b0dee9"),true))
	navigation_marker.visible = false
	_make_ui()
	_restore_ship()
	_apply_flight_mode()
	_update_visuals()
	_update_camera(1.0)
	_refresh_ui()
	get_tree().auto_accept_quit = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_cancel_orders()
		paused = true
		audio.suspend_voice(true)
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		audio.save_settings()
		_save(false)
		get_tree().quit()

func terrain_height(x: float, z: float) -> float:
	var ridge: float = smoothstep(25.0,45.0,Vector2(x,z).length())
	var pool: float = 2.0*exp(-pow((x+23)/6,2)-pow(z/12,2))
	return 0.25+sin(x*0.14)*cos(z*0.12)*0.65+ridge*(2.4+sin(x*0.28+z*0.19)*1.6)-pool

func _mat(color: Color, emissive: bool = false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	if emissive:
		material.emission_enabled = true
		material.emission = color
	return material

func _mesh(mesh: Mesh, at: Vector3, material: Material, parent: Node3D = self) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = at
	node.material_override = material
	parent.add_child(node)
	return node

func _asset(id: String, at: Vector3, size: float = 1.0) -> Node3D:
	var node: Node3D = load("res://assets/encounter/"+id+".glb").instantiate()
	node.position = at
	node.scale = Vector3.ONE*size
	add_child(node)
	return node

func _make_world() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("192d48")
	sky_material.sky_horizon_color = Color("a3a4b9")
	sky_material.ground_bottom_color = Color("544959")
	sky_material.ground_horizon_color = Color("a3a4b9")
	sky_material.sky_curve = 0.25
	var sky := Sky.new()
	sky.sky_material = sky_material
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("d4d5e9")
	env.ambient_light_energy = 0.35
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.fog_enabled = true
	env.fog_light_color = Color("69718d")
	env.fog_density = 0.003
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42,-28,0)
	sun.light_color = Color("ffdda7")
	sun.light_energy = 0.85
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 110
	add_child(sun)
	add_child(camera)
	camera.current = true
	camera.fov = 52
	camera.far = 900
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Distant scenery shares the height function, with coarse cells outside the basin.
	# Playable travel/interaction bounds stay unchanged; this is not new explorable land.
	var coordinates: Array[float] = []
	for v: int in range(-1250,-50,60): coordinates.append(float(v))
	for v: int in range(-50,51): coordinates.append(float(v))
	for v: int in range(110,1251,60): coordinates.append(float(v))
	for xi: int in range(coordinates.size()-1):
		for zi: int in range(coordinates.size()-1):
			for offset: Vector2 in [Vector2(0,0),Vector2(1,0),Vector2(0,1),Vector2(1,0),Vector2(1,1),Vector2(0,1)]:
				var px: float = lerpf(coordinates[xi],coordinates[xi+1],offset.x)
				var pz: float = lerpf(coordinates[zi],coordinates[zi+1],offset.y)
				var h: float = terrain_height(px,pz)
				var blend: float = clampf((sin(px*0.16+pz*0.05)+cos(pz*0.21))*0.25+0.5,0,1)
				var color: Color = Color("666979").lerp(Color("b98e83"),blend).lerp(Color("ddba99"),smoothstep(1.0,4.0,h))
				surface.set_color(color)
				surface.add_vertex(Vector3(px,h,pz))
	surface.generate_normals()
	var ground_shader := Shader.new()
	ground_shader.code = "shader_type spatial; varying vec3 wp; void vertex(){wp=VERTEX;} float h(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);} void fragment(){float fleck=h(floor(wp.xz*9.0)); float band=sin(wp.x*2.0+sin(wp.z*0.7)*3.0)*0.5+0.5; ALBEDO=COLOR.rgb*(0.91+fleck*0.1+band*0.04); ROUGHNESS=0.95;}"
	var ground_material := ShaderMaterial.new()
	ground_material.shader = ground_shader
	_mesh(surface.commit(),Vector3.ZERO,ground_material)
	var rng := RandomNumberGenerator.new()
	rng.seed = 739
	var rock_mesh := SphereMesh.new()
	rock_mesh.radial_segments = 7
	rock_mesh.rings = 3
	rock_mesh.radius = 1
	rock_mesh.height = 2
	var rock_mat := _mat(Color("857888"))
	for i: int in range(65):
		var a: float = rng.randf()*TAU
		var r: float = rng.randf_range(24,47)
		var at := Vector3(cos(a)*r,0,sin(a)*r)
		at.y = terrain_height(at.x,at.z)-0.4
		var rock: MeshInstance3D = _mesh(rock_mesh,at,rock_mat)
		rock.scale = Vector3(rng.randf_range(1,3.8),rng.randf_range(1,5),rng.randf_range(1,2.7))
		rock.rotation.y = a
	# Shallow pools and sparse reed clusters frame the playable subjects.
	var pool := SphereMesh.new()
	pool.radius = 1
	pool.height = 2
	var water_shader := Shader.new()
	water_shader.code = "shader_type spatial; varying vec3 wp; void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;} void fragment(){float ripple=sin(wp.x*1.8+TIME*0.7)*sin(wp.z*2.0-TIME*0.5); ALBEDO=mix(vec3(0.15,0.34,0.39),vec3(0.30,0.52,0.53),ripple*0.5+0.5); ROUGHNESS=0.32; METALLIC=0.15;}"
	var water_material := ShaderMaterial.new()
	water_material.shader = water_shader
	var water: MeshInstance3D = _mesh(pool,Vector3(-23,-0.6,0),water_material)
	water.scale = Vector3(6.0,0.1,12.0)
	_make_ground_cover(rng)
	for i: int in range(16):
		var a: float = rng.randf()*TAU
		var r: float = rng.randf_range(23,33)
		var x: float = cos(a)*r
		var z: float = sin(a)*r
		_asset("pod",Vector3(x,terrain_height(x,z),z),rng.randf_range(0.22,0.42))
	var pod_at := Vector3(-7,terrain_height(-7,4),4)
	for i: int in range(3):
		var at: Vector3 = pod_at+Vector3(i*2.3-1,0,sin(i*2)*2)
		at.y = terrain_height(at.x,at.z)
		wild_plants.append(_asset("pod",at,0.9 if i == 0 else 0.7))
	targets.pod = wild_plants[0]
	for i: int in range(3):
		var at := Vector3(-9+i*3,6+i*0.4,-3-i*1.2)
		grazers.append(_asset("grazer",at,0.8 if i == 0 else 0.5))
		var motion := GrazerMotion.new()
		motion.configure(grazers.back(),i)
		grazer_motion.append(motion)
	targets.grazer = grazers[0]
	var bed := Node3D.new()
	bed.position = Vector3(8,terrain_height(8,-4),-4)
	add_child(bed)
	targets.bed = bed
	var bed_mesh := CylinderMesh.new()
	bed_mesh.top_radius = 4.0
	bed_mesh.bottom_radius = 4.3
	bed_mesh.height = 0.3
	bed_mesh.radial_segments = 40
	bed_material = _mat(Color("89a7ba"))
	_mesh(bed_mesh,Vector3.ZERO,bed_material,bed)
	for i: int in range(7):
		var a: float = i*2.4
		var plant: Node3D = _asset("pod",bed.position+Vector3(cos(a)*2.3,0.2,sin(a)*2.3),0.01)
		grown_plants.append(plant)
	var relay: Node3D = _asset("relay",Vector3(9,terrain_height(9,-13),-13))
	targets.relay = relay
	var core := SphereMesh.new()
	core.radius = 0.42
	core.height = 1.1
	relay_light = _mesh(core,relay.position+Vector3(0,2.8,-0.1),_mat(Color("a8ebce"),true))
	relay_light.visible = false
	ship = _asset("scout",Vector3(0,5,17))
	var torus := TorusMesh.new()
	torus.inner_radius = 1.9
	torus.outer_radius = 2.0
	torus.rings = 32
	torus.ring_segments = 8
	ring = _mesh(torus,Vector3.ZERO,_mat(COLORS[0],true))
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.055
	cylinder.bottom_radius = 0.14
	cylinder.height = 1
	beam_material = _mat(COLORS[0],true)
	beam = _mesh(cylinder,Vector3.ZERO,beam_material)
	beam.visible = false

func _make_ground_cover(rng: RandomNumberGenerator) -> void:
	var leaf_surface := SurfaceTool.new()
	leaf_surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i: int in range(4):
		var angle: float = i*TAU/4
		for p: Vector3 in [Vector3(-0.13,0,0),Vector3(0,0.85,0.28),Vector3(0.13,0,0)]: leaf_surface.add_vertex(p.rotated(Vector3.UP,angle))
	leaf_surface.generate_normals()
	var shader := Shader.new()
	shader.code = "shader_type spatial; render_mode cull_disabled; void vertex(){VERTEX.x+=sin(TIME*1.2+MODEL_MATRIX[3].x)*VERTEX.y*0.12;} void fragment(){ALBEDO=vec3(0.31,0.36,0.40)+COLOR.rgb*0.16; ROUGHNESS=0.95;}"
	var material := ShaderMaterial.new()
	material.shader = shader
	var batch := MultiMesh.new()
	batch.transform_format = MultiMesh.TRANSFORM_3D
	batch.use_colors = true
	batch.mesh = leaf_surface.commit()
	batch.instance_count = 520
	for i: int in range(batch.instance_count):
		var center: Vector2 = [Vector2(-13,6),Vector2(-9,-4),Vector2(15,6),Vector2(18,-15),Vector2(-20,-13)][i%5]
		var at: Vector2 = center+Vector2(rng.randfn(0,3.5),rng.randfn(0,3))
		var size: float = rng.randf_range(0.3,0.95)
		batch.set_instance_transform(i,Transform3D(Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3.ONE*size),Vector3(at.x,terrain_height(at.x,at.y),at.y)))
		batch.set_instance_color(i,Color(rng.randf(),0.25,rng.randf()))
	var node := MultiMeshInstance3D.new()
	node.multimesh = batch
	node.material_override = material
	add_child(node)

func _style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(16)
	style.set_border_width_all(1)
	style.border_color = Color("65556e")
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	return style

func _label(text: String, size: int, color: Color = Color("ebebdf")) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size",size)
	label.add_theme_color_override("font_color",color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _button(text: String, callback: Callable, parent: Control, cue: String = "ui_confirm") -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 42
	button.focus_mode = Control.FOCUS_NONE
	Instruments.instrument(button,"",Instruments.NAV)
	button.mouse_entered.connect(func() -> void:
		if not button.disabled: audio.play("ui_hover")
	)
	button.pressed.connect(func() -> void:
		if not cue.is_empty(): audio.play(cue)
		callback.call()
	)
	parent.add_child(button)
	return button

func _panel(parent: Control, rect: Rect2) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.add_theme_stylebox_override("panel",_style(Color(0.095,0.075,0.13,0.94)))
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation",10)
	panel.add_child(box)
	return box

func _make_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(root)
	var theme := Theme.new()
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Bahnschrift","Segoe UI"])
	theme.default_font = font
	theme.default_font_size = 16
	root.theme = theme
	transition_veil = ColorRect.new()
	transition_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transition_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_veil.color = Color(0.03,0.04,0.07,0)
	root.add_child(transition_veil)
	transition_caption = _label("",22,Instruments.PAPER)
	transition_caption.position = Vector2(510,350)
	transition_caption.size = Vector2(580,60)
	transition_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	transition_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(transition_caption)
	hud = FlightHUD.new()
	root.add_child(hud)
	location_label = hud.location_label
	stats = hud.stats
	objective = hud.objective
	subject = hud.subject
	explanation = hud.explanation
	flight_readout = hud.flight_readout
	energy_bar = hud.energy_bar
	progress_bar = hud.progress_bar
	pause_button = hud.pause_button
	departure_button = hud.departure_button
	use_button = hud.use_button
	toolbar = hud.toolbar
	hud.action_requested.connect(_hud_action)
	hud.tool_requested.connect(_select_tool)
	hud.ui_cue.connect(func(cue: String) -> void: audio.play(cue))
	hud.altitude_requested.connect(func(direction: float) -> void:
		if paused or _inspection_open(): return
		if direction != 0: _cancel_orders()
		vertical_button = direction
		altitude_order = -1)
	hud.navigation.set_terrain(terrain_height)
	hud.navigation.destination_requested.connect(_chart_navigate)
	hud.navigation.target_requested.connect(_command_target)
	hud.navigation.landing_requested.connect(func() -> void:
		if not _inspection_open() and not paused: _begin_landing())
	status = _label("",18,Color("ffe0a8"))
	status.position = Vector2(390,676)
	status.size = Vector2(530,58)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(status)
	guide_caption = _label("",16,Color("b7d2e0"))
	guide_caption.position = Vector2(390,605)
	guide_caption.size = Vector2(530,58)
	guide_caption.add_theme_color_override("font_outline_color",Color("09131f"))
	guide_caption.add_theme_constant_override("outline_size",5)
	guide_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guide_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(guide_caption)
	guide_arrow = _label("▼",28,Color("ffe0a8"))
	root.add_child(guide_arrow)
	ship_locator = _label("◇  SHIP",12,Instruments.GOLD)
	planet_locator = _label("MORROW",13,Instruments.PAPER)
	wreck_label = _label("◇  DRIFTING WRECK · PULSE FIELD",13,Instruments.COMMS)
	for locator: Label in [ship_locator,planet_locator,wreck_label]:
		locator.mouse_filter = Control.MOUSE_FILTER_IGNORE
		locator.add_theme_color_override("font_outline_color",Color("151322"))
		locator.add_theme_constant_override("outline_size",4)
		root.add_child(locator)
	for id: String in targets:
		var label: Label = _label(TITLES[id],13,Color("e3e9de"))
		label.add_theme_color_override("font_outline_color",Color("191724"))
		label.add_theme_constant_override("outline_size",3)
		labels[id] = label
		root.add_child(label)
	popup = PanelContainer.new()
	popup.position = Vector2(1020,100)
	popup.size = Vector2(555,595)
	popup.add_theme_stylebox_override("panel",_style(Instruments.INK))
	root.add_child(popup)
	var popup_scroll := ScrollContainer.new()
	popup_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	popup.add_child(popup_scroll)
	popup_body = VBoxContainer.new()
	popup_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	popup_body.add_theme_constant_override("separation",12)
	popup_scroll.add_child(popup_body)
	popup.visible = false
	planet_map = PlanetMap.new()
	root.add_child(planet_map)
	planet_map.close_requested.connect(func() -> void: planet_map.hide(); audio.play("ui_close"))
	planet_map.travel_requested.connect(_map_travel)
	planet_map.survey_requested.connect(_map_survey)
	planet_map.ui_cue.connect(func(cue: String) -> void: audio.play(cue))
	_select_tool("scan")

func _physics_process(delta: float) -> void:
	if paused or _inspection_open(): velocity = Vector3.ZERO; return
	var input_direction: Vector3 = FlightControls.direction()
	if Input.is_action_pressed("flight_brake"): _cancel_orders(); input_direction = Vector3.ZERO
	var orbital: bool = model.state.flight_mode == "orbit"
	var speed: float = 16.0 if orbital else 12.0
	var move := Vector3(input_direction.x,0,input_direction.z).rotated(Vector3.UP,yaw).limit_length(1)*speed
	if not input_direction.is_zero_approx():
		navigating = false
		approach_subject = false
		landing = false
		held = false
		progress = 0
		altitude_order = -1
		zoom_ascent = false
		salvage_order = false
		salvage_progress = 0
	if navigating:
		if approach_subject: destination = _target_position()+Vector3(0,1,1).normalized()*Equipment.reach(tool)*0.55
		var offset: Vector3 = destination-ship.position
		move = FlightControls.arrival_velocity(offset,speed)
		if offset.length() < 0.65:
			navigating = false
			move = Vector3.ZERO
			if landing: _change_flight_mode("surface"); return
			if approach_subject: approach_subject = false; held = true; latched = false
	if input_direction.y != 0 or vertical_button != 0:
		move.y = clampf(input_direction.y+vertical_button,-1,1)*12
	elif altitude_order >= 0:
		move.y = clampf((altitude_order-ship.position.y)*2,-14,14)
		if absf(altitude_order-ship.position.y) < 0.2: altitude_order = -1
	velocity = velocity.move_toward(move,delta*28)
	ship.position += velocity*delta
	var flat := Vector2(ship.position.x,ship.position.z).limit_length(80 if orbital else 39)
	ship.position.x = flat.x
	ship.position.z = flat.y
	if orbital:
		ship.position.y = clampf(ship.position.y,-55,75)
		# The orbital globe is solid, including during point-and-click flight.
		var away: Vector3 = ship.position-orbit.planet.position
		if away.length() < 21: ship.position = orbit.planet.position+away.normalized()*21
	else:
		ship.position.y = maxf(ship.position.y,terrain_height(flat.x,flat.y)+2.7)
		if ship.position.y >= 58: _change_flight_mode("orbit"); return
		var away: Vector3 = ship.position-targets.relay.position
		if Vector2(away.x,away.z).length() < 3 and away.y < 7:
			var outward := Vector2(away.x,away.z).normalized()
			if outward.is_zero_approx(): outward = Vector2.RIGHT
			ship.position.x = targets.relay.position.x+outward.x*3
			ship.position.z = targets.relay.position.z+outward.y*3
	if Vector2(velocity.x,velocity.z).length() > 0.2: ship.rotation.y = lerp_angle(ship.rotation.y,atan2(-velocity.x,-velocity.z),delta*5)
	ship.rotation.z = lerpf(ship.rotation.z,-move.rotated(Vector3.UP,-ship.rotation.y).x*0.025,delta*5)
	ship.rotation.x = lerpf(ship.rotation.x,-velocity.y*0.015,delta*4)

func _process(delta: float) -> void:
	audio.update_flight(delta,velocity.length(),model.state.flight_mode == "orbit",paused or _inspection_open())
	if not paused and not _inspection_open(): caption_time -= delta
	guide_caption.visible = caption_time > 0
	frame_samples.append(delta*1000)
	if frame_samples.size() > 600: frame_samples.pop_front()
	if not paused and not _inspection_open():
		elapsed += delta
		tick_clock += delta
		while tick_clock >= 1:
			tick_clock -= 1
			var old_count: int = model.state.history.size()
			var pulse: String = model.tick(ship.position.distance_to(OrbitalScene.WRECK_POSITION) if model.state.flight_mode == "orbit" else INF)
			if pulse == "tow":
				_cancel_orders()
				_restore_ship()
				arrival_fade = 0.8
				_toast("Emergency tow · hull 35 / 100 · leave the field and repair")
				audio.play("error")
			elif pulse == "pulse":
				_toast("Defense pulse hit · leave the core or engage the shroud")
				audio.play("error")
			if model.state.history.size() != old_count:
				if pulse not in ["pulse","tow"]:
					_toast(model.state.history.back().text)
					audio.play("arrival")
				if popup.visible: _show_popup(popup_kind)
			if int(model.state.time)%30 == 0 and "--field-capture" not in OS.get_cmdline_user_args(): _save(false)
	_update_camera(delta)
	if not paused and not _inspection_open() and model.state.flight_mode == "orbit": orbit.advance(delta)
	if not paused and not _inspection_open() and model.state.flight_mode == "surface":
		for motion: RefCounted in grazer_motion:
			motion.advance(delta,ship.position)
			motion.actor.position.y = maxf(motion.actor.position.y,terrain_height(motion.actor.position.x,motion.actor.position.z)+3.0)
	_update_visuals()
	_operate(delta)
	_operate_salvage(delta)
	_update_flight_effects(delta)
	ui_clock += delta
	if ui_clock > 0.1:
		ui_clock = 0
		_refresh_ui()
	toast_time -= delta
	status.visible = toast_time > 0 or paused
	if paused: status.text = "Paused — Space to resume"
	if "--field-capture" in OS.get_cmdline_user_args(): _capture(delta)
	if "--flight-capture" in OS.get_cmdline_user_args(): _capture_flight(delta)

func _update_camera(delta: float) -> void:
	distance = lerpf(distance,camera_distance_target,minf(1,delta*8))
	var focus: Vector3 = ship.position+Vector3(0,-1,0)
	if model.state.flight_mode == "orbit":
		var overview: float = smoothstep(65,190,distance)
		focus = focus.lerp((ship.position+orbit.planet.position)*0.5,overview)
	camera_focus = camera_focus.lerp(focus,minf(1,delta*5))
	var offset := Vector3(sin(yaw)*cos(pitch),sin(pitch),cos(yaw)*cos(pitch))*distance
	camera.position = camera_focus+offset
	if model.state.flight_mode == "surface": camera.position.y = maxf(camera.position.y,terrain_height(camera.position.x,camera.position.z)+1.5)
	else:
		var away: Vector3 = camera.position-orbit.planet.position
		if away.length() < 20: camera.position = orbit.planet.position+away.normalized()*20
	camera.look_at(camera_focus)

func _zoom_camera(steps: float) -> void:
	if paused or _inspection_open(): return
	var orbital: bool = model.state.flight_mode == "orbit"
	if steps < 0 and zoom_ascent: _cancel_orders()
	if not orbital and steps > 0 and camera_distance_target >= SURFACE_ZOOM_MAX-0.1:
		if not zoom_ascent:
			_departure()
			zoom_ascent = true
			_toast("Ascending to orbit · scroll in or Stop to cancel")
		return
	var minimum: float = ORBIT_ZOOM_MIN if orbital else SURFACE_ZOOM_MIN
	var maximum: float = ORBIT_ZOOM_MAX if orbital else SURFACE_ZOOM_MAX
	camera_distance_target = clampf(camera_distance_target*pow(1.18,steps),minimum,maximum)
	if orbital and camera_distance_target >= ORBIT_ZOOM_MAX and steps > 0:
		_toast("Morrow orbit overview · other systems are not connected yet")

func _update_flight_effects(delta: float) -> void:
	var stopped: bool = paused or _inspection_open()
	var orbital: bool = model.state.flight_mode == "orbit"
	effects.update(delta,velocity.length(),stopped,orbital,terrain_height(ship.position.x,ship.position.z),tool,beam.visible,_target_position(),progress)
	if not stopped: arrival_fade = maxf(0,arrival_fade-delta*1.8)
	var outbound: float = 0
	if not orbital and velocity.y > 0.1: outbound = smoothstep(53,58,ship.position.y)
	if orbital and landing: outbound = 1-smoothstep(1,9,ship.position.distance_to(destination))
	transition_veil.color.a = maxf(arrival_fade,outbound)
	transition_caption.text = "MORROW / ORBIT" if orbital else "MORROW / ATMOSPHERE"
	transition_caption.modulate.a = transition_veil.color.a

func _update_visuals() -> void:
	var orbital: bool = model.state.flight_mode == "orbit"
	shroud_ring.visible = model.state.shroud_on
	shroud_ring.rotation.y = elapsed*0.3
	ship_locator.visible = distance > 85 and not _inspection_open() and not camera.is_position_behind(ship.position)
	ship_locator.position = camera.unproject_position(ship.position)+Vector2(10,10)
	planet_locator.visible = orbital and distance > 150 and not _inspection_open() and not camera.is_position_behind(orbit.planet.position)
	planet_locator.position = camera.unproject_position(orbit.planet.position)+Vector2(-25,-28)
	wreck_label.visible = orbital and not _inspection_open() and not camera.is_position_behind(OrbitalScene.WRECK_POSITION)
	wreck_label.position = camera.unproject_position(OrbitalScene.WRECK_POSITION)+Vector2(12,-18)
	navigation_marker.visible = navigating
	navigation_marker.position = destination-Vector3(0,0.8,0)
	guide_arrow.visible = not paused and not _inspection_open()
	if orbital:
		guide_arrow.position = Vector2(1400,615)
		ring.visible = false
		for label: Label in labels.values(): label.visible = false
		return
	if model.state.landings > 0: guide_arrow.visible = false
	if "relay" not in model.state.scanned:
		var projected: Vector2 = camera.unproject_position(_target_position("relay"))
		guide_arrow.position = Vector2(clampf(projected.x-14,350,1180),clampf(projected.y-72,130,610))-Vector2(0,sin(elapsed*4)*5)
		guide_arrow.visible = guide_arrow.visible and not camera.is_position_behind(_target_position("relay"))
	else: guide_arrow.position = Vector2(1400,615+sin(elapsed*4)*4)
	for i: int in range(wild_plants.size()):
		wild_plants[i].scale = Vector3.ONE*(0.9 if i == 0 else (0.7 if i < int(model.state.native_stock) else 0.3))
		wild_plants[i].rotation.z = sin(elapsed*1.1+i)*0.035
	bed_material.albedo_color = Color("b08b6b") if model.state.warm else Color("89a7ba")
	for i: int in range(grown_plants.size()):
		grown_plants[i].visible = model.state.seeded
		grown_plants[i].scale = Vector3.ONE*(0.08+float(model.state.growth)*(0.55+0.06*(i%3)))
		grown_plants[i].rotation.z = sin(elapsed*1.2+i)*0.045
	relay_light.visible = "relay" in model.state.scanned or model.state.growth >= 1
	ring.position = _target_position()+Vector3(0,-0.8,0)
	ring.scale = Vector3.ONE*(1.0+sin(elapsed*3)*0.035)
	ring.visible = not camera.is_position_behind(_target_position())
	for id: String in labels:
		var at: Vector3 = _target_position(id)+Vector3(0,3,0)
		var label: Label = labels[id]
		label.position = camera.unproject_position(at)-Vector2(label.size.x/2,20)
		label.visible = not camera.is_position_behind(at) and not _inspection_open() and label.position.y > 145 and label.position.y < 690 and label.position.x > 350
		label.modulate.a = 1.0 if id == selected else 0.65

func _target_position(id: String = "") -> Vector3:
	if id.is_empty(): id = selected
	var node: Node3D = targets[id]
	return node.position+Vector3(0,2.5 if id in ["pod","relay"] else 0.6,0)

func _hud_action(action: String) -> void:
	match action:
		"pause": _toggle_pause()
		"menu": _exit_encounter()
		"save": _save()
		"load": _load()
		"atlas": _toggle_planet_map()
		"departure": _departure()
		"use":
			if not paused and not _inspection_open():
				if model.state.flight_mode == "orbit": _command_wreck()
				else: _activate_selected()
		"shroud":
			if paused or _inspection_open(): return
			var error: String = model.toggle_shroud()
			_toast(error if not error.is_empty() else ("Phase shroud engaged" if model.state.shroud_on else "Phase shroud disengaged"))
			audio.play("error" if not error.is_empty() else "ui_confirm")
		"repair":
			if paused or _inspection_open(): return
			var error: String = model.repair(_wreck_distance())
			_toast(error if not error.is_empty() else "Field repair complete · 35 hull restored")
			audio.play("error" if not error.is_empty() else "cargo")
		"stop": _stop()
		"zoom_in": _zoom_camera(-1)
		"zoom_out": _zoom_camera(1)
		"cargo", "systems", "contact", "journal", "controls", "audio":
			_toggle_drawer(action)
		_:
			if action.begins_with("category:"): audio.play("ui_confirm")

func _chart_navigate(at: Vector2) -> void:
	if paused or _inspection_open(): return
	if model.state.flight_mode == "surface":
		at = at.limit_length(38)
		_navigate(Vector3(at.x,maxf(ship.position.y,terrain_height(at.x,at.y)+4),at.y))
	else: _navigate(Vector3(at.x,ship.position.y,at.y))

func _command_target(id: String) -> void:
	if id == "wreck": _command_wreck(); return
	if paused or _inspection_open() or id not in targets: return
	if id != selected: _cancel_orders()
	selected = id
	_activate_selected()

func _wreck_distance() -> float:
	return ship.position.distance_to(OrbitalScene.WRECK_POSITION) if model.state.flight_mode == "orbit" else INF

func _command_wreck() -> void:
	if paused or _inspection_open(): return
	var reason: String = model.salvage_reason(0)
	if not reason.is_empty(): _toast(reason); audio.play("error"); return
	if salvage_order: _stop(); return
	_navigate(OrbitalScene.WRECK_POSITION+Vector3(0,0,8))
	salvage_order = true
	audio.play("target_lock")

func _operate_salvage(delta: float) -> void:
	if not salvage_order or paused or _inspection_open() or model.state.flight_mode != "orbit": return
	if navigating or _wreck_distance() > Model.SALVAGE_REACH:
		salvage_progress = 0
		return
	var reason: String = model.salvage_reason(_wreck_distance())
	if not reason.is_empty():
		_toast(reason)
		_cancel_orders()
		return
	salvage_progress += delta/3.0
	# A short, visible tether confirms that the ship is working the actual wreck.
	beam.visible = true
	var end: Vector3 = OrbitalScene.WRECK_POSITION
	beam.position = (ship.position+end)*0.5
	var axis: Vector3 = (end-ship.position).normalized()
	var side: Vector3 = axis.cross(Vector3.FORWARD).normalized()
	if side.length() < 0.1: side = axis.cross(Vector3.RIGHT).normalized()
	beam.basis = Basis(side,axis,side.cross(axis)).scaled(Vector3(1,ship.position.distance_to(end),1))
	beam_material.albedo_color = Instruments.COMMS
	beam_material.emission = Instruments.COMMS
	if salvage_progress < 1: return
	var error: String = model.salvage(_wreck_distance())
	_cancel_orders()
	_toast(error if not error.is_empty() else "Phase shroud secured · toggle at the ship panel")
	audio.play("error" if not error.is_empty() else "achievement")

func _operate(delta: float) -> void:
	beam.visible = false
	if paused or _inspection_open() or model.state.flight_mode == "orbit" or not held or latched:
		progress = 0
		return
	var error: String = model.reason(tool,selected,ship.position.distance_to(_target_position()))
	if not error.is_empty():
		_toast(error)
		audio.play("error")
		latched = true
		progress = 0
		return
	if progress == 0:
		audio.play(tool)
		for motion: RefCounted in grazer_motion: motion.react(tool,_target_position())
	progress += delta/Equipment.seconds(tool)
	var end: Vector3 = _target_position()
	beam.visible = true
	beam.position = (ship.position+end)*0.5
	beam.scale.y = ship.position.distance_to(end)
	var axis: Vector3 = (end-ship.position).normalized()
	var side: Vector3 = axis.cross(Vector3.FORWARD).normalized()
	if side.length() < 0.1: side = axis.cross(Vector3.RIGHT).normalized()
	beam.basis = Basis(side,axis,side.cross(axis)).scaled(Vector3(1,ship.position.distance_to(end),1))
	if progress >= 1:
		error = model.act(tool,selected,ship.position.distance_to(end))
		_toast(error if not error.is_empty() else ("Survey complete" if tool == "scan" else "Operation complete"))
		audio.play("error" if not error.is_empty() else ("scan_complete" if tool == "scan" else "cargo"))
		latched = true
		held = false
		progress = 0
		operation_feedback = "COMPLETE" if error.is_empty() else "FAILED"
		operation_feedback_until = elapsed+3
		if error.is_empty(): effects.confirm(end,tool)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and not event.echo:
		if event.physical_keycode == KEY_F:
			held = event.pressed
			if not held: latched = false
		if not event.pressed: return
		match event.physical_keycode:
			KEY_M: _toggle_planet_map()
			KEY_I: _toggle_drawer("cargo")
			KEY_K: _toggle_drawer("systems")
			KEY_1: _select_tool(TOOLS[0])
			KEY_2: _select_tool(TOOLS[1])
			KEY_3: _select_tool(TOOLS[2])
			KEY_4: _select_tool(TOOLS[3])
			KEY_TAB:
				_cancel_orders()
				selected = Model.TARGETS[(Model.TARGETS.find(selected)+1)%4]
			KEY_SPACE: _toggle_pause()
			KEY_ESCAPE: popup.visible = false; planet_map.hide(); _stop()
			KEY_F5: _save()
			KEY_F9: _load()
	if _inspection_open() or paused: return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
			var sign_y: float = 1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1
			if not event.ctrl_pressed: _zoom_camera(-sign_y)
			else:
				var target_altitude: float = ship.position.y if altitude_order < 0 else altitude_order
				_cancel_orders()
				altitude_order = clampf(target_altitude+sign_y*6,3,65)
		if event.button_index == MOUSE_BUTTON_LEFT: _pick(event.position)
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		yaw -= event.relative.x*0.006
		pitch = clampf(pitch+event.relative.y*0.004,0.2,1.3)

func _pick(screen: Vector2) -> void:
	if paused or _inspection_open(): return
	if model.state.flight_mode == "orbit":
		if not camera.is_position_behind(OrbitalScene.WRECK_POSITION) and camera.unproject_position(OrbitalScene.WRECK_POSITION).distance_to(screen) < 33:
			_command_wreck()
			return
		var ray: Vector3 = camera.project_ray_normal(screen)
		var from: Vector3 = camera.project_ray_origin(screen)
		var near: Vector3 = from+ray*maxf(0,(orbit.planet.position-from).dot(ray))
		if near.distance_to(orbit.planet.position) <= 19: _begin_landing(); return
		var plane := Plane(Vector3.UP,ship.position.y)
		var at: Variant = plane.intersects_ray(from,ray)
		if at is Vector3: _navigate(at)
		return
	var closest: float = 48
	var picked: String = ""
	for id: String in targets:
		var at: Vector3 = _target_position(id)
		if camera.is_position_behind(at): continue
		var d: float = camera.unproject_position(at).distance_to(screen)
		if d < closest: closest = d; picked = id
	if not picked.is_empty():
		_command_target(picked)
		return
	# Ray march against the actual terrain height, never an arbitrary screen plane.
	var from: Vector3 = camera.project_ray_origin(screen)
	var ray: Vector3 = camera.project_ray_normal(screen)
	for i: int in range(1,480):
		var at: Vector3 = from+ray*float(i)*0.5
		if at.y <= terrain_height(at.x,at.z):
			var flat := Vector2(at.x,at.z).limit_length(38)
			_navigate(Vector3(flat.x,maxf(ship.position.y,terrain_height(flat.x,flat.y)+4),flat.y))
			return

func _navigate(at: Vector3) -> void:
	_cancel_orders()
	destination = at
	if model.state.flight_mode == "orbit":
		var flat := Vector2(at.x,at.z).limit_length(75)
		destination = Vector3(flat.x,clampf(at.y,-50,70),flat.y)
	navigating = true
	audio.play("navigation")

func _activate_selected() -> void:
	if held or approach_subject: _stop(); return
	if model.state.flight_mode == "orbit": return
	var error: String = model.reason(tool,selected,0)
	if not error.is_empty(): _toast(error); audio.play("error"); return
	_cancel_orders()
	audio.play("target_lock")
	if ship.position.distance_to(_target_position()) > Equipment.reach(tool)*0.85:
		destination = _target_position()+Vector3(0,1,1).normalized()*Equipment.reach(tool)*0.55
		navigating = true
		approach_subject = true
	else: held = true

func _cancel_orders() -> void:
	zoom_ascent = false
	salvage_order = false
	salvage_progress = 0
	effects.reset()
	operation_feedback = ""
	navigating = false
	approach_subject = false
	landing = false
	held = false
	latched = false
	progress = 0
	vertical_button = 0
	altitude_order = -1
	velocity = Vector3.ZERO

func _stop() -> void:
	var had_order: bool = navigating or (held and not latched) or altitude_order >= 0
	_cancel_orders()
	if had_order:
		operation_feedback = "CANCELLED"
		operation_feedback_until = elapsed+2
	audio.play("cancel")

func _toggle_pause() -> void:
	paused = not paused
	_cancel_orders()
	audio.suspend_voice(paused)

func _departure() -> void:
	if paused or _inspection_open(): return
	if model.state.flight_mode == "orbit": _begin_landing(); return
	_cancel_orders()
	altitude_order = 63
	audio.play("departure")

func _begin_landing() -> void:
	_navigate(OrbitalScene.APPROACH)
	landing = true
	audio.play("entry")

func _change_flight_mode(mode: String) -> void:
	if not model.change_flight_mode(mode): return
	_cancel_orders()
	_restore_ship()
	_apply_flight_mode()
	arrival_fade = 1.0
	audio.play("arrival")
	_toast("Morrow orbit reached" if mode == "orbit" else "Atmospheric entry complete")
	_save(false)

func _apply_flight_mode() -> void:
	var orbital: bool = model.state.flight_mode == "orbit"
	surface_root.visible = not orbital
	orbit.visible = orbital
	# Only one WorldEnvironment is active; hidden nodes still register environments.
	surface_environment.environment = null if orbital else surface_environment_resource
	orbit.environment.environment = orbit.get_meta("environment",orbit.environment.environment)
	if not orbit.has_meta("environment"): orbit.set_meta("environment",orbit.environment.environment)
	if not orbital: orbit.environment.environment = null
	for button: Button in toolbar: button.disabled = orbital
	use_button.disabled = orbital
	distance = 85 if orbital else 55
	camera_distance_target = distance
	effects.reset()
	beam_material.albedo_color = COLORS[TOOLS.find(tool)]
	beam_material.emission = COLORS[TOOLS.find(tool)]
	camera_focus = ship.position
	_update_camera(1)

func _select_tool(value: String) -> void:
	if not Equipment.has_tool(value): return
	_cancel_orders()
	tool = value
	progress = 0
	held = false
	latched = false
	var index: int = TOOLS.find(tool)
	beam_material.albedo_color = COLORS[index]
	beam_material.emission = COLORS[index]
	hud.select_tool(value)
	Instruments.meter(progress_bar,COLORS[index])
	audio.play("equip_"+value)

func _refresh_ui() -> void:
	var s: Dictionary = model.state
	var orbital: bool = s.flight_mode == "orbit"
	location_label.text = "MORROW / ORBIT" if orbital else "MORROW / SURFACE"
	stats.text = "%d Marks   ·   Cradle %d/2   ·   %d surveys" % [s.marks,s.samples,s.scanned.size()]
	energy_bar.value = s.energy
	hud.hull_bar.value = s.hull
	hud.hull_label.text = "HULL   %d / 100" % s.hull
	hud.energy_label.text = "ENERGY   %d / 100" % s.energy
	flight_readout.text = "%s %.0f m  ·  %.0f m/s" % ["Y" if orbital else "ALT",ship.position.y,velocity.length()]
	hud.shroud_button.visible = s.shroud_unlocked
	hud.shroud_button.text = "SHROUD ON" if s.shroud_on else "SHROUD"
	hud.shroud_button.disabled = paused or _inspection_open() or not orbital or (not s.shroud_on and s.energy < 2)
	hud.repair_button.disabled = paused or _inspection_open() or not model.repair_reason(_wreck_distance()).is_empty()
	hud.repair_button.tooltip_text = model.repair_reason(_wreck_distance()) if hud.repair_button.disabled else "Restore up to 35 hull · 30 energy · 20 s cooldown"
	var field_distance: float = _wreck_distance()
	hud.danger_label.text = "PULSE CORE · %d m · NEXT IN %d s" % [field_distance,6-int(s.threat_clock)] if orbital and field_distance < Model.HAZARD_RADIUS else ("PULSE FIELD · %d m · KEEP CLEAR" % field_distance if orbital and field_distance < Model.HAZARD_WARNING else "")
	hud.quick_cargo.text = "%d / 2" % s.samples
	hud.paused_badge.text = "INSPECTION PAUSED" if _inspection_open() else ("FLIGHT PAUSED" if paused else "")
	hud.navigation.orbital = orbital
	hud.navigation.ship_at = Vector2(ship.position.x,ship.position.z)
	hud.navigation.heading = -ship.rotation.y
	hud.navigation.planet_at = Vector2(orbit.planet.position.x,orbit.planet.position.z)
	hud.navigation.wreck_at = Vector2(OrbitalScene.WRECK_POSITION.x,OrbitalScene.WRECK_POSITION.z)
	hud.navigation.wreck_known = s.survey_ticks >= int(Geography.definition().survey_seconds)
	hud.navigation.surveyed = s.scanned
	hud.navigation.selected = selected
	hud.navigation.navigating = navigating
	hud.navigation.destination = Vector2(destination.x,destination.z)
	hud.navigation.locked = paused or _inspection_open()
	for id: String in targets: hud.navigation.points[id] = Vector2(targets[id].position.x,targets[id].position.z)
	hud.navigation.queue_redraw()
	pause_button.text = "Resume" if paused else "Pause"
	departure_button.text = "Return to Morrow" if orbital else "Leave atmosphere"
	if orbital:
		if s.survey_ticks < int(Geography.definition().survey_seconds): objective.text = "Chart Morrow from the atlas to locate orbital signals."
		elif not s.shroud_unlocked: objective.text = "A wreck lies inside a pulse field. Click it to recover its shroud."
		else: objective.text = "Shroud recovered. Explore, repair or return to Morrow."
	elif s.landings > 0: objective.text = "Explore freely. Your surveys are secure."
	elif "relay" not in s.scanned: objective.text = "Click the relay to investigate its signal."
	elif not s.history.any(func(entry: Dictionary) -> bool: return entry.id == "first_orbit"): objective.text = "Follow the signal. Leave the atmosphere."
	else: objective.text = "Explore freely. Your surveys are secure."
	if orbital:
		subject.text = "Drifting wreck  /  %.0f m" % field_distance if hud.navigation.wreck_known and not s.shroud_unlocked else "Morrow  /  orbital flight"
		hud.action_state.text = "SALVAGING" if salvage_order and not navigating else ("APPROACHING" if salvage_order else ("DANGER" if field_distance < Model.HAZARD_RADIUS else "ORBIT"))
		explanation.text = "%d%% · stay near the wreck" % int(salvage_progress*100) if salvage_order and not navigating else ("Defense pulse repeats every 6 s." if field_distance < Model.HAZARD_WARNING else "Chart in the atlas; click the wreck to approach." if hud.navigation.wreck_known and not s.shroud_unlocked else "Click Morrow to descend.")
		use_button.text = "Cancel" if salvage_order else ("Salvage" if hud.navigation.wreck_known and not s.shroud_unlocked else "Use")
		use_button.disabled = paused or _inspection_open() or not hud.navigation.wreck_known or s.shroud_unlocked
		use_button.tooltip_text = "Approach the wreck; recovering its shroud takes 3 seconds and 20 energy." if not use_button.disabled else "Chart Morrow first to locate orbital salvage."
	else:
		var gap: float = ship.position.distance_to(_target_position())
		var reason: String = model.reason(tool,selected,0)
		subject.text = "%s   /   %.0f m" % [TITLES[selected],gap]
		if approach_subject:
			hud.action_state.text = "APPROACHING"
			explanation.text = "Moving into tool range."
		elif held and not latched:
			hud.action_state.text = "OPERATING"
			explanation.text = "%s · %d%%" % [Equipment.title(tool),int(progress*100)]
		elif not operation_feedback.is_empty() and elapsed < operation_feedback_until:
			hud.action_state.text = operation_feedback
			explanation.text = "Survey recorded in the chronicle." if operation_feedback == "COMPLETE" and tool == "scan" else ("Operation complete." if operation_feedback == "COMPLETE" else "Orders cleared." if operation_feedback == "CANCELLED" else "Operation failed.")
		elif not reason.is_empty():
			hud.action_state.text = "UNAVAILABLE"
			explanation.text = _short_reason(reason)
		else:
			hud.action_state.text = "READY" if gap <= Equipment.reach(tool) else "OUT OF RANGE"
			explanation.text = "Click Use to operate." if gap <= Equipment.reach(tool) else "Click Use to approach."
		use_button.tooltip_text = reason if not reason.is_empty() else "Approach and operate the selected tool."
	progress_bar.value = salvage_progress if orbital else progress
	if operation_feedback == "COMPLETE" and elapsed < operation_feedback_until: progress_bar.value = 1
	if not orbital:
		use_button.text = "Cancel" if (held and not latched) or approach_subject else "Use"
		use_button.disabled = paused or _inspection_open()
		if not approach_subject and not (held and not latched):
			use_button.disabled = use_button.disabled or not model.reason(tool,selected,0).is_empty()
	for i: int in range(toolbar.size()):
		toolbar[i].tooltip_text = "Surface equipment · enter the atmosphere to operate." if orbital else Equipment.hint(TOOLS[i])
	_update_guidance()

func _short_reason(reason: String) -> String:
	# Keep the full validated reason on hover; the instrument shows one short cause.
	if reason.begins_with("Already catalogued"): return "Survey recorded. Select another tool."
	if reason.begins_with("Sample cradle full"): return "Sample cradles full: 2 / 2."
	if reason.begins_with("Need ") and "energy" in reason: return "Insufficient energy: %s required." % Equipment.amount(Equipment.energy(tool))
	if reason.begins_with("The thermal tool"): return "Requires a cold mineral bed."
	if reason.begins_with("Sample the seed pods"): return "Requires a scanned lantern pod."
	if reason.begins_with("Keep the last native"): return "Native reserve protected."
	if reason.begins_with("The bed is warm"): return "Bed already warmed."
	if reason.begins_with("Already planted"): return "Specimen already deployed."
	return reason

func _update_guidance() -> void:
	if elapsed < 1 or paused or _inspection_open(): return
	var id: String = "survey"
	var line: String = "Captain, that relay is still transmitting. Click it and we'll approach for a scan."
	if model.state.flight_mode == "orbit":
		if model.state.survey_ticks < int(Geography.definition().survey_seconds):
			id = "orbit"
			line = "We're clear of the atmosphere. Chart Morrow in the atlas to locate signals."
		elif not model.state.shroud_unlocked:
			id = "wreck"
			line = "The chart found a wreck inside a repeating pulse field. Click it to approach. Back out if your hull falls."
		else:
			id = "shroud"
			line = "That shroud can blunt pulses, but it drains reactor energy while engaged. Toggle it beside your hull gauge."
	elif model.state.landings > 0:
		id = "return"
		line = "Back in the basin. Your surveys are secure. You're free to explore."
	elif "relay" in model.state.scanned:
		id = "ascend"
		line = "The signal leads off-world. Pull the view back to ascend, or select Leave atmosphere."
	if heard_guides.has(id): return
	heard_guides[id] = true
	guide_caption.text = line
	caption_time = maxf(6,line.length()/14.0)
	audio.guide(id,line)

func _toast(text: String) -> void:
	status.text = text
	toast_time = 6

func _show_popup(kind: String) -> void:
	_cancel_orders()
	planet_map.hide()
	popup_kind = kind
	for child: Node in popup_body.get_children(): popup_body.remove_child(child); child.queue_free()
	popup.visible = true
	var header := HBoxContainer.new()
	popup_body.add_child(header)
	var titles := {"cargo":"EXPEDITION INVENTORY", "systems":"SHIP SYSTEMS", "audio":"AUDIO MIX", "controls":"FLIGHT CONTROLS", "journal":"EXPEDITION LOG", "contact":"VELL / TRADE"}
	var title: Label = _label(titles.get(kind,"EXPEDITION"),22)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	_button("×",func() -> void: popup.visible = false; audio.save_settings(),header,"ui_close")
	popup_body.add_child(_label("INSPECTION PAUSED  ·  Esc to close",12,Instruments.GOLD))
	if kind == "cargo":
		_build_cargo_panel()
	elif kind == "systems":
		_build_systems_panel()
	elif kind == "audio":
		for channel: String in ["sfx","music","voice"]:
			popup_body.add_child(_label({"sfx":"Effects and interface","music":"Music","voice":"Guide voice"}[channel],17))
			var slider := HSlider.new()
			slider.min_value = 0
			slider.max_value = 100
			slider.step = 1
			slider.value = float(audio.mix[channel])*100
			slider.custom_minimum_size = Vector2(460,30)
			slider.value_changed.connect(func(value: float) -> void: audio.set_volume(channel,value/100))
			slider.drag_ended.connect(func(_changed: bool) -> void: audio.save_settings(); audio.play("ui_confirm"))
			popup_body.add_child(slider)
		_button("Preview tools",_preview_tools,popup_body)
		_button("Preview guide",func() -> void: audio.guide("preview","Flight systems ready. Let's see what's beyond those clouds."),popup_body)
		var copy: Label = _label("Original sound and music candidates. Guide speech currently uses your Windows voice; recorded performances can replace it. Voice volume zero disables speech. On-screen instructions remain available.",14,Color("a2bacb"))
		copy.custom_minimum_size.x = 460
		copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		popup_body.add_child(copy)
	elif kind == "controls":
		var copy: Label = _label("Click terrain: fly there\nClick subject: approach and use selected tool\nClick planet in orbit: approach and descend\n\nFly: arrows / numpad 8, 4, 2, 6 / WASD\nAscend: Home / Page Up / numpad 9 or + / E\nDescend: End / Page Down / numpad 3 or − / Q\nBrake: numpad 5 or 0 / Escape / Stop button\n\nWheel: camera zoom · Ctrl + wheel: altitude\nPull back past the surface limit to ascend\nScroll in during that ascent to cancel\nRight drag: rotate camera\n1–4: tools · F: optional tool hold\nSpace: pause · F5: save · F9: load\n\nMouse buttons follow Windows primary-button settings. Flight buttons also support mouse-only play.",16)
		copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		copy.custom_minimum_size.x = 450
		popup_body.add_child(copy)
		_button("Audio settings",_show_popup.bind("audio"),popup_body)
	elif kind == "journal":
		var scroll := ScrollContainer.new()
		scroll.custom_minimum_size = Vector2(450,400)
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		popup_body.add_child(scroll)
		var entries := VBoxContainer.new()
		entries.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		entries.add_theme_constant_override("separation",16)
		scroll.add_child(entries)
		for entry: Dictionary in model.state.history:
			var text: Label = _label("%02d:%02d  %s" % [int(entry.time)/60,int(entry.time)%60,entry.text],16)
			text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			entries.add_child(text)
		if model.state.history.is_empty(): entries.add_child(_label("Your first discovery will appear here.",16))
	else:
		var portrait := TextureRect.new()
		portrait.texture = load("res://assets/advisors/finance-v1.png")
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.custom_minimum_size = Vector2(450,180)
		popup_body.add_child(portrait)
		var copy: Label = _label("“Leave the wild pods for those hungry little bells. Grow your own, and the nursery will buy.”\n\n18 Marks per cultivated pod · %d of 6 still wanted.\nBed output: 1 / 12 seconds; storage: 8.\nStanding order: 1 / 12 seconds when available, with 1 pod kept locally. No freight fee in this isolated trial." % model.state.buyer_remaining,16)
		copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		popup_body.add_child(copy)
		_button("Sell one cultivated pod",func() -> void: _trade(false),popup_body)
		_button("Stop recurring deliveries" if model.state.route else "Agree recurring deliveries",func() -> void: _trade(true),popup_body)

func _inspection_open() -> bool:
	return popup.visible or (planet_map != null and planet_map.visible)

func _toggle_planet_map() -> void:
	if planet_map.visible:
		planet_map.hide()
		audio.play("ui_close")
		return
	_cancel_orders()
	popup.hide()
	var location: Vector3 = Geography.site_direction()
	if model.state.flight_mode == "orbit":
		location = orbit.planet.basis.inverse()*(ship.position-orbit.planet.position)
	planet_map.present(model.state,location,paused,model.survey_reason())

func _map_travel(site_id: String) -> void:
	if site_id != "morrow_basin" or paused: return
	planet_map.hide()
	if model.state.flight_mode == "orbit": _begin_landing()
	else: _navigate(Vector3(0,8,12))

func _map_survey() -> void:
	if paused: return
	var reason: String = model.start_survey()
	if not reason.is_empty(): _toast(reason); audio.play("error"); return
	planet_map.hide()
	_toast("Orbital survey underway · 12 seconds")
	audio.play("target_lock")

func _toggle_drawer(kind: String) -> void:
	if popup.visible and popup_kind == kind:
		popup.visible = false
		audio.play("ui_close")
	else:
		audio.play("ui_open")
		_show_popup(kind)

func _panel_copy(text: String, tint: Color = Instruments.MUTED) -> Label:
	var copy: Label = _label(text,15,tint)
	copy.custom_minimum_size.x = 460
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	popup_body.add_child(copy)
	return copy

func _cargo_tab(location: String) -> void:
	cargo_location = location
	_show_popup("cargo")

func _build_cargo_panel() -> void:
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation",8)
	popup_body.add_child(tabs)
	for location: String in ["ship","surface"]:
		var tab: Button = _button("Onboard" if location == "ship" else "Surface store",_cargo_tab.bind(location),tabs)
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		Instruments.instrument(tab,"cargo",Instruments.CARGO,cargo_location == location)
	var onboard: bool = cargo_location == "ship"
	var amount: int = model.state.samples if onboard else model.state.produce
	var capacity: int = 2 if onboard else 8
	cargo_quantity = _label("%d / %d  %s" % [amount,capacity,"SAMPLE CRADLES" if onboard else "SURFACE STORAGE UNITS"],17,Instruments.CARGO)
	popup_body.add_child(cargo_quantity)
	var slots := GridContainer.new()
	slots.columns = 4
	slots.add_theme_constant_override("h_separation",8)
	slots.add_theme_constant_override("v_separation",8)
	popup_body.add_child(slots)
	for index: int in range(capacity):
		var slot := PanelContainer.new()
		slot.custom_minimum_size = Vector2(110,76)
		slot.add_theme_stylebox_override("panel",Instruments.box(Instruments.CARGO,index < amount))
		slots.add_child(slot)
		if index < amount:
			var pod := TextureRect.new()
			pod.texture = Instruments.icon("pod")
			pod.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			pod.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			pod.modulate = Instruments.CARGO if onboard else COLORS[0]
			pod.tooltip_text = "Living wild seed · Morrow Basin" if onboard else "Cultivated pod · Morrow surface bed"
			slot.add_child(pod)
		else:
			var empty: Label = _label("EMPTY",11,Instruments.MUTED)
			empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			slot.add_child(empty)
	popup_body.add_child(_label("LANTERN POD  /  "+("LIVING SPECIMEN" if onboard else "CULTIVATED PRODUCE"),16,COLORS[0]))
	if onboard:
		_panel_copy("Origin: wild lantern pods, Morrow Basin. Each living seed occupies one cradle. Surface harvests are stored separately.")
		var equip: Button = _button("Equip deployer",_equip_from_panel.bind("seed"),popup_body,"")
		equip.disabled = amount == 0
		equip.tooltip_text = "Collect a scanned wild pod first." if amount == 0 else Equipment.hint("seed")
		Instruments.instrument(equip,"seed",COLORS[3])
		_panel_copy("No specimens aboard. Scan a pod, then use the tractor." if amount == 0 else "Deployment needs a prepared bed. Selecting the tool does not consume the specimen.")
	else:
		_panel_copy("Location: Morrow surface bed. This stock is not aboard your ship. Mature beds produce one unit every 12 seconds, up to eight stored units.")
		_panel_copy("Nursery demand: %d remaining · 18 Marks per unit\nStanding deliveries: %s" % [model.state.buyer_remaining,"active; one unit reserved" if model.state.route else "off"])
		Instruments.instrument(_button("Open nursery agreement",_show_popup.bind("contact"),popup_body,"ui_open"),"comms",Instruments.COMMS)

func _inspect_system(id: String) -> void:
	inspected_system = id
	_show_popup("systems")

func _build_systems_panel() -> void:
	popup_body.add_child(_label("REACTOR  ·  %d / 100 ENERGY" % model.state.energy,17,Instruments.GOLD))
	system_energy = ProgressBar.new()
	system_energy.custom_minimum_size.y = 10
	system_energy.show_percentage = false
	system_energy.value = model.state.energy
	Instruments.meter(system_energy,Instruments.GOLD)
	popup_body.add_child(system_energy)
	_panel_copy("Recharge: 1.5 energy / second while simulation runs. Equipment inspection pauses flight and the simulation.")
	var modules := GridContainer.new()
	modules.columns = 2
	modules.add_theme_constant_override("h_separation",8)
	modules.add_theme_constant_override("v_separation",8)
	popup_body.add_child(modules)
	system_buttons.clear()
	_panel_copy("HULL  %d / 100 · field repair restores 35 for 30 reactor energy outside a hazard. Repair cooldown: 20 s." % model.state.hull)
	_panel_copy("PHASE SHROUD  %s · absorbs most pulse damage, drains 2 energy/s." % ("ACTIVE" if model.state.shroud_on else "INSTALLED" if model.state.shroud_unlocked else "NOT ACQUIRED"))
	for i: int in range(TOOLS.size()):
		var id: String = TOOLS[i]
		var button: Button = _button(Equipment.title(id),_inspect_system.bind(id),modules)
		button.custom_minimum_size = Vector2(232,62)
		button.add_theme_font_size_override("font_size",14)
		button.tooltip_text = Equipment.hint(id)
		Instruments.instrument(button,id,COLORS[i],inspected_system == id)
		system_buttons[id] = button
	var index: int = TOOLS.find(inspected_system)
	popup_body.add_child(_label(Equipment.title(inspected_system).to_upper(),18,COLORS[index]))
	_panel_copy(Equipment.hint(inspected_system),Instruments.PAPER)
	_panel_copy(str(Equipment.value(inspected_system,"acquisition")))
	_panel_copy("Cycle: %.1f seconds · installed\n%s" % [Equipment.seconds(inspected_system),"Currently selected in your hotbar." if tool == inspected_system else "Available to select in your hotbar."])
	var select: Button = _button("Select tool & return to flight",_equip_from_panel.bind(inspected_system),popup_body,"")
	Instruments.instrument(select,inspected_system,COLORS[index],true)

func _equip_from_panel(id: String) -> void:
	if id not in TOOLS: return
	_select_tool(id)
	popup.visible = false
	_toast(Equipment.title(id)+" selected")

func _preview_tools() -> void:
	if previewing_audio: return
	previewing_audio = true
	for item: String in TOOLS:
		audio.play("equip_"+item)
		await get_tree().create_timer(0.45).timeout
	previewing_audio = false

func _trade(recurring: bool) -> void:
	var error: String = model.set_route(not model.state.route) if recurring else model.sell()
	_toast(error if not error.is_empty() else ("Delivery agreement updated." if recurring else "Sold one pod for 18 Marks."))
	audio.play("error" if not error.is_empty() else "arrival")
	_show_popup("contact")

func _save(notify: bool = true) -> void:
	model.state.position = [ship.position.x,ship.position.y,ship.position.z]
	model.state.yaw = yaw
	var error: Error = model.save_to(save_path if notify else save_path.replace(".json","_auto.json"))
	if notify: audio.play("saved" if error == OK else "error")
	if notify or error != OK: _toast("Field progress saved." if error == OK else "Could not save: "+error_string(error))

func _load() -> void:
	var error: Error = model.load_from(save_path)
	if error == OK:
		_cancel_orders()
		_restore_ship()
		_apply_flight_mode()
		progress = 0
		held = false
		tick_clock = 0
		if popup.visible: _show_popup(popup_kind)
		if planet_map.visible:
			planet_map.hide()
			_toggle_planet_map()
	_toast("Field progress restored." if error == OK else "Could not load field progress: "+error_string(error))
	audio.play("saved" if error == OK else "error")

func _restore_ship() -> void:
	var at: Array = model.state.position
	ship.position = Vector3(at[0],at[1],at[2])
	if model.state.flight_mode == "surface": ship.position.y = clampf(ship.position.y,terrain_height(ship.position.x,ship.position.z)+2.7,57)
	yaw = model.state.yaw
	camera_focus = ship.position
	velocity = Vector3.ZERO

func _exit_encounter() -> void:
	audio.save_settings()
	_save(false)
	if leave.get_connections().is_empty(): get_tree().quit()
	else: leave.emit()

func _capture_flight(delta: float) -> void:
	capture_clock += delta
	if capture_clock < 2: return
	capture_clock = 0
	var path: String = ProjectSettings.globalize_path("user://flight_captures")
	DirAccess.make_dir_recursive_absolute(path)
	get_viewport().get_texture().get_image().save_png(path.path_join("flight_%d.png" % capture_step))
	capture_step += 1
	if capture_step == 1: _departure()
	elif capture_step == 5: _begin_landing()
	elif capture_step == 7: _show_popup("audio")
	elif capture_step == 8: get_tree().quit()

func _capture(delta: float) -> void:
	capture_clock += delta
	if capture_clock < 2: return
	capture_clock = 0
	var capture_dir: String = ProjectSettings.globalize_path("user://field_captures")
	DirAccess.make_dir_recursive_absolute(capture_dir)
	get_viewport().get_texture().get_image().save_png(capture_dir.path_join("field_%d.png" % capture_step))
	capture_step += 1
	if capture_step == 1:
		model.act("scan","pod",4)
		model.act("collect","pod",4)
		model.act("scan","bed",4)
		model.act("warm","bed",4)
		model.act("seed","bed",4)
		for i: int in range(21): model.tick()
		ship.position = Vector3(4,5,8)
		selected = "bed"
	elif capture_step == 2: _show_popup("contact")
	elif capture_step == 3:
		popup.visible = false
		ship.position = Vector3(-7,6,1)
		distance = 14
		pitch = 0.35
		selected = "grazer"
	else:
		var sorted: Array[float] = frame_samples.duplicate()
		sorted.sort()
		print("Field rendered sample: p50=%.2f ms p95=%.2f ms; draw calls=%d; triangles=%d" % [sorted[sorted.size()/2],sorted[int(sorted.size()*0.95)],Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)])
		get_tree().quit()
