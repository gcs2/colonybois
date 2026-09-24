extends "res://tests/service_study_panel.gd"
## Static review overlay. Commands remain in the paired actual-state harness.
func _draw() -> void:
	panel(Rect2(24,20,1050,36),DARK)
	text(Vector2(38,45),"PAUSE / SETTINGS STUDY · PROPOSED LAYOUT · STATIC CONTROLS",18)
	var wide: bool=stage=="controls"
	var left: float=360 if wide else 630
	var width: float=1200 if wide else 660
	panel(Rect2(left,190,width,700),IVORY)
	text(Vector2(left+28,236),"FLIGHT CONTROLS" if wide else "AUDIO" if stage.begins_with("audio") else "EXPEDITION PAUSED",27,DARK)
	text(Vector2(left+28,271),"Morrow / surface · simulation paused",18,DARK)
	if wide: controls_sheet(left)
	elif stage.begins_with("audio"): audio_sheet(left)
	else: menu_sheet(left)
	var submenu: bool=wide or stage.begins_with("audio")
	panel(Rect2(left+24,824,width-48,44),DARK if submenu else AMBER)
	text(Vector2(left+42,854),"Back to menu   /   Esc" if submenu else "Resume expedition   /   Esc",22,IVORY if submenu else DARK)
func menu_sheet(x: float) -> void:
	var failure: bool=stage in ["load-missing","load-corrupt"]
	panel(Rect2(x+24,298,612,144),DARK)
	if failure:
		text(Vector2(x+42,331),"SAVE NOT FOUND" if stage=="load-missing" else "SAVE COULD NOT BE READ",23,AMBER)
		text(Vector2(x+42,365),"Your current expedition is unchanged.",20)
		text(Vector2(x+42,395),"No manual save exists here." if stage=="load-missing" else "This file is not a recognized campaign save.",18)
		text(Vector2(x+42,423),"Save expedition to create a manual checkpoint." if stage=="load-missing" else "Resume to continue this expedition.",18)
	else:
		text(Vector2(x+42,333),"EXPEDITION SAVED" if stage=="save-success" else "EXPEDITION RESTORED" if stage=="load-success" else "READY WHEN YOU ARE",24)
		text(Vector2(x+42,373),"One campaign: ship, colonies, relationships and cargo.",18)
		text(Vector2(x+42,411),"No time passes while this menu is open.",18,AMBER)
	button_box(Rect2(x+24,462,294,54),"Save expedition", "F5")
	button_box(Rect2(x+338,462,298,54),"Retry load" if failure else "Load expedition","F9")
	text(Vector2(x+24,555),"REFERENCE AND SETTINGS",17,DARK)
	for i: int in range(4):
		button_box(Rect2(x+24+(i%2)*314,575+(i/2)*61,298,49),["Chronicle","Badges","Controls","Audio"][i],"")
	draw_line(Vector2(x+24,726),Vector2(x+636,726),DARK,1)
	text(Vector2(x+24,760),"LEAVE SESSION",17,DARK)
	button_box(Rect2(x+338,745,298,49),"Return to title","")
func button_box(r: Rect2, caption: String, key: String) -> void:
	panel(r,DARK); text(r.position+Vector2(15,33),caption,21)
	if not key.is_empty(): text(r.position+Vector2(r.size.x-42,33),key,17,AMBER)
func controls_sheet(x: float) -> void:
	var columns: Array=[
		["POINT AND INTERACT",["Fly to a point","Click terrain","Approach / use tool","Click a subject","Land from orbit","Click a planet","Select equipment","Click a tool icon","Inventory / equipment","I / K","Communicate","Y","Tool categories","Tab / Shift + Tab","Tool slots: first / second row","1–9 / Ctrl + 1–9","Attack a target","Select Weapon, then click enemy","Recover salvage","Click wreck or Salvage"]],
		["FLIGHT",["Move ship","Arrows / WASD / numpad 8,4,2,6","Ascend","Home / PgUp / numpad 9,+ / E","Descend","End / PgDn / numpad 3,− / Q","Brake","Numpad 5 or 0 / Stop","Pause simulation","Space","Optional tool hold","F","Save / load","F5 / F9"]],
		["CAMERA AND MAPS",["Zoom camera","Mouse wheel","Change altitude","Ctrl + wheel","Rotate camera","Right drag","Galaxy / planet overview","G / M","Leave the surface","Zoom out past surface limit","Cancel ascent","Scroll in during ascent","Begin orbital landing approach","Descend","Cancel landing approach","Scroll out / Stop"]]]
	for col: int in range(3):
		var cx: float=x+24+col*388
		panel(Rect2(cx,302,372,485),DARK)
		text(Vector2(cx+16,334),columns[col][0],20,AMBER)
		var entries: Array=columns[col][1]
		for i: int in range(0,entries.size(),2):
			text(Vector2(cx+16,363+(i/2)*42),entries[i],18)
			text(Vector2(cx+16,383+(i/2)*42),entries[i+1],16,Color("b8c8c1"))
	text(Vector2(x+24,810),"Windows primary mouse button is respected. Rebinding and accessibility controls are not implemented.",17,DARK)
func audio_sheet(x: float) -> void:
	var channels: Array=["sfx","music","voice"]
	for i: int in range(3):
		var y: float=312+i*122; var value: int=roundi(float(scene.audio.mix[channels[i]])*100)
		panel(Rect2(x+24,y,612,106),DARK)
		text(Vector2(x+42,y+30),["Effects","Music","Guide voice"][i],23)
		text(Vector2(x+446,y+30),"Not installed" if i==2 else "Muted" if value==0 else "%d%%" % value,20,AMBER)
		if i==2:
			text(Vector2(x+42,y+65),"Recorded guide voice is not available in this build.",18)
			text(Vector2(x+42,y+89),"Guide captions remain available.",17)
		else:
			draw_line(Vector2(x+44,y+67),Vector2(x+590,y+67),Color("68736d"),5)
			draw_line(Vector2(x+44,y+67),Vector2(x+44+546*value/100.0,y+67),AMBER,5)
			draw_rect(Rect2(x+38+546*value/100.0,y+56,12,22),IVORY)
	button_box(Rect2(x+24,701,612,48),"Preview unavailable / effects muted" if scene.audio.mix.sfx==0 else "Preview tool sound effects","")
	text(Vector2(x+24,781),"Volume preferences save separately from your campaign.",18,DARK)
