extends SceneTree
## Isolated input-driven proposal. Fixed ship; explicit test-clock transfer; never saves.
const Session=preload("res://scripts/expedition_session.gd")
const ReleasePanel=preload("res://tests/release_study_panel.gd")
const Instrument=preload("res://tests/review_surface_instrument.gd")
const Capacity=preload("res://tests/review_field_capacity.gd")
const OUT="res://artifacts/release-review"

class Interaction extends ReleasePanel:
	var scene: Node3D
	var palette: Control
	var armed: bool=true
	var elapsed: float=0
	var ground: Vector3
	var picker: bool=false
	var tooltip: String=""
	var controls: Dictionary={}
	var last_reason: String=""
	func _ready() -> void:
		super._ready()
		icons["energy_pack"]=load("res://assets/ui/flight/energy_pack.svg")
		refresh_controls()
	func button(key: String, rect: Rect2, title: String, action: Callable) -> void:
		var b:=Button.new(); b.position=rect.position; b.size=rect.size; b.flat=true
		for style: String in ["normal","hover","pressed","focus"]: b.add_theme_stylebox_override(style,StyleBoxEmpty.new())
		b.mouse_entered.connect(func() -> void: tooltip=title; queue_redraw())
		b.mouse_exited.connect(func() -> void: tooltip=""; queue_redraw())
		b.focus_entered.connect(func() -> void: tooltip=title; queue_redraw())
		b.focus_exited.connect(func() -> void: tooltip=""; queue_redraw())
		b.pressed.connect(action); add_child(b); controls[key]=b
	func refresh_controls() -> void:
		if armed and stage=="blocked":
			refusal_detail=game.biosphere.reason(game,specimen,"release",scene.ship.position,ground)
			if refusal_detail.is_empty(): stage="armed"
		scene._select_tool("seed" if armed else "scan"); scene._refresh_ui()
		if palette!=null: palette.prepare()
		for b: Button in controls.values(): remove_child(b); b.queue_free()
		controls.clear(); tooltip=""
		button("cancel",Rect2(1699,612,197,48),"Cancel release [Esc]" if armed else "Choose specimen",func() -> void:
			if armed: cancel()
			else: picker=true; refresh_controls())
		button("cargo",Rect2(1494,612,197,48),"Cargo: specimens and supplies",func() -> void: picker=not picker; refresh_controls())
		for i: int in range(6):
			var tier: int=int(slot[0]) if not slot.is_empty() else 1
			var id: String=game.biosphere.world("morrow").layers[tier][game.biosphere.SLOTS[i]]
			var title: String="T%d · %s · %s" % [tier+1,["Small plant","Medium plant","Large plant","First herbivore","Second herbivore","Predator"][i],"Empty" if id.is_empty() else game.biosphere.data()[id].name]
			button("role%d" % i,Rect2(1370+i*80,910,68,42),title,func() -> void: pass)
		if picker:
			for i: int in range(2):
				var id: String=["glass_moss","snow_bell"][i]
				button(id,Rect2(1196+i*90,500,80,80),game.biosphere.data()[id].name,func() -> void:
					if game.biosphere.state.cargo.get(id,0)>0:
						specimen=id; armed=true; stage="armed"; elapsed=0; picker=false
						slot=game.biosphere.release_slot(game,id); refresh_controls())
			button("pack",Rect2(1390,500,100,80),"Energy pack · restore 50 energy",func() -> void:
				last_reason=game.field.use_energy_pack(); refresh_controls(); tooltip=last_reason if not last_reason.is_empty() else "Energy pack used · +50 energy"; queue_redraw())
		queue_redraw()
	func cancel() -> void:
		if not armed:
			picker=false; refresh_controls(); return
		armed=false; elapsed=0; stage="cancelled"; picker=false; refresh_controls()
	func _unhandled_input(event: InputEvent) -> void:
		if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
			cancel(); get_viewport().set_input_as_handled()
		if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
			# Review HUD regions consume clicks; only exposed world accepts placement.
			if event.position.y>=670 or picker or not armed or stage=="beam": return
			var point: Variant=scene._surface_point(event.position)
			if point==null: last_reason="Choose visible ground"; tooltip=last_reason; queue_redraw(); return
			ground=Vector3(point.x,scene.terrain_height(point.x,point.y)+1.5,point.y)
			last_reason=game.biosphere.reason(game,specimen,"release",scene.ship.position,ground)
			if not last_reason.is_empty():
				stage="blocked"; refusal_detail=last_reason
			else: stage="beam"; elapsed=0
			project_target(); refresh_controls(); get_viewport().set_input_as_handled()
	func project_target() -> void:
		target=scene.camera.unproject_position(ground)
		emitter=scene.camera.unproject_position(scene.ship.position-Vector3(0,0.8,0))
		footprint.clear()
		for i: int in range(49):
			var a: float=TAU*i/48.0; var p:=ground+Vector3(cos(a)*1.7,0,sin(a)*1.7)
			p.y=game.biosphere.Geography.surface_height(game.field.definition(),p.x,p.z)+0.12
			footprint.append(scene.camera.unproject_position(p))
	func advance(seconds: float) -> void:
		if not armed or stage!="beam": return
		elapsed+=seconds
		if elapsed<1.5: return
		last_reason=game.biosphere.act(game,specimen,"release",scene.ship.position,ground)
		if last_reason.is_empty():
			stage="released"; armed=false; scene.biosphere_view.refresh(0,true)
		else: stage="blocked"; refusal_detail=last_reason
		refresh_controls()
	func _draw() -> void:
		super._draw()
		draw_set_transform(Vector2.ZERO)
		panel(Rect2(24,20,820,36),DARK)
		text(Vector2(38,45),"INPUT PROTOTYPE · FIXED SHIP / TEST CLOCK · NOT PRODUCTION",18)
		panel(Rect2(1494,612,197,48),DARK,IVORY); text(Vector2(1512,643),"Cargo",19)
		panel(Rect2(1699,612,197,48),DARK,IVORY); text(Vector2(1710,643),"Cancel release" if armed else "Choose specimen",19)
		if picker:
			panel(Rect2(1180,468,430,130),DARK)
			text(Vector2(1196,492),"SPECIMENS",15); text(Vector2(1390,492),"SUPPLIES",15)
			for i: int in range(2):
				var id: String=["glass_moss","snow_bell"][i]; var rect:=Rect2(1196+i*90,500,80,80)
				draw_rect(rect,Color("45534e")); icon(id,rect.grow(-10))
				text(rect.position+Vector2(3,75),"×%d" % game.biosphere.state.cargo.get(id,0),16)
			draw_rect(Rect2(1390,500,100,80),Color("45534e"))
			icon("energy_pack",Rect2(1414,505,48,48),Color.WHITE if game.field.pack_reason().is_empty() else Color("808a84"))
			text(Vector2(1398,576),"×%d" % game.field.state.energy_packs,18)
		for b: Button in controls.values():
			if b.has_focus(): draw_rect(Rect2(b.position,b.size).grow(2),AMBER,false,2)
		if not tooltip.is_empty():
			panel(Rect2(1180,400,716,50),DARK); text(Vector2(1196,432),tooltip,19)

func _initialize() -> void: call_deferred("run")
func click(view: SubViewport, point: Vector2) -> void:
	var move:=InputEventMouseMotion.new(); move.position=point; view.push_input(move,true); await process_frame
	for down: bool in [true,false]:
		var e:=InputEventMouseButton.new(); e.position=point; e.button_index=MOUSE_BUTTON_LEFT; e.pressed=down
		view.push_input(e,true); await process_frame
func capture(view: SubViewport, tag: String) -> void:
	for frame: int in range(3): await process_frame
	await RenderingServer.frame_post_draw
	assert(view.get_texture().get_image().save_png(OUT+"/input-%s-%d.png" % [tag,view.size.y])==OK)
func run() -> void:
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		var game:=Session.new(); game.field.state.energy=4; game.field.state.energy_packs=1
		game.field.state.survey_ticks=game.field.definition().survey_seconds
		for id: String in ["glass_moss","snow_bell"]: game.biosphere.state.cargo[id]=1; game.biosphere.state.catalogued.append(id)
		var ground:=Vector3(8,0,4); ground.y=game.biosphere.Geography.surface_height(game.field.definition(),8,4)+1.5
		var ship_at:=ground+Vector3(-7,7,5); game.fleet.prepare(game,ship_at)
		var view:=SubViewport.new(); view.size=resolution; view.size_2d_override=Vector2i(1920,1080); view.size_2d_override_stretch=true
		view.render_target_update_mode=SubViewport.UPDATE_ALWAYS; root.add_child(view)
		var scene: Node3D=load("res://scenes/encounter.tscn").instantiate(); scene.campaign=game; scene.process_mode=Node.PROCESS_MODE_DISABLED
		view.add_child(scene); scene.audio.muted=true; scene.ship.position=ship_at; scene._update_camera(1); scene._refresh_ui()
		for child: Node in scene.get_children():
			if child is CanvasLayer: child.hide()
		var overlay:=CanvasLayer.new(); view.add_child(overlay)
		var ui:=Interaction.new(); ui.game=game; ui.scene=scene; ui.stage="armed"; ui.specimen="glass_moss"; ui.ground=ground; ui.slot=game.biosphere.release_slot(game,"glass_moss")
		overlay.add_child(ui)
		var map:=Instrument.Study.new(); map.game=game; map.embedded=true; map.mode="chart"; map.chart=scene.hud.navigation
		map.chart.get_parent().remove_child(map.chart); overlay.add_child(map)
		var palette:=Capacity.Study.new(); palette.hud=scene.hud; palette.model=game.field; palette.embedded=true
		scene.hud.palette_expanded=false; overlay.add_child(palette); palette.prepare(); ui.palette=palette
		await process_frame; ui.project_target()
		var before: Dictionary=game.snapshot().duplicate(true)
		var point: Vector2=scene.camera.unproject_position(ground-Vector3(0,1.5,0))
		await click(view,Vector2(1000,180))
		assert(ui.stage=="blocked" and ui.armed and ui.refusal_detail==ui.last_reason and not ui.last_reason.is_empty())
		assert(before==game.snapshot()); await capture(view,"range-refusal")
		await click(view,point); assert(ui.stage=="blocked" and ui.armed); assert(before==game.snapshot())
		await capture(view,"refusal-retained")
		await click(view,Vector2(1550,630)); assert(ui.picker)
		await capture(view,"cargo-supplies")
		await click(view,Vector2(1440,540)); assert(game.field.state.energy==54 and game.field.state.energy_packs==0)
		var recovered: Dictionary=game.snapshot().duplicate(true)
		await click(view,Vector2(1440,540)); assert(recovered==game.snapshot() and not ui.last_reason.is_empty() and ui.tooltip==ui.last_reason)
		await capture(view,"pack-refusal")
		await click(view,Vector2(1550,630)); assert(ui.armed and ui.specimen=="glass_moss" and not ui.picker)
		before=game.snapshot().duplicate(true)
		await click(view,point); assert(ui.stage=="beam"); ui.advance(0.75); assert(before==game.snapshot())
		await capture(view,"retry-beam")
		await click(view,Vector2(1790,630)); assert(not ui.armed and ui.stage=="cancelled"); ui.advance(2); assert(before==game.snapshot())
		await capture(view,"cancelled")
		await click(view,Vector2(1790,630)); await click(view,Vector2(1230,540)); await click(view,point)
		ui.advance(1.5); assert(ui.stage=="released" and not ui.armed)
		assert(game.field.state.energy==49 and game.biosphere.state.cargo.get("glass_moss",0)==0)
		assert(scene.hud.selected_tool=="scan", "Consumed specimen disarms release and restores scanner")
		before=game.snapshot().duplicate(true); await click(view,point); ui.advance(2); assert(before==game.snapshot())
		var escape:=InputEventKey.new(); escape.keycode=KEY_ESCAPE; escape.pressed=true; view.push_input(escape,true); await process_frame
		assert(ui.stage=="released" and before==game.snapshot(),"Escape preserves completed release result")
		await capture(view,"success-disarmed")
		await click(view,Vector2(1400,930)); assert(ui.tooltip.contains("Glass moss"))
		await capture(view,"slot-tooltip")
		ui.controls.cancel.grab_focus(); await capture(view,"keyboard-focus")
		var key:=InputEventKey.new(); key.keycode=KEY_ENTER; key.pressed=true; view.push_input(key,true); await process_frame
		key=InputEventKey.new(); key.keycode=KEY_ENTER; key.pressed=false; view.push_input(key,true); await process_frame
		assert(ui.picker); await click(view,Vector2(1320,540)); assert(ui.armed and ui.specimen=="snow_bell")
		key=InputEventKey.new(); key.keycode=KEY_ESCAPE; key.pressed=true; view.push_input(key,true); await process_frame
		assert(not ui.armed and before==game.snapshot())
		view.free()
	print("Release interaction:18 captures; injected ground/cargo/pack/cancel/Enter/Escape; refusal/cancel unchanged, pack and single release costs verified.")
	quit()
