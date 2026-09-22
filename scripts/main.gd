extends Node3D
## Presentation and input only; all gameplay mutations go through Simulation.command.
const Simulation = preload("res://scripts/simulation.gd")
const UrbanView = preload("res://scripts/urban_view.gd")
const AudioFeedback = preload("res://scripts/audio_feedback.gd")
const Architecture = preload("res://scripts/city_architecture.gd")
const CityPanel = preload("res://scripts/city_panel.gd")
var city_section: String = "overview"
var zone_start := Vector2i(-1,-1)
var zone_preview: MeshInstance3D
const INK := Color("0a1421")
const PANEL := Color("101f30")
const MUTED := Color("8ea6bb")
const WHITE := Color("e5eef4")
const MINT := Color("79e5c0")
const GOLD := Color("f1c77e")
const COLORS: Dictionary = {"road":"485e72","habitat":"83d8c3","industry":"e7b277","service":"9cacde","power":"f1d47d","life_support":"78cae5","extractor":"cb9771","terraformer":"b7e59b","spaceport":"d3e1ec"}

var sim := Simulation.new()
var sound := AudioFeedback.new()
var world := Node3D.new()
var buildings: Node3D
var camera := Camera3D.new()
var view: String = "colony"
var planet_id: String = "s0p0"
var system_id: String = "s0"
var tool: String = "inspect"
var overlay: String = "natural"
var speed: int = 1
var clock_accumulator: float = 0.0
var orbit: float = -0.35
var camera_pitch: float = 0.7
var zoom: float = 33.0
var focus := Vector3.ZERO
var cursor_cell := Vector2i(-1,-1)
var selected_cell := Vector2i(-1,-1)
var last_painted := Vector2i(-1,-1)
var hover_mesh: MeshInstance3D
var ship_mesh: Node3D
var overview_globe: MeshInstance3D
var hud := CanvasLayer.new()
var title_label: Label
var stats_label: Label
var subtitle_label: Label
var right_box: VBoxContainer
var left_box: VBoxContainer
var toast_label: Label
var hint_label: Label
var tick_label: Label
var view_buttons: Dictionary = {}
var tool_buttons: Dictionary = {}
var overlay_buttons: Dictionary = {}
var speed_buttons: Dictionary = {}
var last_build_signature: String = ""
var last_access_signature: String = ""
var building_nodes: Dictionary = {}
var building_states: Dictionary = {}
var broken_link_marker: Node3D
var terrain_recovery_stage: int = -1
var toast_seconds: float = 0.0
var frame_counter: int = 0
var capture_stage: int = 0
var capture_mode: bool = false
var smoke_mode: bool = false
var mode_menu: Control
var menu_speed: int = 1
var build_panel: PanelContainer
var details_open: bool = false
var colony_site_marker: MeshInstance3D
var site_planet_id: String = ""
var follow_flagship: bool = false

func _ready() -> void:
	if DisplayServer.get_name() != "headless": Engine.max_fps = 60
	add_child(sound)
	add_child(world)
	add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.far = 500
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48,-32,0)
	sun.light_color = Color("fff0d9")
	sun.light_energy = 0.65
	sun.shadow_enabled = true
	add_child(sun)
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = INK
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("a5c6e3")
	env.ambient_light_energy = 0.28
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	environment.environment = env
	add_child(environment)
	sim.new_game()
	sim.changed.connect(_on_sim_changed)
	sim.message.connect(_on_message)
	_make_ui()
	_rebuild_world()
	_refresh_ui()
	capture_mode = "--capture" in OS.get_cmdline_user_args()
	smoke_mode = "--smoke" in OS.get_cmdline_user_args()
	if capture_mode:
		speed = 0
		DirAccess.make_dir_recursive_absolute("res://artifacts")
	_toast("Welcome, Captain. Your colony is already running. Try adding habitat along a road.")
	if not capture_mode and not smoke_mode and not "--script" in OS.get_cmdline_args(): _show_mode_menu()

func _process(delta: float) -> void:
	clock_accumulator += delta * speed
	while clock_accumulator >= 1.0:
		clock_accumulator -= 1.0
		sim.tick()
		if int(sim.state.tick) % 60 == 0:
			var result: Error = sim.save_game(sim.save_path(true))
			if result != OK: _toast("Autosave failed: " + error_string(result))
	if view in ["colony","galaxy"]:
		var pan := Vector3.ZERO
		if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP): pan.z -= 1
		if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN): pan.z += 1
		if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT): pan.x -= 1
		if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT): pan.x += 1
		focus += pan.rotated(Vector3.UP,orbit) * delta * zoom * 0.45
		var limit: float = 150 if sim.state.has("urban") and planet_id == "s0p0" else 35
		focus.x = clampf(focus.x,-limit,limit)
		focus.z = clampf(focus.z,-limit,limit)
	if Input.is_physical_key_pressed(KEY_Q): orbit -= delta * 0.8
	if Input.is_physical_key_pressed(KEY_E): orbit += delta * 0.8
	if Input.is_physical_key_pressed(KEY_R): camera_pitch = minf(1.35,camera_pitch+delta*0.7)
	if Input.is_physical_key_pressed(KEY_F): camera_pitch = maxf(0.15,camera_pitch-delta*0.7)
	_update_camera(delta)
	# The user controls orbital rotation. Surface markers are children of the globe.
	if view == "galaxy" and is_instance_valid(ship_mesh): _position_ship()
	toast_seconds -= delta
	toast_label.modulate.a = clampf(toast_seconds,0.0,1.0)
	frame_counter += 1
	if smoke_mode and frame_counter == 100: get_tree().quit()
	if capture_mode and frame_counter % 40 == 0: _capture_next()

func _update_camera(delta: float = 1.0) -> void:
	var desired_focus: Vector3 = focus
	var distance: float = maxf(45.0,zoom*1.4)
	if view == "galaxy" and follow_flagship and is_instance_valid(ship_mesh): desired_focus = ship_mesh.position
	elif view == "planet": desired_focus = Vector3.ZERO
	var desired: Vector3 = desired_focus + Vector3(sin(orbit)*cos(camera_pitch),sin(camera_pitch),cos(orbit)*cos(camera_pitch))*distance
	camera.position = camera.position.lerp(desired,minf(1.0,delta*9.0))
	camera.look_at(desired_focus)
	camera.size = lerpf(camera.size,zoom,minf(1.0,delta*9.0))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and zone_start.x >= 0:
		_select_tool("inspect")
		return
	if is_instance_valid(mode_menu): return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_SPACE: _set_speed(1 if speed == 0 else 0)
			KEY_ESCAPE: _select_tool("inspect")
			KEY_F5: _save()
			KEY_F9: _load()
			KEY_G: _switch_view("galaxy")
			KEY_C: _switch_view("colony")
			KEY_P: _switch_view("planet")
			KEY_B: _toggle_build()
			KEY_1: _select_tool("road")
			KEY_2: _select_tool("habitat")
			KEY_3: _select_tool("industry")
			KEY_4: _select_tool("service")
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP: zoom = maxf(8,zoom*0.9)
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN: zoom = minf(260,zoom/0.9)
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT: _select_tool("inspect")
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if view == "colony":
					if tool in Simulation.City.ZONES:
						var point: Variant = _ground_point(event.position)
						if point != null: zone_start = Vector2i(floori(point.x+32),floori(point.z+32)); _preview_zone(event.position)
					else: _click_colony(event.position)
				elif view == "galaxy": _click_galaxy(event.position)
			else: last_painted = Vector2i(-1,-1)
			if not event.pressed and zone_start.x >= 0: _finish_zone(event.position)
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			orbit -= event.relative.x*0.006
			camera_pitch = clampf(camera_pitch+event.relative.y*0.005,0.15,1.35)
			return
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) and view == "colony":
			focus += Vector3(-event.relative.x,0,-event.relative.y).rotated(Vector3.UP,orbit)*zoom/900.0
			return
	if event is InputEventMouseMotion and view == "colony":
		var ground: Variant = _ground_point(event.position)
		if ground != null:
			cursor_cell = Vector2i(int(floor(ground.x+32)),int(floor(ground.z+32)))
			if is_instance_valid(hover_mesh):
				hover_mesh.visible = cursor_cell.x >= 0 and cursor_cell.y >= 0 and cursor_cell.x < 64 and cursor_cell.y < 64
				hover_mesh.position = Vector3(cursor_cell.x-31.5,0.12,cursor_cell.y-31.5)
			_update_hint()
		if zone_start.x >= 0: _preview_zone(event.position)
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and tool in ["road","bulldoze"]:
			_click_colony(event.position)

func _preview_zone(screen: Vector2) -> void:
	var point: Variant = _ground_point(screen)
	if point == null: return
	var end := Vector2i(clampi(floori(point.x+32),0,63),clampi(floori(point.z+32),0,63))
	if not is_instance_valid(zone_preview): zone_preview = _box(world,Vector3.ZERO,Vector3.ONE,Color(Color(COLORS[tool]),0.5),0.3)
	zone_preview.position = Vector3((zone_start.x+end.x)*0.5-31.5,0.16,(zone_start.y+end.y)*0.5-31.5)
	zone_preview.scale = Vector3(absi(end.x-zone_start.x)+1,0.035,absi(end.y-zone_start.y)+1)
	_toast("%d × %d zoning rectangle · free designation · release to zone" % [absi(end.x-zone_start.x)+1,absi(end.y-zone_start.y)+1])

func _finish_zone(screen: Vector2) -> void:
	var start: Vector2i = zone_start
	zone_start = Vector2i(-1,-1)
	if is_instance_valid(zone_preview): zone_preview.queue_free(); zone_preview = null
	var point: Variant = _ground_point(screen)
	if point == null: return
	_command("zone_rect",{"planet":planet_id,"type":tool,"x0":start.x,"z0":start.y,"x1":clampi(floori(point.x+32),0,63),"z1":clampi(floori(point.z+32),0,63)})

func _ground_point(screen: Vector2) -> Variant:
	return Plane(Vector3.UP,0).intersects_ray(camera.project_ray_origin(screen),camera.project_ray_normal(screen))

func _click_colony(screen: Vector2) -> void:
	var point: Variant = _ground_point(screen)
	if point == null: return
	var cell := Vector2i(int(floor(point.x+32)),int(floor(point.z+32)))
	if tool == "inspect":
		selected_cell = Simulation.cell_position(str(sim.state.colonies[planet_id].occupied.get(Simulation.key(cell.x,cell.y),Simulation.key(cell.x,cell.y))))
		_refresh_right()
		return
	if cell == last_painted: return
	last_painted = cell
	var error: String = sim.command("build",{"planet":planet_id,"x":cell.x,"z":cell.y,"type":tool})
	if not error.is_empty(): _toast(error)
	else:
		sound.play("build")
		_refresh_buildings()
		if overlay != "natural": _rebuild_world()

func _click_galaxy(screen: Vector2) -> void:
	var best: float = 32.0
	for system: Dictionary in sim.state.systems:
		if not sim.is_revealed(system.id): continue
		var point: Vector2 = camera.unproject_position(Vector3(system.x,0,system.z))
		var distance: float = point.distance_to(screen)
		if distance < best:
			best = distance
			system_id = system.id
			planet_id = system.planets[0]
	_refresh_right()

func _command(action: String, args: Dictionary = {}) -> void:
	var error: String = sim.command(action,args)
	if not error.is_empty():
		_toast(error)
		sound.play("error")
	else:
		if action in ["travel","colonize"]: sound.play("launch")
		elif action == "civic":
			sound.play("build")
			if args.get("choice","") in ["public","sponsor"]: _set_speed(1)
		_refresh_ui()
		if action in ["travel","colonize","discover","cheat"]: _rebuild_world()

func _on_sim_changed() -> void:
	if not is_instance_valid(stats_label): return
	_refresh_ui()
	if view == "colony":
		if int(float(sim.state.planets[planet_id].terraform)*10) != terrain_recovery_stage or (overlay != "natural" and str(sim.state.colonies[planet_id].layer_signature) != last_access_signature):
			_rebuild_world()
		else: _refresh_buildings()
	if view == "planet" and is_instance_valid(overview_globe):
		if site_planet_id != (planet_id if sim.state.colonies.has(planet_id) or sim.state.settlements.has(planet_id) else ""):
			_rebuild_world()
		var planet: Dictionary = sim.state.planets[planet_id]
		var material := overview_globe.material_override as ShaderMaterial
		material.set_shader_parameter("recovery",float(planet.terraform))

func _on_message(text: String) -> void:
	_toast(text)
	if text.begins_with("Arrived") or text.begins_with("Landing hub operational") or text.begins_with("South Loop reconnected"): sound.play("arrival")
	if "imposed an embargo" in text:
		speed = 0
		_toast(text + " Simulation paused; review diplomacy.")
	if "Arrived at" in text and view == "galaxy": _rebuild_world()

func _save() -> void:
	var result: Error = sim.save_game()
	_toast("Game saved · F9 to restore" if result == OK else "Save failed: " + error_string(result))

func _load(autosave: bool = false) -> void:
	# Reset view IDs before the load signal can refresh the HUD.
	planet_id = "s0p0"
	system_id = "s0"
	var result: Error = sim.load_game(sim.save_path(autosave))
	if result != OK: _toast("Could not load: " + error_string(result)); return
	planet_id = "s0p0"
	system_id = "s0"
	clock_accumulator = 0.0
	_switch_view("colony")
	_toast("Expedition restored.")

func _switch_view(next: String) -> void:
	zone_start = Vector2i(-1,-1)
	city_section = "overview"
	if next == "colony" and not sim.state.colonies.has(planet_id):
		_toast("Select one of your colonies first, or found a new settlement.")
		return
	view = next
	zoom = 33.0 if view == "colony" else (57.0 if view == "galaxy" else 25.0)
	if view == "colony" and sim.state.has("urban") and planet_id == "s0p0": zoom = 190.0
	camera_pitch = 0.70 if view == "colony" else (1.05 if view == "galaxy" else 0.25)
	details_open = false
	focus = Vector3.ZERO
	if view == "galaxy": focus = Vector3(1,0,6)
	orbit = -0.35 if view != "planet" else 0.0
	selected_cell = Vector2i(-1,-1)
	_rebuild_world()
	_refresh_ui()

func _select_tool(next: String) -> void:
	zone_start = Vector2i(-1,-1)
	if is_instance_valid(zone_preview): zone_preview.queue_free(); zone_preview = null
	var changed_grid: bool = (tool == "inspect") != (next == "inspect")
	tool = next
	if changed_grid and view == "colony": _rebuild_world()
	for id: String in tool_buttons: tool_buttons[id].button_pressed = id == tool
	_update_hint()

func _toggle_build() -> void:
	if view != "colony":
		if not sim.state.colonies.has(planet_id): _toast("Open an established colony to build."); return
		_switch_view("colony")
	build_panel.visible = not build_panel.visible

func _toggle_details() -> void:
	details_open = not details_open
	_refresh_right()

func _set_overlay(next: String) -> void:
	overlay = next
	if view == "colony" and next != "natural" and zoom > 65: zoom = 36; focus = Vector3.ZERO
	_rebuild_world()
	for id: String in overlay_buttons: overlay_buttons[id].button_pressed = id == overlay

func _set_speed(next: int) -> void:
	speed = next
	for value: int in speed_buttons: speed_buttons[value].button_pressed = value == speed

func _toast(text: String) -> void:
	if not is_instance_valid(toast_label): return
	toast_label.text = text
	toast_seconds = 7.0

func _style(bg: Color, border: Color = Color("26343b"), radius: int = 3) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _label(text: String, size: int = 16, color: Color = WHITE) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size",size)
	label.add_theme_color_override("font_color",color)
	return label

func _text(parent: Control, text: String, size: int = 15, color: Color = MUTED) -> Label:
	var label: Label = _label(text,size,color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	return label

func _button(text: String, callback: Callable, parent: Control, toggle: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 34
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.toggle_mode = toggle
	button.clip_text = true
	button.tooltip_text = text
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override("normal",_style(Color("1a252bf0")))
	button.add_theme_stylebox_override("hover",_style(Color("2d3e44"),Color("a9c7bb")))
	button.add_theme_stylebox_override("pressed",_style(Color("385048"),MINT))
	button.add_theme_color_override("font_color",WHITE)
	button.add_theme_font_size_override("font_size",14)
	button.pressed.connect(callback)
	button.pressed.connect(func() -> void: sound.play("tap"))
	parent.add_child(button)
	return button

func _panel(parent: Control, left: float, top: float, right: float, bottom: float) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(left,top)
	panel.size = Vector2(right-left,bottom-top)
	panel.add_theme_stylebox_override("panel",_style(Color("10191feb")))
	parent.add_child(panel)
	return panel

func _make_ui() -> void:
	add_child(hud)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(root)
	var theme := Theme.new()
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Bahnschrift","Calibri"])
	theme.default_font = font
	theme.default_font_size = 15
	root.theme = theme
	var top: PanelContainer = _panel(root,20,16,1580,78)
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation",12)
	top.add_child(bar)
	var brand := VBoxContainer.new()
	brand.custom_minimum_size.x = 260
	bar.add_child(brand)
	brand.add_child(_label("Frontier Worlds",22,WHITE))
	tick_label = _label("SOLACE EXPEDITION  /  DAY 000",12,MINT)
	brand.add_child(tick_label)
	for id: String in ["galaxy","planet","colony"]:
		view_buttons[id] = _button(id.capitalize(),_switch_view.bind(id),bar,true)
		view_buttons[id].custom_minimum_size.x = 82
	stats_label = _label("",17)
	stats_label.clip_text = true
	stats_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	bar.add_child(stats_label)
	_button("Save",_save,bar).custom_minimum_size.x = 65
	_button("Load",_load,bar).custom_minimum_size.x = 65
	_button("Menu",_show_mode_menu,bar).custom_minimum_size.x = 65
	_button("Build",_toggle_build,bar).custom_minimum_size.x = 65
	var layers := OptionButton.new()
	for layer: String in ["natural","suitability","access","crime","fire","police","clinic","transit"]: layers.add_item(layer.capitalize())
	layers.item_selected.connect(func(index: int) -> void: _set_overlay(["natural","suitability","access","crime","fire","police","clinic","transit"][index]))
	bar.add_child(layers)
	build_panel = _panel(root,20,158,264,790)
	build_panel.visible = false
	var left_scroll := ScrollContainer.new()
	left_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	build_panel.add_child(left_scroll)
	left_box = VBoxContainer.new()
	left_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_box.add_theme_constant_override("separation",8)
	left_scroll.add_child(left_box)
	var right_panel: PanelContainer = _panel(root,1248,100,1580,790)
	var right_scroll := ScrollContainer.new()
	right_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right_panel.add_child(right_scroll)
	right_box = VBoxContainer.new()
	right_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_box.add_theme_constant_override("separation",10)
	right_scroll.add_child(right_box)
	var center := VBoxContainer.new()
	center.position = Vector2(40,100)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(center)
	title_label = _label("",26)
	center.add_child(title_label)
	subtitle_label = _label("",13,MUTED)
	center.add_child(subtitle_label)
	var footer: PanelContainer = _panel(root,20,826,1580,883)
	var footer_row := HBoxContainer.new()
	footer_row.add_theme_constant_override("separation",10)
	footer.add_child(footer_row)
	for value: int in [0,1,3]:
		speed_buttons[value] = _button("Ⅱ" if value == 0 else "%d×" % value,_set_speed.bind(value),footer_row,true)
		speed_buttons[value].custom_minimum_size.x = 46
	hint_label = _label("",14,MUTED)
	hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer_row.add_child(hint_label)
	_button("Restore autosave",_load.bind(true),footer_row).custom_minimum_size.x = 155
	_button("Sound",func() -> void: sound.muted = not sound.muted; _toast("Sound off" if sound.muted else "Sound on"),footer_row)
	footer_row.get_child(footer_row.get_child_count()-1).custom_minimum_size.x = 70
	toast_label = _label("",16,GOLD)
	toast_label.position = Vector2(300,766)
	toast_label.size = Vector2(900,55)
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(toast_label)
	_refresh_left()
	_set_speed(1)

func _show_mode_menu() -> void:
	if is_instance_valid(mode_menu): return
	menu_speed = speed
	speed = 0
	mode_menu = Control.new()
	mode_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.add_child(mode_menu)
	var shade := ColorRect.new()
	shade.color = Color(0.025,0.045,0.075,0.95)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mode_menu.add_child(shade)
	var panel: PanelContainer = _panel(mode_menu,460,70,1140,825)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation",9)
	panel.add_child(content)
	_text(content,"F R O N T I E R   W O R L D S",30,WHITE)
	_text(content,"A settlement. A signal. A sky you haven't mapped.",19,MINT)
	_text(content,"URBAN TUTORIAL · FIRST CAMPAIGN SLICE",12,MINT)
	_text(content,"An existing city, a broken crossing, two repair agreements. Govern one district; keep the consequences as you explore.",16)
	_button("New urban tutorial",_start_mode.bind("urban",false),content)
	_button("Continue urban tutorial",_start_mode.bind("urban",true),content)
	_text(content,"EXPEDITION",12,MINT)
	_text(content,"Discover the galaxy through frontier fog. Grow colonies, trade surpluses and earn influence. All construction tools are available from the start.",17)
	_button("New expedition",_start_mode.bind("expedition",false),content)
	_button("Continue expedition",_start_mode.bind("expedition",true),content)
	_text(content,"SANDBOX",12,GOLD)
	_text(content,"The same simulation with optional god tools: free construction, reveal the map, instant travel, Marks and supply grants, diplomacy and climate recovery. Separate saves protect your expedition.",17)
	_button("New sandbox",_start_mode.bind("sandbox",false),content)
	_button("Continue sandbox",_start_mode.bind("sandbox",true),content)
	_button("Return to current game",_close_mode_menu,content)
	_text(content,"New games replace the current unsaved session. Manual saves remain until you save again. F5 saves, F9 loads; autosaves use a separate slot.",13)

func _close_mode_menu() -> void:
	if is_instance_valid(mode_menu):
		hud.remove_child(mode_menu)
		mode_menu.queue_free()
	mode_menu = null
	_set_speed(menu_speed)

func _start_mode(mode: String, restore: bool) -> void:
	var path: String = "user://%s_save.fw" % ("frontier" if mode == "expedition" else mode)
	if sim.playtest: path = path.replace("user://","user://review_")
	if restore and not FileAccess.file_exists(path):
		_toast("No manual %s save yet. Start a new game or return to restore an autosave." % mode)
		return
	planet_id = "s0p0"
	system_id = "s0"
	view = "colony"
	if restore:
		var result: Error = sim.load_game(path)
		if result != OK: _toast("Could not restore save: " + error_string(result)); return
	else: sim.new_game(2409,mode)
	clock_accumulator = 0.0
	_close_mode_menu()
	_set_speed(1)
	_switch_view("colony")
	if mode == "urban":
		_set_speed(0)
		_toast("Start with the city overview. Inspect South Loop when you are ready.")
		return
	_toast("Sandbox ready. God tools are available in the left panel." if mode == "sandbox" else "Expedition ready. Survey nearby signals to expand your star chart.")

func _clear_box(box: VBoxContainer) -> void:
	for child: Node in box.get_children():
		box.remove_child(child)
		child.queue_free()

func _refresh_left() -> void:
	_clear_box(left_box)
	tool_buttons.clear()
	overlay_buttons.clear()
	_text(left_box,"EXPEDITION CONTROL",12,MINT)
	if sim.state.get("mode","expedition") == "sandbox":
		_text(left_box,"SANDBOX · GOD TOOLS",12,GOLD)
		for pair: Array in [["credits","+1,000 Marks"],["resources","+500 colony resources"],["reveal","Reveal & survey galaxy"],["free_build","Free construction"],["instant_travel","Instant travel"],["friendship","Diplomatic goodwill"],["climate","Restore selected climate"]]:
			var enabled: bool = sim.state.cheats.get(pair[0],false)
			_button(pair[1]+(" · ON" if enabled else ""),_command.bind("cheat",{"ability":pair[0],"planet":planet_id}),left_box)
	if view == "colony":
		_text(left_box,"Shape your settlement",20,WHITE)
		for id: String in ["inspect","road","habitat","industry","service","power","life_support","police","fire","clinic","transit","extractor","terraformer","bulldoze"]:
			var name_text: String = id.capitalize()
			if sim.catalog.buildings.has(id): name_text = "%s  ·  %d" % [sim.catalog.buildings[id].name,sim.catalog.buildings[id].cost]
			if id in Simulation.City.ZONES: name_text = sim.catalog.buildings[id].name+" · drag / free"
			var button: Button = _button(name_text,_select_tool.bind(id),left_box,true)
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.button_pressed = tool == id
			if sim.catalog.buildings.has(id): button.tooltip_text = sim.catalog.buildings[id].description
			tool_buttons[id] = button
		_text(left_box,"DATA LAYERS",12,MINT)
		for id: String in ["natural","suitability","access","crime","fire","police","clinic","transit"]:
			overlay_buttons[id] = _button(id.capitalize(),_set_overlay.bind(id),left_box,true)
			overlay_buttons[id].button_pressed = overlay == id
	else:
		_text(left_box,"Your settlements",20,WHITE)
		for pid: String in sim.state.colonies:
			_button(sim.state.planets[pid].name,_open_colony.bind(pid),left_box)
		_text(left_box,"THE EXPEDITION",12,MINT)
		_text(left_box,"Scout a world. Build around its strengths. Turn a surplus into influence.",16,WHITE)
		_text(left_box,"Travel takes 6 days per link. Visit alien capitals to make contact. Colonies keep running while you explore.")
		_text(left_box,"KNOWN CONTACTS",12,MINT)
		for pair: Array in [["Veyr Directorate","s6"],["Orin Consortium","s7"],["Thalen Commune","s8"]]:
			if sim.system_by_id(pair[1]).visited: _button(pair[0],_select_system.bind(pair[1]),left_box)
		_text(left_box,"Build a climate array on a harsh world to begin terraforming. Preserve a climate to earn the Commune's trust.")
	_text(left_box,"CAMERA",12,MINT)
	_text(left_box,"WASD / arrows  ·  pan\nQ / E  ·  orbit\nMouse wheel  ·  zoom\nSpace  ·  pause\nG / P / C  ·  views\nF5 / F9  ·  save / load",13)

func _open_colony(pid: String) -> void:
	planet_id = pid
	system_id = sim.state.planets[pid].system
	_switch_view("colony")

func _select_system(sid: String) -> void:
	if not sim.is_revealed(sid): _toast("That region is beyond your current charts."); return
	system_id = sid
	planet_id = sim.system_by_id(sid).planets[0]
	_switch_view("galaxy")

func _select_planet(pid: String) -> void:
	planet_id = pid
	_switch_view("planet")

func _refresh_ui() -> void:
	tick_label.text = "%s  /  DAY %03d  /  %s" % ["SANDBOX" if sim.state.get("mode","expedition") == "sandbox" else "SOLACE EXPEDITION",sim.state.tick,["CAPTAIN","PATHFINDER","STEWARD"][int(sim.state.rank)]]
	stats_label.text = "◉  %d Marks     %d / 3 colonies" % [sim.state.credits,sim.state.colonies.size()]
	stats_label.tooltip_text = sim.catalog.currency.history + "\n\n" + sim.catalog.currency.scope
	if sim.state.has("urban"):
		tick_label.text = "SOUTH LOOP  /  DAY %03d  /  CIVIC AUTHORITY" % sim.state.tick
	for id: String in view_buttons: view_buttons[id].button_pressed = id == view
	for value: int in speed_buttons: speed_buttons[value].button_pressed = value == speed
	var planet: Dictionary = sim.state.planets[planet_id]
	var surveyed: bool = sim.system_by_id(planet.system).visited
	title_label.text = "The Solace Frontier" if view == "galaxy" else (planet.name if surveyed else "Uncharted world")
	var revealed: int = 0
	for system: Dictionary in sim.state.systems:
		if sim.is_revealed(system.id): revealed += 1
	subtitle_label.text = "%d KNOWN SIGNALS   /   THE FRONTIER IS WAITING" % revealed if view == "galaxy" else "%s   /   %s" % [str(planet.environment).to_upper()+" WORLD" if surveyed else "SURVEY REQUIRED","COLONY OPERATIONS" if view == "colony" else "ORBITAL SURVEY"]
	_refresh_right()
	_update_hint()

func _refresh_right() -> void:
	_clear_box(right_box)
	var planet: Dictionary = sim.state.planets[planet_id]
	if view == "colony":
		var colony: Dictionary = sim.state.colonies[planet_id]
		CityPanel.tabs(self)
		if city_section != "overview": CityPanel.draw(self,colony); return
		if sim.state.has("urban") and planet_id == "s0p0": _urban_panel()
		else:
			_text(right_box,"SETTLEMENT",12,MINT)
			_text(right_box,"%s residents" % _number(colony.population),24,WHITE)
			_text(right_box,"%d materials   ·   %d supplies" % [colony.materials,colony.supplies],16,WHITE)
			if colony.cells.size() == 1:
				_text(right_box,"The landing hub is ready. Your cargo is finite: start with a road beside the hub, then a habitat and a service zone.",17)
				_button("Open construction tools",_toggle_build,right_box)
		if selected_cell.x >= 0:
			var selected_key: String = Simulation.key(selected_cell.x,selected_cell.y)
			if colony.cells.has(selected_key):
				_text(right_box,"SELECTED · " + str(sim.catalog.buildings[colony.cells[selected_key].type].name),14,MINT)
				_text(right_box,colony.reasons.get(selected_key,"Connected" if colony.connected.has(selected_key) else "No road connection"),16,WHITE)
		_button("Hide economy & logistics" if details_open else "Economy & logistics",_toggle_details,right_box)
		if not details_open: return
		_text(right_box,"DISTRICT TELEMETRY" if sim.state.has("urban") and planet_id == "s0p0" else "COLONY TELEMETRY",12,MINT)
		_text(right_box,"Population · %s" % _number(colony.population),26,WHITE)
		_text(right_box,"%d jobs  ·  %+.2f Marks/day" % [colony.jobs,colony.income])
		_text(right_box,"Materials   %d   (%+.2f/day)\nSupplies     %d   (%+.2f/day)" % [colony.materials,colony.material_rate,colony.supplies,colony.supply_rate],16,WHITE)
		_text(right_box,"Power  %.0f / %.0f used" % [colony.power_used,colony.power],16,GOLD if colony.power_used > colony.power else MINT)
		_text(right_box,"GROWTH & DEMAND",12,MINT)
		var reasons: Dictionary = {}
		for reason: String in colony.reasons.values(): reasons[reason] = int(reasons.get(reason,0))+1
		for reason: String in reasons: _text(right_box,"%d  ·  %s" % [reasons[reason],reason],14)
		if selected_cell.x >= 0:
			var k: String = Simulation.key(selected_cell.x,selected_cell.y)
			_text(right_box,"TILE %d / %d" % [selected_cell.x,selected_cell.y],12,MINT)
			if colony.cells.has(k):
				var cell: Dictionary = colony.cells[k]
				_text(right_box,"%s · level %d" % [sim.catalog.buildings[cell.type].name,cell.level],16,WHITE)
				_text(right_box,colony.reasons.get(k,"Connected" if colony.connected.has(k) else "No road connection"))
			_text(right_box,"Residential suitability: %d%%" % int(sim.suitability(planet_id,selected_cell.x,selected_cell.y)*100))
		_text(right_box,"AUTOMATED LOGISTICS",12,MINT)
		_text(right_box,colony.get("trade_status","Exports retain 60 units locally."),14)
		for faction: Dictionary in sim.state.factions:
			if (str(faction.id)+":trade") in sim.state.agreements:
				for resource: String in ["materials","supplies"]:
					_button("%s → %s" % [resource.capitalize(),str(faction.name).split(" ")[0]],_command.bind("trade",{"planet":planet_id,"faction":faction.id,"resource":resource}),right_box)
		if not str(colony.trade_target).is_empty(): _button("Stop exports",_command.bind("trade",{"planet":planet_id,"faction":""}),right_box)
		for source: String in sim.state.colonies:
			if source != planet_id:
				_button("Import from " + sim.state.planets[source].name,_command.bind("import",{"planet":planet_id,"source":source}),right_box)
		if not str(colony.import_from).is_empty():
			_text(right_box,"Receiving reserves from " + sim.state.planets[colony.import_from].name)
			_button("Stop imports",_command.bind("import",{"planet":planet_id,"source":""}),right_box)
		if int(sim.state.rank) > 0:
			_text(right_box,"SPECIALIZATION · " + str(colony.get("policy","balanced")).to_upper(),12,MINT)
			for policy: String in ["balanced","industry","ecology"]:
				_button(policy.capitalize(),_command.bind("specialize",{"planet":planet_id,"policy":policy}),right_box)
		_button("Orbital survey & climate",_switch_view.bind("planet"),right_box)
	elif view == "galaxy":
		var system: Dictionary = sim.system_by_id(system_id)
		_text(right_box,"SELECTED SYSTEM",12,MINT)
		_text(right_box,system.name if system.visited else "Unknown signal",26,WHITE)
		_text(right_box,"Survey complete" if system.visited else "Unsurveyed · visit with flagship")
		var ship: Dictionary = sim.state.flagship
		if not str(ship.destination).is_empty():
			_text(right_box,"Flagship → %s\nArrival in %d days" % [sim.system_by_id(ship.destination).name,ship.remaining],16,GOLD)
			_button("Release camera" if follow_flagship else "Follow flagship",func() -> void: follow_flagship = not follow_flagship; _refresh_right(),right_box)
		else:
			_text(right_box,"Flagship at " + sim.system_by_id(ship.system).name)
			if system_id != ship.system: _button("Travel to " + (system.name if system.visited else "unknown signal"),_command.bind("travel",{"system":system_id}),right_box)
		for pid: String in system.planets:
			var p: Dictionary = sim.state.planets[pid]
			_button("%s · %s" % [p.name,p.environment] if system.visited else "Unsurveyed world",_select_planet.bind(pid),right_box)
		if sim.state.discoveries.has(system_id) and system.visited:
			var found: Dictionary = sim.state.discoveries[system_id]
			for item: Dictionary in sim.catalog.discoveries:
				if item.id != found.id: continue
				_text(right_box,item.title,19,GOLD)
				_text(right_box,item.text)
				if not found.resolved:
					for i: int in range(2): _button(item.choices[i],_command.bind("discover",{"system":system_id,"choice":i}),right_box)
				else: _text(right_box,"Discovery resolved",14,MINT)
		if not str(system.owner).is_empty() and system.visited: _faction_ui(sim.faction_by_id(system.owner))
	else:
		_text(right_box,"PLANETARY PROFILE",12,MINT)
		var surveyed: bool = sim.system_by_id(planet.system).visited
		_text(right_box,planet.name if surveyed else "Unknown world",26,WHITE)
		if not surveyed:
			_text(right_box,"Travel to this system to survey its climate, resources and settlement sites.")
			_button("Galaxy navigation",_switch_view.bind("galaxy"),right_box)
		else:
			_text(right_box,sim.catalog.environments[planet.environment].description,16,WHITE)
			_text(right_box,"Surface signatures\n◆ Mineral deposits\n● Geothermal vent\n● Subsurface water",15)
			_text(right_box,"Colony site: " + ("Your administration" if planet.owner == "player" else (str(planet.owner).capitalize() if not str(planet.owner).is_empty() else "Unclaimed")))
			_text(right_box,"A colony is a settlement, not a claim to govern an entire world.",13)
			if sim.state.colonies.has(planet_id):
				_button("Enter colony",_switch_view.bind("colony"),right_box)
				if planet.environment != "temperate":
					_text(right_box,"CLIMATE RECOVERY",12,MINT)
					_text(right_box,"%d%% complete" % int(float(planet.terraform)*100),23,WHITE)
					_text(right_box,"Warming" if planet.environment == "frozen" else "Water recovery",16,MINT)
					_text(right_box,"120 Marks to start. A powered array uses 0.5 materials + 0.2 supplies/day for 180 days. The Commune objects to replacing native climates (-18).")
					if planet.project: _text(right_box,planet.get("project_status","Project beginning"),14,GOLD)
					elif planet.terraform < 1: _button("Begin climate project",_command.bind("terraform",{"planet":planet_id}),right_box)
			elif sim.state.settlements.has(planet_id):
				var landing: Dictionary = sim.state.settlements[planet_id]
				_text(right_box,"LANDING EXPEDITION",12,GOLD)
				_text(right_box,Simulation.Settlement.phase(landing),20,WHITE)
				_text(right_box,"%d / 18 days · cargo already committed" % (18-int(landing.remaining)),16)
				if landing.get("blocked",false): _text(right_box,"Cargo route blocked. Restore diplomatic access to continue.",16,GOLD)
				_text(right_box,"Only a landing hub will be assembled. Homes, roads and workplaces are yours to build.")
			elif str(planet.owner).is_empty():
				_text(right_box,"FOUND A SETTLEMENT",12,MINT)
				_text(right_box,"300 Marks + 100 materials + 80 supplies\n18 days to assemble a landing hub",18,WHITE)
				for source: String in sim.state.colonies:
					var depot: Dictionary = sim.state.colonies[source]
					_text(right_box,"%s: %d materials / %d supplies" % [sim.state.planets[source].name,depot.materials,depot.supplies],14)
					_button("Dispatch from " + str(sim.state.planets[source].name),_command.bind("colonize",{"planet":planet_id,"source":source}),right_box)
	_button("Hide expedition log" if details_open else "Expedition log",_toggle_details,right_box)
	if not details_open: return
	_text(right_box,"EXPEDITION RECORD",12,MINT)
	_text(right_box,"%d milestones · next rank at %s" % [sim.state.milestones.size(),"3" if sim.state.rank == 0 else ("6" if sim.state.rank == 1 else "maximum")])
	for milestone: String in sim.state.milestones: _text(right_box,"✓ " + milestone,14,MINT)
	var logs: Array = sim.state.log
	for i: int in range(maxi(0,logs.size()-3),logs.size()): _text(right_box,"DAY %d · %s" % [logs[i].tick,logs[i].text],12)

func _faction_ui(faction: Dictionary) -> void:
	_text(right_box,"DIPLOMATIC CHANNEL",12,MINT)
	_text(right_box,faction.name,20,Color(faction.color))
	_text(right_box,"%s / %s" % [faction.government,faction.philosophy])
	if not faction.get("contacted",false):
		_text(right_box,"Visit this system to establish contact.")
		return
	_text(right_box,"Relations  %+d%s" % [faction.relation," · EMBARGO" if faction.get("embargo",false) else ""],18,WHITE)
	_text(right_box,faction.reason)
	_text(right_box,"Needs: " + faction.need + "\n" + faction.bonus)
	for pact: String in ["trade","non_aggression","alliance"]:
		if (str(faction.id)+":"+pact) in sim.state.agreements: _text(right_box,"✓ " + pact.replace("_"," ").capitalize(),14,MINT)
		else: _button("Propose " + pact.replace("_"," "),_command.bind("diplomacy",{"faction":faction.id,"pact":pact}),right_box)
	if faction.relation < 0: _button("Reconcile · 80 Marks",_command.bind("diplomacy",{"faction":faction.id,"pact":"reconcile"}),right_box)

func _update_hint() -> void:
	if not is_instance_valid(hint_label): return
	if view == "colony":
		var description: String = sim.catalog.buildings[tool].description if sim.catalog.buildings.has(tool) else "Click a tile to inspect." if tool == "inspect" else "Remove a tile for a 50% material refund."
		hint_label.text = "%s  |  %s\n1–4 tools · Right-click/Esc inspect · Costs in materials · Cyan: water / Amber: minerals / Red: geothermal" % [tool.to_upper().replace("_"," "),description]
		if sim.state.has("urban") and planet_id == "s0p0": hint_label.text = "%s · %s" % [tool.to_upper().replace("_"," "),description]
		hint_label.text += "\nRight-drag orbit · Middle-drag pan · Wheel zoom · R/F tilt · B build · Space pause"
	elif view == "galaxy": hint_label.text = "Click a signal to inspect · Travel to survey it and reveal neighboring routes\nMint: surveyed · Gold: unexplored frontier · The deep galaxy remains hidden until you explore."
	else: hint_label.text = "Right-drag or Q/E to orbit · Wheel zoom · R/F tilt\nSurface sites remain attached to the planet."

func _material(color: Color, glow: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.8
	if color.a < 1.0: material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if glow > 0:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = glow
	return material

func _box(parent: Node3D, pos: Vector3, dimensions: Vector3, color: Color, glow: float = 0.0) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	return _mesh(parent,mesh,pos,color,glow)

func _mesh(parent: Node3D, shape: Mesh, pos: Vector3, color: Color, glow: float = 0.0) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = shape
	node.material_override = _material(color,glow)
	node.position = pos
	parent.add_child(node)
	return node

func _sphere(parent: Node3D, pos: Vector3, radius: float, color: Color, glow: float = 0.0) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius*2
	mesh.radial_segments = 32
	mesh.rings = 16
	return _mesh(parent,mesh,pos,color,glow)

func _line(parent: Node3D, start: Vector3, end: Vector3, color: Color, thickness: float = 0.05) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = thickness
	mesh.bottom_radius = thickness
	mesh.height = start.distance_to(end)
	mesh.radial_segments = 6
	var node: MeshInstance3D = _mesh(parent,mesh,(start+end)/2,color,0.3)
	var direction: Vector3 = (end-start).normalized()
	var axis: Vector3 = Vector3.UP.cross(direction)
	if axis.length() > 0.001: node.quaternion = Quaternion(axis.normalized(),acos(clampf(Vector3.UP.dot(direction),-1,1)))

func _world_label(parent: Node3D, text: String, pos: Vector3, color: Color = WHITE, size: int = 22) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = pos
	label.font_size = size
	label.pixel_size = 0.025
	label.modulate = color
	label.outline_size = 6
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	parent.add_child(label)

func _rebuild_world() -> void:
	for child: Node in world.get_children():
		world.remove_child(child)
		child.queue_free()
	last_build_signature = ""
	building_nodes.clear()
	building_states.clear()
	broken_link_marker = null
	hover_mesh = null
	ship_mesh = null
	overview_globe = null
	colony_site_marker = null
	site_planet_id = ""
	if view == "colony": _draw_colony()
	elif view == "galaxy": _draw_galaxy()
	else: _draw_planet()
	_refresh_left()

func _planet_color(planet: Dictionary) -> Color:
	return Color(sim.catalog.environments[planet.environment].color).lerp(Color("72b49a"),float(planet.terraform)*0.65)

func _draw_colony() -> void:
	var planet: Dictionary = sim.state.planets[planet_id]
	last_access_signature = str(sim.state.colonies[planet_id].layer_signature)
	terrain_recovery_stage = int(float(planet.terraform)*10)
	var base: Color = _planet_color(planet)
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(planet.seed)
	for x: int in range(64):
		for z: int in range(64):
			var kind: String = sim.terrain(planet_id,x,z)
			var color: Color = base.darkened(rng.randf_range(0.0,0.13))
			if kind == "water": color = Color("284b66")
			elif kind == "cliff": color = base.darkened(0.35)
			elif overlay == "suitability": color = Color("b96b69").lerp(Color("6bdbad"),sim.suitability(planet_id,x,z))
			elif overlay != "natural": color = CityPanel.layer_color(self,x,z)
			var h: float = -0.16 if kind == "water" else (0.5 if kind == "cliff" else 0.0)
			for point: Vector2 in [Vector2(0,0),Vector2(0,1),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(1,0)]:
				surface.set_color(color)
				surface.set_normal(Vector3.UP)
				surface.add_vertex(Vector3(x-32+point.x,h,z-32+point.y))
	var mesh: ArrayMesh = surface.commit()
	var terrain_mesh := MeshInstance3D.new()
	terrain_mesh.mesh = mesh
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 1
	terrain_mesh.material_override = material
	world.add_child(terrain_mesh)
	if not (sim.state.has("urban") and planet_id == "s0p0"): _box(world,Vector3(0,-0.65,0),Vector3(64,1,64),base.darkened(0.6))
	# A fine construction grid keeps single-tile zoning legible.
	for i: int in range(12,53):
		if overlay == "natural" and tool == "inspect": continue
		_line(world,Vector3(i-32,0.025,-20),Vector3(i-32,0.025,20),base.darkened(0.45),0.012)
		_line(world,Vector3(-20,0.025,i-32),Vector3(20,0.025,i-32),base.darkened(0.45),0.012)
	for feature: Dictionary in sim.features(planet_id):
		if sim.state.has("urban") and planet_id == "s0p0": continue
		var pos := Vector3(feature.x-31.5,0.3,feature.z-31.5)
		var color: Color = GOLD if feature.type == "mineral" else (Color("78c7ed") if feature.type == "water" else Color("f4947e"))
		var crystal := CylinderMesh.new()
		crystal.top_radius = 0.08
		crystal.bottom_radius = 0.35
		crystal.height = 1.2
		crystal.radial_segments = 5
		_mesh(world,crystal,pos,color,0.4)
		_world_label(world,str(feature.type).to_upper(),pos+Vector3(0,1.25,0),color,16)
	for i: int in range(75):
		if sim.state.has("urban") and planet_id == "s0p0": continue
		var x: int = rng.randi_range(10,53)
		var z: int = rng.randi_range(5,58)
		if Vector2(x-32,z-32).length() < 12: continue
		if sim.terrain(planet_id,x,z) != "land": continue
		var rock := SphereMesh.new()
		rock.radius = rng.randf_range(0.2,0.6)
		rock.height = rock.radius*1.5
		rock.radial_segments = 5
		rock.rings = 3
		_mesh(world,rock,Vector3(x-31.5,0.12,z-31.5),base.darkened(0.2))
	if sim.state.has("urban") and planet_id == "s0p0" and overlay == "natural": UrbanView.draw_context(self)
	if overlay != "natural": _world_label(world,CityPanel.legend(overlay),Vector3(0,0.2,-12),WHITE,19)
	buildings = Node3D.new()
	world.add_child(buildings)
	_refresh_buildings()
	hover_mesh = _box(world,Vector3.ZERO,Vector3(0.98,0.04,0.98),Color(0.55,1,0.85,0.4),0.4)
	hover_mesh.visible = false

func _number(value: int) -> String:
	var digits: String = str(value)
	var result: String = ""
	for i: int in range(digits.length()):
		if i > 0 and (digits.length()-i)%3 == 0: result += ","
		result += digits[i]
	return result

func _urban_panel() -> void:
	var city: Dictionary = sim.state.urban
	_text(right_box,"LATCH · %s" % _number(Simulation.Urban.population(sim)),23,WHITE)
	if int(city.get("tutorial_step",0)) == 0:
		_text(right_box,"1 / LOOK AT THE CITY",12,GOLD)
		_text(right_box,"You administer South Loop, one district of a much larger city. A broken crossing has cut its eastern neighborhoods off from the hub.",18,WHITE)
		_text(right_box,"Start by looking at the problem. Time is paused. You do not need to build anything yet.",16)
		_button("Inspect South Loop",_inspect_crossing,right_box)
		return
	_text(right_box,"2 / CHOOSE A REPAIR" if str(city.path).is_empty() else ("3 / WATCH THE REPAIR" if not city.repaired else "4 / USE YOUR NEW AUTHORITY"),12,GOLD)
	var isolated: int = Simulation.Urban.isolated_population(sim)
	_text(right_box,"%s residents lack road access to the hub." % _number(isolated),16,GOLD if isolated > 0 else MINT)
	_button("Focus damaged crossing",_inspect_crossing,right_box)
	if str(city.path).is_empty():
		_text(right_box,"Public: 60 materials, 8 days. Unlock supply-for-material mutual aid; retain a 60-supply reserve.",14)
		_button("Sign public repair agreement",_command.bind("civic",{"choice":"public"}),right_box)
		_text(right_box,"Sponsor: 180 Marks, 2 days. Unlock instant zone upgrades; pay 1 Mark/day after reopening.",14)
		_button("Sign sponsored repair agreement",_command.bind("civic",{"choice":"sponsor"}),right_box)
	elif not city.repaired:
		_text(right_box,"%s repair · %d days remaining. Time controls are below." % [str(city.path).capitalize(),city.remaining],16,GOLD)
	else:
		_text(right_box,"%s · %s agreement" % ["District reconnected" if isolated == 0 else "Access needs attention",city.path],16,MINT if isolated == 0 else GOLD)
		_text(right_box,"Crews ready" if sim.state.tick >= city.ability_ready else "Crews return on day %d" % city.ability_ready,13)
		if city.path == "public":
			_button("Dispatch mutual-aid crews",_command.bind("civic",{"choice":"mutual_aid"}),right_box)
			_text(right_box,"30 supplies → 20 materials. Retains 60 supplies. Crews available every 12 days.",13)
		else:
			_button("Find a growth-ready zone",_inspect_growth_zone,right_box)
			_button("Priority works · selected zone",_command.bind("civic",{"choice":"priority","tile":Simulation.key(selected_cell.x,selected_cell.y)}),right_box)
			_text(right_box,"Inspect a Ready to grow zone. 30 Marks + 15 materials; 4-day crew cooldown. Sponsor paid: %.0f Marks." % city.fees_paid,13)
			if city.fee_due > 0: _text(right_box,"Arrears: %.0f Marks. Priority works suspended until treasury income clears them." % city.fee_due,14,GOLD)
		_text(right_box,"Access restores jobs and lets connected zones grow. Try your new power, then open Build to develop the district.",16)
		_button("Open construction tools",_toggle_build,right_box)
		_button("Explore the frontier",_switch_view.bind("galaxy"),right_box)

func _inspect_crossing() -> void:
	sim.command("civic",{"choice":"inspect"})
	selected_cell = Vector2i(32,32)
	focus = Vector3(0.5,0,0.5)
	zoom = 30
	_set_overlay("access")
	_refresh_right()

func _inspect_growth_zone() -> void:
	var colony: Dictionary = sim.state.colonies["s0p0"]
	for key: String in colony.reasons:
		if colony.reasons[key] != "Ready to grow": continue
		selected_cell = Simulation.cell_position(key)
		_select_tool("inspect")
		focus = Vector3(selected_cell.x-31.5,0,selected_cell.y-31.5)
		zoom = 24
		_refresh_right()
		_toast("Selected tile %s: ready for priority works." % key)
		return
	_toast("No eligible zones yet. Add a zone beside a road, or resolve its growth blocker.")

func _refresh_buildings() -> void:
	if not is_instance_valid(buildings) or view != "colony": return
	var colony: Dictionary = sim.state.colonies[planet_id]
	var signature: String = JSON.stringify(colony.cells)
	if sim.state.has("urban") and planet_id == "s0p0": signature += str(colony.connected.keys())
	if signature == last_build_signature: return
	last_build_signature = signature
	for key: String in building_nodes.keys():
		if colony.cells.has(key): continue
		buildings.remove_child(building_nodes[key])
		building_nodes[key].queue_free()
		building_nodes.erase(key)
		building_states.erase(key)
	for k: String in colony.cells:
		var cell: Dictionary = colony.cells[k]
		var descriptor: String = JSON.stringify(cell)
		if sim.state.has("urban") and planet_id == "s0p0" and cell.type in ["habitat","service"]: descriptor += str(colony.connected.has(k))
		if building_states.get(k,"") == descriptor: continue
		if building_nodes.has(k):
			buildings.remove_child(building_nodes[k])
			building_nodes[k].queue_free()
		var cell_root := Node3D.new()
		buildings.add_child(cell_root)
		building_nodes[k] = cell_root
		building_states[k] = descriptor
		var p: Vector2i = Simulation.cell_position(k)
		var pos := Vector3(p.x-31.5,0.0,p.y-31.5)
		cell_root.position = pos+Vector3((float(cell.get("width",1))-1)*0.5,0,(float(cell.get("depth",1))-1)*0.5)
		cell_root.scale = Vector3(cell.get("width",1),1,cell.get("depth",1))
		pos = Vector3.ZERO
		var color := Color(COLORS.get(cell.type,"82bdd0"))
		if overlay != "natural":
			_box(cell_root,Vector3(0,0.15,0),Vector3(0.94,0.22,0.94),CityPanel.layer_color(self,p.x,p.y),0.3)
			continue
		if cell.type == "road":
			_box(cell_root,pos+Vector3(0,0.04,0),Vector3(0.99,0.06,0.99),color)
			_box(cell_root,pos+Vector3(0,0.08,0),Vector3(0.12,0.012,0.35),Color("a0b4bd"),0.2)
			continue
		_box(cell_root,pos+Vector3(0,0.045,0),Vector3(0.89,0.07,0.89),color.darkened(0.38))
		if int(cell.level) == 0:
			_box(cell_root,pos+Vector3(0,0.09,0),Vector3(0.64,0.02,0.64),Color(color,0.45))
			continue
		if Architecture.draw(self,cell_root,cell,k): continue
		var height: float = 0.65 + int(cell.level)*0.32
		if cell.type == "spaceport":
			_box(cell_root,pos+Vector3(0,0.25,0),Vector3(0.88,0.5,0.88),color)
			_box(cell_root,pos+Vector3(0.2,0.9,0.2),Vector3(0.24,1.3,0.24),color)
			_sphere(cell_root,pos+Vector3(0.2,1.6,0.2),0.15,MINT,0.9)
		elif cell.type in ["power","life_support","terraformer"]:
			var cylinder := CylinderMesh.new()
			cylinder.top_radius = 0.27
			cylinder.bottom_radius = 0.37
			cylinder.height = height
			cylinder.radial_segments = 12
			_mesh(cell_root,cylinder,pos+Vector3(0,height/2,0),color)
			_sphere(cell_root,pos+Vector3(0,height,0),0.25,color.lightened(0.3),0.4)
		else:
			_box(cell_root,pos+Vector3(0,height/2,0),Vector3(0.67,height,0.73),color)
			_box(cell_root,pos+Vector3(0,height+0.035,0),Vector3(0.71,0.07,0.77),color.lightened(0.3))
			for y: int in range(int(cell.level)+1):
				_box(cell_root,pos+Vector3(0,0.25+y*0.3,0.372),Vector3(0.48,0.095,0.015),Color("d6fff0"),0.6)
			if cell.type == "industry": _box(cell_root,pos+Vector3(0.2,height+0.3,-0.15),Vector3(0.17,0.6,0.17),color.darkened(0.3))
	if is_instance_valid(broken_link_marker) and colony.cells.has("32,32"):
		buildings.remove_child(broken_link_marker)
		broken_link_marker.queue_free()
		broken_link_marker = null
	if sim.state.has("urban") and planet_id == "s0p0" and not colony.cells.has("32,32") and not is_instance_valid(broken_link_marker):
		broken_link_marker = Node3D.new()
		buildings.add_child(broken_link_marker)
		_box(broken_link_marker,Vector3(0.5,0.2,0.5),Vector3(0.9,0.3,0.9),Color("d98b83"))
		_world_label(broken_link_marker,"BROKEN LINK",Vector3(0.5,1.1,0.5),GOLD,18)

func _draw_galaxy() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 19
	for i: int in range(240):
		_sphere(world,Vector3(rng.randf_range(-70,70),rng.randf_range(-8,-4),rng.randf_range(-55,65)),rng.randf_range(0.025,0.075),Color("758eac"),0.6)
	for system: Dictionary in sim.state.systems:
		if not sim.is_revealed(system.id): continue
		var pos := Vector3(system.x,0,system.z)
		for target: String in system.links:
			if str(system.id) > target: continue
			var other: Dictionary = sim.system_by_id(target)
			if not sim.is_revealed(target) or (not system.visited and not other.visited): continue
			_line(world,pos,Vector3(other.x,0,other.z),Color("304c64"),0.07)
		var color: Color = MINT if system.visited else GOLD
		if not str(system.owner).is_empty() and system.visited: color = Color(sim.faction_by_id(system.owner).color)
		_sphere(world,pos,0.5,color,0.9)
		_world_label(world,system.name if system.visited else "UNKNOWN",pos+Vector3(0,1.8,0),WHITE if system.visited else MUTED,36)
		var ring := TorusMesh.new()
		ring.inner_radius = 0.95
		ring.outer_radius = 1.02
		_mesh(world,ring,pos,color.darkened(0.3),0.3)
		if not str(system.owner).is_empty() and system.visited:
			var zone := CylinderMesh.new()
			zone.top_radius = 3.4
			zone.bottom_radius = 3.4
			zone.height = 0.02
			_mesh(world,zone,pos-Vector3(0,0.15,0),Color(color,0.1))
	ship_mesh = Node3D.new()
	world.add_child(ship_mesh)
	var route: Array = sim.state.flagship.route
	for i: int in range(1,route.size()):
		var a: Dictionary = sim.system_by_id(route[i-1])
		var b: Dictionary = sim.system_by_id(route[i])
		_line(world,Vector3(a.x,0.15,a.z),Vector3(b.x,0.15,b.z),MINT,0.10)
	var ship := PrismMesh.new()
	ship.size = Vector3(0.7,0.3,1.5)
	_mesh(ship_mesh,ship,Vector3.ZERO,WHITE,0.2)
	_box(ship_mesh,Vector3(0,0,0.2),Vector3(1.8,0.12,0.55),Color("829aab"))
	for x: float in [-0.6,0.6]:
		_box(ship_mesh,Vector3(x,0.02,0.45),Vector3(0.25,0.22,0.85),WHITE)
		_sphere(ship_mesh,Vector3(x,0.02,0.95),0.14,MINT,1.2)
	_position_ship()

func _position_ship() -> void:
	var ship: Dictionary = sim.state.flagship
	var system: Dictionary = sim.system_by_id(ship.system)
	var pos := Vector3(system.x,0,system.z)
	if not str(ship.destination).is_empty() and ship.route.size() > 1:
		var progress: float = (float(ship.duration)-float(ship.remaining)+clock_accumulator)/6.0
		var segment: int = mini(int(progress),ship.route.size()-2)
		var a: Dictionary = sim.system_by_id(ship.route[segment])
		var b: Dictionary = sim.system_by_id(ship.route[segment+1])
		pos = Vector3(a.x,0,a.z).lerp(Vector3(b.x,0,b.z),clampf(progress-segment,0,1))
		ship_mesh.rotation.y = atan2(float(a.x)-float(b.x),float(a.z)-float(b.z))
	ship_mesh.position = pos+Vector3(0,1.0,0.8)

func _draw_planet() -> void:
	var planet: Dictionary = sim.state.planets[planet_id]
	if not sim.system_by_id(planet.system).visited:
		_sphere(world,Vector3.ZERO,6,Color("1b3044"))
		_world_label(world,"SURVEY REQUIRED",Vector3(0,0,7),MUTED,28)
		return
	var color: Color = _planet_color(planet)
	overview_globe = _sphere(world,Vector3.ZERO,6.0,color)
	var material := ShaderMaterial.new()
	material.shader = preload("res://assets/planet.gdshader")
	material.set_shader_parameter("climate",["temperate","frozen","arid"].find(planet.environment))
	material.set_shader_parameter("world_seed",float(planet.seed % 100))
	material.set_shader_parameter("recovery",float(planet.terraform))
	overview_globe.material_override = material
	var ring := TorusMesh.new()
	ring.inner_radius = 7.3
	ring.outer_radius = 7.34
	var ring_node: MeshInstance3D = _mesh(world,ring,Vector3.ZERO,MINT,0.3)
	ring_node.rotation_degrees.z = 18
	if sim.state.colonies.has(planet_id) or sim.state.settlements.has(planet_id):
		site_planet_id = planet_id
		var site: Vector3 = Vector3(1.5,1.5,5.8).normalized()*6.04
		colony_site_marker = _sphere(overview_globe,site,0.075,GOLD,0.5)
		var label := Label3D.new()
		label.text = "LANDING SITE" if sim.state.settlements.has(planet_id) else "COLONY SITE"
		label.position = site.normalized()*6.22
		label.font_size = 22
		label.pixel_size = 0.012
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = false
		overview_globe.add_child(label)
	_world_label(world,"%s  /  ORBITAL TELEMETRY" % str(planet.environment).to_upper(),Vector3(0,-8,0),MUTED,18)

func _capture_next() -> void:
	var names: Array = ["01-colony","02-galaxy","03-frozen-colony","04-planet","05-mode-menu","06-sandbox","07-urban","08-urban-repaired","09-city-ledger","10-fire-layer","11-city-architecture"]
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("res://artifacts/%s.png" % names[capture_stage])
	capture_stage += 1
	if capture_stage == 1: _switch_view("galaxy")
	elif capture_stage == 2:
		sim.state.flagship.system = "s1"
		sim.system_by_id("s1").visited = true
		sim.command("colonize",{"planet":"s1p0"})
		for i: int in range(18): sim.tick()
		_open_colony("s1p0")
	elif capture_stage == 3: _switch_view("planet")
	elif capture_stage == 4: _show_mode_menu()
	elif capture_stage == 5:
		_start_mode("sandbox",false)
		_set_speed(0)
	elif capture_stage == 6:
		_start_mode("urban",false)
		_set_speed(0)
	elif capture_stage == 7:
		sim.command("civic",{"choice":"public"})
		for i: int in range(8): sim.tick()
	elif capture_stage == 8:
		city_section = "ledger"
		zoom = 33
		_refresh_right()
	elif capture_stage == 9:
		city_section = "services"
		_set_overlay("fire")
		_refresh_right()
	elif capture_stage == 10:
		_set_overlay("natural")
		zoom = 24
		city_section = "services"
		_refresh_right()
	else: get_tree().quit()
