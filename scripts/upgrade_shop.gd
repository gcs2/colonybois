extends HBoxContainer
## A bounded catalogue and one detail panel. Offers are quotes; commands revalidate.
signal selected(id: String)
signal purchase_requested(action: String, id: String)
const Instruments = preload("res://scripts/flight_interface.gd")
var offers: Array[Dictionary] = []
var selected_id: String = ""
var locked: bool = false
var entries: Dictionary = {}
var detail: VBoxContainer
var copy_parent: Control
var catalogue: ScrollContainer
var purchase_button: Button

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation",14)
	catalogue = ScrollContainer.new()
	catalogue.custom_minimum_size = Vector2(270,288)
	catalogue.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(catalogue)
	var list := GridContainer.new()
	list.columns = 3
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("h_separation",6)
	list.add_theme_constant_override("v_separation",6)
	catalogue.add_child(list)
	detail = VBoxContainer.new()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.custom_minimum_size.x = 250
	detail.add_theme_constant_override("separation",10)
	add_child(detail)
	for offer: Dictionary in offers:
		var button := Button.new()
		button.custom_minimum_size = Vector2(84,92)
		button.set_meta("equipment_tile",true)
		button.tooltip_text = Instruments.tooltip("%s · %s\n%s" % [offer.title,"Installed" if offer.owned else "%d Marks" % offer.price,offer.reason if not str(offer.reason).is_empty() else offer.description])
		button.set_meta("upgrade_id",offer.id)
		button.pressed.connect(_select.bind(str(offer.id)))
		list.add_child(button)
		var contents := VBoxContainer.new()
		contents.mouse_filter = Control.MOUSE_FILTER_IGNORE
		contents.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		contents.offset_left = 6; contents.offset_right = -6
		contents.offset_top = 5; contents.offset_bottom = -5
		contents.add_theme_constant_override("separation",0)
		button.add_child(contents)
		var selection := ColorRect.new()
		selection.name = "Selection"
		selection.color = Color("f2ead3")
		selection.position = Vector2(2,7)
		selection.size = Vector2(3,78)
		selection.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(selection)
		var suffix: String = str(offer.id).get_slice("_",1)
		if suffix in ["1","2","3","4"] or offer.id == "drive":
			var tier := Label.new()
			tier.text = {"1":"I","2":"II","3":"III","4":"IV"}.get(suffix,"I")
			tier.position = Vector2(7,3)
			tier.add_theme_font_size_override("font_size",11)
			tier.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.add_child(tier)
		var picture := TextureRect.new()
		picture.texture = preload("res://scripts/communicator_style.gd").equipment_icon(offer.id)
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.custom_minimum_size.y = 49
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		contents.add_child(picture)
		for line: String in ["Installed" if offer.owned else "%d Marks" % offer.price,"" if offer.owned or str(offer.reason).is_empty() else "Unavailable"]:
			if line.ends_with(" Marks"):
				var price := preload("res://scripts/communicator_style.gd").money(offer.price,13)
				price.alignment = BoxContainer.ALIGNMENT_CENTER
				price.mouse_filter = Control.MOUSE_FILTER_IGNORE
				contents.add_child(price)
				continue
			var label := Label.new()
			label.text = line
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.add_theme_font_size_override("font_size",11)
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			contents.add_child(label)
		entries[offer.id] = button
	if not entries.has(selected_id): selected_id = str(offers[0].id) if not offers.is_empty() else ""
	_select(selected_id)
	if entries.has(selected_id): catalogue.ensure_control_visible.call_deferred(entries[selected_id])

func _copy(text: String, color: Color = Instruments.PAPER, font_size: int = 15) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color",color)
	label.add_theme_font_size_override("font_size",font_size)
	(copy_parent if is_instance_valid(copy_parent) else detail).add_child(label)
	return label

func _select(id: String) -> void:
	selected_id = id
	for child: Node in detail.get_children(): detail.remove_child(child); child.queue_free()
	copy_parent = detail
	for offer: Dictionary in offers:
		var button: Button = entries[offer.id]
		button.set_meta("instrument_selected",offer.id == id)
		button.get_node("Selection").visible = offer.id == id
		if offer.id != id: continue
		_copy(offer.title,Instruments.PAPER,20)
		if offer.owned: _copy("Installed",Instruments.GOLD,18)
		else: detail.add_child(preload("res://scripts/communicator_style.gd").money(offer.price,20))
		var prose_scroll := ScrollContainer.new()
		prose_scroll.custom_minimum_size.y = 140
		prose_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		detail.add_child(prose_scroll)
		var prose := VBoxContainer.new()
		prose.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		prose.add_theme_constant_override("separation",9)
		prose_scroll.add_child(prose)
		copy_parent = prose
		if not str(offer.get("flavor","")).is_empty(): _copy(offer.flavor,Instruments.MUTED,14)
		_copy(offer.description)
		if not str(offer.requirements).is_empty(): _copy(offer.requirements,Instruments.MUTED,14)
		purchase_button = Button.new()
		purchase_button.text = "Installed" if offer.owned else "Load colony kit" if offer.action == "kit" else "Purchase"
		purchase_button.custom_minimum_size.y = 42
		Instruments.instrument(purchase_button,offer.icon,Instruments.GOLD)
		purchase_button.icon = preload("res://scripts/communicator_style.gd").equipment_icon(offer.id)
		purchase_button.disabled = locked or offer.owned or not str(offer.reason).is_empty()
		purchase_button.tooltip_text = Instruments.tooltip(offer.reason)
		purchase_button.set_meta("purchase_upgrade_id",id)
		purchase_button.pressed.connect(func() -> void: purchase_requested.emit(offer.action,offer.id))
		detail.add_child(purchase_button)
		copy_parent = detail
		if not str(offer.reason).is_empty() and not offer.owned:
			var blocked: Label = _copy(offer.reason,Instruments.GOLD,13)
			blocked.max_lines_visible = 2
			blocked.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			blocked.tooltip_text = offer.reason
			blocked.mouse_filter = Control.MOUSE_FILTER_PASS
			blocked.set_meta("semantic_color",true)
	preload("res://scripts/communicator_style.gd").apply(self)
	selected.emit(id)
