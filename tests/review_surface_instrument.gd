extends SceneTree
## Actual terrain under proposed read-only instrument. No new climate commands.
const Session = preload("res://scripts/expedition_session.gd")
const Base = preload("res://tests/review_field_inventory.gd")
const OUT = "res://artifacts/surface-instrument-review"

class Study extends Base.InventoryStudy:
	var game: RefCounted
	var mode: String
	var chart: Control
	var embedded: bool=false
	func _ready() -> void:
		if mode=="chart":
			chart.position=Vector2(54,772); chart.scale=Vector2(1.25,1.25)
			chart.mouse_filter=Control.MOUSE_FILTER_IGNORE
			add_child(chart)
		for id: String in game.biosphere.data(): icons[id]=load("res://assets/specimens/%s.png" % id)
	func _draw() -> void:
		if not embedded: text(Vector2(32,42),"ACTUAL WORLD · PROPOSED SURFACE INSTRUMENT",19)
		panel(Rect2(24,722,304 if mode=="chart" else 644,330),IVORY)
		text(Vector2(44,756),"MAP" if mode=="chart" else "CONDITIONS",22,DARK)
		text(Vector2(198 if mode=="chart" else 478,756),"MORROW",20,DARK)
		panel(Rect2(40,774,268,254),DARK)
		if mode!="chart": panel(Rect2(322,774,330,254),DARK)
		if mode=="chart":
			text(Vector2(49,1043),"Conditions →",17,DARK)
			return
		if mode=="unknown":
			text(Vector2(63,817),"No survey data",23)
			text(Vector2(63,850),"Climate readings hidden",18)
			text(Vector2(341,817),"Ecosystem unassessed",22)
			text(Vector2(341,854),"Complete an orbital survey",18)
			text(Vector2(341,881),"to inspect global conditions.",18)
			return
		var local: Dictionary=game.climate.world("morrow")
		var center := Vector2(172,892)
		for radius: float in [80,54,28]: draw_arc(center,radius,0,TAU,64,Color("7caa97"),1.5,true)
		for band: int in range(3): text(Vector2(179,817+band*26),"T%d" % (band+1),13)
		draw_line(Vector2(72,892),Vector2(272,892),Color("65736b"))
		draw_line(Vector2(172,792),Vector2(172,992),Color("65736b"))
		var point := Vector2(72+local.temperature*2,992-local.atmosphere*2)
		draw_circle(point,7,AMBER)
		text(Vector2(48,805),"Atmosphere ↑",15)
		text(Vector2(64,1013),"Cold   Temperature   Hot",17)
		text(Vector2(337,804),"Climate T%d · Ecosystem T%d" % [game.climate.score(local),game.biosphere.complete_tier("morrow")],21)
		text(Vector2(337,831),"Temp %d · Atmos %d (indices)" % [local.temperature,local.atmosphere],17)
		var layers: Array=game.biosphere.world("morrow").layers
		var roles := ["S","M","L","H","H","P"]
		for col: int in range(6): text(Vector2(378+col*46,852),roles[col],13)
		for row: int in range(3):
			text(Vector2(334,876+row*44),"T%d" % (row+1),15)
			for col: int in range(6):
				var r := Rect2(363+col*46,857+row*44,41,39)
				draw_rect(r,Color("3c4841"))
				var id: String=layers[row][game.biosphere.SLOTS[col]]
				if not id.is_empty(): icon(id,r.grow(-3))
				else: text(r.position+Vector2(16,27),"–",19,Color("83958a"))
		var stress: int=game.biosphere.world("morrow").stress
		text(Vector2(337,1006),"Habitat loss in %ds" % (30-stress) if stress>0 else "Established food web · T%d" % game.biosphere.complete_tier("morrow"),19,AMBER if stress>0 else LIGHT)

func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	for mode: String in ["chart","unknown","known","stress"]:
		var game := Session.new()
		game.field.state.survey_ticks=0 if mode=="unknown" else game.field.definition().survey_seconds
		if mode=="stress":
			var climate: Dictionary=game.climate.world("morrow"); climate.temperature=0; climate.atmosphere=0
			game.climate.state.worlds.morrow=climate
			var bio: Dictionary=game.biosphere.world("morrow"); bio.stress=10; game.biosphere.state.worlds.morrow=bio
		game.fleet.prepare(game,Vector3.ZERO)
		var before: Dictionary=game.snapshot().duplicate(true)
		var view := SubViewport.new(); view.size_2d_override=Vector2i(1600,900); view.size_2d_override_stretch=true
		view.render_target_update_mode=SubViewport.UPDATE_ALWAYS; root.add_child(view)
		var scene: Node3D=load("res://scenes/encounter.tscn").instantiate()
		scene.campaign=game; scene.process_mode=Node.PROCESS_MODE_DISABLED; view.add_child(scene); scene.audio.muted=true
		scene.climate_tool="heat_ray" if mode!="chart" else ""
		scene._update_camera(1); scene._refresh_ui(); scene._refresh_climate_ui()
		for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
			view.size=resolution
			for i: int in range(3): await process_frame
			await RenderingServer.frame_post_draw
			assert(view.get_texture().get_image().save_png(OUT+"/current-%s-%d.png" % [mode,resolution.y])==OK)
		for child: Node in scene.get_children():
			if child is CanvasLayer: child.hide()
		view.size_2d_override=Vector2i(1920,1080)
		var overlay := CanvasLayer.new(); view.add_child(overlay)
		var study := Study.new(); study.game=game; study.mode=mode
		if mode=="chart":
			study.chart=scene.hud.navigation
			study.chart.get_parent().remove_child(study.chart)
		overlay.add_child(study)
		for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
			view.size=resolution
			for i: int in range(3): await process_frame
			await RenderingServer.frame_post_draw
			assert(view.get_texture().get_image().save_png(OUT+"/mock-%s-%d.png" % [mode,resolution.y])==OK)
		assert(before==game.snapshot(),"Instrument rendering must not mutate simulation")
		view.free()
	print("Surface instrument: 16 paired captures, four immutable fixtures; actual terrain, proposed controls.")
	quit()
