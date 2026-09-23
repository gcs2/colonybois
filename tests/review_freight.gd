extends SceneTree
## Deterministic presentation fixture; gameplay commands are covered separately.
const Session = preload("res://scripts/expedition_session.gd")
func _initialize() -> void: call_deferred("run")
func capture(view: SubViewport, name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	view.get_texture().get_image().save_png("res://artifacts/freight_%s.png" % name)
func run() -> void:
	var game := Session.new()
	game.field.marks = 800
	for id: String in ["s1","s2"]: game.sector.system_by_id(id).visited = true
	game.sector._create_colony("s1p0",false)
	game.colonies.state.outposts.s1p0 = {"site":[-6.0,-18.0],"module":"water","stock":{"water":12,"alloy":0,"glass":0},"status":"Producing water","online_recorded":true}
	game.sector.tick()
	var view := SubViewport.new()
	view.size = Vector2i(1920,1080)
	view.size_2d_override = Vector2i(1600,900); view.size_2d_override_stretch = true
	view.own_world_3d = true; view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = game; view.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	scene.distance = 65; scene._update_camera(1); scene._update_visuals(); scene._refresh_ui()
	scene._show_popup("freight")
	var panel: Node = scene.popup_body.get_children().back()
	panel.destination = "s2p0"; panel.rebuild()
	await capture(view,"contract")
	game.freight.configure(game,"s1p0","s2p0","water",4)
	game.freight.tick(game); game.freight.tick(game)
	scene._refresh_ui()
	scene._show_popup("freight")
	await capture(view,"outbound")
	scene.popup.hide(); scene._toggle_sector_map()
	await capture(view,"chart")
	view.free(); quit()
