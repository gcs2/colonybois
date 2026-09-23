extends SceneTree
const HUD = preload("res://scripts/flight_hud.gd")
const Fixture = preload("res://tests/palette_fixture.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var hud := HUD.new()
	root.add_child(hud)
	await process_frame
	Fixture.populate(hud)
	for child: Node in hud.get_children():
		if child is Label and child.text == "FLIGHT ASSIST  /  NAVLINK": child.hide()
	hud.label_at("ICON / CAPACITY REVIEW",Rect2(36,40,900,42),28)
	hud.label_at("Dense layout fixture · preview items are not playable content",Rect2(36,90,1000,40),20)
	hud.tool_title.text = "Survey scanner"
	hud.tool_spec.text = "Selected tool stays fixed while browsing pages"
	hud.hull_label.text = "HULL  100 / 100"
	hud.energy_label.text = "ENERGY  65 / 100"
	hud.hull_bar.value = 100
	hud.energy_bar.value = 65
	hud.stats.text = "SCREEN / UI SCALE REVIEW"
	var specification: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/specs/flight_icon_vocabulary_v1.json"))
	for i: int in range(specification.icons.size()):
		var item: Dictionary = specification.icons[i]
		var at := Vector2(48+(i%8)*190,168+(i/8)*158)
		hud.symbol_at(item.id,Rect2(at,Vector2(86,86)),"",item.id)
		hud.label_at(item.id.replace("_"," "),Rect2(at+Vector2(-8,90),Vector2(180,26)),16)
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		root.size = resolution
		for frame: int in range(20): await process_frame
		await RenderingServer.frame_post_draw
		var capture: Image = root.get_texture().get_image()
		assert(capture.get_size() == resolution)
		capture.save_png("res://artifacts/icon_capacity_%d.png" % resolution.y)
	hud.free()
	quit()
