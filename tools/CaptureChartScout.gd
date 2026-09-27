extends SceneTree
## Reusable transparent chart portrait rendered from the authored player scout.
## Run with: godot --path . --script tools/CaptureChartScout.gd

const OUTPUT_PATH := "res://assets/ui/chart_scout.png"

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var viewport := SubViewport.new()
	viewport.name = "ChartScoutCapture"
	viewport.size = Vector2i(512, 512)
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)

	var stage := Node3D.new()
	stage.name = "Stage"
	viewport.add_child(stage)

	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color(0, 0, 0, 0)
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color = Color("aeb7c4")
	world.environment.ambient_light_energy = 0.7
	stage.add_child(world)

	var key_light := DirectionalLight3D.new()
	key_light.rotation_degrees = Vector3(-42, -32, 0)
	key_light.light_color = Color("fff0d5")
	key_light.light_energy = 1.25
	stage.add_child(key_light)

	var fill_light := DirectionalLight3D.new()
	fill_light.rotation_degrees = Vector3(-18, 145, 0)
	fill_light.light_color = Color("a6c8e5")
	fill_light.light_energy = 0.6
	stage.add_child(fill_light)

	var ship: Node3D = load("res://assets/encounter/scout.glb").instantiate()
	ship.name = "AuthoredScout"
	stage.add_child(ship)

	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 8.4
	var camera_position := Vector3(6.4, 7.0, -9.5)
	camera.position = camera_position
	camera.basis = Basis.looking_at(-camera_position, Vector3.UP)
	stage.add_child(camera)
	camera.current = true

	# Wait for the imported GLB and transparent viewport to finish a real frame.
	for _frame: int in range(3):
		await process_frame
	await RenderingServer.frame_post_draw

	var image := viewport.get_texture().get_image()
	if image.is_empty():
		printerr("Chart scout capture returned an empty image")
		quit(1)
		return
	var error := image.save_png(OUTPUT_PATH)
	if error != OK:
		printerr("Could not save chart scout: ", error)
		quit(1)
		return
	print("Saved %s (%dx%d), transparent=%s" % [OUTPUT_PATH, image.get_width(), image.get_height(), viewport.transparent_bg])
	quit(0)
