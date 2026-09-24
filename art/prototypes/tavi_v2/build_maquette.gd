extends Node3D
## Reproducible connected implicit sculpt review. +Y up, +Z front; metres.
## Generated body from sculpt_mesh.py; separate eye/prop meshes. Not production topology.

var character := Node3D.new()
var materials: Dictionary = {}
var camera: Camera3D
var output_dir := "res://renders"
var inspect_mode := false
var orbit_yaw := 0.4
var orbit_pitch := 0.13

func _unhandled_input(event: InputEvent) -> void:
	if not inspect_mode:
		return
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		orbit_yaw -= event.relative.x*0.008
		orbit_pitch = clampf(orbit_pitch+event.relative.y*0.008,-0.65,0.85)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index==MOUSE_BUTTON_WHEEL_UP:
			camera.size=maxf(2.5,camera.size-0.25)
		if event.button_index==MOUSE_BUTTON_WHEEL_DOWN:
			camera.size=minf(8.0,camera.size+0.25)
	if event is InputEventKey and event.pressed:
		if event.keycode==KEY_ESCAPE:
			get_tree().quit()
		if event.keycode==KEY_R:
			orbit_yaw=0.4
			orbit_pitch=0.13
			camera.size=4.6
	update_orbit()

func update_orbit() -> void:
	var target := Vector3(0,1.52,0.28)
	camera.position=target+Vector3(sin(orbit_yaw)*cos(orbit_pitch),sin(orbit_pitch),cos(orbit_yaw)*cos(orbit_pitch))*8.0
	camera.look_at(target)

func material(id: String, color: Color, roughness: float = 0.5, metal: float = 0.0) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.resource_name = id
	result.albedo_color = color
	result.roughness = roughness
	result.metallic = metal
	materials[id] = result
	return result

func mesh_node(id: String, mesh: Mesh, mat: Material, pos: Vector3 = Vector3.ZERO, size: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = id
	node.mesh = mesh
	node.material_override = mat
	node.position = pos
	node.scale = size
	character.add_child(node)
	return node

func ellipsoid(id: String, pos: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
	var sphere := SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 2.0
	sphere.radial_segments = 20 if size.length() < 0.6 else 40
	sphere.rings = 12 if size.length() < 0.6 else 24
	return mesh_node(id, sphere, mat, pos, size)

func box(id: String, pos: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh_node(id, mesh, mat, pos)

func tube(id: String, points: Array[Vector3], radii: Array[float], mat: Material, samples: int = 48, sides: int = 12) -> MeshInstance3D:
	var curve := Curve3D.new()
	for i in points.size():
		var tangent := Vector3.ZERO
		if i > 0 and i < points.size()-1:
			tangent = (points[i+1]-points[i-1])*0.17
		curve.add_point(points[i], -tangent, tangent)
	curve.bake_interval = 0.025
	var length := curve.get_baked_length()
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for i in samples+1:
		var f := float(i)/samples
		var d := f*length
		var center := curve.sample_baked(d, true)
		var direction := (curve.sample_baked(minf(d+0.012,length),true)-curve.sample_baked(maxf(d-0.012,0.0),true)).normalized()
		var ref := Vector3.FORWARD if absf(direction.dot(Vector3.FORWARD)) < 0.96 else Vector3.RIGHT
		var x := direction.cross(ref).normalized()
		var y := direction.cross(x).normalized()
		var rpos := f*(radii.size()-1)
		var r := lerpf(radii[int(rpos)],radii[mini(int(rpos)+1,radii.size()-1)],fmod(rpos,1.0))
		for j in sides+1:
			var angle := float(j)/sides*TAU
			var n := x*cos(angle)+y*sin(angle)
			vertices.append(center+n*r)
			normals.append(n)
			uvs.append(Vector2(float(j)/sides,f*2.0))
			if i < samples and j < sides:
				var k := i*(sides+1)+j
				indices.append_array([k,k+sides+1,k+1,k+1,k+sides+1,k+sides+2])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX]=vertices
	arrays[Mesh.ARRAY_NORMAL]=normals
	arrays[Mesh.ARRAY_TEX_UV]=uvs
	arrays[Mesh.ARRAY_INDEX]=indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh_node(id,mesh,mat)

func build() -> void:
	character.name="Tavi_V2_Connected_Sculpt"
	add_child(character)
	var doc:=GLTFDocument.new()
	var state:=GLTFState.new()
	var error:=doc.append_from_file("res://connected_anatomy.glb",state)
	assert(error==OK,"Generate connected_anatomy.glb with sculpt_mesh.py first")
	character.add_child(doc.generate_scene(state))
	for mesh_instance in character.find_children("*","MeshInstance3D",true,false):
		var pigment: StandardMaterial3D=mesh_instance.mesh.surface_get_material(0)
		pigment.vertex_color_use_as_albedo=true
		pigment.vertex_color_is_srgb=false
		print("PIGMENT ",mesh_instance.mesh.surface_get_arrays(0)[Mesh.ARRAY_COLOR].size()," ",mesh_instance.mesh.surface_get_arrays(0)[Mesh.ARRAY_COLOR][0])
	var eye:=material("Warm_eye_rim",Color("bda476"),0.32)
	var iris:=material("Reflective_olive_eye",Color("687153"),0.22)
	var pupil:=material("Black_gloss_pupil",Color("0c1716"),0.16)
	var horn:=material("Ochre_beak",Color("a28455"),0.55)
	var leather:=material("Matte_trade_harness",Color("39362f"),0.92)
	var metal:=material("Muted_steel_fittings",Color("8b9189"),0.48,0.45)
	var amber:=material("Amber_sample",Color("9c6920"),0.34,0.05)
	var sucker:=material("Warm_suckers",Color("ad9274"),0.82)
	for s in [-1.0,1.0]:
		var lift:=0.11 if s<0 else -0.05
		var p:=Vector3(s*1.73,2.64+lift,0.87)
		ellipsoid("Eye_rim_"+str(s),p,Vector3(0.197,0.215,0.15),eye)
		ellipsoid("Eye_iris_"+str(s),p+Vector3(-s*0.017,0.01,0.116),Vector3(0.15,0.17,0.062),iris)
		ellipsoid("Eye_pupil_"+str(s),p+Vector3(-s*0.022,0.01,0.164),Vector3(0.107,0.126,0.035),pupil)
		tube("Harness_shoulder_"+str(s),[Vector3(s*0.72,1.97,0.24),Vector3(s*0.92,1.6,0.65),Vector3(s*0.98,1.05,0.79),Vector3(s*0.73,0.49,0.84)],[0.13,0.13,0.13,0.12],leather,38,12)
		var buckle:=box("Harness_clasp_"+str(s),Vector3(s*0.89,1.54,0.75),Vector3(0.27,0.25,0.055),metal)
		buckle.rotation.z=s*-0.2
		var inset:=box("Clasp_leather_"+str(s),Vector3(s*0.89,1.54,0.79),Vector3(0.18,0.13,0.025),leather)
		inset.rotation.z=s*-0.2
	tube("Harness_chest",[Vector3(-0.91,1.11,0.78),Vector3(-0.4,0.95,0.96),Vector3(0.35,0.95,0.97),Vector3(0.94,1.11,0.75)],[0.085,0.10,0.10,0.085],leather,42,12)
	tube("Upper_beak",[Vector3(0,2.36,0.82),Vector3(0,2.23,0.94),Vector3(0,2.06,0.90)],[0.125,0.105,0.005],horn,24,20)
	tube("Lower_beak",[Vector3(0.03,2.11,0.8),Vector3(0.025,2.01,0.83),Vector3(0.01,2.08,0.91)],[0.085,0.065,0.003],horn,20,20)
	for i in 7:
		ellipsoid("Sucker_presenting_%02d"%i,Vector3(-1.49+0.015*i,0.74+0.113*i,1.235),Vector3(0.10-0.005*i,0.094-0.004*i,0.034),sucker)
	for i in 5:
		ellipsoid("Sucker_curl_%02d"%i,Vector3(0.55+i*0.13,0.41-i*0.02,1.34-i*0.025),Vector3(0.064,0.070,0.027),sucker)
	var vial:=CylinderMesh.new()
	vial.top_radius=0.115
	vial.bottom_radius=0.115
	vial.height=0.54
	vial.radial_segments=32
	mesh_node("Amber_sample_capsule",vial,amber,Vector3(-1.10,1.24,1.14))
	for y in [0.95,1.53]:
		var cap:=CylinderMesh.new()
		cap.top_radius=0.13
		cap.bottom_radius=0.13
		cap.height=0.065
		cap.radial_segments=32
		mesh_node("Sample_closure_"+str(y),cap,metal,Vector3(-1.10,y,1.14))
	box("Sample_inspection_strip",Vector3(-1.10,1.24,1.252),Vector3(0.042,0.37,0.01),eye)

func stage() -> void:
	var env := WorldEnvironment.new()
	env.environment=Environment.new()
	env.environment.background_mode=Environment.BG_COLOR
	env.environment.background_color=Color("333942")
	env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color=Color("cacbd1")
	env.environment.ambient_light_energy=0.35
	env.environment.tonemap_mode=Environment.TONE_MAPPER_LINEAR
	add_child(env)
	for setup in [[Vector3(-4,6,5),Color("fff0d8"),0.60],[Vector3(5,3,3),Color("d4e7ff"),0.18],[Vector3(2,5,-4),Color("d6d6ff"),0.28]]:
		var light := DirectionalLight3D.new()
		add_child(light)
		light.position=setup[0]
		light.look_at(Vector3(0,1.6,0))
		light.light_color=setup[1]
		light.light_energy=setup[2]
		light.shadow_enabled=setup[0].x < 0
		light.shadow_blur=2.5
		light.directional_shadow_max_distance=15
	var floor_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size=Vector2(200,200)
	floor_mesh.mesh=plane
	floor_mesh.position.y=-0.34
	floor_mesh.material_override=material("Review_floor",Color("535863"),0.95)
	add_child(floor_mesh)
	camera=Camera3D.new()
	camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	camera.size=4.6
	camera.near=0.1
	camera.far=100
	add_child(camera)
	camera.current=true
	get_viewport().msaa_3d=Viewport.MSAA_4X

func measure() -> Dictionary:
	var triangles := 0
	var vertices := 0
	var meshes := 0
	var used_materials: Dictionary = {}
	for child in character.find_children("*","MeshInstance3D",true,false):
		if child is MeshInstance3D:
			meshes+=1
			var mat: Material=child.material_override if child.material_override else child.mesh.surface_get_material(0)
			used_materials[mat.resource_name]=true
			for s in child.mesh.get_surface_count():
				var arrays: Array=child.mesh.surface_get_arrays(s)
				vertices+=arrays[Mesh.ARRAY_VERTEX].size()
				triangles+=int(arrays[Mesh.ARRAY_INDEX].size()/3) if arrays[Mesh.ARRAY_INDEX]!=null and arrays[Mesh.ARRAY_INDEX].size()>0 else int(arrays[Mesh.ARRAY_VERTEX].size()/3)
	return {"triangles":triangles,"vertices":vertices,"mesh_nodes":meshes,"material_count":used_materials.size(),"materials":used_materials.keys(),"texture_inputs":[],"pigment":"Continuous vertex colors on connected sculpt; no UV texture","rigged":false,"animated":false,"production_ready":false,"renderer":"Godot 4.7.2 Compatibility","concept_fidelity":"unapproved sculpt-like dimensional proof"}

func _ready() -> void:
	build()
	stage()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var document := GLTFDocument.new()
	var state := GLTFState.new()
	var append_error := document.append_from_scene(character,state)
	var export_error := document.write_to_filesystem(state,"res://tavi_v2_maquette.glb") if append_error==OK else append_error
	var stats := measure()
	stats["glb_export_error"]=export_error
	# Verify and render the actual exported asset, not just its source geometry.
	var imported_state := GLTFState.new()
	var imported_doc := GLTFDocument.new()
	var import_error := imported_doc.append_from_file("res://tavi_v2_maquette.glb", imported_state)
	stats["glb_reimport_error"]=import_error
	if import_error==OK:
		var imported_root := imported_doc.generate_scene(imported_state)
		for mesh_instance in imported_root.find_children("*","MeshInstance3D",true,false):
			var mat: Material=mesh_instance.mesh.surface_get_material(0)
			if mat is StandardMaterial3D and mat.resource_name=="Matte_lavender_vertex_pigment":
				mat.vertex_color_use_as_albedo=true
				mat.vertex_color_is_srgb=false
		character.hide()
		add_child(imported_root)
		stats["renders_from_reimported_glb"]=true
	else:
		stats["renders_from_reimported_glb"]=false
	var f:=FileAccess.open("res://model_stats.json",FileAccess.WRITE)
	f.store_string(JSON.stringify(stats,"  "))
	f.close()
	print("MODEL_STATS ",JSON.stringify(stats))
	inspect_mode=OS.get_cmdline_user_args().has("--inspect")
	if inspect_mode:
		var label := Label.new()
		label.text="ACTUAL CONNECTED SCULPT — NOT FINAL ART\nDrag: orbit · Wheel: zoom · R: reset · Esc: close"
		label.position=Vector2(24,24)
		label.add_theme_font_size_override("font_size",18)
		add_child(label)
		update_orbit()
		return
	for setup in [["front",Vector3(0,2.2,8)],["three_quarter",Vector3(3.4,2.5,8)],["side",Vector3(8,2.1,0)],["rear",Vector3(0,2.4,-8)]]:
		camera.position=setup[1]
		camera.look_at(Vector3(0,1.52,0.28))
		for i in 5:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var result := get_viewport().get_texture().get_image().save_png(output_dir+"/"+setup[0]+".png")
		print("RENDER ",setup[0]," ",result)
	get_tree().quit(0 if export_error==OK else 1)





