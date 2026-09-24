extends SceneTree
## In-engine evidence fixtures; no native-input or visual-approval claim.
const Session = preload("res://scripts/expedition_session.gd")
const War = preload("res://scripts/empire_conflict.gd")
func _initialize() -> void: call_deferred("run")
func capture(scene: Node3D, id: String) -> void:
	scene._update_visuals(); scene._update_camera(1); scene._refresh_ui(); scene.conflict_view.refresh(0)
	await process_frame; await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/conflict-"+id+"-"+str(root.size.x)+".png")
func run() -> void:
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(2560,1440)]:
		root.size = resolution
		var game := Session.new(); game.field.marks = 2000; game.field.change_flight_mode("orbit")
		game.field.state.guardian_hull = 0.0; game.field.state.guardian_disabled = true
		game.diplomacy.contact(game,"directorate"); game.conflict.command(game,"directorate","declare"); game.tick()
		var scene: Node3D = load("res://scenes/encounter.tscn").instantiate(); scene.campaign = game; root.add_child(scene)
		scene.set_process(false); scene.set_physics_process(false); scene.audio.muted = true; scene.save_path = "res://artifacts/conflict-review.fw"
		await capture(scene,"warning")
		scene._show_popup("conflict"); await capture(scene,"response")
		scene._close_popup()
		for i: int in range(90): game.tick()
		scene.ship.position = War.HOME+Vector3(0,0,16)
		game.field.state.position = [scene.ship.position.x,scene.ship.position.y,scene.ship.position.z]
		game.conflict.step(game,scene.ship.position)
		await capture(scene,"combat")
		game.conflict.fire(game,scene.ship.position); scene.conflict_view.line(scene.ship.position,War.HOME)
		await capture(scene,"weapon")
		for i: int in range(75): game.tick()
		scene._show_popup("conflict"); await capture(scene,"damage")
		scene.free()
	print("Conflict captures complete: warning, response, combat, weapon and damage at 1080p/1440p."); quit()
