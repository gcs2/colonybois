extends HBoxContainer
## Presentation-only quotes. The campaign command revalidates every transaction.
signal selected(id: String)
signal trade_requested(action: String, id: String)
const Style = preload("res://scripts/communicator_style.gd")
var offers: Array[Dictionary] = []
var selected_id: String = ""
var amount: int = 1
var locked: bool = false
var entries: Dictionary = {}
var detail: VBoxContainer
var buy_button: Button
var sell_button: Button

func _ready() -> void:
	name = "CommodityShop"
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation",14)
	var catalogue := ScrollContainer.new()
	catalogue.custom_minimum_size = Vector2(270,288)
	catalogue.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(catalogue)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation",6)
	grid.add_theme_constant_override("v_separation",6)
	catalogue.add_child(grid)
	for offer: Dictionary in offers:
		var button := Button.new()
		button.custom_minimum_size = Vector2(84,92)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.set_meta("equipment_tile",true)
		button.set_meta("commodity_id",offer.id)
		button.tooltip_text = "%s\nBuy: %d Marks / unit\nSell: %d Marks / unit\n%s" % [offer.title,offer.buy,offer.sell,offer.description]
		button.pressed.connect(_select.bind(offer.id))
		grid.add_child(button)
		var contents := VBoxContainer.new()
		contents.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(contents)
		contents.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		contents.offset_top = 5; contents.offset_bottom = -5
		var picture := TextureRect.new()
		picture.texture = Style.equipment_icon(offer.id)
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.custom_minimum_size.y = 49
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		contents.add_child(picture)
		var price := Style.money(offer.buy,13)
		price.alignment = BoxContainer.ALIGNMENT_CENTER
		price.mouse_filter = Control.MOUSE_FILTER_IGNORE
		contents.add_child(price)
		var stripe := ColorRect.new()
		stripe.name = "Selection"; stripe.color = Color("f2ead3")
		stripe.position = Vector2(2,7); stripe.size = Vector2(3,78)
		stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(stripe)
		entries[offer.id] = button
	detail = VBoxContainer.new()
	detail.custom_minimum_size.x = 250
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.add_theme_constant_override("separation",8)
	add_child(detail)
	if not entries.has(selected_id): selected_id = str(offers[0].id) if not offers.is_empty() else ""
	_select(selected_id)

func _copy(parent: Node, text: String, font_size: int = 15) -> Label:
	var label := Label.new()
	label.text = text; label.add_theme_font_size_override("font_size",font_size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(label)
	return label

func _select(id: String) -> void:
	selected_id = id
	for child: Node in detail.get_children(): detail.remove_child(child); child.queue_free()
	for offer: Dictionary in offers:
		entries[offer.id].set_meta("instrument_selected",offer.id == id)
		entries[offer.id].get_node("Selection").visible = offer.id == id
		if offer.id != id: continue
		_copy(detail,offer.title,20)
		_copy(detail,offer.description)
		_copy(detail,"Aboard %d    Port stock %d    Demand %d" % [offer.aboard,offer.stock,offer.demand])
		var actions := HBoxContainer.new()
		actions.add_theme_constant_override("separation",10)
		detail.add_child(actions)
		for buying: bool in [true,false]:
			var side := VBoxContainer.new()
			side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			actions.add_child(side)
			var price: int = offer.buy if buying else offer.sell
			var reason: String = offer.buy_reason if buying else offer.sell_reason
			var action: String = "buy" if buying else "sell"
			var quote := HBoxContainer.new()
			side.add_child(quote)
			_copy(quote,"Total",13)
			quote.add_child(Style.money(price*amount,19))
			var button := Button.new()
			button.text = "%s %d" % ["Buy" if buying else "Sell",amount]
			button.custom_minimum_size.y = 40
			button.disabled = locked or not reason.is_empty()
			button.tooltip_text = reason if not reason.is_empty() else "%s %d %s for %d Marks (%d per unit)." % [button.text.get_slice(" ",0),amount,offer.title,price*amount,price]
			button.pressed.connect(func() -> void: trade_requested.emit(action,id))
			side.add_child(button)
			if buying: buy_button = button
			else: sell_button = button
			var blocked := _copy(side,"Paused" if locked else reason,13)
			blocked.custom_minimum_size.y = 34
			blocked.max_lines_visible = 2
			blocked.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			blocked.tooltip_text = blocked.text
			blocked.mouse_filter = Control.MOUSE_FILTER_PASS
	Style.apply(self)
	selected.emit(id)
