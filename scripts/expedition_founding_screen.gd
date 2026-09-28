extends CanvasLayer
## First-run identity choice for the connected scout-flight campaign.
signal begin_requested(captain_name: String, philosophy: String)
signal cancel_requested

const Instruments = preload("res://scripts/flight_interface.gd")
const PAPER := Color("e9e3d6")
const INK := Color("16232b")
const MUTED := Color("53636a")
const GOLD := Color("b88c36")
const MINT := Color("357c72")
const CORAL := Color("a84d3e")
const CHOICES := {
	"scientist": {
		"title":"SCIENTIST",
		"icon":"scan",
		"tint":MINT,
		"summary":"Follow evidence. Chart what others have not seen.",
		"commitment":"Survey Morrow from orbit and record its living geography."
	},
	"zealot": {
		"title":"ZEALOT",
		"icon":"category_life",
		"tint":GOLD,
		"summary":"Protect living worlds. Carry life beyond its home.",
		"commitment":"Establish a scanned native species on a different world."
	},
	"knight": {
		"title":"KNIGHT",
		"icon":"category_weapons",
		"tint":CORAL,
		"summary":"Stand between frontier crews and danger.",
		"commitment":"Neutralize Morrow's hostile custodian."
	}
}

var selected: String = "scientist"
var name_entry: LineEdit
var detail: Label
var error_label: Label
var choice_buttons: Dictionary = {}

func _ready() -> void:
	layer = 30
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root)
	var shade := ColorRect.new()
	shade.color = Color(0.035,0.045,0.052,0.38)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(shade)
	var frame := PanelContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	frame.offset_left = -500
	frame.offset_top = -315
	frame.offset_right = 500
	frame.offset_bottom = 315
	frame.add_theme_stylebox_override("panel",_style(PAPER,INK,2,18))
	root.add_child(frame)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",24)
	margin.add_theme_constant_override("margin_right",24)
	margin.add_theme_constant_override("margin_top",19)
	margin.add_theme_constant_override("margin_bottom",18)
	frame.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation",12)
	margin.add_child(content)
	var eyebrow := _label("FRONTIER WORLDS     /     NEW EXPEDITION",13,MINT)
	content.add_child(eyebrow)
	var title := _label("Name your captain",32,INK)
	content.add_child(title)
	var introduction := _label("Your first promise shapes the work you take on across the frontier.",16,MUTED)
	content.add_child(introduction)
	var name_label := _label("CAPTAIN NAME",12,INK)
	content.add_child(name_label)
	name_entry = LineEdit.new()
	name_entry.placeholder_text = "Enter a name"
	name_entry.max_length = 24
	name_entry.custom_minimum_size.y = 42
	name_entry.add_theme_font_size_override("font_size",18)
	name_entry.add_theme_color_override("font_color",INK)
	name_entry.add_theme_color_override("font_placeholder_color",MUTED)
	name_entry.add_theme_stylebox_override("normal",_style(Color("f4efe5"),Color("85918c"),1,8))
	name_entry.add_theme_stylebox_override("focus",_style(Color("f8f4ec"),GOLD,2,8))
	content.add_child(name_entry)
	var philosophy_label := _label("CHOOSE A PHILOSOPHY",12,INK)
	content.add_child(philosophy_label)
	var cards := HBoxContainer.new()
	cards.add_theme_constant_override("separation",12)
	content.add_child(cards)
	for id: String in ["scientist","zealot","knight"]:
		_add_choice(cards,id)
	detail = _label("",15,INK)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.custom_minimum_size.y = 38
	content.add_child(detail)
	error_label = _label("",13,CORAL)
	error_label.custom_minimum_size.y = 18
	content.add_child(error_label)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation",10)
	content.add_child(footer)
	var back := _action_button("BACK TO MENU",false)
	back.pressed.connect(func() -> void: cancel_requested.emit())
	footer.add_child(back)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(spacer)
	var begin := _action_button("BEGIN EXPEDITION",true)
	begin.pressed.connect(_begin)
	footer.add_child(begin)
	_refresh_choice()
	name_entry.grab_focus()

func _style(fill: Color, border: Color, width: int, padding: int) -> StyleBoxFlat:
	var result := StyleBoxFlat.new()
	result.bg_color = fill
	result.border_color = border
	result.set_border_width_all(width)
	result.set_corner_radius_all(0)
	result.content_margin_left = padding
	result.content_margin_right = padding
	result.content_margin_top = padding
	result.content_margin_bottom = padding
	return result

func _label(copy: String, size: int, color: Color) -> Label:
	var result := Label.new()
	result.text = copy
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result.add_theme_font_size_override("font_size",size)
	result.add_theme_color_override("font_color",color)
	return result

func _add_choice(parent: HBoxContainer, id: String) -> void:
	var spec: Dictionary = CHOICES[id]
	var card := Button.new()
	card.custom_minimum_size = Vector2(0,156)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.focus_mode = Control.FOCUS_ALL
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.pressed.connect(func() -> void: selected = id; error_label.text = ""; _refresh_choice())
	parent.add_child(card)
	choice_buttons[id] = card
	var stack := VBoxContainer.new()
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stack.add_theme_constant_override("separation",7)
	card.add_child(stack)
	var icon := TextureRect.new()
	icon.texture = Instruments.icon(str(spec.icon))
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(42,38)
	icon.modulate = spec.tint
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(icon)
	var heading := _label(str(spec.title),16,INK)
	stack.add_child(heading)
	var summary := _label(str(spec.summary),13,MUTED)
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(summary)
	Instruments.focus_cue(card)

func _refresh_choice() -> void:
	for id: String in choice_buttons:
		var spec: Dictionary = CHOICES[id]
		var card: Button = choice_buttons[id]
		card.add_theme_stylebox_override("normal",_style(Color("f3eee4"),GOLD if id == selected else Color("b8b6aa"),2 if id == selected else 1,10))
		card.add_theme_stylebox_override("hover",_style(Color("f8f3e8"),Color(spec.tint),2,10))
		card.add_theme_stylebox_override("pressed",_style(Color("eee5d5"),GOLD,2,10))
	var spec: Dictionary = CHOICES[selected]
	detail.text = "FIRST COMMITMENT  ·  "+str(spec.commitment)

func _action_button(copy: String, primary: bool) -> Button:
	var button := Button.new()
	button.text = copy
	button.custom_minimum_size = Vector2(190,42)
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_stylebox_override("normal",_style(INK if primary else PAPER,GOLD if primary else INK,2,8))
	button.add_theme_stylebox_override("hover",_style(Color("26353a") if primary else Color("f7f2e7"),GOLD,2,8))
	button.add_theme_color_override("font_color",PAPER if primary else INK)
	button.add_theme_font_size_override("font_size",13)
	Instruments.focus_cue(button)
	return button

func _begin() -> void:
	var captain_name: String = name_entry.text.strip_edges()
	if captain_name.is_empty():
		error_label.text = "Enter a captain name to continue."
		name_entry.grab_focus()
		return
	error_label.text = ""
	begin_requested.emit(captain_name,selected)

func show_error(copy: String) -> void:
	error_label.text = copy
