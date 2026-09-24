extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var view := SubViewport.new(); view.size_2d_override = Vector2i(1600,900); view.size_2d_override_stretch = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS; root.add_child(view)
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); scene.campaign = Session.new(); view.add_child(scene)
	scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	for id: String in ["moss_lantern","ribbon_bush","hollow_crown"]: scene.campaign.biosphere.act(scene.campaign,id,"scan",scene.campaign.biosphere.site("morrow",id))
	scene.campaign.recognition.state.pinned = "naturalist"
	scene.campaign.field.marks = 125; scene.ship.position = scene.model.service_position("basin_port")
	for dimensions: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		view.size = dimensions
		for phase: String in ["case","reward","notice"]:
			scene.paused = false; scene.recognition_notice.hide()
			if phase == "case": scene._show_popup("badges")
			if phase == "reward":
				var panel: Node = scene.popup_body.get_children().back(); panel.shop_requested.emit("hold")
			if phase == "notice":
				scene._close_popup(); scene.recognition_notice.present({"kind":"badge","id":"naturalist","tier":1},scene.campaign); scene.recognition_notice.advance(0.6,false)
			scene._refresh_ui()
			for i: int in range(5): await process_frame
			await RenderingServer.frame_post_draw
			view.get_texture().get_image().save_png("res://artifacts/progression_%s_%d.png" % [phase,dimensions.y])
	scene.free(); view.free(); quit()
