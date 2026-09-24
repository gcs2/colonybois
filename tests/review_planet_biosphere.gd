extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
const Bio = preload("res://scripts/planet_biosphere.gd")
const Field = preload("res://scripts/encounter_state.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game := Session.new(); game.field.marks = 2000
	for id: String in Bio.native_species("morrow"):
		var at: Vector3 = game.biosphere.site("morrow",id)
		game.biosphere.act(game,id,"scan",at); game.biosphere.act(game,id,"collect",at)
	var view := SubViewport.new(); view.size_2d_override = Vector2i(1600,900); view.size_2d_override_stretch = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS; root.add_child(view)
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); scene.campaign = game
	view.add_child(scene); scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
	scene.save_path = "res://artifacts/biosphere_review.fw"
	for dimensions: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		view.size = dimensions
		for phase: String in ["close","surface","inventory","ecosystem"]:
			scene._close_popup()
			scene.ship.position = Bio.position("morrow","pocket_manta")+Vector3(0,4,6)
			scene.yaw = 0.3; scene.pitch = 0.62; scene.distance = 18 if phase == "close" else 60; scene.camera_distance_target = scene.distance
			scene.biosphere_view.refresh(0.5,false)
			if phase == "inventory": scene._cargo_tab("specimens")
			if phase == "ecosystem": scene._show_popup("biosphere")
			scene._update_camera(1); scene._refresh_ui(); scene._update_visuals()
			for i: int in range(8): await process_frame
			await RenderingServer.frame_post_draw
			view.get_texture().get_image().save_png("res://artifacts/biosphere_%s_%d.png" % [phase,dimensions.y])
	scene.free(); view.free(); quit()
