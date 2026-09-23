extends PanelContainer
## Inspection only: emits commands; the encounter owns time, state and travel.
signal close_requested
signal travel_requested(site_id: String)
signal survey_requested
signal ui_cue(cue: String)
const Globe = preload("res://scripts/planet_globe.gd")
const Geography = preload("res://scripts/planet_geography.gd")
const UI = preload("res://scripts/flight_interface.gd")
var globe: Node3D
var camera: Camera3D
var viewport: SubViewport
var preview: SubViewportContainer
var survey_button: Button
var travel_button: Button
var progress_label: Label
var progress_bar: ProgressBar
var report: Label
var site_button: Button
var site_caption: Label
var ship_marker: MeshInstance3D
var ship_caption: Label
var layer_buttons: Array[Button] = []
var chart_progress: float = 0
var chart_layer: bool = false
var dragging: bool = false
var drag_distance: float = 0
var zoom: float = 10.8
var snapshot: Dictionary = {}

func text_label(text: String, size: int = 16, color: Color = UI.PAPER) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size",size)
	label.add_theme_color_override("font_color",color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func button(text: String, action: Callable, parent: Control, tint: Color = UI.NAV) -> Button:
	var item := Button.new()
	item.text = text
	item.custom_minimum_size.y = 44
	UI.instrument(item,"",tint)
	item.pressed.connect(func() -> void: ui_cue.emit("ui_confirm"); action.call())
	item.mouse_entered.connect(func() -> void: ui_cue.emit("ui_hover"))
	parent.add_child(item)
	return item

func _ready() -> void:
	position = Vector2(24,100)
	size = Vector2(1552,592)
	add_theme_stylebox_override("panel",UI.box(UI.NAV))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",10)
	add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	var title: Label = text_label("MORROW  /  PLANETARY ATLAS",24)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	header.add_child(text_label("INSPECTION PAUSED",12,UI.GOLD))
	button("Close  [M / Esc]",func() -> void: close_requested.emit(),header)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation",24)
	column.add_child(body)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(left)
	preview = SubViewportContainer.new()
	preview.custom_minimum_size = Vector2(870,450)
	preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview.stretch = true
	preview.mouse_filter = Control.MOUSE_FILTER_STOP
	preview.gui_input.connect(_map_input)
	left.add_child(preview)
	viewport = SubViewport.new()
	viewport.size = Vector2i(960,460)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	preview.add_child(viewport)
	var world := Node3D.new()
	viewport.add_child(world)
	globe = Globe.new()
	globe.radius = 3
	world.add_child(globe)
	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("100e19")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("afa4c9")
	env.ambient_light_energy = 0.55
	env_node.environment = env
	world.add_child(env_node)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-25,-35,0)
	light.light_energy = 1.3
	world.add_child(light)
	camera = Camera3D.new()
	camera.position = Vector3(0,0,zoom)
	camera.fov = 42
	world.add_child(camera)
	camera.look_at(Vector3.ZERO)
	ship_marker = MeshInstance3D.new()
	var arrow := PrismMesh.new()
	arrow.size = Vector3(0.13,0.20,0.07)
	ship_marker.mesh = arrow
	var ink := StandardMaterial3D.new()
	ink.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ink.albedo_color = UI.GOLD
	ship_marker.material_override = ink
	globe.add_child(ship_marker)
	site_caption = text_label("●  MORROW BASIN",13,Color("a4f0bc"))
	preview.add_child(site_caption)
	ship_caption = text_label("▲  SHIP",12,UI.GOLD)
	preview.add_child(ship_caption)
	left.add_child(text_label("Drag globe to rotate  ·  Wheel to zoom  ·  Select the green landing beacon",13,UI.MUTED))
	var sidebar := VBoxContainer.new()
	sidebar.custom_minimum_size.x = 490
	sidebar.add_theme_constant_override("separation",12)
	body.add_child(sidebar)
	var layers := HBoxContainer.new()
	layers.add_theme_constant_override("separation",8)
	sidebar.add_child(layers)
	layer_buttons.append(button("Geography",set_layer.bind(false),layers))
	layer_buttons.append(button("Survey coverage",set_layer.bind(true),layers))
	progress_label = text_label("")
	sidebar.add_child(progress_label)
	progress_bar = ProgressBar.new()
	progress_bar.show_percentage = false
	progress_bar.custom_minimum_size.y = 8
	UI.meter(progress_bar,UI.NAV)
	sidebar.add_child(progress_bar)
	survey_button = button("Chart from orbit · 20 energy",func() -> void: survey_requested.emit(),sidebar,UI.GOLD)
	sidebar.add_child(text_label("KNOWN LANDING SITES",12,UI.MUTED))
	site_button = button("Morrow Basin   /   15.95° N · 0.00° E",focus_site,sidebar,Color("86cf9a"))
	report = text_label("",15,UI.MUTED)
	report.custom_minimum_size.x = 480
	report.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar.add_child(report)
	travel_button = button("",func() -> void: travel_requested.emit("morrow_basin"),sidebar,Color("86cf9a"))
	var legend: Label = text_label("Dark grid: uncharted\nViolet: orbital geography · green: local site chart\nOrbital imaging does not identify ground resources.",13,UI.MUTED)
	legend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	legend.custom_minimum_size.x = 480
	sidebar.add_child(legend)
	visibility_changed.connect(func() -> void:
		dragging = false
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if visible else SubViewport.UPDATE_DISABLED
	)
	set_layer(false)
	hide()

func present(state: Dictionary, ship_direction: Vector3, player_paused: bool, reason: String) -> void:
	snapshot = state.duplicate(true)
	chart_progress = float(state.survey_ticks)/float(Geography.definition().survey_seconds)
	globe.chart(chart_progress,chart_layer)
	progress_bar.value = chart_progress*100
	progress_label.text = "ORBITAL CHART  /  %d%%" % int(chart_progress*100)
	if state.survey_active: progress_label.text += "  ·  paused for inspection"
	survey_button.disabled = not reason.is_empty() or player_paused
	survey_button.tooltip_text = "Resume the game first." if player_paused else (reason if not reason.is_empty() else "20 energy · 12 seconds in orbit. Closes the atlas so the survey can run.")
	survey_button.text = "Orbital chart complete" if chart_progress >= 1 else ("Survey commissioned" if state.survey_active else "Chart from orbit · 20 energy")
	travel_button.text = "Approach & land at Morrow Basin" if state.flight_mode == "orbit" else "Fly to basin landing beacon"
	travel_button.disabled = player_paused
	travel_button.tooltip_text = "Resume flight first." if player_paused else "Closes the atlas and begins travel; no instant teleport."
	report.text = "MORROW BASIN  /  VISITED\n%d of 4 local subjects catalogued.\n\nOne accessible surface site. Other regions have no cleared landing sites yet." % state.scanned.size()
	ship_marker.position = ship_direction.normalized()*3.23
	focus_site()
	show()

func set_layer(survey: bool) -> void:
	chart_layer = survey
	if globe != null: globe.chart(chart_progress,survey)
	for i: int in range(layer_buttons.size()): UI.instrument(layer_buttons[i],"",UI.NAV,(i == 1) == survey)

func focus_site() -> void:
	globe.rotation = Vector3(deg_to_rad(Geography.definition().sites[0].latitude),0,0)
	ui_cue.emit("target_lock")

func _map_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			if event.pressed: drag_distance = 0
			elif drag_distance < 5: pick_site(event.position)
		if event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
			zoom = clampf(zoom+(-0.6 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 0.6),8.8,17)
			camera.position.z = zoom
		accept_event()
	elif event is InputEventMouseMotion and dragging:
		drag_distance += event.relative.length()
		globe.rotation.y += event.relative.x*0.008
		globe.rotation.x = clampf(globe.rotation.x+event.relative.y*0.006,-1.4,1.4)
		accept_event()

func marker_visible(marker: Node3D) -> bool:
	var normal: Vector3 = marker.global_position.normalized()
	return normal.dot((camera.global_position-marker.global_position).normalized()) > 0.02

func pick_site(at: Vector2) -> bool:
	if not marker_visible(globe.site_marker): return false
	var projected: Vector2 = camera.unproject_position(globe.site_marker.global_position)
	if projected.distance_to(at) > 30: return false
	focus_site()
	return true

func _process(_delta: float) -> void:
	if not visible or camera == null: return
	site_caption.visible = marker_visible(globe.site_marker)
	site_caption.position = camera.unproject_position(globe.site_marker.global_position)+Vector2(12,8)
	ship_caption.visible = marker_visible(ship_marker)
	ship_caption.position = camera.unproject_position(ship_marker.global_position)+Vector2(12,-24)
