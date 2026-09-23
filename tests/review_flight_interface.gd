extends SceneTree
## Reproducible rendered review; isolated --script state, never the player's save.
func _initialize() -> void: call_deferred("run")

func capture(scene: Node, name: String) -> void:
	scene._refresh_ui()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/flight_ui_"+name+".png")

func run() -> void:
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	scene.set_physics_process(false)
	scene.audio.muted = true
	scene.audio.set_volume("voice",0)
	scene.model.act("scan","pod",4)
	scene.model.act("collect","pod",4)
	scene._refresh_ui()
	await capture(scene,"hud")
	scene._show_popup("cargo")
	await capture(scene,"cargo")
	scene._show_popup("systems")
	scene._inspect_system("warm")
	await capture(scene,"systems")
	root.size = Vector2i(1280,720)
	await capture(scene,"systems_720")
	scene._toggle_planet_map()
	await capture(scene,"atlas_uncharted")
	scene.planet_map.hide()
	scene._change_flight_mode("orbit")
	scene.model.start_survey()
	for i: int in range(12): scene.model.tick()
	scene._toggle_planet_map()
	await capture(scene,"atlas_charted")
	scene.planet_map.set_layer(true)
	await capture(scene,"atlas_coverage")
	scene.free()
	quit()
