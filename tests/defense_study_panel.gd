extends "res://tests/diplomacy_study_panel.gd"
## Static domestic-defense proposal. No simulated command handlers.
func _ready() -> void:
	super._ready()
	icons["defense"]=load("res://assets/ui/flight/defense.svg")
func _draw() -> void:
	var war: RefCounted=game.conflict
	var site: Dictionary=war.site("morrow")
	var raid: Dictionary=war.state.raid
	var nation: Dictionary=war.nation("directorate")
	panel(Rect2(24,20,1090,36),DARK); text(Vector2(38,45),"DEFENSE STUDY · ACTUAL STATE / STATIC PROPOSED CONTROLS",18)
	panel(Rect2(425,210,1070,650),IVORY)
	text(Vector2(449,251),"MORROW / PORT DEFENSE",25,DARK)
	text(Vector2(1050,251),"%d Marks / %d local materials" % [game.field.marks,game.sector.state.colonies.s0p0.materials],20,DARK)
	panel(Rect2(449,274,1022,140),DARK)
	var headline: String="No active raid"
	var detail: String="Prepare defenses or return to exploration."
	if not raid.is_empty():
		headline="DIRECTORATE RAID / "+("INBOUND %d s" % (raid.arrival-game.field.state.time) if raid.phase=="inbound" else "BOMBARDMENT ACTIVE")
		detail="Target: Morrow. Intercept in orbit or negotiate peace."
		if raid.phase=="attacking": detail="Next bombardment in %d s / 20 integrity damage. Intercept or negotiate peace." % maxi(0,raid.bombard-game.field.state.time)
	elif nation.warning>game.field.state.time:
		headline="DIRECTORATE WAR WARNING / %d s" % (nation.warning-game.field.state.time)
		detail="Relations %d. Improve above -50 before the deadline to avert war." % game.sector.faction_by_id("directorate").relation
	elif site.integrity==0:
		headline="PORT DISABLED / RAID DEPARTED"
		detail="Exports and ship services are unavailable until repairs."
	elif stage=="defended":
		headline="RAID DEFEATED"
		detail="Remaining port damage and ammunition expenditure persist."
	elif stage=="peace-withdrawn":
		headline="RAID WITHDRAWN / PEACE AGREED"
		var paid: int=0
		for event: Dictionary in game.diplomacy.state.events:
			if event.kind=="war" and event.outcome.has("truce_until"): paid=-int(event.outcome.marks_delta)
		detail="Paid %d Marks. Port damage remains; no defense victory awarded." % paid
	elif stage=="repaired":
		headline="PORT REPAIRED"
		detail="Exports and ship services restored. War has not ended."
	text(Vector2(470,310),headline,25,AMBER)
	lines(Vector2(470,346),detail,91)
	text(Vector2(470,391),"AT WAR" if nation.war else "TRUCE %d s" % (nation.truce-game.field.state.time) if nation.truce>game.field.state.time else "PEACE",18)
	panel(Rect2(449,432,310,329),DARK)
	icon("defense",Rect2(470,455,60,60)); text(Vector2(543,489),"INTEGRITY",21)
	text(Vector2(470,551),"%d / 100" % site.integrity,32,AMBER)
	draw_rect(Rect2(470,566,265,12),Color("48504c")); draw_rect(Rect2(470,566,265*site.integrity/100.0,12),AMBER)
	text(Vector2(470,623),"BATTERY",21)
	text(Vector2(470,659),"%d / 12 rounds" % site.ammo if site.battery else "Not commissioned",24)
	if site.battery:
		for round_index: int in range(12): draw_rect(Rect2(470+round_index*22,675,17,9),AMBER if round_index<site.ammo else Color("48504c"))
	lines(Vector2(470,706),"12 damage / 6 seconds. Ammunition is finite." if site.battery else "Commission before a raid arrives.",27)
	var ids: Array=["rearm" if site.battery else "battery","repair"]
	if site.integrity==0: ids.reverse()
	for i: int in range(2):
		var id: String=ids[i]; var y: float=432+i*166
		var reason: String=war.reason(game,"s0p0",id)
		panel(Rect2(779,y,692,155),DARK)
		text(Vector2(799,y+30),"Rearm to 12 rounds" if id=="rearm" else "Commission battery / 12 rounds" if id=="battery" else "Repair port to 100 integrity",23)
		text(Vector2(799,y+60),"%d Marks / %d Morrow materials" % [war.data[id+"_marks"],war.data[id+"_materials"]],19)
		lines(Vector2(799,y+89),reason if not reason.is_empty() else "Available",57,AMBER)
		panel(Rect2(1250,y+110,201,32),IVORY if reason.is_empty() else Color("727c75")); text(Vector2(1264,y+133),"Commission" if id=="battery" else id.capitalize(),18,DARK)
	var nav: Array=[["Communications","comms"],["Colony overview","cargo"]]
	if not raid.is_empty(): nav.push_front(["Plot response route to Morrow","system_view"])
	for i: int in range(nav.size()):
		var r:=Rect2(449+i*58,806,44,32); panel(r,DARK)
		if not icons.has(nav[i][1]): icons[nav[i][1]]=load("res://assets/ui/flight/%s.svg" % nav[i][1])
		icon(nav[i][1],r.grow(-5)); named_regions[nav[i][0]]=r
	if not raid.is_empty() or nation.warning>game.field.state.time:
			named_regions.clear()
			panel(Rect2(449,796,810,48),IVORY)
			var actions: Array=["Contact Directorate"] if raid.is_empty() else ["Plot route to Morrow","Contact for peace"]
			for i: int in range(actions.size()):
				var r:=Rect2(449+i*282,802,268,38); panel(r,DARK); text(r.position+Vector2(12,26),actions[i],20); named_regions[actions[i]]=r
	panel(Rect2(1320,801,151,40),DARK); text(Vector2(1350,829),"Close",21)
