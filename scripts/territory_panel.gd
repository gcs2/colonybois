extends RefCounted
const C = preload("res://scripts/surface_combat.gd")
const UI = preload("res://scripts/flight_interface.gd")
var flight: Node3D
var confirm_refusal: bool = false
func setup(view: Node3D) -> void: flight = view
func administration() -> void:
	flight.selected_colony = flight.campaign.field.state.planet_id
	flight._show_popup("colonies")
func act(action: String) -> void:
	if flight.paused: return
	if action == "refuse" and not confirm_refusal: confirm_refusal = true; flight._show_popup("territory"); return
	confirm_refusal = false
	var game: RefCounted = flight.campaign
	var blocked: String = game.territory.command(game,game.field.state.planet_id,action,flight.ship.position)
	flight._toast(blocked if not blocked.is_empty() else "Colony terms recorded")
	flight.audio.play("error" if not blocked.is_empty() else "ui_confirm")
	if blocked.is_empty(): flight._save(false)
	flight._show_popup("territory")
func build() -> void:
	var game: RefCounted = flight.campaign; var id: String = game.field.state.planet_id
	if not game.territory.catalog.has(id): flight._panel_copy("No alien settlement here."); return
	var spec: Dictionary = game.territory.catalog[id]; var record: Dictionary = game.territory.world(id)
	var units: Dictionary = game.combat.world(id).units
	var intro := HBoxContainer.new(); intro.add_theme_constant_override("separation",18); flight.popup_body.add_child(intro)
	var portrait := preload("res://scripts/alien_portrait.gd").new(); portrait.faction_id = spec.owner; portrait.mood = "wary"
	portrait.custom_minimum_size = Vector2(210,155); intro.add_child(portrait)
	var words := VBoxContainer.new(); words.size_flags_horizontal = Control.SIZE_EXPAND_FILL; intro.add_child(words)
	flight._contact_copy(words,str(spec.name)+" · "+str(record.phase).capitalize(),UI.GOLD)
	flight._contact_copy(words,"“We will stand down. Preserve the works and take responsibility for this settlement.”" if record.phase == "surrendered" else "This settlement's condition and ownership are recorded in your chronicle.",UI.PAPER)
	var stored: int = int(game.colonies.state.outposts[id].stock[spec.goods]) if record.phase == "annexed" else int(record.stock)
	flight._panel_copy("Civic hall %d / 240 · housing %d / 96 · industry %d / 96\nLocal reserves: %d %s" % [units.civic.hull,units.housing.hull,units.industry.hull,stored,game.commerce.catalog.goods[spec.goods].name],UI.PAPER)
	if record.phase == "surrendered":
		flight._panel_copy("Annexation retains surviving infrastructure, finite goods and damage. Continued attacks can destroy the hall and leave an unclaimed ruin.",UI.MUTED)
		for action: String in ["annex","refuse"]:
			var blocked: String = game.territory.reason(game,id,action,flight.ship.position)
			var label: String = "Accept surrender · administer this colony" if action == "annex" else "Confirm refusal · resume hostilities" if confirm_refusal else "Review rejection of surrender"
			var button: Button = flight._button(label,act.bind(action),flight.popup_body)
			UI.instrument(button,"badge_colonist" if action == "annex" else "defense",UI.CARGO)
			button.set_meta("territory_action",action); button.disabled = flight.paused or not blocked.is_empty()
			button.tooltip_text = blocked if not blocked.is_empty() else "Takes one of the scenario's three administered colony slots. No free kit, repair or energy." if action == "annex" else "The colony will no longer offer surrender. Its remaining guards resume fire. Destruction worsens other nations' relations."
			if not blocked.is_empty(): flight._panel_copy(blocked)
	elif record.phase == "annexed":
		var admin: Button = flight._button("Open colony administration",administration,flight.popup_body); UI.instrument(admin,"badge_colonist",UI.NAV)
	elif record.phase == "ruined": flight._panel_copy("Port and exports destroyed. A paid colony kit is required to rebuild. This does not establish extinction of the inhabitants' species.",UI.CARGO)
	else:
		flight._panel_copy("Its defenses respond during war. Precise damage can force surrender before destroying the hall; bombs can damage several structures at once.")
		var comms: Button = flight._button("Open communications",flight._show_popup.bind("contact"),flight.popup_body); UI.instrument(comms,"comms",UI.COMMS)
