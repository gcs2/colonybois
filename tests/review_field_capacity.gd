extends SceneTree
## Review-only Field Instruments capacity layout driven by the actual HUD paging.
const HUD=preload("res://scripts/flight_hud.gd")
const Fixture=preload("res://tests/palette_fixture.gd")
const Session=preload("res://scripts/expedition_session.gd")
const Palette=preload("res://scripts/flight_palette.gd")
const OUT="res://artifacts/field-instruments-review/states"

class Study extends "res://tests/review_field_navigation.gd".Study:
	var hud: Control
	var model: RefCounted
	var background: Texture2D
	var textures: Dictionary={}
	var title: String=""
	var fixture: bool=false
	var ids: Array[String]=[]
	var hover: String=""
	var embedded: bool=false
	func prepare() -> void:
		ids.clear()
		for id: String in hud.GROUPS[hud.active_group]:
			if hud.item_buttons[id].visible: ids.append(id)
			var entry: Dictionary=Palette.entry(id)
			var glyph: String=entry.get("icon","scan")
			if not textures.has(glyph): textures[glyph]=load("res://assets/ui/flight/%s.svg" % glyph)
		for glyph: String in Palette.CATEGORY_ICONS.values():
			if not textures.has(glyph): textures[glyph]=load("res://assets/ui/flight/%s.svg" % glyph)
		queue_redraw()
	func _draw() -> void:
		if background != null: draw_texture_rect(background,Rect2(0,0,1920,1080),false)
		if not embedded:
			label(Vector2(32,48),"Morrow",30)
			housing(Rect2(430,16,1080,38),INK)
			label(Vector2(448,42),"REVIEW ONLY · "+title+(" · SYNTHETIC CAPACITY ITEMS" if fixture else " · ACTUAL PALETTE ENTRIES"),17)
		var panel_height: float=(246 if hud.GROUPS[hud.active_group].size()>9 else 174) if hud.palette_expanded else 78
		var y: float=1056-panel_height
		if embedded and hud.palette_expanded:
			housing(Rect2(1056,y,840,60),PAPER)
			var tray_width: float=minf(9,ids.size())*69+32
			housing(Rect2(1056,y+60,tray_width,panel_height-60),PAPER)
		else: housing(Rect2(1056,y,840,panel_height),PAPER)
		var index: int=0
		for category: String in Palette.GROUPS:
			var r:=Rect2(1072+index*62,y+12,50,42)
			housing(r,INK)
			draw_texture_rect(textures[Palette.CATEGORY_ICONS[category]],r.grow(-7),false)
			if category==hud.active_group: draw_line(r.position+Vector2(5,40),r.end-Vector2(5,2),GOLD,3)
			index+=1
		label(Vector2(1340,y+37),hud.active_group,18,INK)
		var equipped:=Rect2(1496,y+10,48,48)
		housing(equipped,INK)
		draw_texture_rect(hud.item_buttons[hud.selected_tool].icon,equipped.grow(-7),false)
		bracket(equipped.get_center(),23,GOLD)
		label(Vector2(1570,y+30),"HULL %d/%d" % [model.state.hull,model.max_capacity("hull")],14,INK)
		label(Vector2(1740,y+30),"ENERGY %d/%d" % [model.state.energy,model.max_capacity("energy")],14,INK)
		if embedded:
			for i: int in range(2):
				var family: String="hull" if i==0 else "energy"
				var bar:=Rect2(1570+i*170,y+40,138,6)
				draw_rect(bar,INK)
				bar.size.x*=float(model.state[family])/model.max_capacity(family)
				draw_rect(bar,Color("df905f") if i==0 else Color("f3c95f"))
		if not hud.palette_expanded: return
		for i: int in range(ids.size()):
			var id: String=ids[i]
			var r:=Rect2(1072+(i%9)*69,y+66+(i/9)*76,62,68)
			housing(r,INK)
			var entry: Dictionary=Palette.entry(id)
			var tint: Color=Color(1,1,1,0.68) if hud.item_buttons[id].disabled else Color.WHITE
			draw_texture_rect(hud.item_buttons[id].icon,Rect2(r.position+Vector2(10,12),Vector2(42,42)),false,tint)
			label(r.position+Vector2(4,13),hud.count_labels[id].text,12)
			label(r.position+Vector2(4,64),hud.slot_labels[id].text,11,Color("acb9b4"))
			if hud.item_buttons[id].disabled: label(r.position+Vector2(50,14),"!",14,GOLD)
			if id==hud.selected_tool: bracket(r.get_center(),29,GOLD)
			if id==hover: draw_rect(r,LIGHT,false,2)
		if ids.is_empty(): label(Vector2(1072,911),"No entries in this category",20,INK)
		if hud.page_next.visible:
			label(Vector2(1710,y+80),hud.page_label.text,20,INK)
			label(Vector2(1710,y+117),"<",26,Color("90948d") if hud.page_previous.disabled else INK)
			label(Vector2(1790,y+117),">",26,Color("90948d") if hud.page_next.disabled else INK)
		if not hover.is_empty():
			housing(Rect2(1060,y-120,650,102),INK)
			var entry: Dictionary=Palette.entry(hover)
			label(Vector2(1078,y-90),entry.get("title","Layout specimen · preview only"),22)
			label(Vector2(1078,y-59),"Layout test item; not playable content" if fixture else entry.get("summary",""),16)
			var reason: String=Palette.unavailable(hover,model)
			label(Vector2(1078,y-32),reason if not reason.is_empty() else "Hover study · native input not tested",16,GOLD)

func _initialize() -> void: call_deferred("run")
func run() -> void:
	var path: String=ProjectSettings.globalize_path("res://artifacts/field-instruments-review/surface-review-background-v1.png")
	if not FileAccess.file_exists(path): push_error("Missing local concept background"); quit(1); return
	var texture:=ImageTexture.create_from_image(Image.load_from_file(path))
	var records: Array=[]
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		for mode: String in ["tools","weapons","inventory","dense-first","dense-last","collapsed"]:
			var hud:=HUD.new(); root.add_child(hud); hud.hide()
			var game:=Session.new(); game.field.state.energy=65
			hud.refresh_items(game.field,false)
			var fixture: bool=mode.begins_with("dense") or mode=="collapsed"
			if fixture: Fixture.populate(hud)
			elif mode=="weapons": hud.show_group("Weapons")
			elif mode=="inventory": hud.show_group("Inventory")
			else: hud.show_group("Main tools")
			if mode=="dense-last": hud._internal_action("page_next")
			if mode=="collapsed": hud._internal_action("palette_toggle")
			var view:=SubViewport.new(); view.size=resolution; view.size_2d_override=Vector2i(1920,1080); view.size_2d_override_stretch=true
			view.render_target_update_mode=SubViewport.UPDATE_ALWAYS; view.gui_disable_input=true; root.add_child(view)
			var study:=Study.new(); study.hud=hud; study.model=game.field; study.background=texture; study.fixture=fixture; study.title=mode.to_upper(); view.add_child(study)
			study.hover="seeker" if mode=="weapons" else ("pack" if mode=="inventory" else "")
			study.prepare()
			assert(study.ids.size()<=18 and hud.selected_tool=="scan")
			if mode=="dense-first": assert(study.ids.size()==18)
			if mode=="dense-last": assert(study.ids.size()==9)
			if mode=="collapsed": assert(study.ids.is_empty())
			for frame: int in range(3): await process_frame
			await RenderingServer.frame_post_draw
			var file: String="%s/capacity-%s-%d.png" % [OUT,mode,resolution.x]
			assert(view.get_texture().get_image().save_png(file)==OK)
			records.append({"state":mode,"image":file,"visible_ids":study.ids.duplicate(),"synthetic":fixture,"selected_tool":hud.selected_tool})
			view.free(); hud.free()
	var record:=FileAccess.open(OUT+"/capacity-evidence.json",FileAccess.WRITE)
	record.store_string(JSON.stringify({"kind":"review layout over static concept world; actual HUD paging; no native input","records":records},"\t"))
	print("Capacity review:12 images; paging and selected-tool invariants pass."); quit()
