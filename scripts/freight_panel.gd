extends VBoxContainer
## UI quotes state; only the freight model can commit contracts or move cargo.
signal committed
const UI = preload("res://scripts/flight_interface.gd")
const Geography = preload("res://scripts/planet_geography.gd")
var campaign: RefCounted
var source: String = ""
var destination: String = "morrow"
var commodity: String = "water"
var reserve: int = 4
var preview: Label
var confirm: Button
var feedback: String = ""
var locked: bool = false

func _ready() -> void: rebuild()
func copy(text: String, tint: Color = UI.MUTED) -> Label:
	var label := Label.new()
	label.text = text; label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",16)
	label.add_theme_color_override("font_color",tint)
	add_child(label)
	return label
func action(text: String, icon: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text; button.custom_minimum_size.y = 44
	UI.instrument(button,icon,UI.CARGO)
	button.pressed.connect(callback)
	add_child(button)
	return button
func choose(title: String, choices: Dictionary, selected: String, callback: Callable) -> void:
	var row := HBoxContainer.new()
	add_child(row)
	var label := Label.new(); label.text = title; label.custom_minimum_size.x = 130
	row.add_child(label)
	var options := OptionButton.new()
	options.custom_minimum_size.y = 44; options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UI.instrument(options,"",UI.NAV)
	for key: String in choices:
		options.add_item(choices[key]); options.set_item_metadata(options.item_count-1,key)
		if key == selected: options.select(options.item_count-1)
	options.item_selected.connect(func(index: int) -> void: callback.call(str(options.get_item_metadata(index))))
	row.add_child(options)

func rebuild() -> void:
	for child: Node in get_children(): remove_child(child); child.queue_free()
	add_theme_constant_override("separation",12)
	var sources: Dictionary = {}
	for id: String in campaign.colonies.state.outposts:
		if campaign.sector.state.colonies.has(id): sources[id] = Geography.definition(id).name
	if sources.is_empty(): copy("Complete an export outpost to charter a carrier."); return
	if not sources.has(source): source = sources.keys()[0]
	choose("Source",sources,source,func(id: String) -> void: source = id; feedback = ""; rebuild())
	if not feedback.is_empty(): copy(feedback,UI.GOLD)
	var freight: RefCounted = campaign.freight
	if freight.state.routes.has(source):
		var route: Dictionary = freight.state.routes[source]
		destination = route.destination; commodity = route.item; reserve = route.reserve
		copy("%s → %s\n%s" % [sources[source],Geography.definition(destination).name,route.status],UI.PAPER)
		copy("Aboard: %d / 4 · Delivered: %d\nReceipts: %d Marks · Transport: %d Marks" % [route.cargo,route.delivered,route.receipts,route.fees])
		if route.phase != "waiting":
			var progress := ProgressBar.new(); progress.show_percentage = false
			progress.custom_minimum_size.y = 8
			progress.value = 100*(1.0-float(route.remaining)/maxi(1,route.duration))
			UI.meter(progress,UI.CARGO); add_child(progress)
		var hold: Button = action("Resume departures" if route.paused else "Pause departures","ascend" if route.paused else "brake",func() -> void: finish(freight.pause(campaign,source)))
		hold.disabled = locked
		hold.tooltip_text = "Existing shipments finish. Pausing only stops new departures."
		if route.phase == "outbound":
			var recall: Button = action("Recall with cargo","descend",func() -> void: finish(freight.recall(campaign,source)))
			recall.disabled = locked
			recall.tooltip_text = UI.tooltip("Reverse the current journey without selling and pause future departures. Closed transit borders can still hold the carrier. Prepaid transport is not refunded.")
		if route.phase != "waiting" or route.cargo > 0:
			var is_supply_active: bool = campaign.colonies.state.outposts.has(route.destination) and campaign.sector.state.colonies.has(route.destination)
			if is_supply_active:
				var dest_wh: Dictionary = campaign.colonies.state.outposts[route.destination].stock
				var dest_stored: int = 0
				for amount: int in dest_wh.values(): dest_stored += amount
				copy("%s · keeping %d units locally\nDestination warehouse: %d / %d storage" % [campaign.commerce.catalog.goods[route.item].name,route.reserve,dest_stored,campaign.colonies.STORAGE])
			else:
				copy("%s · keeping %d units locally\nBuyer demand: %d units" % [campaign.commerce.catalog.goods[route.item].name,route.reserve,campaign.commerce.market(route.destination)[route.item].demand])
			copy("The contract can be changed after the carrier returns and unloads. One colony day is 30 active seconds.")
			return
	var destinations: Dictionary = {}
	for system: Dictionary in campaign.sector.state.systems:
		if not system.visited: continue
		for id: String in system.planets:
			var local: String = campaign.local_id(id)
			if local != source: destinations[local] = Geography.definition(local).name
	if not destinations.has(destination): destination = destinations.keys()[0]
	copy("CONTRACT · four-unit shipments",UI.CARGO)
	choose("Destination",destinations,destination,func(id: String) -> void: destination = id; refresh_quote())
	var goods: Dictionary = {}
	for id: String in campaign.commerce.catalog.goods: goods[id] = campaign.commerce.catalog.goods[id].name
	choose("Commodity",goods,commodity,func(id: String) -> void: commodity = id; refresh_quote())
	choose("Keep locally",{"0":"0 units","4":"4 units","8":"8 units"},str(reserve),func(id: String) -> void: reserve = int(id); refresh_quote())
	preview = copy("")
	confirm = action("","cargo",func() -> void: finish(freight.configure(campaign,source,destination,commodity,reserve)))
	confirm.set_meta("freight_confirm",true)
	refresh_quote()
func refresh_quote() -> void:
	var offer: Dictionary = campaign.freight.quote(campaign,source,destination,commodity,reserve)
	var available: int = campaign.colonies.state.outposts[source].stock[commodity]
	var is_supply: bool = campaign.colonies.state.outposts.has(destination) and campaign.sector.state.colonies.has(destination)
	if is_supply:
		var dest_wh: Dictionary = campaign.colonies.state.outposts[destination].stock
		var dest_stored: int = 0
		for amount: int in dest_wh.values(): dest_stored += amount
		preview.text = "Warehouse: %d · departure needs %d\n%d days each way · %d Marks round-trip transport\nSupply delivery · destination storage: %d / %d" % [available,reserve+4,offer.days,offer.fee,dest_stored,campaign.colonies.STORAGE]
	else:
		preview.text = "Warehouse: %d · departure needs %d\n%d days each way · %d Marks round-trip transport\nCurrent full-load sale: %d Marks · %d after transport" % [available,reserve+4,offer.days,offer.fee,offer.gross,offer.net]
	if not offer.reason.is_empty(): preview.text += "\n"+offer.reason
	confirm.text = "Charter carrier · 80 Marks" if offer.charter > 0 else "Apply contract"
	confirm.disabled = locked or not offer.reason.is_empty()
	confirm.tooltip_text = UI.tooltip("Resume flight before issuing orders." if locked else offer.reason if confirm.disabled else "Reserve stock stays in the warehouse. Transport is prepaid at dispatch; inter-colony supply transfers generate 0 sale receipts. Net quote excludes facility operating costs and the initial charter. Unsold goods return. One colony day is 30 active seconds." if is_supply else "Reserve stock stays in the warehouse. Transport is prepaid at dispatch; sale price and demand are checked on arrival. Net quote excludes facility operating costs and the initial charter. Unsold goods return. One colony day is 30 active seconds.")
func finish(error: String) -> void:
	feedback = error if not error.is_empty() else "Freight orders updated."
	if error.is_empty(): committed.emit()
	rebuild()
