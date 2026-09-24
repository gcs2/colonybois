extends SceneTree
## Design audition only. These symbols are not installed in the campaign UI.
const FONT = preload("res://assets/fonts/Barlow-Regular.ttf")
const PATHS := [
	'<path d="M24 7A11 11 0 1 0 27 19M6 25L27 5M5 17L13 25"/>',
	'<path d="M8 6H25L8 26H25M16 3V10M16 22V29"/>',
	'<path d="M7 26V7L16 18L25 7V26M4 14H10M22 14H28"/>'
]
func _initialize() -> void: call_deferred("run")
func label(text: String, at: Vector2, size: int, color: Color, parent: Node) -> void:
	var l := Label.new()
	l.text = text; l.position = at
	l.add_theme_font_override("font",FONT)
	l.add_theme_font_size_override("font_size",size)
	l.add_theme_color_override("font_color",color)
	parent.add_child(l)
func run() -> void:
	var view := SubViewport.new()
	view.size = Vector2i(1440,760)
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	view.gui_disable_input = true
	root.add_child(view)
	var bg := ColorRect.new()
	bg.color = Color("151919"); bg.size = view.size
	view.add_child(bg)
	label("ONE CURRENCY. A SIGN YOU RECOGNIZE.",Vector2(56,34),30,Color("e7e2d5"),view)
	label("Original symbol candidates · working name: Marks · not yet installed",Vector2(56,82),19,Color("aeb6b0"),view)
	var names := ["A / ORBITAL SEAL","B / CROSSED STROKE","C / CUT MARK"]
	for i: int in range(3):
		var panel := PanelContainer.new()
		panel.position = Vector2(56+i*448,146); panel.size = Vector2(420,526)
		var style := StyleBoxFlat.new()
		style.bg_color = Color("242928"); style.border_color = Color("c9c5b7")
		style.border_width_top = 8; style.border_width_bottom = 1
		panel.add_theme_stylebox_override("panel",style)
		view.add_child(panel)
		label(names[i],Vector2(80+i*448,170),20,Color("e7e2d5"),view)
		var img := Image.new()
		var svg: String = '<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 32 32"><g fill="none" stroke="#e2bb76" stroke-width="3" stroke-linecap="square" stroke-linejoin="round">'+PATHS[i]+'</g></svg>'
		assert(img.load_svg_from_string(svg) == OK)
		var texture := ImageTexture.create_from_image(img)
		for sample: Dictionary in [{"at":Vector2(200,222),"size":104},{"at":Vector2(88,402),"size":24},{"at":Vector2(88,482),"size":18},{"at":Vector2(88,562),"size":14}]:
			var icon := TextureRect.new()
			icon.texture = texture; icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.position = sample.at+Vector2(i*448,0); icon.size = Vector2.ONE*sample.size
			view.add_child(icon)
		label("300",Vector2(123+i*448,394),30,Color("e2bb76"),view)
		label("Colony landing kit",Vector2(211+i*448,402),18,Color("e2e4df"),view)
		label("12,480",Vector2(116+i*448,477),24,Color("e2bb76"),view)
		label("Treasury",Vector2(253+i*448,481),17,Color("aeb6b0"),view)
		label("250",Vector2(110+i*448,556),18,Color("e2bb76"),view)
		label("Small tile price · 14 px symbol",Vector2(176+i*448,557),16,Color("aeb6b0"),view)
	label("Choose the silhouette first. The name can change without adding another economy or treasury.",Vector2(56,703),20,Color("b7bdb4"),view)
	for frame: int in range(8): await process_frame
	await RenderingServer.frame_post_draw
	view.get_texture().get_image().save_png("res://artifacts/currency-symbol-candidates.png")
	quit()
