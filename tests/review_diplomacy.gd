extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var view := SubViewport.new()
	view.size = Vector2i(1920,1080)
	view.size_2d_override = Vector2i(1600,900)
	view.size_2d_override_stretch = true
	view.own_world_3d = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.campaign = Session.new()
	scene.campaign.field.change_flight_mode("orbit")
	view.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false)
	scene.audio.muted = true
	scene.save_path = "res://artifacts/diplomacy_render.json"
	scene.campaign.field.marks = 300
	for id: String in ["directorate","consortium","commune"]:
		scene.campaign.diplomacy.contact(scene.campaign,id)
		scene._contact_select(id)
		scene._update_camera(1); scene._refresh_ui()
		await process_frame
		await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png("res://artifacts/contact_%s.png" % id)
	scene.contacted_faction = "consortium"
	scene._contact_action("trade")
	scene._contact_action("gift")
	scene._contact_action("alliance")
	await process_frame
	await RenderingServer.frame_post_draw
	view.get_texture().get_image().save_png("res://artifacts/contact_response.png")
	scene._show_popup("journal")
	await process_frame
	await RenderingServer.frame_post_draw
	view.get_texture().get_image().save_png("res://artifacts/contact_chronicle.png")
	scene.free(); view.free(); quit()
