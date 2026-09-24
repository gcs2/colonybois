extends SceneTree
## Reproducible portraits rendered from the same original gameplay geometry.
const View = preload("res://scripts/biosphere_view.gd")
const Bio = preload("res://scripts/planet_biosphere.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/specimens")
	var viewport := SubViewport.new(); viewport.size = Vector2i(192,192); viewport.transparent_bg = true
	viewport.own_world_3d = true; viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS; root.add_child(viewport)
	var kit := View.new(); viewport.add_child(kit)
	var environment := WorldEnvironment.new(); var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR; settings.background_color = Color(0,0,0,0)
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; settings.ambient_light_color = Color("b9cbd0"); settings.ambient_light_energy = 0.65
	environment.environment = settings; viewport.add_child(environment)
	var light := DirectionalLight3D.new(); light.rotation_degrees = Vector3(-35,-35,0); light.light_energy = 1.1; viewport.add_child(light)
	var camera := Camera3D.new(); camera.projection = Camera3D.PROJECTION_ORTHOGONAL; viewport.add_child(camera)
	for id: String in Bio.data():
		var actor: Node3D = kit.make_actor(id)
		var role: String = Bio.data()[id].role
		var focus := Vector3(0,1.2,0) if role == "large" else Vector3(0,0.4,0)
		camera.size = 5.6 if role == "large" else 4.4; camera.position = focus+Vector3(4,2,-6); camera.look_at(focus)
		for i: int in range(3): await process_frame
		await RenderingServer.frame_post_draw
		viewport.get_texture().get_image().save_png("res://assets/specimens/"+id+".png")
		actor.free()
	viewport.free(); quit()
