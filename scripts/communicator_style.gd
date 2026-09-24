extends RefCounted
const FACE = preload("res://assets/ui/communicator-button.svg")
const ACTIONS = preload("res://assets/ui/contact-actions-v1.png")
const FONT = preload("res://assets/fonts/Barlow-Regular.ttf")
const EQUIPMENT = preload("res://assets/ui/equipment-objects-v1.png")
const MARK = preload("res://assets/ui/mark-symbol.svg")
static func money(amount: int, font_size: int = 18) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	row.tooltip_text = "%d Marks" % amount
	row.add_theme_constant_override("separation",3)
	var symbol := TextureRect.new()
	symbol.texture = MARK; symbol.modulate = Color("e2bb76")
	symbol.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	symbol.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	symbol.custom_minimum_size = Vector2(font_size,font_size)
	symbol.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(symbol)
	var value := Label.new()
	value.text = str(amount)
	value.set_meta("semantic_color",true)
	value.add_theme_font_override("font",FONT)
	value.add_theme_font_size_override("font_size",font_size)
	value.add_theme_color_override("font_color",Color("e2bb76"))
	value.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(value)
	return row
static func equipment_icon(id: String) -> Texture2D:
	var ids: Array = ["colony_kit","shield","rally_call","heat_ray","cool_ray","cloud_accumulator","cloud_vacuum","seeker","ground_bomb","hold","emitter","drive","hull","energy","water","alloy"]
	var key: String = "hull" if id.begins_with("hull_") else "energy" if id.begins_with("energy_") else "drive" if id.begins_with("drive") else id
	var index: int = ids.find(key)
	if index < 0: return action_icon(0)
	var icon := AtlasTexture.new()
	icon.atlas = EQUIPMENT
	var cell: Vector2 = EQUIPMENT.get_size()/4.0
	icon.region = Rect2(Vector2(index%4,index/4)*cell,cell)
	return icon
static func action_icon(index: int) -> Texture2D:
	var icon := AtlasTexture.new()
	icon.atlas = ACTIONS
	var cell: Vector2 = ACTIONS.get_size()/2.0
	icon.region = Rect2(Vector2(index%2,index/2)*cell,cell)
	return icon
static func button(control: Button, selected: bool = false) -> void:
	for state: String in ["normal","hover","pressed","disabled","focus"]:
		var box := StyleBoxTexture.new()
		box.texture = FACE
		for side: int in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
			box.set_texture_margin(side,9)
			box.set_content_margin(side,10)
		box.modulate_color = Color("e8dfbd") if state == "hover" or selected else Color.WHITE
		if state == "pressed": box.modulate_color = Color("b3bba0")
		if state == "disabled" and not selected: box.modulate_color = Color("878c7d")
		control.add_theme_stylebox_override(state,box)
	control.add_theme_color_override("font_color",Color("e9e9e1"))
	control.add_theme_color_override("font_hover_color",Color("fff7df"))
	control.add_theme_color_override("font_disabled_color",Color("d7d9c6") if selected else Color("919685"))
	control.add_theme_color_override("icon_normal_color",Color.WHITE)
	control.add_theme_color_override("icon_hover_color",Color.WHITE)
	control.add_theme_color_override("icon_disabled_color",Color("838779"))
static func apply(root: Node) -> void:
	for child: Node in root.get_children():
		if child is Control: child.add_theme_font_override("font",FONT)
		if child is Button:
			var selected: bool = child.get_meta("instrument_selected",false)
			if not child.has_meta("equipment_tile") and (child.has_meta("upgrade_id") or child.has_meta("instrument_selected")):
				for state: String in ["normal","hover","pressed","disabled","focus"]:
					var box := StyleBoxFlat.new()
					box.bg_color = Color("3c4240") if selected or state == "hover" else Color("252a29")
					box.border_color = Color("d9d6c7")
					box.border_width_bottom = 2 if selected else 0
					box.set_content_margin_all(8)
					child.add_theme_stylebox_override(state,box)
				child.add_theme_color_override("font_color",Color("e9e9e1"))
				child.add_theme_color_override("font_disabled_color",Color("f3f0e4") if selected else Color("888c88"))
			else: button(child,selected)
		if child is Label:
			if not child.has_meta("semantic_color"): child.add_theme_color_override("font_color",Color("e2e4df"))
			if child.text.ends_with(" Marks"): child.add_theme_color_override("font_color",Color("e2bb76"))
		apply(child)
