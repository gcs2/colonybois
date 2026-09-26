extends RefCounted
## Shared flight instrument styling; original SVGs remain editable vector sources.
const INK := Color("0d1923")
const PAPER := Color("e9efe5")
const MUTED := Color("8fa9b2")
const GOLD := Color("f3c567")
const CARGO := Color("eba66d")
const NAV := Color("8cc9d0")
const COMMS := Color("dca0cf")
const Equipment = preload("res://scripts/equipment_catalog.gd")

static func icon(id: String) -> Texture2D:
	var path: String = str(Equipment.value(id,"icon")) if Equipment.has_tool(id) else "res://assets/ui/flight/"+id+".svg"
	return load(path) as Texture2D

static func box(tint: Color, selected: bool = false) -> StyleBoxFlat:
	var result := StyleBoxFlat.new()
	result.bg_color = INK.lerp(tint,0.21 if selected else 0.05)
	result.bg_color.a = 0.88 if selected else 0.18
	result.set_corner_radius_all(1)
	result.set_border_width_all(0)
	result.border_color = tint if selected else tint.darkened(0.65)
	result.border_width_bottom = 2 if selected else 0
	result.content_margin_left = 9
	result.content_margin_right = 9
	result.content_margin_top = 5
	result.content_margin_bottom = 5
	return result

static func instrument(button: Button, id: String, tint: Color, selected: bool = false) -> void:
	button.add_theme_stylebox_override("normal",box(tint,selected))
	button.add_theme_stylebox_override("hover",box(tint,true))
	button.add_theme_stylebox_override("pressed",box(tint.darkened(0.15),true))
	button.add_theme_stylebox_override("disabled",box(tint.darkened(0.6),false))
	button.add_theme_color_override("font_disabled_color",Color("56707a"))
	button.add_theme_color_override("icon_disabled_color",Color("56707a"))
	button.add_theme_color_override("font_color",PAPER if selected else tint.lightened(0.2))
	var authored: bool = Equipment.has_tool(id)
	button.add_theme_color_override("icon_normal_color",Color.WHITE if authored else tint)
	button.add_theme_color_override("icon_hover_color",Color.WHITE if authored else tint.lightened(0.2))
	button.add_theme_constant_override("h_separation",10)
	button.add_theme_constant_override("icon_max_width",26)
	button.expand_icon = true
	if not id.is_empty(): button.icon = icon(id)

static func focus_cue(button: Button) -> void:
	# A restrained warm edge keeps keyboard focus legible without changing the instrument palette.
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color("e9efe5", 0.12)
	focus.border_color = Color("f3c567")
	focus.set_border_width_all(2)
	focus.set_corner_radius_all(1)
	focus.content_margin_left = 9
	focus.content_margin_right = 9
	focus.content_margin_top = 5
	focus.content_margin_bottom = 5
	button.add_theme_stylebox_override("focus", focus)

static func meter(bar: ProgressBar, tint: Color) -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color("100e19")
	bg.set_corner_radius_all(0)
	var fill := StyleBoxFlat.new()
	fill.bg_color = tint
	fill.set_corner_radius_all(0)
	bar.add_theme_stylebox_override("background",bg)
	bar.add_theme_stylebox_override("fill",fill)

static func symbol(button: Button, id: String, tint: Color, selected: bool = false) -> void:
	instrument(button,id,tint,selected)
	# Rejected ornamental wells are removed. Neutral hit areas pending art review.
	for state: String in ["normal","hover","pressed","disabled"]:
		var area := StyleBoxFlat.new()
		area.bg_color = Color(0.7,0.8,0.85,0.10) if state == "hover" else Color(0,0,0,0)
		area.border_width_bottom = 2 if selected else 0
		area.border_color = Color("d5dfdf")
		area.content_margin_left = 9
		area.content_margin_right = 9
		area.content_margin_top = 7
		area.content_margin_bottom = 7
		button.add_theme_stylebox_override(state,area)
	button.add_theme_color_override("icon_normal_color",Color.WHITE)
	button.add_theme_color_override("icon_hover_color",Color.WHITE)
	button.add_theme_constant_override("icon_max_width",38)
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER

static func tooltip(copy: String) -> String:
	# Native tooltip labels do not wrap; keep explanations within a readable column.
	var lines: PackedStringArray = []
	for paragraph: String in copy.split("\n"):
		var line: String = ""
		for word: String in paragraph.split(" "):
			if line.length()+word.length()+1 > 64 and not line.is_empty():
				lines.append(line)
				line = ""
			line += (" " if not line.is_empty() else "")+word
		lines.append(line)
	return "\n".join(lines)
