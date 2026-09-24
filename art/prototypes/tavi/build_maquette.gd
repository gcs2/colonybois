extends Node3D
## Reproducible original maquette. +Y up, +Z character front; metres.
## Separate anatomical pieces are deliberately editable, not production topology.

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

func mantle(mat: Material) -> void:
	# A continuous low dome with broad overhanging lip and a tucked underside.
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var rings := 40
	var sides := 80
	for i in rings+1:
		var phi := float(i)/rings*PI
		for j in sides+1:
			var theta := float(j)/sides*TAU
			var ring := sin(phi)
			var x := 1.65*ring*cos(theta)
			var z := 1.03*ring*sin(theta)
			var y := 2.55+0.72*cos(phi)
			if phi > PI*0.5:
				y = 2.55+0.27*cos(phi)
			# Slight forward fold and unequal rim: anatomy, not a perfect mushroom.
			y += 0.07*sin(theta*3.0+0.4)*pow(ring,8.0)
			z += 0.12*ring
			vertices.append(Vector3(x,y,z))
			uvs.append(Vector2(float(j)/sides,float(i)/rings))
			if i < rings and j < sides:
				var k := i*(sides+1)+j
				indices.append_array([k,k+sides+1,k+1,k+1,k+sides+1,k+sides+2])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX]=vertices
	arrays[Mesh.ARRAY_TEX_UV]=uvs
	arrays[Mesh.ARRAY_INDEX]=indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var st := SurfaceTool.new()
	st.create_from(mesh,0)
	st.generate_normals()
	st.generate_tangents()
	mesh_node("Broad_mantle",st.commit(),mat)

func build() -> void:
	character.name = "Tavi_Merchant_Maquette"
	add_child(character)
	var skin := material("Mottled_lavender_skin",Color.WHITE,0.64)
	skin.albedo_texture = load("res://skin_color.png")
	skin.normal_enabled = false
	skin.normal_texture = load("res://skin_normal.png")
	skin.normal_scale = 0.24
	var underside := material("Warm_mantle_underside",Color("b09679"),0.75)
	var fold := material("Deep_folds",Color("726075"),0.8)
	var horn := material("Ochre_beak",Color("bb935a"),0.42)
	var eye := material("Pearly_eye",Color("e4d5a3"),0.24)
	var pupil := material("Dark_gloss_eye",Color("111a1b"),0.12)
	var iris := material("Olive_iris",Color("7e905c"),0.25)
	var leather := material("Matte_trade_harness",Color("453e37"),0.9)
	var edge := material("Worn_strap_edges",Color("6b6052"),0.83)
	var clasp := material("Dull_steel_fittings",Color("8e9592"),0.34,0.65)
	var amber := material("Amber_sample",Color("c48e25"),0.26,0.1)
	var luminous := material("Teal_status_glass",Color("52bcae"),0.25,0.25)
	luminous.emission_enabled=true
	luminous.emission=Color("237e74")
	luminous.emission_energy_multiplier=0.35
	# Lower weight is planted, shoulders disappear beneath the great mantle.
	ellipsoid("Heavy_pear_body",Vector3(0,0.95,0),Vector3(1.13,1.25,0.78),skin)
	ellipsoid("Forward_soft_belly",Vector3(0,0.75,0.37),Vector3(1.04,0.83,0.56),skin)
	ellipsoid("Recessed_throat",Vector3(0,1.95,0.27),Vector3(0.79,0.85,0.6),skin)
	mantle(skin)
	ellipsoid("Mantle_underside",Vector3(0,2.43,0.12),Vector3(1.53,0.28,0.93),underside)
	ellipsoid("Continuous_throat_mass",Vector3(0,1.87,0.51),Vector3(0.65,0.70,0.48),underside)
	# Lateral independently aimable eyes; no humanoid face or brows.
	for s in [-1.0,1.0]:
		var offset := 0.1 if s < 0 else -0.09
		tube("Eye_stalk_left" if s < 0 else "Eye_stalk_right",[Vector3(s*1.1,2.6,0.37),Vector3(s*1.48,2.72+offset,0.47),Vector3(s*1.78,2.70+offset,0.62)],[0.35,0.28,0.23],skin,28,20)
		var p := Vector3(s*1.79,2.72+offset,0.65)
		ellipsoid("Eye_socket_"+str(s),p,Vector3(0.275,0.29,0.21),fold)
		ellipsoid("Eye_sclera_"+str(s),p+Vector3(0,0,0.065),Vector3(0.215,0.23,0.17),eye)
		ellipsoid("Eye_iris_"+str(s),p+Vector3(-s*0.025,0.01,0.234),Vector3(0.15,0.174,0.038),iris)
		ellipsoid("Eye_pupil_"+str(s),p+Vector3(-s*0.025,0.01,0.263),Vector3(0.103,0.127,0.032),pupil)
	# Ribbed soft feeding veil framing a small two-piece beak.
	for s in [-1.0,1.0]:
		for i in 3:
			var x := 0.23+0.19*i
			tube("Facial_velum_%s_%s"%[s,i],[Vector3(s*x,2.4,0.81),Vector3(s*(x*0.63),2.08,0.91),Vector3(s*(x*0.83),1.65,0.88),Vector3(s*(0.28+0.1*i),1.19,0.70)],[0.14,0.15,0.115,0.03],skin,32,20)
	tube("Upper_beak",[Vector3(0,2.34,0.79),Vector3(0,2.22,0.87),Vector3(0,2.04,0.84)],[0.145,0.105,0.005],horn,20,18)
	tube("Lower_beak",[Vector3(0.04,2.17,0.72),Vector3(0.04,2.02,0.77),Vector3(0.01,2.06,0.87)],[0.11,0.07,0.005],underside,18,16)
	# Two shoulder straps follow the round body; named separate parts for editing.
	for s in [-1.0,1.0]:
		tube("Trade_harness_"+str(s),[Vector3(s*0.78,1.97,0.16),Vector3(s*0.87,1.65,0.59),Vector3(s*0.88,1.05,0.76),Vector3(s*0.63,0.4,0.8)],[0.125,0.13,0.13,0.12],leather,30,8)
		var buckle := box("Strap_buckle_"+str(s),Vector3(s*0.85,1.4,0.79),Vector3(0.31,0.31,0.07),clasp)
		buckle.rotation.z=s*-0.15
		box("Buckle_recess_"+str(s),Vector3(s*0.85,1.4,0.835),Vector3(0.19,0.20,0.045),leather)
	tube("Chest_band",[Vector3(-0.86,1.16,0.68),Vector3(0,1.0,0.99),Vector3(0.86,1.16,0.68)],[0.13,0.13,0.13],leather,30,8)
	box("Central_trade_seal",Vector3(0,1.05,1.02),Vector3(0.4,0.3,0.075),clasp)
	box("Trade_seal_glass",Vector3(0,1.05,1.07),Vector3(0.24,0.10,0.026),luminous)
	box("Sample_pouch",Vector3(0.86,0.8,0.86),Vector3(0.33,0.42,0.19),leather)
	box("Pouch_flap",Vector3(0.86,0.94,0.97),Vector3(0.36,0.17,0.045),edge)
	# Relaxed large tentacles, one offered wares gesture and one confident curl.
	tube("Tentacle_presenting",[Vector3(-0.82,1.3,0.05),Vector3(-1.28,0.72,0.3),Vector3(-1.43,0.48,0.77),Vector3(-1.5,1.0,1.0),Vector3(-1.42,1.56,1.02),Vector3(-1.14,1.76,1.0),Vector3(-1.03,1.57,1.08)],[0.36,0.32,0.28,0.22,0.17,0.115,0.024],skin,90,24)
	tube("Tentacle_confident_curl",[Vector3(0.93,1.32,0.0),Vector3(1.27,0.72,0.48),Vector3(1.16,0.25,0.91),Vector3(0.65,0.32,1.17),Vector3(0.3,0.66,1.20),Vector3(0.34,0.93,1.17),Vector3(0.6,0.94,1.13),Vector3(0.67,0.77,1.19)],[0.35,0.34,0.30,0.23,0.20,0.14,0.08,0.016],skin,96,24)
	tube("Small_grasping_tentacle",[Vector3(-0.45,0.56,0.77),Vector3(-0.75,0.8,1.18),Vector3(-0.71,1.16,1.2),Vector3(-0.95,1.32,1.12)],[0.2,0.17,0.11,0.015],skin,40,16)
	# Suckers placed on visible inner arm surfaces; simple maquette disks.
	for i in 7:
		var y := 0.59+i*0.127
		ellipsoid("Presenting_sucker_%02d"%i,Vector3(-1.49+0.04*i/7.0,y,1.17),Vector3(0.105-0.005*i,0.10-0.004*i,0.045),underside)
	for i in 6:
		ellipsoid("Resting_sucker_%02d"%i,Vector3(0.36+i*0.13,0.45-i*0.017,1.31),Vector3(0.066,0.072,0.03),underside)
	# Amber sample capsule held between two tentacles; opaque for reliable export.
	var vial := CylinderMesh.new()
	vial.top_radius=0.13
	vial.bottom_radius=0.13
	vial.height=0.58
	vial.radial_segments=24
	mesh_node("Amber_sample_vial",vial,amber,Vector3(-1.06,1.34,1.02))
	for y in [1.04,1.64]:
		var cap := CylinderMesh.new()
		cap.top_radius=0.16
		cap.bottom_radius=0.16
		cap.height=0.08
		cap.radial_segments=24
		mesh_node("Vial_cap_"+str(y),cap,clasp,Vector3(-1.06,y,1.02))
	box("Vial_view_strip",Vector3(-1.055,1.34,1.145),Vector3(0.07,0.40,0.012),eye)

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
	for child in character.get_children():
		if child is MeshInstance3D:
			meshes+=1
			used_materials[child.material_override.resource_name]=true
			for s in child.mesh.get_surface_count():
				var arrays: Array=child.mesh.surface_get_arrays(s)
				vertices+=arrays[Mesh.ARRAY_VERTEX].size()
				triangles+=int(arrays[Mesh.ARRAY_INDEX].size()/3) if arrays[Mesh.ARRAY_INDEX]!=null and arrays[Mesh.ARRAY_INDEX].size()>0 else int(arrays[Mesh.ARRAY_VERTEX].size()/3)
	return {"triangles":triangles,"vertices":vertices,"mesh_nodes":meshes,"material_count":used_materials.size(),"materials":used_materials.keys(),"texture_inputs":[{"path":"skin_color.png","size":[1024,1024],"used_in_export":true},{"path":"skin_normal.png","size":[1024,1024],"used_in_export":false}],"normal_map_note":"Generated experiment disabled; no sculpt bake, production UV atlas or active normal texture.","rigged":false,"animated":false,"production_ready":false,"renderer":"Godot 4.7.2 Compatibility","concept_fidelity":"unapproved dimensional maquette"}

func _ready() -> void:
	build()
	stage()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var document := GLTFDocument.new()
	var state := GLTFState.new()
	var append_error := document.append_from_scene(character,state)
	var export_error := document.write_to_filesystem(state,"res://tavi_maquette.glb") if append_error==OK else append_error
	var stats := measure()
	stats["glb_export_error"]=export_error
	# Verify and render the actual exported asset, not just its source geometry.
	var imported_state := GLTFState.new()
	var imported_doc := GLTFDocument.new()
	var import_error := imported_doc.append_from_file("res://tavi_maquette.glb", imported_state)
	stats["glb_reimport_error"]=import_error
	if import_error==OK:
		var imported_root := imported_doc.generate_scene(imported_state)
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
		label.text="ACTUAL 3D MAQUETTE — NOT FINAL ART\nDrag: orbit · Wheel: zoom · R: reset · Esc: close"
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


