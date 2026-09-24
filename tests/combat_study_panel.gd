extends "res://tests/review_field_inventory.gd".InventoryStudy
## Read-only proposed combat presentation. Actual commands stay in the fixture harness.
var game: RefCounted
var scene: Node3D
var stage: String
var target_id: String
var target_screen: Vector2
var ship_screen: Vector2
var chart: Control
var current_reason: String=""
var presented_state: String=""
var salvage_reason: String=""
func _ready() -> void:
	chart.position=Vector2(40,824); add_child(chart)
	icons.weapon=scene.hud.item_buttons["seeker" if stage=="wrong-target" else "surface_laser"].icon
func _draw() -> void:
	panel(Rect2(24,20,820,36),DARK)
	text(Vector2(38,45),"COMBAT STUDY · PROPOSED UI / FROZEN ACTUAL WORLD",18)
	panel(Rect2(24,68,210,40),DARK)
	text(Vector2(38,96),game.field.definition().name,24)
	panel(Rect2(24,778,230,278),IVORY)
	text(Vector2(40,808),"LOCAL TERRAIN",18,DARK)
	var unit: Dictionary=game.combat.world(game.field.state.planet_id).units[target_id]
	var profile: Dictionary=game.combat.profiles(game.field.state.planet_id)[target_id]
	var wreck: bool=unit.hull<=0
	var accent: Color=Color("99c5b0") if wreck else Color("e9aa7a")
	corners(Rect2(target_screen-Vector2(30,30),Vector2(60,60)),accent)
	var anchor:=Vector2(clampf(target_screen.x+58,270,1620),clampf(target_screen.y-135,110,710))
	draw_line(target_screen+Vector2(32,-25),anchor+Vector2(0,70),DARK,4,true)
	draw_line(target_screen+Vector2(32,-25),anchor+Vector2(0,70),accent,1.5,true)
	panel(Rect2(anchor,Vector2(260,92)),DARK)
	text(anchor+Vector2(14,26),profile.name,21)
	text(anchor+Vector2(14,53),"Cargo recovered" if unit.salvaged else "Cargo available in wreck" if wreck else "HOSTILE · %d / %d" % [unit.hull,profile.hull],17,accent)
	if not wreck:
		draw_rect(Rect2(anchor+Vector2(14,68),Vector2(232,7)),Color("4b5652"))
		draw_rect(Rect2(anchor+Vector2(14,68),Vector2(232*unit.hull/profile.hull,7)),accent)
	var weapon: String="seeker" if stage=="wrong-target" else "surface_laser"
	var spec: Dictionary=game.combat.data().weapons[weapon]
	current_reason=game.combat.reason(game,weapon,target_id,Vector3.ZERO,scene.ship.position) if not wreck else salvage_reason if not unit.salvaged else ""
	var cooling: bool=current_reason=="Weapon cooling down."
	var status: String="COOLING · %ds" % (game.combat.state.ready-game.field.state.time) if cooling else "BLOCKED" if not current_reason.is_empty() else "READY"
	if wreck: status="RECOVERED" if unit.salvaged else "BLOCKED" if not current_reason.is_empty() else "RECOVERY QUEUED" if scene.surface_salvage_order else "RECOVER CARGO"
	presented_state=status
	panel(Rect2(1376,806,520,156),IVORY)
	if not wreck: icon("weapon",Rect2(1392,824,56,56))
	else:
		draw_rect(Rect2(1404,838,29,25),DARK,false,2)
		draw_line(Vector2(1404,838),Vector2(1418,830),DARK,2)
		draw_line(Vector2(1418,830),Vector2(1433,838),DARK,2)
	text(Vector2(1464,836),status,21,DARK)
	text(Vector2(1464,864),"%s · 1 freight unit" % str(profile.goods).capitalize() if wreck else "%d energy / shot · %d m range" % [spec.energy,spec.range],18,DARK)
	var detail: String=current_reason if not current_reason.is_empty() else "Recovered to cargo" if unit.salvaged else "Wreck in recovery range" if wreck else spec.name
	text(Vector2(1394,899),detail,18,DARK)
	if wreck: text(Vector2(1394,938),"HOLD %d / %d" % [game.commerce.used_space(game),game.commerce.capacity()],17,DARK)
	else:
		var guidance: String="Click target to attack"
		if cooling: guidance="Resumes automatically" if scene.surface_order else "Wait for cooldown"
		elif current_reason=="Need 5 energy.": guidance="Use a pack or dock"
		elif not current_reason.is_empty(): guidance="Select a suitable weapon"
		elif stage=="hit": guidance="Hit · 16 damage"
		text(Vector2(1394,938),guidance,17,DARK)
	if scene.surface_order:
		panel(Rect2(1736,914,142,36),DARK)
		text(Vector2(1760,939),"Cancel",18)
	elif wreck and not unit.salvaged:
		panel(Rect2(1736,914,142,36),DARK if current_reason.is_empty() else Color("737b71"))
		text(Vector2(1756,939),"Recover",18)
	elif not wreck:
		panel(Rect2(1736,914,142,36),DARK if current_reason.is_empty() else Color("737b71"))
		text(Vector2(1760,939),"Attack",18)
	if stage=="incoming":
		var warning:=Vector2(clampf(ship_screen.x-410,280,1400),maxf(120,ship_screen.y-155))
		panel(Rect2(warning,Vector2(370,56)),DARK)
		text(warning+Vector2(15,23),"!  INCOMING FIRE",20,Color("ffd0a1"))
		text(warning+Vector2(15,45),"Move clear of the marked volumes",17)
