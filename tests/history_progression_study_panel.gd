extends "res://tests/diplomacy_study_panel.gd"
const Recognition=preload("res://scripts/expedition_progression.gd")
const UI=preload("res://scripts/flight_interface.gd")
func _draw() -> void:
	panel(Rect2(24,20,1110,36),DARK); text(Vector2(38,45),"HISTORY / BADGES STUDY · ACTUAL STATE / STATIC PROPOSED CONTROLS",18)
	panel(Rect2(380,200,1160,660),IVORY)
	text(Vector2(405,245),"CHRONICLE" if stage.begins_with("history") else "EQUIPMENT" if stage=="upgrade-eligible-poor" else "BADGES AND UNLOCKS",27,DARK)
	text(Vector2(1290,245),"%d Marks" % game.field.marks,22,DARK)
	if stage.begins_with("history"): draw_history()
	elif stage=="upgrade-eligible-poor": draw_equipment()
	else: draw_badges()
	panel(Rect2(1360,801,156,38),DARK); text(Vector2(1390,828),"Close",21)
func draw_history() -> void:
	var filter: String=scene.chronicle_filter
	var entries: Array=game.diplomacy.state.events.duplicate(true)
	if filter=="diplomacy": entries=entries.filter(func(e: Dictionary) -> bool: return e.kind in ["contact","diplomacy"])
	elif filter!="all": entries=entries.filter(func(e: Dictionary) -> bool: return e.kind==filter)
	entries.reverse()
	var filters: Array=["all","diplomacy","trade","exploration","encounter","war","local"]
	for i: int in range(filters.size()):
		var r:=Rect2(405+i*158,272,147,34); panel(r,DARK); text(r.position+Vector2(10,24),filters[i].capitalize(),18)
		if filters[i]==filter: corners(r.grow(2),AMBER)
	if entries.is_empty():
		panel(Rect2(405,337,1110,420),DARK)
		text(Vector2(435,389),"No recorded events yet" if filter=="all" else "No %s events" % filter.capitalize(),27)
		lines(Vector2(435,434),"Your discoveries and decisions will appear here." if filter=="all" else "Other events are still recorded. Show All to return to the full history.",80)
		if filter!="all": panel(Rect2(435,512,200,42),IVORY); text(Vector2(451,541),"Show All",22,DARK)
		return
	# Five-item proposal pages keep selected event and causal context visible.
	var page_index: int=mini(scene.chronicle_page,(entries.size()-1)/5)
	var start: int=page_index*5
	var shown: Array=entries.slice(start,start+5)
	text(Vector2(405,332),"%d-%d of %d / page %d of %d" % [start+1,start+shown.size(),entries.size(),page_index+1,ceili(entries.size()/5.0)],19,DARK)
	for i: int in range(shown.size()):
		var entry: Dictionary=shown[i]; var r:=Rect2(405,351+i*78,515,69); panel(r,DARK)
		text(r.position+Vector2(13,23),"%02d:%02d / %s" % [int(entry.time)/60,int(entry.time)%60,str(entry.kind).capitalize()],17,AMBER)
		text(r.position+Vector2(13,49),str(entry.summary).left(48)+( "..." if str(entry.summary).length()>48 else ""),18)
		if i==0: corners(r.grow(2),AMBER)
	var selected_event: Dictionary=shown[0]
	panel(Rect2(941,351,575,390),DARK)
	text(Vector2(964,387),"EVENT / "+str(selected_event.kind).to_upper(),23)
	lines(Vector2(964,430),str(selected_event.summary),53)
	text(Vector2(964,539),"Location: "+str(preload("res://scripts/planet_geography.gd").definition(selected_event.location).name),18)
	if selected_event.cause>0:
		text(Vector2(964,582),"FOLLOWING",18,AMBER)
		lines(Vector2(964,617),str(game.diplomacy.state.events[selected_event.cause-1].summary),53)
	panel(Rect2(405,801,156,38),DARK); text(Vector2(428,828),"Newer",20,IVORY if page_index>0 else Color("727c75"))
	panel(Rect2(579,801,156,38),DARK); text(Vector2(606,828),"Older",20,IVORY if start+shown.size()<entries.size() else Color("727c75"))
func draw_badges() -> void:
	var tiers: Dictionary=game.commerce.state.badges
	var selected_badge: String="explorer" if game.recognition.state.pinned.is_empty() else game.recognition.state.pinned
	text(Vector2(405,284),Recognition.title(tiers)+" / %d badge points" % Recognition.points(tiers),22,DARK)
	var rank: int=Recognition.rank(tiers)
	text(Vector2(984,284),"Highest rank" if rank==10 else "Next: %s / %d points" % [Recognition.catalog.rank_names[rank],Recognition.catalog.rank_points[rank]],20,DARK)
	var ids: Array=game.commerce.catalog.badges.keys()
	for i: int in range(ids.size()):
		var id: String=ids[i]; var b: Dictionary=game.commerce.catalog.badges[id]
		var r:=Rect2(405+(i%4)*139,315+(i/4)*140,128,130); panel(r,DARK)
		draw_texture_rect(UI.icon(b.icon),Rect2(r.position+Vector2(36,12),Vector2(56,56)),false)
		text(r.position+Vector2(8,91),str(b.name),16)
		text(r.position+Vector2(8,116),"Tier %d / 5" % tiers[id],17,AMBER)
		if id==selected_badge: corners(r.grow(2),AMBER)
	var badge: Dictionary=game.commerce.catalog.badges[selected_badge]
	panel(Rect2(984,315,532,445),DARK)
	text(Vector2(1003,350),badge.name+" / tier %d" % tiers[selected_badge],25,AMBER)
	lines(Vector2(1003,389),badge.description,48)
	text(Vector2(1003,476),"Complete" if tiers[selected_badge]==5 else "Toward tier %d: %d / %d" % [tiers[selected_badge]+1,game.commerce.progress(game,selected_badge),badge.levels[mini(tiers[selected_badge],4)]],20)
	var item: Dictionary=game.commerce.catalog.upgrades.hold
	text(Vector2(1003,523),item.name+" / %d Marks" % item.price,23)
	text(Vector2(1003,558),"Badge requirement met" if game.commerce.eligible("hold") else "Requires Merchant 1, Explorer 2 or Naturalist 1",17,AMBER)
	var reason: String=game.commerce.upgrade_reason(game,"basin_port",scene.ship.position,"hold")
	lines(Vector2(1003,595),reason if not reason.is_empty() else "Available at this dock",48,AMBER)
	text(Vector2(1003,647),"Freight capacity: 8 to 16. Bought separately.",18)
	panel(Rect2(1003,693,265,40),IVORY); text(Vector2(1016,721),"Inspect in equipment",20,DARK)
	text(Vector2(405,781),"Recognition grants eligibility; equipment is not awarded free.",19,DARK)
	panel(Rect2(405,801,260,38),DARK); text(Vector2(419,828),"Unpin selected progress" if not game.recognition.state.pinned.is_empty() else "Pin selected progress",20)

func draw_equipment() -> void:
	var item: Dictionary=game.commerce.catalog.upgrades.hold
	panel(Rect2(405,295,330,450),DARK)
	icon("cargo",Rect2(475,352,180,180))
	text(Vector2(431,590),"Expanded cargo hold",24)
	text(Vector2(431,632),"Not installed",21,AMBER)
	panel(Rect2(759,295,757,450),DARK)
	text(Vector2(783,338),item.name,28)
	lines(Vector2(783,383),item.flavor,69)
	lines(Vector2(783,450),item.description,69)
	text(Vector2(783,538),"Badge requirement met / Naturalist 1",22,AMBER)
	text(Vector2(783,581),"Price: %d Marks / treasury: %d Marks" % [item.price,game.field.marks],22)
	var reason: String=game.commerce.upgrade_reason(game,"basin_port",scene.ship.position,"hold")
	text(Vector2(783,625),reason,21,AMBER)
	panel(Rect2(783,681,270,42),Color("727c75")); text(Vector2(801,710),"Buy / %d Marks" % item.price,22,DARK)
	panel(Rect2(405,801,260,38),DARK); text(Vector2(425,828),"Back to badges",20)
