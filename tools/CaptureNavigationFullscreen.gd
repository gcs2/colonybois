extends SceneTree
const Session = preload("res://scripts/expedition_session.gd")
func _initialize() -> void: call_deferred("run")
func capture(scene: Node3D, label: String) -> void:
	scene._refresh_ui()
	await process_frame; await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/navigation-fullscreen-"+label+"-"+str(root.size.x)+".png")
func run() -> void:
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		root.size = resolution
		var scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); scene.campaign = Session.new(); root.add_child(scene)
		scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true
		scene.model.change_flight_mode("orbit"); scene.model.state.survey_ticks = 12; scene._apply_flight_mode()
		scene._toggle_planet_map(); await capture(scene,"planet"); scene.planet_map.hide()
		# Known three-planet system fixture, not awarded player exploration.
		scene.campaign.sector.system_by_id("s2").visited = true
		scene._open_system_view("s2"); await capture(scene,"system"); scene.system_map.hide()
		scene._toggle_sector_map(); await capture(scene,"sector")
		scene._show_popup("menu"); await capture(scene,"menu")
		scene.free()
	print("Full-screen navigation captures complete."); quit()
