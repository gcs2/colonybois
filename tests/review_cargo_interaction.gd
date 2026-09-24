extends SceneTree
## Isolated GUI prototype: synthetic pointer/key input, real pack command, no player saves.
const Mock = preload("res://tests/review_cargo_mock.gd")
const Session = preload("res://scripts/expedition_session.gd")
const OUT = "res://artifacts/cargo-review"

class Interactive extends Mock.Study:
	var hovered := -1
	var focused := -1
	var notice := ""
	var controls: Dictionary = {}
	func tile(index: int) -> Rect2:
		var local: int = index-page*8
		return Rect2(954+(local%4)*130,385+int(local/4)*143,116,127)
	func button(id: String, rect: Rect2, callback: Callable, disabled: bool = false) -> Button:
		var b := Button.new()
		b.position=rect.position; b.size=rect.size; b.flat=true; b.disabled=disabled
		b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
		for key: String in ["normal","hover","pressed","focus","disabled"]: b.add_theme_stylebox_override(key,StyleBoxEmpty.new())
		b.pressed.connect(callback)
		add_child(b); controls[id]=b
		return b
	func refresh() -> void:
		for id: String in game.biosphere.state.cargo:
			if not icons.has(id): icons[id]=load("res://assets/specimens/%s.png" % id)
		for child: Node in get_children(): remove_child(child); child.queue_free()
		entries.clear(); controls.clear(); action=""; refusal=""; detail=""
		hovered=-1; focused=-1
		prepare()
		for index: int in range(page*8,mini(entries.size(),page*8+8)):
			var b := button("item%d" % index,tile(index),func() -> void:
				selected=index; notice=""; refresh()
				controls["item%d" % index].grab_focus())
			b.mouse_entered.connect(func() -> void: hovered=index; queue_redraw())
			b.mouse_exited.connect(func() -> void: hovered=-1; queue_redraw())
			b.focus_entered.connect(func() -> void: focused=index; queue_redraw())
			b.focus_exited.connect(func() -> void: focused=-1; queue_redraw())
		if section=="supplies":
			button("use",Rect2(1510,709,330,38),func() -> void:
				var before: float = game.field.state.energy if selected==0 else game.field.state.hull
				var why: String=game.field.use_energy_pack() if selected==0 else game.field.use_repair_pack("repair_pack" if selected==1 else "mega_repair_pack")
				var gained: float = (game.field.state.energy if selected==0 else game.field.state.hull)-before
				notice=("Energy pack used · +%d energy" if selected==0 else "Repair pack used · +%d hull") % gained if why.is_empty() else why
				refresh(); controls["item%d" % selected].grab_focus(),not refusal.is_empty())
		if entries.size()>8:
			button("previous",Rect2(1090,701,44,48),func() -> void: page-=1; selected=page*8; refresh(),page==0)
			button("next",Rect2(1202,701,44,48),func() -> void: page+=1; selected=page*8; refresh(),page+1>=ceili(entries.size()/8.0))
		queue_redraw()
	func _draw() -> void:
		super._draw()
		if focused>=0: draw_rect(tile(focused).grow(5),Color("81c0b9"),false,2)
		if hovered>=0:
			var r := tile(hovered)
			draw_rect(r.grow(2),LIGHT,false,1)
			var tip := Rect2(clampf(r.position.x,938,1500),144,338,43)
			panel(tip,DARK,Color("95a599"))
			text(tip.position+Vector2(12,29),entries[hovered].name+" ×"+str(entries[hovered].count),20)
		if not notice.is_empty():
			panel(Rect2(938,834,542,45),DARK)
			text(Vector2(952,864),notice,22,Color("a5d1ba"))

func _initialize() -> void: call_deferred("run")
func move(view: SubViewport, at: Vector2) -> void:
	var event := InputEventMouseMotion.new(); event.position=at; event.global_position=at
	view.push_input(event,true)
	await process_frame
func click(view: SubViewport, at: Vector2) -> void:
	await move(view,at)
	for down: bool in [true,false]:
		var event := InputEventMouseButton.new(); event.position=at; event.global_position=at
		event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down
		view.push_input(event,true)
		await process_frame
func capture(view: SubViewport, state: String) -> void:
	for i: int in range(3): await process_frame
	await RenderingServer.frame_post_draw
	assert(view.get_texture().get_image().save_png(OUT+"/interaction-%s-%d.png" % [state,view.size.y])==OK)
func run() -> void:
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		var view := SubViewport.new(); view.size=resolution
		view.size_2d_override=Vector2i(1920,1080); view.size_2d_override_stretch=true
		view.render_target_update_mode=SubViewport.UPDATE_ALWAYS; root.add_child(view)
		var game := Session.new(); game.field.state.energy=40; game.field.state.energy_packs=2
		var study := Interactive.new(); study.game=game; study.section="supplies"
		study.background=ImageTexture.create_from_image(Image.load_from_file("res://artifacts/field-instruments-review/surface-review-background-v1.png"))
		view.add_child(study); study.refresh()
		await move(view,Vector2(1000,430))
		assert(study.hovered==0,"Pointer must identify the energy pack immediately")
		await capture(view,"hover")
		await move(view,Vector2(850,850))
		study.controls.item1.grab_focus(); await process_frame
		assert(study.focused==1 and study.selected==0)
		await capture(view,"focus")
		await click(view,Vector2(1630,730))
		assert(game.field.state.energy==90 and game.field.state.energy_packs==1)
		assert(study.controls.use.disabled)
		await capture(view,"used-cooldown")
		var snapshot: Dictionary=game.snapshot().duplicate(true)
		await click(view,Vector2(1630,730))
		assert(snapshot==game.snapshot(),"Disabled pack action must not consume another pack")
		study.controls.item1.grab_focus()
		for down: bool in [true,false]:
			var key := InputEventKey.new(); key.keycode=KEY_ENTER; key.pressed=down
			view.push_input(key,true); await process_frame
		assert(study.selected==1 and study.controls.use.disabled)
		assert(study.refusal==game.field.repair_pack_reason("repair_pack"))
		assert(snapshot==game.snapshot(),"Inspecting a repair pack must not use the energy pack")
		await capture(view,"keyboard-repair")
		study.section="specimens"; study.selected=0
		study.notice=""
		for id: String in game.biosphere.data().keys().slice(0,12): game.biosphere.state.cargo[id]=1
		study.refresh()
		snapshot=game.snapshot().duplicate(true)
		await click(view,Vector2(1224,725))
		assert(study.page==1 and study.selected==8 and study.controls.next.disabled)
		assert(snapshot==game.snapshot())
		await capture(view,"page2")
		await move(view,Vector2(1000,430))
		assert(study.hovered==8)
		await capture(view,"page2-hover")
		view.free()
	print("Cargo interaction: synthetic GUI hover, focus, Enter selection, pack use/refusal and pagination verified at two resolutions; 12 captures.")
	quit()
