extends SceneTree
## One-off live-render review of the surface target-context card layout.
## Uses a fresh model and isolated review profile; never loads a player campaign.
const Model = preload("res://scripts/encounter_state.gd")
const OUTPUT_DIR := "res://artifacts/target-card-layout-20260927"

func _initialize() -> void:
	call_deferred("run")

func capture(scene: Node3D, resolution: Vector2i) -> void:
	root.size = resolution
	root.content_scale_size = Vector2i(1600,900)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	await process_frame
	scene.paused = false
	scene.selected = "relay"
	scene._refresh_ui()
	scene._update_visuals()
	scene._update_camera(1.0)
	for frame: int in range(3): await process_frame
	await RenderingServer.frame_post_draw
	var suffix := "%d" % resolution.x
	var output := OUTPUT_DIR.path_join("selected-relay-%s.png" % suffix)
	var error: Error = root.get_texture().get_image().save_png(output)
	if error != OK:
		push_error("Could not save selected-relay capture %s (error %d)" % [output,error])
		quit(1)
		return
	print("TARGET_CARD_CAPTURE %s" % output)

func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	scene.model = Model.new()
	scene.save_path = OUTPUT_DIR.path_join("isolated-review-save.json")
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	scene.set_physics_process(false)
	scene.audio.muted = true
	scene.audio.set_volume("voice",0.0)
	scene.paused = false
	scene._change_flight_mode("surface")
	scene._dismiss_first_landing_welcome()
	scene.selected = "relay"
	scene._refresh_ui()
	await capture(scene,Vector2i(1920,1080))
	await capture(scene,Vector2i(2560,1440))
	scene.free()
	quit()
