extends SceneTree

# Local review utility; expects four user-supplied GLBs in the ignored Tripo inbox.
const OUT_DIR := "res://artifacts/visual-critic-surface-pass"
const VIEW_SIZE := Vector2i(960, 540)
const OUTPUT_SIZE := Vector2i(1920, 1080)
const CANDIDATES := [
	{"name": "GEMSTONE OUTCROP", "path": "res://assets/tripo_inbox/tripo-gemstone-outcrop-candidate.glb"},
	{"name": "LANTERN FLORA", "path": "res://assets/tripo_inbox/tripo-lantern-flora-candidate.glb"},
	{"name": "FREIGHT CANISTER", "path": "res://assets/tripo_inbox/tripo-freight-canister-candidate.glb"},
	{"name": "SCOUT SHIP", "path": "res://assets/tripo_inbox/tripo-scout-ship-candidate.glb"},
]

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	root.size = OUTPUT_SIZE
	var views: Array[SubViewport] = []
	for index in range(CANDIDATES.size()):
		var view := SubViewport.new()
		view.size = VIEW_SIZE
		view.own_world_3d = true
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		_add_candidate_view(view, CANDIDATES[index])
		views.append(view)
	for _frame in range(12):
		await process_frame
	await RenderingServer.frame_post_draw
	var board := Image.create(OUTPUT_SIZE.x, OUTPUT_SIZE.y, false, Image.FORMAT_RGBA8)
	board.fill(Color("111b23"))
	for index in range(views.size()):
		var source := views[index].get_texture().get_image()
		var destination := Vector2i((index % 2) * VIEW_SIZE.x, int(index / 2) * VIEW_SIZE.y)
		board.blit_rect(source, Rect2i(Vector2i.ZERO, VIEW_SIZE), destination)
	board.fill_rect(Rect2i(958, 0, 4, 1080), Color("77847f"))
	board.fill_rect(Rect2i(0, 538, 1920, 4), Color("77847f"))
	var output_path := OUT_DIR + "/tripo-inbox-gallery-1080.png"
	assert(board.save_png(output_path) == OK, "Unable to save Tripo preview")
	print("Saved Tripo inbox gallery: " + output_path)
	for view in views:
		view.free()
	quit()

func _add_candidate_view(view: SubViewport, item: Dictionary) -> void:
	var stage := Node3D.new()
	view.add_child(stage)
	_add_environment(stage)
	_add_floor(stage)
	var packed := load(item.path) as PackedScene
	assert(packed != null, "Unable to load " + item.path)
	var instance := packed.instantiate() as Node3D
	assert(instance != null, "Candidate root must be Node3D: " + item.path)
	stage.add_child(instance)
	var mesh_instance := _find_mesh_instance(instance)
	assert(mesh_instance != null, "No MeshInstance3D in " + item.path)
	var bounds := mesh_instance.mesh.get_aabb()
	var dimensions := bounds.size
	var largest_axis := maxf(dimensions.x, maxf(dimensions.y, dimensions.z))
	assert(largest_axis > 0.001, "Empty mesh bounds in " + item.path)
	var fit := 3.6 / largest_axis
	instance.scale = Vector3.ONE * fit
	instance.position = -(bounds.position + bounds.size * 0.5) * fit
	if item.name == "SCOUT SHIP":
		instance.rotation.y = deg_to_rad(24.0)
	var base := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 1.0
	cylinder.bottom_radius = 1.16
	cylinder.height = 0.18
	base.mesh = cylinder
	base.position.y = -1.9
	var base_material := StandardMaterial3D.new()
	base_material.albedo_color = Color("485255")
	base_material.metallic = 0.34
	base_material.roughness = 0.48
	base.material_override = base_material
	stage.add_child(base)
	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 2.2, 6.5)
	camera.fov = 45.0
	stage.add_child(camera)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	camera.current = true
	_add_caption(view, item, dimensions, _triangle_count(mesh_instance.mesh), item.path)
	var importer := ConfigFile.new()
	var import_path: String = str(item.path) + ".import"
	var lods_enabled := importer.load(import_path) == OK and bool(importer.get_value("params", "meshes/generate_lods", false))
	print("Previewed %s | source bounds %s units | triangles %s | Godot import LOD: %s" % [item.name, dimensions, _triangle_count(mesh_instance.mesh), lods_enabled])

func _add_caption(view: SubViewport, item: Dictionary, dimensions: Vector3, triangles: int, path: String) -> void:
	var layer := CanvasLayer.new()
	view.add_child(layer)
	var panel := Panel.new()
	panel.position = Vector2(18.0, 16.0)
	panel.size = Vector2(580.0, 74.0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.07, 0.09, 0.86)
	style.border_color = Color("9b8769")
	style.border_width_left = 3
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	panel.add_theme_stylebox_override("panel", style)
	layer.add_child(panel)
	var label := Label.new()
	label.position = Vector2(14.0, 8.0)
	label.size = Vector2(550.0, 58.0)
	label.text = "%s\nNormalized close-up · source bounds %.2f × %.2f × %.2f units · %.2fM triangles" % [item.name, dimensions.x, dimensions.y, dimensions.z, float(triangles) / 1000000.0]
	label.add_theme_color_override("font_color", Color("f2e8d5"))
	label.add_theme_font_size_override("font_size", 18)
	panel.add_child(label)

func _add_environment(stage: Node3D) -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("111b23")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("bdc9c5")
	environment.ambient_light_energy = 0.68
	world.environment = environment
	stage.add_child(world)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-48.0, -27.0, 0.0)
	key.light_color = Color("ffe5c2")
	key.light_energy = 2.1
	stage.add_child(key)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-18.0, 145.0, 0.0)
	fill.light_color = Color("9bcde0")
	fill.light_energy = 0.72
	stage.add_child(fill)

func _add_floor(stage: Node3D) -> void:
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(8.0, 8.0)
	floor.mesh = plane
	floor.position = Vector3(0.0, -2.02, 0.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("283137")
	material.roughness = 0.86
	floor.material_override = material
	stage.add_child(floor)

func _find_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node as MeshInstance3D
	for child in node.get_children():
		var found := _find_mesh_instance(child)
		if found != null:
			return found
	return null

func _triangle_count(mesh: Mesh) -> int:
	var total := 0
	for surface in range(mesh.get_surface_count()):
		var arrays := mesh.surface_get_arrays(surface)
		var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
		if indices.is_empty():
			var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
			total += vertices.size() / 3
		else:
			total += indices.size() / 3
	return total
