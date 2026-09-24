extends "res://tests/service_study_panel.gd"
## Static review composition; all diplomatic eligibility comes from the campaign.
var page: String="home"
func lines(at: Vector2, value: String, limit: int=68, tint: Color=IVORY) -> void:
	var remaining:=value
	var row:=0
	while remaining.length()>limit:
		var cut:=remaining.rfind(" ",limit)
		if cut<1: cut=limit
		text(at+Vector2(0,row*22),remaining.substr(0,cut),18,tint)
		remaining=remaining.substr(cut+1); row+=1
	text(at+Vector2(0,row*22),remaining,18,tint)
func _draw() -> void:
	var f: Dictionary=game.sector.faction_by_id("consortium")
	var war: bool=game.conflict.at_war("consortium")
	panel(Rect2(24,20,1050,36),DARK); text(Vector2(38,45),"DIPLOMACY STUDY · ACTUAL CAMPAIGN / PROPOSED STATIC CONTROLS",18)
	panel(Rect2(410,210,1100,650),IVORY)
	text(Vector2(435,248),"ORIN CONSORTIUM",25,DARK)
	text(Vector2(1250,248),"%d Marks" % game.field.marks,23,DARK)
	panel(Rect2(430,273,250,405),DARK)
	var fit: float=minf(230.0/TAVI.get_width(),330.0/TAVI.get_height())
	var extent: Vector2=TAVI.get_size()*fit
	draw_texture_rect(TAVI,Rect2(Vector2(555,462)-extent*0.5,extent),false)
	text(Vector2(449,655),"Tavi Rill",23)
	text(Vector2(435,716),"RELATIONS %+d" % f.relation,22,DARK)
	lines(Vector2(435,745),str(f.reason).replace("trust","relations"),25,DARK)
	panel(Rect2(704,273,784,115),DARK)
	text(Vector2(722,301),"AT WAR" if war else "COMMUNICATIONS" if page=="home" else page.to_upper(),21,AMBER)
	lines(Vector2(722,337),scene.contact_greeting,72)
	if war:
		panel(Rect2(704,410,784,230),DARK)
		text(Vector2(724,448),"Treaties and exchanges suspended",25,AMBER)
		lines(Vector2(724,491),"Review the current conflict and available peace terms.",67)
		panel(Rect2(724,559,330,48),IVORY); text(Vector2(742,590),"Review war and peace",22,DARK)
	elif page=="home":
		var choices: Array=[["Trade","cargo"],["Diplomacy","comms"],["Fleet","fleet"],["Dock services","repair_pack"]]
		for i: int in range(4):
			var r:=Rect2(704+(i%2)*398,410+(i/2)*145,386,130)
			panel(r,DARK); icon(choices[i][1],Rect2(r.position+Vector2(24,28),Vector2(70,70)))
			text(r.position+Vector2(112,74),choices[i][0],25)
	else:
		var ids: Array=["gift","chart","reconcile"] if page=="exchange" else ["trade","non_aggression","alliance"]
		var titles: Dictionary={"trade":"Trade agreement","non_aggression":"Non-aggression","alliance":"Alliance","gift":"Goodwill grant","chart":"License current survey","reconcile":"Reconciliation"}
		var effects: Dictionary={"trade":"Local purchases -10%; sales +10%. Finite stock remains.","non_aggression":"Transit through embargoed territory; markets stay closed.","alliance":"Nearby charts and access to one loaned escort.","gift":"120 Marks / +15 relations. One grant per nation.","chart":"Receive 25 Marks / +8 relations. Exclusive license.","reconcile":"80 Marks / restore negative relations to zero."}
		for i: int in range(3):
			var id: String=ids[i]; var active: bool="consortium:"+id in game.sector.state.agreements
			var reason: String=game.diplomacy.reason(game,"consortium",id)
			var y: float=407+i*124
			panel(Rect2(704,y,784,114),DARK)
			text(Vector2(722,y+28),titles[id]+(" · ACTIVE" if active else ""),22,AMBER if active else IVORY)
			text(Vector2(722,y+55),effects[id],18)
			lines(Vector2(722,y+80),"Benefit in effect" if active else reason if not reason.is_empty() else "Available",56,AMBER)
			panel(Rect2(1254,y+67,218,33),DARK if active else IVORY if reason.is_empty() else Color("727c75"))
			text(Vector2(1263,y+90),"Withdraw / -20 relations" if active else "Offer" if page=="exchange" else "Sign agreement",16,IVORY if active else DARK)
	var tabs: Array=[["Contact","comms"],["Trade","cargo"],["Agreements","category_tools"],["Exchange","housing"],["Fleet","fleet"],["Dock services","repair_pack"]]
	for i: int in range(tabs.size()):
		var r:=Rect2(704+i*55,808,44,32); panel(r,DARK); icon(tabs[i][1],r.grow(-5)); named_regions[tabs[i][0]]=r
		if tabs[i][0].to_lower()==page or (page=="home" and i==0): corners(r.grow(3),AMBER)
	panel(Rect2(1322,804,166,40),DARK); text(Vector2(1350,832),"Goodbye",22)
