extends "res://tests/review_field_inventory.gd".InventoryStudy
## Static outcome proposal over real fixture state; no input or production integration.
var game: RefCounted
var scene: Node3D
var stage: String
var refusal: String
var chart: Control
var target_screen: Vector2
var ship_screen: Vector2
var wreck_screen: Vector2
var heading: String=""
var action: String=""
var action_enabled: bool=false
func _ready() -> void:
	if chart!=null:
		chart.position=Vector2(40,824); add_child(chart)
func _draw() -> void:
	panel(Rect2(24,20,880,36),DARK)
	text(Vector2(38,45),"OUTCOME STUDY · PROPOSED UI / FROZEN ACTUAL WORLD",18)
	panel(Rect2(24,68,300,40),DARK)
	text(Vector2(38,96),str(game.field.definition().name)+(" / ORBIT" if game.field.state.flight_mode=="orbit" else " / SURFACE"),23)
	if chart!=null:
		panel(Rect2(24,778,230,278),IVORY); text(Vector2(40,808),"LOCAL TERRAIN",18,DARK)
	var orbital: bool=game.field.state.flight_mode=="orbit"
	var tow: bool=stage=="surface-tow"
	var civilian: bool=stage=="civilian-wreck"
	var neutralized: bool=orbital and game.field.state.guardian_disabled
	var name: String=game.field.enemy_profile().name if orbital else "Civic hall" if civilian else "Rime watcher"
	var subtitle: String=""
	var detail: String=""
	var guidance: String=""
	var color: Color=Color("e9aa7a")
	action=""; action_enabled=false
	if tow:
		heading="EMERGENCY TOW COMPLETE"
		detail="Recovered to a holding position. Repairs still needed."
		guidance="Dock for repairs and energy, or use inventory supplies."
	elif civilian:
		heading="CIVILIAN STRUCTURE DESTROYED"
		subtitle="Ruined · no ship cargo"
		detail=refusal
		guidance="No salvage action available."
	elif neutralized:
		color=Color("99c5b0")
		if game.field.has_wreck():
			heading="CUSTODIAN DISABLED"
			subtitle="Intact · no freight salvage"
			detail="The separate drifting wreck still emits defense pulses."
			var distance: float=scene.ship.position.distance_to(game.field.WRECK_POSITION)
			guidance=game.field.salvage_reason(distance)
			if guidance=="Chart Morrow first to locate the drifting wreck.": guidance="Survey Morrow before recovering the pulse ward."
			if guidance.is_empty(): guidance="Recover pulse ward · 20 energy · 3 seconds"
			var warning:=Vector2(clampf(wreck_screen.x-360,24,1480),clampf(wreck_screen.y-100,140,700))
			panel(Rect2(warning,Vector2(360,62)),DARK)
			text(warning+Vector2(14,25),"PULSE CORE · %d m" % distance,19,Color("ffc68b"))
			text(warning+Vector2(14,49),"Next pulse in %d s · move clear" % (6-int(game.field.state.threat_clock)),17)
			draw_line(warning+Vector2(360,45),wreck_screen,DARK,3,true)
		elif game.field.state.guardian_salvaged:
			heading="CARGO RECOVERED"; subtitle="Cleared"
			detail="%d freight units added to cargo." % game.field.enemy_profile().quantity
			guidance="This wreck has no remaining cargo."
		else:
			heading="RECOVERY BLOCKED" if not refusal.is_empty() else "CARGO AVAILABLE"
			subtitle="Disabled · cargo aboard wreck"
			detail=refusal if not refusal.is_empty() else "%d freight units · within recovery range" % game.field.enemy_profile().quantity
			guidance="HOLD %d / %d" % [game.commerce.used_space(game),game.commerce.capacity()]
			action="Recover"; action_enabled=refusal.is_empty()
	elif orbital:
		var cooling: bool=refusal=="Arc lance recharging."
		heading="COOLING · %ds" % maxi(0,int(game.field.state.weapon_ready_at-game.field.state.time)) if cooling else "BLOCKED" if not refusal.is_empty() else "READY"
		subtitle="HOSTILE · %d / %d" % [game.field.state.guardian_hull,game.field.enemy_profile().hull]
		detail="10 energy / shot · 24 m range · %d damage" % game.field.lance_damage()
		guidance="Resumes automatically" if cooling else refusal if not refusal.is_empty() else "Click the selected target to attack."
		action="Cancel" if scene.attack_order else "Attack"; action_enabled=scene.attack_order or refusal.is_empty()
	else:
		heading="STRIKE EVADED" if stage=="surface-evaded" else "HULL HIT · 16 DAMAGE"
		subtitle="HOSTILE · 64 / 64"
		detail="No hull damage from the marked strike." if stage=="surface-evaded" else "Move clear of marked strike volumes."
		guidance="Threat remains active."
	if not tow:
		corners(Rect2(target_screen-Vector2(30,30),Vector2(60,60)),color)
		var anchor:=Vector2(clampf(target_screen.x+65,280,1530),clampf(target_screen.y-135,145,650))
		draw_line(target_screen+Vector2(32,-25),anchor+Vector2(0,67),DARK,4,true)
		draw_line(target_screen+Vector2(32,-25),anchor+Vector2(0,67),color,1.5,true)
		panel(Rect2(anchor,Vector2(320,96)),DARK)
		text(anchor+Vector2(14,29),name,22)
		text(anchor+Vector2(14,57),subtitle,17,color)
		if not neutralized and not civilian:
			var ratio: float=float(game.field.state.guardian_hull)/game.field.enemy_profile().hull if orbital else 1.0
			draw_rect(Rect2(anchor+Vector2(14,75),Vector2(288,6)),Color("4b5652"))
			draw_rect(Rect2(anchor+Vector2(14,75),Vector2(288*ratio,6)),color)
	# Keep outcome and corrective action together, above the own-ship gauges.
	var shift: float=36.0 if action.is_empty() and not tow else 0.0
	panel(Rect2(1226,806+shift,670,156-shift),IVORY)
	text(Vector2(1246,838+shift),heading,23,DARK)
	text(Vector2(1246,870+shift),detail,18,DARK)
	text(Vector2(1246,899+shift),guidance,18,DARK)
	if tow:
		text(Vector2(1246,938),"HULL %d / %d     ENERGY %d / %d" % [game.field.state.hull,game.field.max_capacity("hull"),game.field.state.energy,game.field.max_capacity("energy")],18,DARK)
	elif not action.is_empty():
		panel(Rect2(1736,916,140,32),DARK if action_enabled else Color("737b71"))
		text(Vector2(1758,939),action,18)
