extends "res://tests/diplomacy_study_panel.gd"
const Art=preload("res://scripts/communicator_style.gd")
func _ready() -> void:
	super._ready()
	var aperture:=Control.new(); aperture.position=Vector2(572,223); aperture.size=Vector2(441,567); aperture.clip_contents=true; aperture.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(aperture)
	var portrait:=TextureRect.new(); portrait.texture=TAVI; portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.position=Vector2(0,32); portrait.size=Vector2(441,535); portrait.mouse_filter=Control.MOUSE_FILTER_IGNORE; aperture.add_child(portrait)
func bevel(r: Rect2, face: Color, depth: float=3) -> void:
	panel(Rect2(r.position+Vector2(0,depth),r.size),Color("080c0e"))
	panel(r,face,Color("797c72"))
	draw_line(r.position+Vector2(10,1),Vector2(r.end.x-10,r.position.y+1),face.lightened(.26),1,true)
	draw_line(Vector2(r.end.x-1,r.position.y+10),r.end-Vector2(1,10),face.darkened(.4),2,true)
func _draw() -> void:
	panel(Rect2(24,20,1190,36),DARK); text(Vector2(38,45),"FIDELITY STUDY · ENGINE WORLD / EXISTING ART · STATIC PROPOSED COMMUNICATOR",18)
	var frame:=Rect2(540,190,1260,670)
	for i: int in range(6,0,-1): panel(Rect2(frame.position+Vector2(0,6+i),frame.size+Vector2(i,0)),Color(0,0,0,.035))
	bevel(frame,Color("c9c4b4"),7)
	bevel(frame.grow(-4),Color("e1ddcf"),2)
	var grain:=RandomNumberGenerator.new(); grain.seed=804
	for i: int in range(1800):
		var at:=Vector2(grain.randf_range(545,1795),grain.randf_range(194,855))
		if at.x<560 or at.x>1780 or at.y<211 or at.y>834: draw_circle(at,grain.randf_range(.25,.65),Color(.27,.28,.24,.14),true,-1,true)
	# Narrow physical rim and continuous recessed display, rather than ivory gutters.
	bevel(Rect2(563,214,1214,617),Color("111b20"),2)
	var portrait:=Rect2(572,223,441,599)
	panel(portrait,Color("182324"))
	# Architectural depth behind the approved existing portrait; no new character art.
	draw_colored_polygon(PackedVector2Array([Vector2(572,223),Vector2(633,261),Vector2(633,788),Vector2(572,822)]),Color("354344"))
	draw_colored_polygon(PackedVector2Array([Vector2(1013,223),Vector2(965,261),Vector2(965,788),Vector2(1013,822)]),Color("263438"))
	for x: float in [605,977]:
		draw_rect(Rect2(x,260,9,493),Color("0c1317")); draw_rect(Rect2(x+2,282,3,92),Color("929e91"))
	for y: float in [313,470,628]: draw_line(Vector2(634,y),Vector2(965,y),Color("344446"),2)
	draw_rect(Rect2(741,247,126,5),Color("d2b58c"))
	bevel(Rect2(572,704,441,118),Color("303b3d"))
	draw_colored_polygon(PackedVector2Array([Vector2(583,705),Vector2(1002,705),Vector2(980,737),Vector2(606,737)]),Color("465251"))
	draw_line(Vector2(606,738),Vector2(980,738),Color("77827b"),1)
	draw_rect(Rect2(1017,213,12,620),Color("b8b6a9")); draw_line(Vector2(1018,216),Vector2(1018,830),IVORY,2)
	var f: Dictionary=game.sector.faction_by_id("consortium")
	text(Vector2(1060,270),"Tavi Rill",34)
	text(Vector2(1060,302),"Orin Consortium",22,Color("b9c9c9"))
	text(Vector2(1535,266),"Relations %+d" % f.relation,20,Color("9bc6a2"))
	for i: int in range(8): draw_rect(Rect2(1537+i*22,283,17,10),Color("77aa8f") if i<int(clampf((f.relation+100)/25.0,0,8)) else Color("384246"))
	draw_line(Vector2(1060,323),Vector2(1744,323),Color("536362"),1)
	lines(Vector2(1060,363),scene.contact_greeting if page=="home" else "Agreements / shared commitments",65)
	if page=="home":
		for i: int in range(4):
			var r:=Rect2(1058+(i%2)*349,435+(i/2)*145,333,127)
			bevel(r,Color("243034"),3)
			draw_texture_rect(Art.action_icon(i),Rect2(r.position+Vector2(9,7),Vector2(118,112)),false)
			text(r.position+Vector2(141,70),["Trade","Diplomacy","Fleet","Dock services"][i],23)
	else:
		var ids: Array=["trade","non_aggression","alliance"]
		for i: int in range(3):
			var y: float=427+i*106
			var id: String=ids[i]; var reason: String=game.diplomacy.reason(game,"consortium",id)
			draw_line(Vector2(1060,y+97),Vector2(1744,y+97),Color("3b4b4e"),1)
			draw_texture_rect(Art.action_icon(1),Rect2(1058,y+5,72,72),false)
			text(Vector2(1145,y+28),["Trade agreement","Non-aggression","Alliance"][i],23)
			text(Vector2(1145,y+55),["Purchases −10% / sales +10%","Passage allowed / markets stay closed","Nearby charts / one loaned escort"][i],18,Color("b9c9c9"))
			text(Vector2(1145,y+81),reason if not reason.is_empty() else "Available",17,AMBER)
			bevel(Rect2(1635,y+9,109,34),Color("747e72") if reason.is_empty() else Color("303b3e"))
			text(Vector2(1651,y+33),"Sign",19,IVORY if reason.is_empty() else Color("899395"))
	# Mounted exit, sparse seams and fasteners; no glossy metallic borders.
	draw_colored_polygon(PackedVector2Array([Vector2(1568,832),Vector2(1568,795),Vector2(1596,764),Vector2(1777,764),Vector2(1777,832)]),Color("d1ccbd"))
	draw_polyline(PackedVector2Array([Vector2(1568,831),Vector2(1568,795),Vector2(1596,764),Vector2(1777,764)]),Color("f0ecdf"),2,true)
	bevel(Rect2(1599,780,145,39),Color("263236")); text(Vector2(1627,807),"Goodbye",22)
	if page!="home":
		bevel(Rect2(1058,777,158,42),Color("243034")); text(Vector2(1073,805),"‹  Contact",20)
	else: text(Vector2(1060,808),"Connected / Orin channel",18,Color("b9c9c9"))
	for at: Vector2 in [Vector2(552,213),Vector2(1788,213),Vector2(552,837),Vector2(1788,837)]:
		draw_circle(at,3,Color("7c8075")); draw_line(at-Vector2(1,1),at+Vector2(1,1),Color("313c39"),1)
	for x: float in [1019,1700]: draw_line(Vector2(x,192),Vector2(x,207),Color("737a71"),2)
	bevel(Rect2(1320,951,540,90),Color("d8d4c5"))
	text(Vector2(1340,981),"HULL",17,DARK); text(Vector2(1340,1015),"ENERGY",17,DARK)
	for row: int in range(2):
		var amount: int=game.field.state.hull if row==0 else game.field.state.energy
		bevel(Rect2(1414,961+row*34,144,27),Color("10191d"),1)
		for i: int in range(10): draw_rect(Rect2(1422+i*13,966+row*34,9,17),(Color("dc9870") if row==0 else AMBER) if i<amount/10 else DARK)
		text(Vector2(1568,981+row*34),str(amount),18,DARK)
	text(Vector2(1661,998),"%d Marks" % game.field.marks,23,DARK)
