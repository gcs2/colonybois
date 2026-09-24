extends SceneTree
const Session=preload("res://scripts/expedition_session.gd")
const Field=preload("res://scripts/encounter_state.gd")
const Study=preload("res://tests/service_interaction_panel.gd")
const OUT="res://artifacts/service-review"
func _initialize() -> void: call_deferred("run")
func click(view: SubViewport, at: Vector2) -> void:
	var move:=InputEventMouseMotion.new(); move.position=at; view.push_input(move,true); await process_frame
	for down: bool in [true,false]:
		var event:=InputEventMouseButton.new(); event.position=at; event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down
		view.push_input(event,true); await process_frame
func key(view: SubViewport, code: Key) -> void:
	for down: bool in [true,false]:
		var event:=InputEventKey.new(); event.keycode=code; event.pressed=down
		view.push_input(event,true); await process_frame
func capture(view: SubViewport, tag: String) -> void:
	for frame: int in range(3): await process_frame
	await RenderingServer.frame_post_draw
	assert(view.get_texture().get_image().save_png(OUT+"/input-%s-%d.png" % [tag,view.size.y])==OK)
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		var game:=Session.new(); game.field.state=Field.fresh("s7p0"); game.field.bind_account(game.sector.state); game.configure_flagship()
		game.field.change_flight_mode("orbit"); game.diplomacy.contact(game,"consortium")
		game.field.state.hull=15.0; game.field.state.energy=15.0; game.field.marks=200
		# Three-stock fixture isolates lack of funds from the sold-out refusal.
		game.field.state.repair_stock.orbit_tender.repair_pack=3
		var view:=SubViewport.new(); view.size=resolution; view.size_2d_override=Vector2i(1920,1080); view.size_2d_override_stretch=true
		view.render_target_update_mode=SubViewport.UPDATE_ALWAYS; root.add_child(view)
		var scene: Node3D=load("res://scenes/encounter.tscn").instantiate(); scene.campaign=game; scene.process_mode=Node.PROCESS_MODE_DISABLED
		view.add_child(scene); scene.audio.muted=true; scene.ship.position=Field.service_position("orbit_tender"); scene._update_camera(1)
		for child: Node in scene.get_children():
			if child is CanvasLayer: child.hide()
		var overlay:=CanvasLayer.new(); view.add_child(overlay)
		var study:=Study.new(); study.game=game; study.scene=scene; overlay.add_child(study)
		await process_frame
		var move:=InputEventMouseMotion.new(); move.position=Vector2(870,520); view.push_input(move,true); await process_frame
		assert(study.tooltip=="Repair pack"); await capture(view,"hover")
		await click(view,Vector2(870,520)); assert(study.selected=="repair_pack")
		await click(view,Vector2(1380,670))
		assert(game.field.marks==120 and game.field.state.repair_packs.repair_pack==1 and game.field.state.hull==15)
		await capture(view,"purchased")
		await click(view,Vector2(1380,670))
		assert(game.field.marks==40 and game.field.state.repair_packs.repair_pack==2)
		var unchanged: Dictionary=game.snapshot()
		assert(game.service_reason("orbit_tender",scene.ship.position,"repair_pack")=="Need 80 Marks.")
		await click(view,Vector2(1380,670)); assert(game.snapshot()==unchanged and study.controls.buy.disabled)
		await capture(view,"unaffordable")
		await click(view,Vector2(1240,765)); assert(study.inventory_open and study.selected=="repair_pack")
		await capture(view,"inventory")
		await key(view,KEY_TAB); await key(view,KEY_TAB)
		assert(study.controls.use.has_focus(),"Tab navigation reaches Use from retained item selection")
		await capture(view,"keyboard-focus")
		await key(view,KEY_ENTER)
		assert(game.field.state.hull==90 and game.field.state.repair_packs.repair_pack==1 and game.field.marks==40 and game.field.state.energy==15)
		await capture(view,"used-cooldown")
		unchanged=game.snapshot(); await click(view,Vector2(1380,670)); assert(game.snapshot()==unchanged)
		# Explicit review clock: let the shared repair cooldown expire without world ticks.
		game.field.state.time+=20; study.refresh(); await process_frame
		await click(view,Vector2(1380,670))
		assert(game.field.state.hull==100 and game.field.state.repair_packs.repair_pack==0 and game.field.marks==40 and game.field.state.energy==15)
		await capture(view,"second-use")
		await key(view,KEY_ESCAPE); assert(not study.inventory_open and not study.closed and study.selected=="repair_pack")
		await capture(view,"back-to-dock")
		unchanged=game.snapshot(); await click(view,Vector2(1390,359)); assert(game.snapshot()==unchanged)
		await capture(view,"refuel-refused")
		# Explicit affordability fixture; then the real input-driven transaction.
		game.field.marks=100; study.refresh(); await process_frame
		study.controls.refuel.grab_focus(); await key(view,KEY_ENTER)
		assert(game.field.marks==49 and game.field.state.energy==100)
		unchanged=game.snapshot(); await key(view,KEY_ENTER); assert(game.snapshot()==unchanged)
		await capture(view,"refueled")
		await click(view,Vector2(1240,765)); await click(view,Vector2(738,520))
		assert(study.controls.use.disabled and study.selected=="pack")
		unchanged=game.snapshot(); await click(view,Vector2(1380,670)); assert(game.snapshot()==unchanged)
		await capture(view,"empty-pack")
		await key(view,KEY_ESCAPE); await key(view,KEY_ESCAPE); assert(study.closed and game.snapshot()==unchanged)
		view.free()
	print("Service interaction:22 captures; injected pointer/Tab/Enter/Escape, buy-versus-use, cooldown/empty/funds refusals, single debit and persistent selection verified. Not native play.")
	quit()
