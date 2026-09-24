extends SceneTree
## Current scene and proposed world-facing HUD, sharing isolated command-backed fixtures.
const Session = preload("res://scripts/expedition_session.gd")
const Base = preload("res://tests/review_field_inventory.gd")
const ID = "pocket_manta"
const OUT = "res://artifacts/collection-review"

class Study extends Base.InventoryStudy:
	var game: RefCounted
	var stage: String
	var why: String
	func _ready() -> void:
		for id: String in ["scan","collect","inventory","category_tools","category_life","category_weapons"]:
			icons[id]=load("res://assets/ui/flight/%s.svg" % id)
		icons.creature=load("res://assets/specimens/pocket_manta.png")
	func _draw() -> void:
		draw_texture_rect(background,Rect2(0,0,1920,1080),false)
		text(Vector2(32,48),"Morrow",32)
		text(Vector2(32,79),"COLLECTION STUDY · STATIC CONCEPT WORLD / SCHEMATIC TARGET",16)
		var target := Rect2(962,603,102,72)
		if stage!="collected":
			icon("creature",target)
			draw_rect(target.grow(6),Color("242b2a"),false,4)
			corners(target.grow(6),LIGHT if why.is_empty() else Color("ffcf85"))
			if not why.is_empty():
				panel(Rect2(target.end.x+12,target.position.y,28,30),DARK)
				text(Vector2(target.end.x+21,target.position.y+23),"!",23,AMBER)
		if stage=="collecting":
			draw_line(Vector2(950,590),target.get_center(),Color(0.65,0.86,0.69,0.22),18,true)
			draw_line(Vector2(950,590),target.get_center(),Color("aedab7"),3,true)
		panel(Rect2(1480,116,404,194),IVORY)
		panel(Rect2(1492,128,110,112),DARK)
		icon("creature",Rect2(1501,142,92,83))
		text(Vector2(1620,154),"Unknown lifeform" if stage=="unscanned" else "Pocket manta",24,DARK)
		text(Vector2(1620,184),"Scan to identify" if stage=="unscanned" else "Herbivore · Morrow",19,DARK)
		if stage!="unscanned": text(Vector2(1620,218),"Local stock: %d" % game.biosphere.world("morrow").stock[ID],18,DARK)
		text(Vector2(1500,275),why if not why.is_empty() else "Collection complete" if stage=="collected" else "Tractor engaged · 5 energy" if stage=="collecting" else "Ready to collect · 5 energy",19,DARK)
		panel(Rect2(1160,886,724,166),IVORY)
		var categories := ["category_tools","category_life","category_weapons","inventory"]
		for i: int in range(4):
			panel(Rect2(1160+i*58,842,54,44),DARK)
			icon(categories[i],Rect2(1171+i*58,850,30,30))
		for i: int in range(2):
			var r := Rect2(1176+i*75,906,65,68)
			panel(r,DARK); icon("scan" if i==0 else "collect",Rect2(r.position+Vector2(8,8),Vector2(49,49)))
			if i==1: corners(r.grow(3),AMBER)
		panel(Rect2(1342,901,91,94),DARK)
		icon("creature",Rect2(1348,905,78,64))
		text(Vector2(1398,986),"×%d" % int(game.biosphere.state.cargo.get(ID,0)),19)
		text(Vector2(1176,1027),"SPECIMENS  %d / 12" % game.biosphere.used(),19,DARK)
		for i: int in range(2):
			var key: String="hull" if i==0 else "energy"
			var y: int=927+i*62
			text(Vector2(1470,y),"%s   %d / %d" % [key.to_upper(),game.field.state[key],game.field.max_capacity(key)],18,DARK)
			draw_rect(Rect2(1470,y+12,380,12),DARK)
			draw_rect(Rect2(1472,y+14,376*float(game.field.state[key])/game.field.max_capacity(key),8),AMBER if i==1 else Color("e79d78"))
		if stage=="collected":
			panel(Rect2(1160,790,724,40),DARK)
			text(Vector2(1176,818),"Pocket manta collected  ·  +1 specimen  ·  −5 energy",21,Color("b3d4b2"))
		if stage=="collecting":
			draw_rect(Rect2(974,686,78,5),DARK); draw_rect(Rect2(974,686,39,5),AMBER)
		# No map is invented: geographic chart remains a separate review dependency.

func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var records: Array=[]
	for stage: String in ["unscanned","ready","collecting","collected","full","no-energy","recovering"]:
		var game := Session.new(); game.field.state.energy=40
		var site: Vector3=game.biosphere.site("morrow",ID)
		var at: Vector3=site+Vector3(0,5,3)
		# Match scene initialization before asserting render-only immutability.
		game.fleet.prepare(game,at)
		if stage!="unscanned": assert(game.biosphere.act(game,ID,"scan",at).is_empty())
		if stage=="full": game.biosphere.state.cargo[ID]=12
		if stage=="no-energy": game.field.state.energy=4
		if stage=="recovering":
			var local: Dictionary=game.biosphere.world("morrow"); local.stock[ID]=0
			game.biosphere.state.worlds.morrow=local
		if stage=="collected":
			assert(game.biosphere.act(game,ID,"collect",at).is_empty())
			assert(game.field.state.energy==35 and game.biosphere.used()==1 and game.biosphere.world("morrow").stock[ID]==3)
		var why: String=game.biosphere.reason(game,ID,"collect",at)
		var before: Dictionary=game.snapshot().duplicate(true)
		if stage in ["unscanned","full","no-energy","recovering"]:
			assert(not why.is_empty())
			assert(game.biosphere.act(game,ID,"collect",at)==why)
			assert(before==game.snapshot(),"Refusal must preserve resources and world")
		var view := SubViewport.new(); view.size_2d_override=Vector2i(1600,900); view.size_2d_override_stretch=true
		view.render_target_update_mode=SubViewport.UPDATE_ALWAYS; root.add_child(view)
		var scene: Node3D=load("res://scenes/encounter.tscn").instantiate()
		scene.campaign=game; scene.process_mode=Node.PROCESS_MODE_DISABLED; view.add_child(scene)
		scene.set_process(false); scene.set_physics_process(false); scene.audio.muted=true
		scene.ship.position=at; scene.destination=at; scene.navigating=false
		scene._select_tool("collect")
		scene.biosphere_view.selected=ID; scene.biosphere_view.point=site
		if stage=="collecting": scene.biosphere_view.action="collect"; scene.biosphere_view.progress=0.75
		scene.biosphere_view.refresh(0,true); scene._update_camera(1); scene._refresh_ui()
		if not why.is_empty(): scene._toast(why)
		if stage=="collected": scene._toast("Pocket manta collected")
		for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
			view.size=resolution
			for i: int in range(4): await process_frame
			await RenderingServer.frame_post_draw
			assert(view.get_texture().get_image().save_png(OUT+"/current-%s-%d.png" % [stage,resolution.y])==OK)
		scene.free(); view.free()
		for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
			var proposal := SubViewport.new(); proposal.size=resolution
			proposal.size_2d_override=Vector2i(1920,1080); proposal.size_2d_override_stretch=true
			proposal.render_target_update_mode=SubViewport.UPDATE_ALWAYS; root.add_child(proposal)
			var study := Study.new(); study.game=game; study.stage=stage; study.why=why
			study.background=ImageTexture.create_from_image(Image.load_from_file("res://artifacts/field-instruments-review/surface-review-background-v1.png"))
			proposal.add_child(study)
			for i: int in range(3): await process_frame
			await RenderingServer.frame_post_draw
			assert(proposal.get_texture().get_image().save_png(OUT+"/mock-%s-%d.png" % [stage,resolution.y])==OK)
			proposal.free()
		if before!=game.snapshot():
			var after: Dictionary=game.snapshot()
			for key: String in before:
				if before[key]!=after[key]: print("Changed review field: ",key," BEFORE ",before[key]," AFTER ",after[key])
			quit(1); return
		records.append({"state":stage,"reason":why,"energy":game.field.state.energy,"specimens":game.biosphere.used()})
	var file := FileAccess.open(OUT+"/evidence.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"kind":"isolated command-backed current captures and static proposal; schematic concept target; no motion/audio/input proof","states":records},"\t"))
	print("Collection review: 28 current/proposed captures; success and four refusal snapshots verified.")
	quit()
