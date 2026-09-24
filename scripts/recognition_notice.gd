extends PanelContainer
## Bounded, non-blocking celebration. Authoritative queue belongs to the saved campaign.
signal opened
const UI = preload("res://scripts/flight_interface.gd")
const Recognition = preload("res://scripts/expedition_progression.gd")
var remaining: float = 0
var headline: Label
var detail: Label
var emblem: TextureRect
var stars: Label
func _ready() -> void:
	position = Vector2(590,148); custom_minimum_size = Vector2(420,116); mouse_filter = Control.MOUSE_FILTER_STOP
	var style := StyleBoxFlat.new(); style.bg_color = Color("101c28"); style.border_width_left = 3; style.border_color = UI.GOLD; style.set_content_margin_all(14); add_theme_stylebox_override("panel",style)
	var row := HBoxContainer.new(); row.add_theme_constant_override("separation",16); add_child(row)
	emblem = TextureRect.new(); emblem.custom_minimum_size = Vector2(58,58); emblem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; emblem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; row.add_child(emblem)
	var column := VBoxContainer.new(); column.size_flags_horizontal = Control.SIZE_EXPAND_FILL; row.add_child(column)
	headline = Label.new(); headline.add_theme_font_size_override("font_size",22); column.add_child(headline)
	stars = Label.new(); stars.add_theme_color_override("font_color",UI.GOLD); column.add_child(stars)
	detail = Label.new(); detail.text = "Click to view badges and unlocks"; detail.add_theme_font_size_override("font_size",13); column.add_child(detail)
	tooltip_text = "Achievement earned · open badge case"; gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT: opened.emit())
	for node: Control in [row,column,emblem,headline,stars,detail]: node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()
func present(item: Dictionary, game: RefCounted) -> void:
	var rank: bool = item.kind == "rank"
	headline.text = str(Recognition.catalog.rank_names[item.tier-1]) if rank else "%s %d" % [game.commerce.catalog.badges[item.id].name,item.tier]
	stars.text = "PROMOTED" if rank else "★".repeat(item.tier)
	emblem.texture = UI.icon("system_view" if rank else game.commerce.catalog.badges[item.id].icon)
	remaining = 4.0; modulate.a = 0; position.y = 136; show()
func advance(delta: float, suspended: bool) -> void:
	if not visible or suspended: return
	remaining = maxf(0,remaining-delta)
	var enter: float = clampf((4.0-remaining)/0.3,0,1)
	position.y = 136+12*(1-pow(1-enter,3)); modulate.a = minf(enter,remaining/0.5)
	emblem.rotation = sin(enter*PI)*0.12; emblem.pivot_offset = emblem.size*0.5
	if remaining <= 0: hide()
