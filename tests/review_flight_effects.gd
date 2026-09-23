extends SceneTree
## Render real components in arranged review states, without loading player saves.
func _initialize() -> void: call_deferred("run")
func capture(scene: Node, name: String) -> void:
	scene._update_camera(1)
	scene._update_visuals()
	scene._refresh_ui()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/flight_effects_"+name+".png")
func run() -> void:
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	scene.set_physics_process(false)
	scene.audio.muted = true
	scene.audio.set_volume("voice",0)
	scene.camera_distance_target = 110
	await capture(scene,"surface_wide")
	scene.camera_distance_target = 19
	scene.yaw = -0.65
	for i: int in range(35):
		scene.effects.update(1.0/60,16,false,false,scene.terrain_height(scene.ship.position.x,scene.ship.position.z),"scan",false,Vector3.ZERO,0)
		await process_frame
	await capture(scene,"thrust")
	scene.effects.reset()
	scene.ship.position = scene._target_position("relay")+Vector3(0,3,6)
	scene._command_target("relay")
	scene.camera_distance_target = 25
	for i: int in range(36):
		scene._operate(1.0/60)
		scene._update_flight_effects(1.0/60)
		await process_frame
	await capture(scene,"scan")
	scene._stop()
	scene._change_flight_mode("orbit")
	scene.arrival_fade = 0
	scene._update_flight_effects(1)
	scene.camera_distance_target = 320
	await capture(scene,"orbit_wide")
	scene.free()
	quit()
