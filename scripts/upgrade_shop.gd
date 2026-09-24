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
var catalogue: ScrollContainer
var purchase_button: Button

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation",14)
	catalogue = ScrollContainer.new()
	catalogue.custom_minimum_size = Vector2(185,270)
	catalogue.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(catalogue)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation",6)
	catalogue.add_child(list)
	detail = VBoxContainer.new()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.custom_minimum_size.x = 250
	detail.add_theme_constant_override("separation",10)
	add_child(detail)
	for offer: Dictionary in offers:
		var button := Button.new()
		button.text = offer.title
		button.custom_minimum_size = Vector2(170,48)
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override("font_size",14)
		button.tooltip_text = Instruments.tooltip("%s · %s\n%s" % [offer.title,"Installed" if offer.owned else "%d Marks" % offer.price,offer.reason if not str(offer.reason).is_empty() else offer.description])
		button.set_meta("upgrade_id",offer.id)
		button.pressed.connect(_select.bind(str(offer.id)))
		list.add_child(button)
		entries[offer.id] = button
	if not entries.has(selected_id): selected_id = str(offers[0].id) if not offers.is_empty() else ""
	_select(selected_id)
	if entries.has(selected_id): catalogue.ensure_control_visible.call_deferred(entries[selected_id])

func _copy(text: String, color: Color = Instruments.PAPER, font_size: int = 15) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color",color)
	label.add_theme_font_size_override("font_size",font_size)
	detail.add_child(label)

func _select(id: String) -> void:
	selected_id = id
	for child: Node in detail.get_children(): detail.remove_child(child); child.queue_free()
	for offer: Dictionary in offers:
		var button: Button = entries[offer.id]
		Instruments.instrument(button,offer.icon,Instruments.GOLD if offer.owned else Instruments.NAV,offer.id == id)
		button.add_theme_constant_override("icon_max_width",30)
		if offer.id != id: continue
		_copy(offer.title,Instruments.PAPER,20)
		_copy("Installed" if offer.owned else "%d Marks" % offer.price,Instruments.GOLD,18)
		_copy(offer.description)
		if not str(offer.requirements).is_empty(): _copy(offer.requirements,Instruments.MUTED,14)
		purchase_button = Button.new()
		purchase_button.text = "Installed" if offer.owned else "Load colony kit" if offer.action == "kit" else "Purchase"
		purchase_button.custom_minimum_size.y = 42
		Instruments.instrument(purchase_button,offer.icon,Instruments.GOLD)
		purchase_button.disabled = locked or offer.owned or not str(offer.reason).is_empty()
		purchase_button.tooltip_text = Instruments.tooltip(offer.reason)
		purchase_button.set_meta("purchase_upgrade_id",id)
		purchase_button.pressed.connect(func() -> void: purchase_requested.emit(offer.action,offer.id))
		detail.add_child(purchase_button)
		if not str(offer.reason).is_empty() and not offer.owned: _copy(offer.reason,Instruments.GOLD,14)
	selected.emit(id)
