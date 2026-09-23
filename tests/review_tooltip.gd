extends SceneTree
## Engine-local pointer event; does not move or click the operating-system cursor.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var hud: Control = load("res://scripts/flight_hud.gd").new()
	var view := SubViewport.new()
	view.size = Vector2i(1920,1080)
	view.size_2d_override = Vector2i(1600,900)
	view.size_2d_override_stretch = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	view.gui_embed_subwindows = true
	root.add_child(view)
	view.add_child(hud)
	await process_frame
	hud.refresh_items(load("res://scripts/encounter_state.gd").new(),false)
	var button: Button = hud.toolbar[0]
	var motion := InputEventMouseMotion.new()
	motion.position = button.get_global_transform_with_canvas()*(button.size*0.5)
	view.notify_mouse_entered()
	view.push_input(motion,true)
	await create_timer(1.0).timeout
	var shown: bool = false
	for node: Node in root.find_children("*","Label",true,false):
		if node.text == button.tooltip_text and node.is_visible_in_tree(): shown = true
	print("Rendered tool tooltip visible: ",shown)
	if not shown:
		hud.free()
		quit(1)
		return
	await RenderingServer.frame_post_draw
	view.get_texture().get_image().save_png("res://artifacts/tooltip_1080.png")
	hud.free()
	quit()
