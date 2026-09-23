extends Node3D
## Bounded field encounter. Detailed presentation is independent of the saved model.
signal leave
var suspended_session: Node = null
const Model = preload("res://scripts/encounter_state.gd")
const Sound = preload("res://scripts/audio_feedback.gd")
const FlightControls = preload("res://scripts/flight_controls.gd")
const OrbitalScene = preload("res://scripts/orbital_scene.gd")
const GrazerMotion = preload("res://scripts/grazer_motion.gd")
const TITLES := {"pod":"Lantern pods", "grazer":"Bell grazer", "bed":"Cold mineral bed", "relay":"Silent relay"}
const TOOLS: Array[String] = ["scan","collect","warm","seed"]
const COLORS: Array[Color] = [Color("9ae5d3"),Color("ddd0f1"),Color("edb46c"),Color("ace6a0")]
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
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
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
	camera.far = 230
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for x: int in range(-50,50):
		for z: int in range(-50,50):
			for offset: Vector2 in [Vector2(0,0),Vector2(1,0),Vector2(0,1),Vector2(1,0),Vector2(1,1),Vector2(0,1)]:
				var px: float = x+offset.x
				var pz: float = z+offset.y
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
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
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

func _button(text: String, callback: Callable, parent: Control) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 42
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override("normal",_style(Color("273a48")))
	button.add_theme_stylebox_override("hover",_style(Color("3e5962")))
	button.add_theme_stylebox_override("pressed",_style(Color("416b64")))
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _panel(parent: Control, rect: Rect2) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.add_theme_stylebox_override("panel",_style(Color(0.045,0.08,0.115,0.92)))
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
	var top: VBoxContainer = _panel(root,Rect2(24,24,365,105))
	location_label = _label("MORROW / SURFACE",22)
	top.add_child(location_label)
	stats = _label("",14,Color("a2bacb"))
	top.add_child(stats)
	var right := HBoxContainer.new()
	right.position = Vector2(950,24)
	right.add_theme_constant_override("separation",6)
	root.add_child(right)
	_button("Comms",_show_popup.bind("contact"),right)
	_button("Log",_show_popup.bind("journal"),right)
	_button("Controls",_show_popup.bind("controls"),right)
	pause_button = _button("Pause",_toggle_pause,right)
	_button("Menu",_exit_encounter,right)
	var card: VBoxContainer = _panel(root,Rect2(24,145,320,110))
	card.add_child(_label("FLIGHT ASSIST",12,Color("82b7c9")))
	objective = _label("",17)
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective.custom_minimum_size.x = 280
	card.add_child(objective)
	var instruments: VBoxContainer = _panel(root,Rect2(24,716,320,160))
	flight_readout = _label("",18)
	instruments.add_child(flight_readout)
	energy_bar = ProgressBar.new()
	energy_bar.custom_minimum_size.y = 8
	energy_bar.show_percentage = false
	energy_bar.tooltip_text = "Ship energy"
	instruments.add_child(energy_bar)
	var flight_row := HBoxContainer.new()
	instruments.add_child(flight_row)
	var rise: Button = _button("Ascend",func() -> void: pass,flight_row)
	rise.button_down.connect(func() -> void: vertical_button = 1; altitude_order = -1)
	rise.button_up.connect(func() -> void: vertical_button = 0)
	var lower: Button = _button("Descend",func() -> void: pass,flight_row)
	lower.button_down.connect(func() -> void: vertical_button = -1; altitude_order = -1)
	lower.button_up.connect(func() -> void: vertical_button = 0)
	_button("Stop",_cancel_orders,flight_row)
	var footer: VBoxContainer = _panel(root,Rect2(370,732,840,144))
	var tools_row := HBoxContainer.new()
	tools_row.add_theme_constant_override("separation",8)
	footer.add_child(tools_row)
	for i: int in range(TOOLS.size()):
		var names: Array[String] = ["Scan","Tractor","Thermal","Deploy"]
		var button: Button = _button(str(i+1)+"  "+names[i],_select_tool.bind(TOOLS[i]),tools_row)
		button.tooltip_text = "Click a target to approach and use this tool."
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		toolbar.append(button)
	use_button = _button("Use",_activate_selected,tools_row)
	subject = _label("",17)
	footer.add_child(subject)
	explanation = _label("",13,Color("a2bacb"))
	footer.add_child(explanation)
	progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size.y = 4
	progress_bar.show_percentage = false
	progress_bar.max_value = 1
	footer.add_child(progress_bar)
	var nav: VBoxContainer = _panel(root,Rect2(1235,765,340,110))
	departure_button = _button("Leave atmosphere",_departure,nav)
	status = _label("",18,Color("ffe0a8"))
	status.position = Vector2(435,655)
	status.size = Vector2(730,58)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(status)
	guide_arrow = _label("▼",28,Color("ffe0a8"))
	root.add_child(guide_arrow)
	for id: String in targets:
		var label: Label = _label(TITLES[id],13,Color("e3e9de"))
		labels[id] = label
		root.add_child(label)
	popup = PanelContainer.new()
	popup.position = Vector2(1045,100)
	popup.size = Vector2(530,560)
	popup.add_theme_stylebox_override("panel",_style(Color("111f2b")))
	root.add_child(popup)
	popup_body = VBoxContainer.new()
	popup_body.add_theme_constant_override("separation",12)
	popup.add_child(popup_body)
	popup.visible = false
	_select_tool("scan")

func _physics_process(delta: float) -> void:
	if paused or popup.visible: velocity = Vector3.ZERO; return
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
		if input_direction.y != 0: altitude_order = -1
	if navigating:
		if approach_subject: destination = _target_position()+Vector3(0,5,5)
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
	frame_samples.append(delta*1000)
	if frame_samples.size() > 600: frame_samples.pop_front()
	if not paused:
		elapsed += delta
		tick_clock += delta
		while tick_clock >= 1:
			tick_clock -= 1
			var old_count: int = model.state.history.size()
			model.tick()
			if model.state.history.size() != old_count:
				_toast(model.state.history.back().text)
				audio.play("arrival")
				if popup.visible: _show_popup(popup_kind)
			if int(model.state.time)%30 == 0 and "--field-capture" not in OS.get_cmdline_user_args(): _save(false)
	_update_camera(delta)
	if not paused and model.state.flight_mode == "orbit": orbit.advance(delta)
	if not paused and model.state.flight_mode == "surface":
		for motion: RefCounted in grazer_motion:
			motion.advance(delta,ship.position)
			motion.actor.position.y = maxf(motion.actor.position.y,terrain_height(motion.actor.position.x,motion.actor.position.z)+3.0)
	_update_visuals()
	_operate(delta)
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
	camera_focus = camera_focus.lerp(ship.position+Vector3(0,-1,0),minf(1,delta*5))
	var offset := Vector3(sin(yaw)*cos(pitch),sin(pitch),cos(yaw)*cos(pitch))*distance
	camera.position = camera_focus+offset
	camera.look_at(camera_focus)

func _update_visuals() -> void:
	var orbital: bool = model.state.flight_mode == "orbit"
	navigation_marker.visible = navigating
	navigation_marker.position = destination-Vector3(0,0.8,0)
	guide_arrow.visible = not paused and not popup.visible
	if orbital:
		guide_arrow.position = Vector2(1390,724)
		ring.visible = false
		for label: Label in labels.values(): label.visible = false
		return
	if "relay" not in model.state.scanned:
		var projected: Vector2 = camera.unproject_position(_target_position("relay"))
		guide_arrow.position = Vector2(clampf(projected.x-14,350,1180),clampf(projected.y-72,130,610))-Vector2(0,sin(elapsed*4)*5)
		guide_arrow.visible = guide_arrow.visible and not camera.is_position_behind(_target_position("relay"))
	else: guide_arrow.position = Vector2(1390,724+sin(elapsed*4)*4)
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
		label.visible = not camera.is_position_behind(at) and not popup.visible and label.position.y > 145 and label.position.y < 690 and label.position.x > 350
		label.modulate.a = 1.0 if id == selected else 0.65

func _target_position(id: String = "") -> Vector3:
	if id.is_empty(): id = selected
	var node: Node3D = targets[id]
	return node.position+Vector3(0,2.5 if id in ["pod","relay"] else 0.6,0)

func _operate(delta: float) -> void:
	beam.visible = false
	if paused or popup.visible or model.state.flight_mode == "orbit" or not held or latched:
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
	progress += delta/float(Model.ACTION_SECONDS[tool])
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
		audio.play("error" if not error.is_empty() else "build")
		latched = true
		progress = 0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and not event.echo:
		if event.physical_keycode == KEY_F:
			held = event.pressed
			if not held: latched = false
		if not event.pressed: return
		match event.physical_keycode:
			KEY_1: _select_tool("scan")
			KEY_2: _select_tool("collect")
			KEY_3: _select_tool("warm")
			KEY_4: _select_tool("seed")
			KEY_TAB:
				_cancel_orders()
				selected = Model.TARGETS[(Model.TARGETS.find(selected)+1)%4]
			KEY_SPACE: _toggle_pause()
			KEY_ESCAPE: popup.visible = false; _cancel_orders()
			KEY_F5: _save()
			KEY_F9: _load()
	if popup.visible or paused: return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
			var sign_y: float = 1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1
			if event.ctrl_pressed: distance = clampf(distance-sign_y*3,12,65)
			else:
				navigating = false
				approach_subject = false
				altitude_order = clampf((ship.position.y if altitude_order < 0 else altitude_order)+sign_y*6,3,65)
		if event.button_index == MOUSE_BUTTON_LEFT: _pick(event.position)
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		yaw -= event.relative.x*0.006
		pitch = clampf(pitch+event.relative.y*0.004,0.2,1.3)

func _pick(screen: Vector2) -> void:
	if paused or popup.visible: return
	if model.state.flight_mode == "orbit":
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
		selected = picked
		_activate_selected()
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
	audio.play("tap")

func _activate_selected() -> void:
	if held or approach_subject: _cancel_orders(); return
	if model.state.flight_mode == "orbit": return
	var error: String = model.reason(tool,selected,0)
	if not error.is_empty(): _toast(error); audio.play("error"); return
	_cancel_orders()
	if ship.position.distance_to(_target_position()) > 11:
		destination = _target_position()+Vector3(0,5,5)
		navigating = true
		approach_subject = true
	else: held = true

func _cancel_orders() -> void:
	navigating = false
	approach_subject = false
	landing = false
	held = false
	latched = false
	progress = 0
	vertical_button = 0
	altitude_order = -1
	velocity = Vector3.ZERO

func _toggle_pause() -> void:
	paused = not paused
	_cancel_orders()

func _departure() -> void:
	if paused or popup.visible: return
	if model.state.flight_mode == "orbit": _begin_landing(); return
	_cancel_orders()
	altitude_order = 63
	audio.play("launch")

func _begin_landing() -> void:
	_navigate(OrbitalScene.APPROACH)
	landing = true
	audio.play("launch")

func _change_flight_mode(mode: String) -> void:
	if not model.change_flight_mode(mode): return
	_cancel_orders()
	_restore_ship()
	_apply_flight_mode()
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
	distance = 43 if orbital else 29
	camera_focus = ship.position
	_update_camera(1)

func _select_tool(value: String) -> void:
	_cancel_orders()
	tool = value
	progress = 0
	held = false
	latched = false
	var index: int = TOOLS.find(tool)
	beam_material.albedo_color = COLORS[index]
	beam_material.emission = COLORS[index]
	for i: int in range(toolbar.size()): toolbar[i].modulate = COLORS[i] if i == index else Color("a1aaae")
	audio.play("tap")

func _refresh_ui() -> void:
	var s: Dictionary = model.state
	var orbital: bool = s.flight_mode == "orbit"
	location_label.text = "MORROW / ORBIT" if orbital else "MORROW / SURFACE"
	stats.text = "%d Marks   /   Cargo %d   /   %d surveys" % [s.marks,s.samples+s.produce,s.scanned.size()]
	energy_bar.value = s.energy
	flight_readout.text = "%s  %.0f m   /   %.0f m/s\nENERGY  %d / 100" % ["Y" if orbital else "ALT",ship.position.y,velocity.length(),s.energy]
	pause_button.text = "Resume" if paused else "Pause"
	departure_button.text = "Return to Morrow" if orbital else "Leave atmosphere"
	if orbital: objective.text = "You're in orbit. Click Morrow to approach and descend."
	elif "relay" not in s.scanned: objective.text = "Click the old relay to approach and scan. Or leave whenever you're ready."
	elif not s.history.any(func(entry: Dictionary) -> bool: return entry.id == "first_orbit"): objective.text = "The signal points beyond the clouds. Ascend or choose Leave atmosphere."
	else: objective.text = "Flight assist complete. Survey the basin or return to orbit."
	if orbital:
		subject.text = "MORROW  /  orbital flight"
		explanation.text = "Click planet to descend · Click space to fly · Wheel changes altitude"
	else:
		var gap: float = ship.position.distance_to(_target_position())
		subject.text = "%s   /   %.0f m   /   %s" % [TITLES[selected],gap,tool.capitalize()]
		if approach_subject: explanation.text = "Approaching target · Stop or steer to cancel"
		elif held and not latched: explanation.text = "Tool active · Click Use or press Escape to cancel"
		else: explanation.text = "Click a target to use tool · Click terrain to fly · Wheel changes altitude"
	progress_bar.value = progress
	use_button.text = "Cancel" if (held and not latched) or approach_subject else "Use"

func _toast(text: String) -> void:
	status.text = text
	toast_time = 6

func _show_popup(kind: String) -> void:
	_cancel_orders()
	popup_kind = kind
	for child: Node in popup_body.get_children(): popup_body.remove_child(child); child.queue_free()
	popup.visible = true
	var header := HBoxContainer.new()
	popup_body.add_child(header)
	var title: Label = _label("FLIGHT CONTROLS" if kind == "controls" else ("EXPEDITION LOG" if kind == "journal" else "VELL / TRADE"),22)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	_button("×",func() -> void: popup.visible = false,header)
	if kind == "controls":
		var copy: Label = _label("Click terrain: fly there\nClick subject: approach and use selected tool\nClick planet in orbit: approach and descend\n\nFly: arrows / numpad 8, 4, 2, 6 / WASD\nAscend: Home / Page Up / numpad 9 or + / E\nDescend: End / Page Down / numpad 3 or − / Q\nBrake: numpad 5 or 0 / Escape / Stop button\n\nWheel: altitude · Ctrl + wheel: camera zoom\nRight drag: rotate camera\n1–4: tools · F: optional tool hold\nSpace: pause · F5: save · F9: load\n\nMouse buttons follow Windows primary-button settings. Flight buttons also support mouse-only play.",16)
		copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		copy.custom_minimum_size.x = 450
		popup_body.add_child(copy)
		_button("Sound: off" if audio.muted else "Sound: on",func() -> void: audio.muted = not audio.muted; _show_popup("controls"),popup_body)
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
	var hint: Label = _label("Isolated field save · campaign resources are untouched",12,Color("9fcbbf"))
	popup_body.add_child(hint)

func _trade(recurring: bool) -> void:
	var error: String = model.set_route(not model.state.route) if recurring else model.sell()
	_toast(error if not error.is_empty() else ("Delivery agreement updated." if recurring else "Sold one pod for 18 Marks."))
	audio.play("error" if not error.is_empty() else "arrival")
	_show_popup("contact")

func _save(notify: bool = true) -> void:
	model.state.position = [ship.position.x,ship.position.y,ship.position.z]
	model.state.yaw = yaw
	var error: Error = model.save_to(save_path if notify else save_path.replace(".json","_auto.json"))
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
	_toast("Field progress restored." if error == OK else "Could not load field progress: "+error_string(error))

func _restore_ship() -> void:
	var at: Array = model.state.position
	ship.position = Vector3(at[0],at[1],at[2])
	if model.state.flight_mode == "surface": ship.position.y = clampf(ship.position.y,terrain_height(ship.position.x,ship.position.z)+2.7,57)
	yaw = model.state.yaw
	camera_focus = ship.position
	velocity = Vector3.ZERO

func _exit_encounter() -> void:
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
