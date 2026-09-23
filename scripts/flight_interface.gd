extends RefCounted
## Shared flight instrument styling; original SVGs remain editable vector sources.
const INK := Color("201c2c")
const PAPER := Color("fff0d8")
const MUTED := Color("b9b0c7")
const GOLD := Color("f3c567")
const CARGO := Color("eba66d")
const NAV := Color("a9a7ef")
const COMMS := Color("dca0cf")
const Equipment = preload("res://scripts/equipment_catalog.gd")

static func icon(id: String) -> Texture2D:
	var path: String = str(Equipment.value(id,"icon")) if Equipment.has_tool(id) else "res://assets/ui/flight/"+id+".svg"
	return load(path) as Texture2D

static func box(tint: Color, selected: bool = false) -> StyleBoxFlat:
	var result := StyleBoxFlat.new()
	result.bg_color = INK.lerp(tint,0.21 if selected else 0.05)
	result.bg_color.a = 0.97
	result.set_corner_radius_all(12)
	result.set_border_width_all(1)
	result.border_color = tint if selected else tint.darkened(0.65)
	result.border_width_bottom = 3 if selected else 1
	result.content_margin_left = 14
	result.content_margin_right = 14
	result.content_margin_top = 10
	result.content_margin_bottom = 10
	return result

static func instrument(button: Button, id: String, tint: Color, selected: bool = false) -> void:
	button.add_theme_stylebox_override("normal",box(tint,selected))
	button.add_theme_stylebox_override("hover",box(tint,true))
	button.add_theme_stylebox_override("pressed",box(tint.darkened(0.15),true))
	button.add_theme_color_override("font_color",PAPER if selected else tint.lightened(0.2))
	var authored: bool = Equipment.has_tool(id)
	button.add_theme_color_override("icon_normal_color",Color.WHITE if authored else tint)
	button.add_theme_color_override("icon_hover_color",Color.WHITE if authored else tint.lightened(0.2))
	button.add_theme_constant_override("h_separation",10)
	button.add_theme_constant_override("icon_max_width",26)
	button.expand_icon = true
	if not id.is_empty(): button.icon = icon(id)

static func meter(bar: ProgressBar, tint: Color) -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color("100e19")
	bg.set_corner_radius_all(4)
	var fill := StyleBoxFlat.new()
	fill.bg_color = tint
	fill.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("background",bg)
	bar.add_theme_stylebox_override("fill",fill)
