extends "res://tests/diplomacy_study_panel.gd"
## Model-backed layout proposal; controls and schematic are review-only.
var conflict: bool=false
func action_box(at: Vector2, label: String, reason: String="", quiet: bool=false) -> void:
	panel(Rect2(at,Vector2(320,42)),DARK if quiet else IVORY if reason.is_empty() else Color("727c75"))
	if quiet: draw_rect(Rect2(at,Vector2(320,42)),Color("a3aaa0"),false,1)
	text(at+Vector2(14,28),label,20,IVORY if quiet else DARK)
func _draw() -> void:
	var faction: Dictionary=game.sector.faction_by_id("consortium")
	panel(Rect2(24,20,1060,36),DARK); text(Vector2(38,45),"FLEET / PEACE STUDY · ACTUAL STATE / STATIC PROPOSED CONTROLS",18)
	panel(Rect2(410,210,1100,650),IVORY)
	text(Vector2(435,248),"ORIN CONSORTIUM",25,DARK); text(Vector2(1250,248),"%d Marks" % game.field.marks,23,DARK)
	panel(Rect2(430,273,250,405),DARK)
	var fit: float=minf(230.0/TAVI.get_width(),330.0/TAVI.get_height())
	var extent: Vector2=TAVI.get_size()*fit
	draw_texture_rect(TAVI,Rect2(Vector2(555,462)-extent*0.5,extent),false)
	text(Vector2(449,655),"Tavi Rill",23)
	text(Vector2(435,716),"RELATIONS %+d" % faction.relation,22,DARK)
	lines(Vector2(435,745),str(faction.reason).replace("trust","relations"),25,DARK)
	panel(Rect2(704,273,784,494),DARK)
	if conflict: draw_peace()
	else: draw_fleet()
	var tabs: Array=[["Communications","comms"],["Fleet","fleet"],["Domestic defense","housing"],["Dock services","repair_pack"]]
	for i: int in range(tabs.size()):
		var r:=Rect2(704+i*55,808,44,32); panel(r,DARK); icon(tabs[i][1],r.grow(-5)); named_regions[tabs[i][0]]=r
		if (not conflict and i==1) or (conflict and i==0): corners(r.grow(3),AMBER)
	action_box(Vector2(1155,801),"Goodbye","",true)
func draw_fleet() -> void:
	var unit: Dictionary=game.fleet.state.ships.get("consortium",{})
	var spec: Dictionary=game.fleet.catalog.consortium
	var status: String=unit.get("status","available")
	text(Vector2(725,311),"ALLIED FLEET / %d OF %d SLOTS" % [game.fleet.active_ids().size(),game.fleet.capacity(game)],23)
	# Schematic placeholder, not a new ship asset or rendered production model.
	icon("fleet",Rect2(736,345,86,86)); text(Vector2(725,459),"SCHEMATIC",14)
	text(Vector2(858,366),spec.name+" / "+status.to_upper(),25,AMBER)
	var hull: float=unit.get("hull",spec.hull)
	text(Vector2(858,401),"HULL %d / %d" % [hull,spec.hull],21)
	draw_rect(Rect2(858,416,570,10),Color("48504c")); draw_rect(Rect2(858,416,570*hull/spec.hull,10),AMBER)
	text(Vector2(858,463),"Fleet stance: assist attacks" if game.fleet.state.assist else "Fleet stance: hold fire",20)
	panel(Rect2(1210,442,218,34),IVORY)
	text(Vector2(1223,466),"Set hold fire" if game.fleet.state.assist else "Set assist",18,DARK)
	named_regions["Toggle escort orders; following ships can still take damage"]=Rect2(1210,442,218,34)
	text(Vector2(725,508),"One loaned ship per ally. Returned ships retain their damage.",18)
	var action: String="repair" if status=="active" else "recruit"
	var reason: String=game.fleet.reason(game,"consortium",action,scene.ship.position)
	if status=="active":
		text(Vector2(725,550),"Repair restores %d hull / %d Marks" % [spec.hull-hull,game.fleet.repair_cost("consortium")],22)
	elif status=="lost":
		text(Vector2(725,550),"Escort lost / -7 relations / replacement 120 Marks",22,AMBER)
	else:
		text(Vector2(725,550),"Request a loaned escort / no Marks charge",22)
	lines(Vector2(725,589),reason if not reason.is_empty() else "Ready at this location",65,AMBER)
	action_box(Vector2(725,670),"Repair escort" if status=="active" else "Request replacement" if status=="lost" else "Request escort",reason)
	if status=="active": action_box(Vector2(1118,670),"Return ship","",true)
	text(Vector2(725,745),"More slots: raise Explorer, Merchant or Defender tier (maximum 3).",17)
func draw_peace() -> void:
	var n: Dictionary=game.conflict.nation("consortium")
	text(Vector2(725,315),"WAR AND PEACE",25)
	if stage=="war-confirm":
		text(Vector2(725,370),"Declare war on the Orin Consortium?",26,AMBER)
		lines(Vector2(725,420),"Trade, transit and alliance agreements end. Their loaned escort returns home. Your colonies become targets for warned raids.",67)
		text(Vector2(725,527),"No declaration has been made.",20)
		action_box(Vector2(725,620),"Cancel","",true)
		action_box(Vector2(1118,620),"Confirm declaration")
	elif n.war:
		text(Vector2(725,370),"AT WAR / treaties ended",26,AMBER)
		lines(Vector2(725,416),"Peace recalls their current raid and starts a 300-second truce. Treaties must be renegotiated; damaged ports remain damaged.",67)
		text(Vector2(725,522),"Peace payment / %d Marks" % game.conflict.peace_cost("consortium"),24)
		var reason: String=game.conflict.reason(game,"consortium","peace")
		lines(Vector2(725,564),reason if not reason.is_empty() else "Funds available",65,AMBER)
		action_box(Vector2(725,637),"Negotiate peace",reason)
	else:
		text(Vector2(725,370),"PEACE AGREED",26,AMBER)
		var paid: int=0
		for event: Dictionary in game.diplomacy.state.events:
			if event.kind=="war" and event.outcome.has("truce_until"): paid=-int(event.outcome.marks_delta)
		text(Vector2(725,416),"Paid %d Marks / treasury %d Marks" % [paid,game.field.marks],22)
		text(Vector2(725,465),"Truce remaining: %d seconds" % maxi(0,n.truce-game.field.state.time),24)
		lines(Vector2(725,515),"Former treaties remain ended. Port damage is unchanged. Renegotiate agreements through communications.",67)
		action_box(Vector2(725,614),"Review agreements")
	action_box(Vector2(1118,704),"Domestic defenses","",true)
