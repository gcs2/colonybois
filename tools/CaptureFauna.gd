extends SceneTree
## Disposable in-engine motion study. Never writes gameplay saves.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene: Node3D = load("res://scenes/encounter.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	scene.set_physics_process(false)
	scene.ship.visible = false
	for i: int in [1,2]: scene.grazers[i].visible = false
	for child: Node in scene.get_children():
		if child is CanvasLayer: child.visible = false
	var canvas := CanvasLayer.new()
	scene.add_child(canvas)
	var title := Label.new()
	title.position = Vector2(50,36)
	title.add_theme_font_size_override("font_size",32)
	canvas.add_child(title)
	var subtitle := Label.new()
	subtitle.position = Vector2(50,84)
	subtitle.add_theme_font_size_override("font_size",20)
	canvas.add_child(subtitle)
	var motion: RefCounted = scene.grazer_motion[0]
	motion.actor.position = Vector3(-9,5,-3)
	motion.home = motion.actor.position
	motion.alarm = 0
	motion.next_blink = 0.6
	var scout := Vector3(-9,5,-10)
	DirAccess.make_dir_recursive_absolute("res://artifacts/fauna_motion")
	for frame: int in range(120):
		if frame == 48: motion.react("warm",motion.actor.position)
		motion.advance(0.05,scout)
		scene.elapsed += 0.05
		scene._update_visuals()
		for label: Label in scene.labels.values(): label.visible = false
		scene.ring.visible = false
		scene.camera.position = motion.actor.position+Vector3(5.5,2.4,-9)
		scene.camera.look_at(motion.actor.position+Vector3(0,-0.8,0))
		title.text = "BELL GRAZER   /   "+motion.mode.to_upper()
		subtitle.text = "Original 3D asset · independent eyes, breathing bell, fins and trailing tendrils"
		await process_frame
		await RenderingServer.frame_post_draw
		var picture: Image = root.get_texture().get_image()
		picture.resize(960,540,Image.INTERPOLATE_LANCZOS)
		picture.save_png("res://artifacts/fauna_motion/%03d.png" % frame)
	print("Rendered 120 animation frames.")
	quit()
