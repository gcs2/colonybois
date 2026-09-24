extends SceneTree
## Isolated composed review. Only instrument switching/tooltips are interactive.
const Instrument=preload("res://tests/review_surface_instrument.gd")
const Capacity=preload("res://tests/review_field_capacity.gd")
const Session=preload("res://scripts/expedition_session.gd")
const OUT="res://artifacts/surface-instrument-review"

class Interactive extends Instrument.Study:
	const ROLES=["Small plant","Medium plant","Large plant","Herbivore · first slot","Herbivore · second slot","Predator"]
	var controls: Dictionary={}
	var hovered: String=""
	var focused: String=""
	var tip_title: String=""
	var tip_detail: String=""
	func _ready() -> void:
		super._ready()
		refresh()
	func known() -> bool:
		return game.field.state.survey_ticks>=game.field.definition().survey_seconds
	func control(id: String, rect: Rect2, title: String, detail: String, callback: Callable) -> void:
		var b:=Button.new(); b.position=rect.position; b.size=rect.size; b.flat=true
		b.set_meta("explanation",[title,detail])
		for key: String in ["normal","hover","pressed","focus"]: b.add_theme_stylebox_override(key,StyleBoxEmpty.new())
		b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
		b.mouse_entered.connect(func() -> void: hovered=id; tip_title=title; tip_detail=detail; queue_redraw())
		b.mouse_exited.connect(func() -> void: hovered=""; tip_title=""; tip_detail=""; queue_redraw())
		b.focus_entered.connect(func() -> void: focused=id; queue_redraw())
		b.focus_exited.connect(func() -> void: focused=""; queue_redraw())
		b.pressed.connect(callback)
		add_child(b); controls[id]=b
	func refresh() -> void:
		for b: Button in controls.values(): remove_child(b); b.queue_free()
		controls.clear(); hovered=""; focused=""; tip_title=""; tip_detail=""
		chart.visible=mode=="chart"
		control("toggle",Rect2(40,1028,268,40),"Planet conditions" if mode=="chart" else "Local terrain chart","Switch instrument; no resources consumed.",func() -> void:
			mode=("known" if known() else "unknown") if mode=="chart" else "chart"
			refresh(); controls.toggle.grab_focus())
		if mode=="known":
			var layers: Array=game.biosphere.world("morrow").layers
			for row: int in range(3):
				for col: int in range(6):
					var id: String=layers[row][game.biosphere.SLOTS[col]]
					var title: String="T%d · %s" % [row+1,ROLES[col]]
					var detail: String="Empty ecological slot" if id.is_empty() else game.biosphere.data()[id].name
					control("slot%d_%d" % [row,col],Rect2(363+col*46,857+row*44,41,39),title,detail,func() -> void: pass)
		queue_redraw()
	func _draw() -> void:
		super._draw()
		panel(Rect2(24,1028,304 if mode=="chart" else 644,44),IVORY)
		text(Vector2(49,1056),"Conditions →" if mode=="chart" else "← Map",19,DARK)
		panel(Rect2(24,18,815,37),DARK)
		text(Vector2(38,43),"COMPOSED REVIEW · SWITCHING / TOOLTIP PROTOTYPE · PALETTE STATIC",17)
		panel(Rect2(1716,20,180,42),DARK)
		text(Vector2(1730,49),"%d Marks" % game.field.marks,22)
		if not focused.is_empty() and controls.has(focused):
			var b: Button=controls[focused]; draw_rect(Rect2(b.position,b.size).grow(2),DARK if focused=="toggle" else Color("81c0b9"),false,3)
		if not hovered.is_empty() and controls.has(hovered):
			var b: Button=controls[hovered]; draw_rect(Rect2(b.position,b.size),AMBER,false,1)
		var explained: String=hovered if not hovered.is_empty() else focused
		if not explained.is_empty() and controls.has(explained):
			var explanation: Array=controls[explained].get_meta("explanation")
			panel(Rect2(24,622,644,84),DARK)
			text(Vector2(42,652),explanation[0],22)
			text(Vector2(42,683),explanation[1],20)

func _initialize() -> void: call_deferred("run")
func move(view: SubViewport, at: Vector2) -> void:
	var e:=InputEventMouseMotion.new(); e.position=at; e.global_position=at; view.push_input(e,true)
	await process_frame
func click(view: SubViewport, at: Vector2) -> void:
	await move(view,at)
	for down: bool in [true,false]:
		var e:=InputEventMouseButton.new(); e.position=at; e.global_position=at; e.button_index=MOUSE_BUTTON_LEFT; e.pressed=down
		view.push_input(e,true); await process_frame
func capture(view: SubViewport, state: String) -> void:
	for frame: int in range(3): await process_frame
	await RenderingServer.frame_post_draw
	assert(view.get_texture().get_image().save_png(OUT+"/composed-%s-%d.png" % [state,view.size.y])==OK)
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		for surveyed: bool in [false,true]:
			var game:=Session.new(); game.field.state.energy=65
			game.field.state.survey_ticks=game.field.definition().survey_seconds if surveyed else 0
			game.fleet.prepare(game,Vector3.ZERO)
			var before: Dictionary=game.snapshot().duplicate(true)
			var view:=SubViewport.new(); view.size=resolution; view.size_2d_override=Vector2i(1920,1080); view.size_2d_override_stretch=true
			view.render_target_update_mode=SubViewport.UPDATE_ALWAYS; root.add_child(view)
			var scene: Node3D=load("res://scenes/encounter.tscn").instantiate()
			scene.campaign=game; scene.process_mode=Node.PROCESS_MODE_DISABLED; view.add_child(scene); scene.audio.muted=true
			scene._update_camera(1); scene._refresh_ui()
			for child: Node in scene.get_children():
				if child is CanvasLayer: child.hide()
			var overlay:=CanvasLayer.new(); view.add_child(overlay)
			var study:=Interactive.new(); study.game=game; study.mode="chart"; study.chart=scene.hud.navigation
			study.chart.get_parent().remove_child(study.chart); overlay.add_child(study)
			var palette:=Capacity.Study.new(); palette.hud=scene.hud; palette.model=game.field; palette.embedded=true
			overlay.add_child(palette); palette.prepare()
			await capture(view,"map-known" if surveyed else "map-unknown")
			await click(view,Vector2(150,1040))
			assert(study.mode==("known" if surveyed else "unknown") and not study.chart.visible)
			await move(view,Vector2(900,600))
			await capture(view,"conditions-known" if surveyed else "conditions-unknown")
			if surveyed:
				await move(view,Vector2(518,875))
				assert(study.hovered=="slot0_3" and study.tip_title=="T1 · Herbivore · first slot" and study.tip_detail=="Pocket manta")
				await capture(view,"species-hover")
				await move(view,Vector2(565,920))
				assert(study.tip_title=="T2 · Herbivore · second slot" and study.tip_detail=="Empty ecological slot")
				await capture(view,"empty-role-hover")
				await move(view,Vector2(900,600)); study.controls.slot0_3.grab_focus(); await process_frame
				assert(study.focused=="slot0_3" and study.controls.slot0_3.get_meta("explanation")[1]=="Pocket manta")
				await capture(view,"species-focus")
			else: assert(study.controls.size()==1,"No hidden ecological slot hit targets before survey")
			await move(view,Vector2(900,600)); study.controls.toggle.grab_focus(); await process_frame
			assert(study.focused=="toggle")
			await capture(view,"toggle-focus-known" if surveyed else "toggle-focus-unknown")
			for down: bool in [true,false]:
				var key:=InputEventKey.new(); key.keycode=KEY_ENTER; key.pressed=down; view.push_input(key,true); await process_frame
			assert(study.mode=="chart" and study.chart.visible)
			assert(before==game.snapshot(),"Map/condition inspection must not mutate campaign")
			view.free()
	print("Composed surface review:18 captures; pointer switching, role/species hover and focus, Enter return and unchanged snapshots verified at1080p/1440p.")
	quit()
