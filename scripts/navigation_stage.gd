extends RefCounted
## Full-screen navigation canvas with lightweight overlaid instruments.
## The world/map fills the viewport; layout never reserves a second window for it.
static func create(host: PanelContainer) -> Control:
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.z_index = 10
	host.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
	var stage := Control.new()
	stage.name = "NavigationStage"
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(stage)
	var background := ColorRect.new()
	background.color = Color("050a15")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return stage

static func header(stage: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	stage.add_child(row)
	row.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	row.offset_left = 32; row.offset_right = -32; row.offset_top = 24; row.offset_bottom = 76
	row.add_theme_constant_override("separation",18)
	return row

static func sidebar(stage: Control, width: float = 360) -> VBoxContainer:
	var panel := PanelContainer.new()
	stage.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	panel.offset_left = -width-32; panel.offset_right = -32; panel.offset_top = 118; panel.offset_bottom = 118
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025,0.045,0.065,0.9)
	style.set_content_margin_all(20)
	panel.add_theme_stylebox_override("panel",style)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",12)
	panel.add_child(column)
	return column

static func footer(stage: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	stage.add_child(row)
	row.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	row.offset_left = 32; row.offset_right = -32; row.offset_top = -74; row.offset_bottom = -24
	row.add_theme_constant_override("separation",18)
	return row

static func world(stage: Control, surface: Control) -> void:
	stage.add_child(surface)
	surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stage.move_child(surface,1)
