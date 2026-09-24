extends SceneTree
## Composition/state study only. No game state, saves, travel commands or input.
const OUT := "res://artifacts/field-instruments-review/states"

class Study extends Control:
	const FONT = preload("res://assets/fonts/Barlow-Regular.ttf")
	const PAPER := Color("dcdace")
	const INK := Color("202927")
	const LIGHT := Color("f0eee1")
	const GOLD := Color("edc461")
	var mode := "known"
	var icons: Array[Texture2D]=[]
	func _ready() -> void:
		for asset: String in ["scan","inventory","category_weapons","comms"]:
			icons.append(load("res://assets/ui/flight/%s.svg" % asset))
	func label(p: Vector2, value: String, pixels: int = 20, color: Color = LIGHT) -> void:
		draw_string(FONT,p,value,HORIZONTAL_ALIGNMENT_LEFT,-1,pixels,color)
	func housing(r: Rect2, color: Color) -> void:
		var p:=r.position; var e:=r.end
		draw_colored_polygon(PackedVector2Array([p+Vector2(8,0),Vector2(e.x-8,p.y),Vector2(e.x,p.y+8),e-Vector2(0,8),e-Vector2(8,0),Vector2(p.x+8,e.y),Vector2(p.x,e.y-8),p+Vector2(0,8)]),color)
	func orbit(center: Vector2, radius: float, color: Color, width: float = 1.0) -> void:
		var points:=PackedVector2Array()
		for i: int in range(97):
			var angle: float=TAU*i/96.0
			points.append(center+Vector2(cos(angle)*radius,sin(angle)*radius*0.38).rotated(-0.15))
		draw_polyline(points,color,width,true)
	func bracket(p: Vector2, radius: float, color: Color) -> void:
		for x: int in [-1,1]:
			for y: int in [-1,1]:
				var at:=p+Vector2(x,y)*radius
				draw_line(at,at-Vector2(x*10,0),color,2,true)
				draw_line(at,at-Vector2(0,y*10),color,2,true)
	func ship(p: Vector2) -> void:
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,-16),p+Vector2(12,13),p+Vector2(0,7),p+Vector2(-12,13)]),PAPER)
		draw_line(p+Vector2(0,9),p+Vector2(0,25),Color("83c9c6"),3,true)
	func _draw() -> void:
		draw_rect(Rect2(0,0,1920,1080),Color("090e15"))
		var rng:=RandomNumberGenerator.new(); rng.seed=2841
		for i: int in range(440):
			var p:=Vector2(rng.randf_range(0,1920),rng.randf_range(0,1080))
			draw_circle(p,rng.randf_range(0.5,1.5),Color(0.65,0.74,0.78,rng.randf_range(0.12,0.65)))
		var system: bool=mode in ["system","arrival","intermediate"]
		label(Vector2(32,48),"Nacre" if system else "The local arm",30)
		label(Vector2(34,76),"SYSTEM" if system else "GALAXY",15,Color("96aaa6"))
		label(Vector2(655,35),"NAVIGATION COMPOSITION STUDY · SCHEMATIC WORLD",16,Color("96aaa6"))
		var target:=Vector2(1120,450)
		var origin:=Vector2(730,610)
		target=origin+Vector2(cos(-0.5)*400,sin(-0.5)*152).rotated(-0.15)
		if system:
			var center:=Vector2(800,470)
			if mode=="intermediate": center=target
			var factor: float=0.5 if mode=="intermediate" else 1.0
			for radius: float in [200.0,380.0,600.0]: orbit(center,radius*factor,Color("37474d"))
			draw_circle(center,36*factor,Color("f4dca0"))
			draw_circle(center,44*factor,Color(1,0.8,0.4,0.08))
			target=center+Vector2(359,-105)*factor
			draw_circle(target,23*factor,Color("8cafb5"))
			draw_circle(center+Vector2(-171,54)*factor,14*factor,Color("c78f70"))
			draw_circle(center+Vector2(-402,-119)*factor,31*factor,Color("a3a883"))
			bracket(target,33*factor,GOLD)
			ship(target+Vector2(60,45) if mode=="arrival" else center+Vector2(70,85))
			if mode!="intermediate": label(target+Vector2(-30,-46),"Nacre I",21)
			else:
				housing(Rect2(center+Vector2(45,-42),Vector2(148,43)),PAPER)
				label(center+Vector2(61,-13),"Nacre",23,INK)
		else:
			orbit(origin,500,Color("6aa698"),2)
			for i: int in range(28):
				var p:=Vector2(rng.randf_range(200,1650),rng.randf_range(160,820))
				draw_circle(p,rng.randf_range(2,4),Color("7c8c9c"))
			draw_circle(origin,7,LIGHT); label(origin+Vector2(-30,45),"Morrow",20)
			draw_circle(target,8,Color("badad6")); bracket(target,23,LIGHT if mode in ["known","unknown"] else GOLD)
			if mode!="transit": ship(origin+Vector2(35,-25))
			if mode in ["selected","denied","transit"]:
				draw_line(origin,target,GOLD,2,true)
				label(Vector2(845,501),"2.4 pc",17,GOLD)
			if mode=="transit": ship(origin.lerp(target,0.55))
			if mode=="transit": label(Vector2(615,842),"Departure reach · 3 pc",17,Color("96aaa6"))
		if mode in ["known","unknown"]:
			housing(Rect2(1170,408,300,174 if mode=="known" else 95),PAPER)
			label(Vector2(1188,439),"Nacre" if mode=="known" else "Uncharted signal",23,INK)
			if mode=="known":
				for i: int in range(3):
					draw_circle(Vector2(1198,468+i*37),7,[Color("8cafb5"),Color("c78f70"),Color("a3a883")][i])
					label(Vector2(1218,475+i*37),["Nacre I","Nacre II","Nacre III"][i],19,INK)
			else: label(Vector2(1188,478),"Worlds not yet charted",18,INK)
		if mode in ["selected","denied","system"]:
			housing(Rect2(1170,490,380,150),PAPER)
			label(Vector2(1188,521),"Nacre I · orbital destination",21,INK)
			label(Vector2(1188,554),"3 energy · 2 s" if system else "8 energy · 2 s · reach 3 pc",18,INK)
			label(Vector2(1188,586),"Need 8 energy · dock or use a pack" if mode=="denied" else "Click selected destination to depart",18,Color("943e32") if mode=="denied" else INK)
			label(Vector2(1188,615),"Energy available: 5/100" if mode=="denied" else ("Energy after departure: 89/100" if system else "Energy after departure: 84/100"),16,INK)
			if system: label(Vector2(32,106),"SEPARATE LOCAL JOURNEY FIXTURE",16,GOLD)
		if mode in ["transit","arrival"]:
			housing(Rect2(752,86,416,66),INK)
			label(Vector2(774,114),"Nacre I · arriving" if mode=="transit" else "Nacre I · orbit reached",23)
			if mode=="transit": draw_rect(Rect2(774,130,220,3),GOLD)
		# Persistent ship instrument; no local chart at these scales.
		housing(Rect2(1320,936,576,120),PAPER)
		label(Vector2(1340,965),"EXPEDITION SHIP",16,INK)
		for i: int in range(4):
			var box:=Rect2(1340+i*54,981,44,48)
			housing(box,INK)
			draw_texture_rect(icons[i],box.grow(-7),false)
		var energy: int=5 if mode=="denied" else (84 if mode in ["transit","arrival"] else 92)
		for i: int in range(2):
			label(Vector2(1590,973+i*42),"HULL  100 / 100" if i==0 else "ENERGY  %d / 100" % energy,15,INK)
			draw_rect(Rect2(1590,984+i*42,280,8),INK)
			draw_rect(Rect2(1590,984+i*42,280*(1.0 if i==0 else energy/100.0),8),Color("cf8d64") if i==0 else GOLD)

func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var records: Array=[]
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		var viewport:=SubViewport.new(); viewport.size=resolution
		viewport.size_2d_override=Vector2i(1920,1080); viewport.size_2d_override_stretch=true
		viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS; viewport.gui_disable_input=true
		root.add_child(viewport)
		var study:=Study.new(); viewport.add_child(study)
		for mode: String in ["known","unknown","selected","denied","intermediate","system","transit","arrival"]:
			study.mode=mode; study.queue_redraw()
			for frame: int in range(3): await process_frame
			await RenderingServer.frame_post_draw
			var path: String="%s/navigation-%s-%d.png" % [OUT,mode,resolution.x]
			var error: Error=viewport.get_texture().get_image().save_png(path)
			if error!=OK:
				push_error("Cannot save navigation study: %s" % path); quit(1); return
			records.append({"state":mode,"resolution":[resolution.x,resolution.y],"image":path})
		viewport.free()
	var record:=FileAccess.open(OUT+"/navigation-evidence.json",FileAccess.WRITE)
	if record==null: quit(1); return
	var evidence: Dictionary={"kind":"schematic composition study, not playable navigation","limitations":["fixture values, no campaign calls","no input or motion validation","temporary glyphs and schematic world","states are not a continuous voyage"],"records":records}
	record.store_string(JSON.stringify(evidence,"\t"))
	print("Navigation composition study: 16 scripted stills; no input or campaign validation.")
	quit()
