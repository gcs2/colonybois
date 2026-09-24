extends SceneTree
## In-engine layout/effect fixtures, not a native combat playtest.
const Session = preload("res://scripts/expedition_session.gd")
const Field = preload("res://scripts/encounter_state.gd")
func _initialize() -> void: call_deferred("run")
func capture(scene: Node3D, label: String) -> void:
	scene._update_visuals(); scene._update_camera(1); scene._refresh_ui()
	scene.support_visual.refresh(scene.model,scene.ship.position,0.5,false)
	await process_frame; await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/support-"+label+"-"+str(root.size.x)+".png")
func run() -> void:
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		root.size = resolution
		var game := Session.new(); game.field.marks = 1200; game.commerce.state.badges.defender = 3
		var scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); scene.campaign = game; root.add_child(scene)
		scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true; scene.save_path = "res://artifacts/support-review.fw"
		scene.ship.position = Field.service_position("basin_port"); scene.selected_service = "basin_port"; scene.dock_page = "upgrades"
		scene.upgrade_family = "support"; scene._show_popup("service"); await capture(scene,"shop")
		for id: String in ["shield","rally_call"]: game.commerce.buy_upgrade(game,"basin_port",scene.ship.position,id)
		scene._close_popup(); game.field.change_flight_mode("orbit"); scene._apply_flight_mode(); scene.ship.position = Vector3(20,8,35)
		scene.distance = 24; scene.camera_distance_target = 24; scene.hud.show_group("Weapons"); scene._select_weapon()
		game.use_support("shield"); game.field.receive_damage(20); await capture(scene,"shield")
		game.use_support("rally_call"); await capture(scene,"rally")
		scene._show_popup("systems"); await capture(scene,"equipment")
		scene._close_popup()
		for i: int in range(12): game.tick()
		await capture(scene,"cooldown")
		scene.free()
	print("Ship support captures complete at 1080p/1440p."); quit()
