extends SceneTree
const Globe = preload("res://scripts/planet_globe.gd")
const Generator = preload("res://scripts/planet_generator.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1600,900)
	var world := Node3D.new()
	root.add_child(world)
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("070d1a")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("a7bac8")
	env.ambient_light_energy = 0.35
	environment.environment = env
	world.add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-20,-55,0)
	sun.light_energy = 1.3
	world.add_child(sun)
	var camera := Camera3D.new()
	world.add_child(camera)
	camera.position = Vector3(0,1.5,19)
	camera.fov = 50
	camera.look_at(Vector3.ZERO)
	camera.current = true
	var kinds := ["temperate","frozen","arid"]
	var seeds := [1948,7123,8831]
	for i: int in range(3):
		var globe := Globe.new()
		globe.radius = 3.5
		globe.position.x = (i-1)*8
		globe.planet_definition = Generator.make_recipe(kinds[i],seeds[i],kinds[i])
		if i == 0: globe.planet_definition = preload("res://scripts/planet_geography.gd").definition().duplicate(true)
		globe.rotation.y = -0.3
		world.add_child(globe)
		print(kinds[i]," geography bake ms: ",globe.generator.maps().generation_ms)
	var layer := CanvasLayer.new()
	root.add_child(layer)
	for line: Dictionary in [{"text":"FRONTIER WORLDS  /  PLANET GEOGRAPHY","position":Vector2(60,48),"size":28}, {"text":"MORROW / TEMPERATE                 FROZEN / SEED 7123                    ARID / SEED 8831","position":Vector2(230,660),"size":23}, {"text":"In-engine generation study · shared spherical elevation, moisture and temperature · candidate art","position":Vector2(110,800),"size":20}]:
		var label := Label.new()
		label.text = line.text
		label.position = line.position
		label.add_theme_font_size_override("font_size",line.size)
		label.modulate = Color("c6dbdf")
		layer.add_child(label)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/planet_generation_review.png")
	world.queue_free(); layer.queue_free()
	quit()
