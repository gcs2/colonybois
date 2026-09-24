extends VBoxContainer
signal shop_requested(id: String)
signal pinned
const UI = preload("res://scripts/flight_interface.gd")
const Recognition = preload("res://scripts/expedition_progression.gd")
var campaign: RefCounted
var selected: String = "explorer"

func text(copy: String, tint: Color = UI.PAPER) -> Label:
	var label := Label.new(); label.text = copy; label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color",tint); label.custom_minimum_size.x = 160; add_child(label); return label
func _ready() -> void:
	custom_minimum_size.x = 830; add_theme_constant_override("separation",10)
	if not campaign.recognition.state.pinned.is_empty(): selected = campaign.recognition.state.pinned
	rebuild()
func rebuild() -> void:
	for child: Node in get_children(): remove_child(child); child.queue_free()
	var tiers: Dictionary = campaign.commerce.state.badges
	var rank: int = Recognition.rank(tiers); var points: int = Recognition.points(tiers)
	text(Recognition.title(tiers)+" · %d badge points" % points,UI.GOLD).add_theme_font_size_override("font_size",22)
	var rank_bar := ProgressBar.new(); rank_bar.show_percentage = false; rank_bar.custom_minimum_size.y = 10
	rank_bar.max_value = Recognition.catalog.rank_points[mini(rank,9)]; rank_bar.value = points; UI.meter(rank_bar,UI.GOLD); add_child(rank_bar)
	text("Highest master rank earned" if rank == 10 else "%d / %d · next: %s" % [points,rank_bar.max_value,Recognition.catalog.rank_names[rank]],UI.MUTED)
	var grid := GridContainer.new(); grid.columns = 5; grid.add_theme_constant_override("h_separation",7); grid.add_theme_constant_override("v_separation",7); add_child(grid)
	for id: String in campaign.commerce.catalog.badges:
		var definition: Dictionary = campaign.commerce.catalog.badges[id]; var level: int = tiers[id]
		var cell := VBoxContainer.new(); cell.custom_minimum_size.x = 160; grid.add_child(cell)
		var button := Button.new(); button.custom_minimum_size = Vector2(160,82); button.text = definition.name+"\n"+"★".repeat(level)+"☆".repeat(5-level)
		button.add_theme_font_size_override("font_size",14); button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER; button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		UI.instrument(button,definition.icon,UI.GOLD if level > 0 else UI.MUTED,id == selected)
		button.tooltip_text = UI.tooltip(definition.name+"\n"+definition.description)
		button.pressed.connect(func() -> void: selected = id; rebuild()); cell.add_child(button)
		var bar := ProgressBar.new(); bar.show_percentage = false; bar.custom_minimum_size.y = 6
		bar.max_value = definition.levels[mini(level,4)]; bar.value = campaign.commerce.progress(campaign,id)
		UI.meter(bar,UI.NAV); cell.add_child(bar)
	var badge: Dictionary = campaign.commerce.catalog.badges[selected]; var tier: int = tiers[selected]
	text(badge.name+" · "+("Complete" if tier == 5 else "%d / %d toward tier %d" % [campaign.commerce.progress(campaign,selected),badge.levels[tier],tier+1]),UI.GOLD)
	text(badge.description)
	var pin := Button.new(); pin.text = "Unpin progress" if campaign.recognition.state.pinned == selected else "Pin progress to HUD"
	UI.instrument(pin,"log",UI.NAV); add_child(pin)
	pin.pressed.connect(func() -> void: campaign.recognition.state.pinned = "" if campaign.recognition.state.pinned == selected else selected; pinned.emit(); rebuild())
	var found: bool = false
	for id: String in campaign.commerce.catalog.upgrades:
		var item: Dictionary = campaign.commerce.catalog.upgrades[id]
		if not item.requires.has(selected): continue
		found = true
		var purchase := Button.new(); purchase.custom_minimum_size.y = 36; purchase.alignment = HORIZONTAL_ALIGNMENT_LEFT
		purchase.text = "%s · %d Marks · %s" % [item.name,item.price,"Installed" if id in campaign.commerce.state.upgrades else "Eligible" if campaign.commerce.eligible(id) else badge.name+" "+str(item.requires[selected])]
		UI.instrument(purchase,"cargo",UI.CARGO); purchase.tooltip_text = "Inspect this equipment in the shop. Dock access, prior installation and price still apply."
		purchase.pressed.connect(func() -> void: shop_requested.emit(id)); add_child(purchase)
	if not found: text("Badge points contribute to master-rank promotions.",UI.MUTED)
	text("Recognition unlocks purchase eligibility. Equipment is never awarded free.",UI.MUTED)
