extends SceneTree
## Review-only UI prototype. Static concept world; never loaded by the game.
const Model = preload("res://scripts/encounter_state.gd")
const Palette = preload("res://scripts/flight_palette.gd")
const FONT = preload("res://assets/fonts/Barlow-Regular.ttf")
const OUT := "res://artifacts/field-instruments-review/states"

class InventoryStudy extends Control:
	const FONT = preload("res://assets/fonts/Barlow-Regular.ttf")
	const Palette = preload("res://scripts/flight_palette.gd")
	var model: RefCounted
	var background: Texture2D
	var hover_id := ""
	var focus_id := ""
	var feedback := ""
	var buttons: Dictionary = {}
	var icons: Dictionary = {}
	var tooltip_bounds := Rect2(1122,734,374,106)
	var instrument_bounds := Rect2(1200,896,696,160)
	var chart_bounds := Rect2(24,864,208,192)
	const IVORY := Color("dedbcd")
	const DARK := Color("242b2a")
	const LIGHT := Color("f5f1e7")
	const AMBER := Color("e9bc55")
	const IDS := ["pack","repair_pack","mega_repair_pack"]
	func _ready() -> void:
		for key: String in ["energy_pack","repair_pack","mega_repair_pack","scan","category_tools","category_life","category_weapons","inventory","comms"]:
			icons[key] = load("res://assets/ui/flight/%s.svg" % key)
		var supply_image:=Image.load_from_file(ProjectSettings.globalize_path("res://artifacts/field-instruments-review/supply-portraits-v1.png"))
		var supply_texture:=ImageTexture.create_from_image(supply_image)
		var cell: Vector2=supply_texture.get_size()/Vector2(3,1)
		for index: int in range(3):
			var portrait:=AtlasTexture.new(); portrait.atlas=supply_texture
			portrait.region=Rect2(Vector2(index*cell.x,0),cell)
			icons[["energy_pack","repair_pack","mega_repair_pack"][index]]=portrait
		for i: int in range(IDS.size()):
			var id: String = IDS[i]
			var button := Button.new()
			button.position = slot_rect(i).position; button.size = slot_rect(i).size
			button.flat = true; button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			for state: String in ["normal","hover","pressed","focus"]:
				button.add_theme_stylebox_override(state,StyleBoxEmpty.new())
			button.mouse_entered.connect(func() -> void: hover_id=id; queue_redraw())
			button.mouse_exited.connect(func() -> void: hover_id=""; queue_redraw())
			button.focus_entered.connect(func() -> void: focus_id=id; queue_redraw())
			button.focus_exited.connect(func() -> void: focus_id=""; queue_redraw())
			button.pressed.connect(func() -> void:
				var error: String = model.use_energy_pack() if id == "pack" else model.use_repair_pack(id)
				feedback = error if not error.is_empty() else ("Energy pack used" if id == "pack" else "Repair pack used")
				queue_redraw())
			add_child(button); buttons[id]=button
		var equipped:=Button.new()
		equipped.position=Vector2(1482,935); equipped.size=Vector2(62,62); equipped.flat=true
		equipped.mouse_entered.connect(func() -> void: hover_id="scan"; queue_redraw())
		equipped.mouse_exited.connect(func() -> void: hover_id=""; queue_redraw())
		for state: String in ["normal","hover","pressed","focus"]: equipped.add_theme_stylebox_override(state,StyleBoxEmpty.new())
		add_child(equipped)
	func slot_rect(index: int) -> Rect2:
		return Rect2(1218+index*74,925,66,88)
	func poly(rect: Rect2, cut: float = 9.0) -> PackedVector2Array:
		var p: Vector2=rect.position; var e: Vector2=rect.end
		return PackedVector2Array([p+Vector2(cut,0),Vector2(e.x-cut,p.y),Vector2(e.x,p.y+cut),e-Vector2(0,cut),e-Vector2(cut,0),Vector2(p.x+cut,e.y),Vector2(p.x,e.y-cut),p+Vector2(0,cut)])
	func panel(rect: Rect2, color: Color, edge: Color = Color.TRANSPARENT) -> void:
		draw_colored_polygon(poly(rect),color)
		if edge.a > 0:
			var points:=poly(rect); points.append(points[0]); draw_polyline(points,edge,1.0,true)
	func text(at: Vector2, value: String, font_size: int = 18, color: Color = LIGHT) -> void:
		draw_string(FONT,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,color)
	func icon(key: String, rect: Rect2, tint: Color = Color.WHITE) -> void:
		draw_texture_rect(icons[key],rect,false,tint)
	func reason(id: String) -> String:
		if id=="scan": return ""
		return model.pack_reason() if id == "pack" else model.repair_pack_reason(id)
	func corners(rect: Rect2, color: Color) -> void:
		for point: Vector2 in [rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]:
			var xdir: float=1.0 if point.x == rect.position.x else -1.0
			var ydir: float=1.0 if point.y == rect.position.y else -1.0
			draw_line(point,point+Vector2(xdir*12,0),color,2,true)
			draw_line(point,point+Vector2(0,ydir*12),color,2,true)
	func _draw() -> void:
		if background == null: return
		draw_texture_rect(background,Rect2(0,0,1920,1080),false)
		text(Vector2(32,48),"Morrow",32)
		text(Vector2(34,73),"SURFACE",16)
		panel(Rect2(724,18,475,30),Color(0.08,0.10,0.10,0.76))
		text(Vector2(739,39),"DESIGN STUDY  /  STATIC CONCEPT WORLD",16)
		panel(Rect2(1760,22,136,40),DARK)
		text(Vector2(1776,49),"%d Marks" % int(model.marks),20)
		# The schematic deliberately makes no geographic-alignment claim.
		panel(chart_bounds,IVORY,Color("a8aca1"))
		panel(Rect2(34,874,188,151),DARK)
		var lake:=PackedVector2Array([Vector2(57,931),Vector2(83,909),Vector2(121,922),Vector2(130,944),Vector2(104,963),Vector2(70,957)])
		draw_colored_polygon(lake,Color("427a79"))
		lake.append(lake[0]); draw_polyline(lake,Color("7db0a4"),1.5,true)
		draw_colored_polygon(PackedVector2Array([Vector2(126,978),Vector2(120,993),Vector2(133,990)]),LIGHT)
		draw_circle(Vector2(181,923),6,AMBER,false,2,true)
		draw_line(Vector2(151,1009),Vector2(207,1009),LIGHT,2)
		text(Vector2(166,1002),"50 m",14)
		text(Vector2(40,1045),"LOCAL CHART",16,DARK)
		# One housing; categories and consumables are deliberately distinct.
		panel(Rect2(instrument_bounds.position+Vector2(0,4),instrument_bounds.size),Color("575e55"))
		panel(instrument_bounds,IVORY,Color("a8aca1"))
		draw_line(instrument_bounds.position+Vector2(12,2),Vector2(instrument_bounds.end.x-12,instrument_bounds.position.y+2),Color("f4f0e5"),1)
		for anchor: Vector2 in [Vector2(1209,910),Vector2(1209,1041),Vector2(1885,910),Vector2(1885,1041)]:
			draw_circle(anchor,2,Color("70766c"),true,-1,true)
		var categories:= ["category_tools","category_life","category_weapons","inventory"]
		for i: int in range(4):
			var r:=Rect2(1218+i*62,856,56,40)
			panel(r,DARK,AMBER if i==3 else Color("999e94"))
			icon(categories[i],Rect2(r.position+Vector2(13,6),Vector2(28,28)))
			if i==3: draw_line(r.position+Vector2(8,36),r.position+Vector2(48,36),AMBER,3)
		text(Vector2(1220,919),"INVENTORY",14,DARK)
		for i: int in range(3):
			var id: String=IDS[i]; var rect:=slot_rect(i)
			var unavailable: bool=not reason(id).is_empty()
			panel(rect,DARK,Color("777d73"))
			var icon_id: String="energy_pack" if id=="pack" else id
			icon(icon_id,Rect2(rect.position+Vector2(3,3),Vector2(60,60)),Color("858e83") if unavailable else Color.WHITE)
			text(rect.position+Vector2(42,80),str(model.state.energy_packs if id=="pack" else model.state.repair_packs[id]),18)
			if id=="pack" and model.state.time < model.state.pack_ready_at and model.state.energy_packs>0:
				panel(Rect2(rect.position+Vector2(4,24),Vector2(58,27)),Color(0.08,0.09,0.09,0.92))
				text(rect.position+Vector2(21,44),"%ds" % int(model.state.pack_ready_at-model.state.time),18)
			if hover_id==id: panel(rect.grow(2),Color.TRANSPARENT,LIGHT)
			if focus_id==id:
				draw_rect(rect.grow(5),DARK,false,4)
				draw_rect(rect.grow(5),Color("60a59d"),false,2)
			if hover_id==id:
				var cursor: Vector2=rect.position+Vector2(49,48)
				draw_colored_polygon(PackedVector2Array([cursor,cursor+Vector2(2,17),cursor+Vector2(7,12),cursor+Vector2(13,12)]),LIGHT)
		# Equipped scanner remains equipped while browsing/using consumables.
		panel(Rect2(1482,935,62,62),DARK)
		icon("scan",Rect2(1488,941,50,50)); corners(Rect2(1482,935,62,62),AMBER)
		draw_line(Vector2(1561,912),Vector2(1561,1039),Color("9a9e92"),1)
		text(Vector2(1580,924),"ALT 12 m",15,DARK)
		for index: int in range(2):
			var key: String="hull" if index==0 else "energy"
			var value: float=model.state[key]; var capacity: float=model.max_capacity(key)
			var y: float=945+index*44
			text(Vector2(1580,y),key.to_upper(),14,DARK)
			text(Vector2(1808,y),"%d/%d" % [value,capacity],14,DARK)
			draw_rect(Rect2(1580,y+8,285,12),DARK)
			draw_rect(Rect2(1582,y+10,281*value/capacity,8),Color("e99b6a") if index==0 else AMBER)
		panel(Rect2(1847,1011,36,36),DARK)
		icon("comms",Rect2(1850,1014,30,30))
		if not feedback.is_empty():
			panel(Rect2(34,93,460,36),DARK)
			text(Vector2(46,118),feedback,18)
		var inspecting: String=hover_id if not hover_id.is_empty() else focus_id
		if not inspecting.is_empty():
			panel(tooltip_bounds,DARK,Color("8a9385"))
			var entry: Dictionary=Palette.entry(inspecting)
			text(tooltip_bounds.position+Vector2(16,28),entry.title,22)
			var detail: String="Restores up to %d energy" % model.PACK_ENERGY if inspecting=="pack" else entry.summary
			if inspecting=="scan": detail="Equipped tool · %s m reach" % model.Equipment.amount(model.Equipment.reach("scan"))
			text(tooltip_bounds.position+Vector2(16,54),detail,17)
			var why: String=reason(inspecting)
			var action_copy: String="Enter / Space to use one pack" if hover_id.is_empty() else "Click to use one pack"
			var line: String=action_copy if why.is_empty() else why
			if inspecting=="scan": line="Choose a valid subject in the world"
			if inspecting=="pack" and model.state.energy_packs<=0: line="None aboard · buy at a dock"
			text(tooltip_bounds.position+Vector2(16,82),line,17,AMBER if not why.is_empty() else Color("9bd3bd"))

func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var background_path: String=ProjectSettings.globalize_path("res://artifacts/field-instruments-review/surface-review-background-v1.png")
	for required: String in [background_path,ProjectSettings.globalize_path("res://artifacts/field-instruments-review/supply-portraits-v1.png")]:
		if not FileAccess.file_exists(required):
			push_error("Missing local review asset: %s; see FIELD_INSTRUMENTS_MOCK_PROMPTS.md" % required); quit(1); return
	var background:=ImageTexture.create_from_image(Image.load_from_file(background_path))
	var records: Array=[]
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		var view:=SubViewport.new(); view.size=resolution
		view.size_2d_override=Vector2i(1920,1080); view.size_2d_override_stretch=true
		view.render_target_update_mode=SubViewport.UPDATE_ALWAYS; view.gui_disable_input=true
		root.add_child(view)
		var study:=InventoryStudy.new(); study.model=Model.new(); study.background=background
		study.size=Vector2(1920,1080); view.add_child(study)
		for state: String in ["ready","used","empty","full","repair","keyboard","equipped"]:
			study.model.state=Model.fresh(); study.model.state.energy=36.0; study.model.state.hull=68.0
			study.model.marks=248; study.model.state.energy_packs=2
			study.model.state.repair_packs={"repair_pack":1,"mega_repair_pack":0}
			study.hover_id="pack"; study.focus_id=""; study.feedback=""
			if state=="used":
				# Same command as the prototype button; no game save or world tick.
				study.buttons.pack.pressed.emit()
				assert(study.model.state.energy==86 and study.model.state.energy_packs==1)
				assert(study.model.state.pack_ready_at==Model.PACK_COOLDOWN)
			if state=="empty":
				study.model.state.energy_packs=0
				study.buttons.pack.pressed.emit()
				assert(study.model.state.energy==36 and study.model.state.energy_packs==0)
			if state=="full":
				study.model.state.energy=100.0; study.buttons.pack.pressed.emit()
				assert(study.model.state.energy_packs==2)
			if state=="repair": study.hover_id="repair_pack"
			if state=="keyboard": study.hover_id=""; study.focus_id="pack"
			if state=="equipped": study.hover_id="scan"
			study.queue_redraw()
			for frame: int in range(3): await process_frame
			await RenderingServer.frame_post_draw
			var output: String="%s/inventory-%s-%d.png" % [OUT,state,resolution.x]
			view.get_texture().get_image().save_png(output)
			records.append({"state":state,"resolution":[resolution.x,resolution.y],"energy":study.model.state.energy,"packs":study.model.state.energy_packs,"reason":study.reason(study.hover_id if not study.hover_id.is_empty() else "pack"),"image":output,"input":"scripted fixture; not a physical pointer or keyboard test"})
		study.free(); view.free()
	var file:=FileAccess.open(OUT+"/inventory-evidence.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"kind":"review prototype over generated static world; not game runtime","records":records},"\t"))
	print("Field inventory review: 14 captures; resource use/refusal assertions passed.")
	quit()
