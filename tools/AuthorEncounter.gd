extends SceneTree
## Reproducible, dimensioned candidate mesh source. Hand-set profiles, no random asset shapes.
var palette: Dictionary

func _initialize() -> void:
	var spec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/encounter_art.json"))
	palette = spec.palette
	DirAccess.make_dir_recursive_absolute("res://assets/encounter")
	for entry: Dictionary in spec.assets:
		var asset: Node3D = make_asset(entry.id)
		asset.name = entry.id.capitalize()
		merge_materials(asset)
		var document := GLTFDocument.new()
		var gltf := GLTFState.new()
		var error: Error = document.append_from_scene(asset,gltf)
		if error == OK: error = document.write_to_filesystem(gltf,"res://assets/encounter/"+entry.id+".glb")
		asset.free()
		if error != OK:
			printerr("Asset export failed: ",entry.id," ",error)
			quit(1)
			return
		print("Authored ",entry.id)
	quit()

func merge_materials(asset: Node3D) -> void:
	# Author separate parts, then batch static geometry into one surface per palette material.
	var groups: Dictionary = {}
	for child: Node in asset.get_children():
		if not child is MeshInstance3D:
			if child is Node3D: merge_materials(child)
			continue
		var mat: StandardMaterial3D = child.material_override
		var key: String = mat.albedo_color.to_html()+str(mat.emission_enabled)+str(mat.cull_mode)
		if not groups.has(key):
			var surface := SurfaceTool.new()
			surface.begin(Mesh.PRIMITIVE_TRIANGLES)
			groups[key] = {"surface":surface,"material":mat}
		groups[key].surface.append_from(child.mesh,0,child.transform)
	for child: Node in asset.get_children():
		if child is MeshInstance3D: child.free()
	for key: String in groups:
		var node := MeshInstance3D.new()
		node.name = "Palette_"+key
		node.mesh = groups[key].surface.commit()
		node.material_override = groups[key].material
		asset.add_child(node)

func group(parent: Node3D, id: String, at: Vector3 = Vector3.ZERO) -> Node3D:
	var node := Node3D.new()
	node.name = id
	node.position = at
	parent.add_child(node)
	return node

func material(key: String, glow: bool = false) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(palette.get(key,key))
	mat.roughness = 0.65
	if glow:
		mat.emission_enabled = true
		mat.emission = mat.albedo_color
		mat.emission_energy_multiplier = 0.22
	return mat

func ellipsoid(parent: Node3D, name_text: String, at: Vector3, size: Vector3, key: String, glow: bool = false) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = 1
	mesh.height = 2
	mesh.radial_segments = 20
	mesh.rings = 10
	var node := MeshInstance3D.new()
	node.name = name_text
	node.mesh = mesh
	node.material_override = material(key,glow)
	node.position = at
	node.scale = size
	parent.add_child(node)
	return node

func tube(parent: Node3D, name_text: String, points: Array[Vector3], radii: Array[float], key: String, sides: int = 10) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings: Array[PackedVector3Array] = []
	for i: int in range(points.size()):
		var tangent: Vector3 = (points[mini(i+1,points.size()-1)]-points[maxi(0,i-1)]).normalized()
		var axis: Vector3 = tangent.cross(Vector3.RIGHT).normalized()
		if axis.length() < 0.1: axis = tangent.cross(Vector3.UP).normalized()
		var across: Vector3 = tangent.cross(axis).normalized()
		var ring := PackedVector3Array()
		for j: int in range(sides): ring.append(points[i]+(axis*cos(TAU*j/sides)+across*sin(TAU*j/sides))*radii[i])
		rings.append(ring)
	for i: int in range(points.size()-1):
		for j: int in range(sides):
			var k: int = (j+1)%sides
			for p: Vector3 in [rings[i][j],rings[i][k],rings[i+1][j],rings[i][k],rings[i+1][k],rings[i+1][j]]: surface.add_vertex(p)
	surface.generate_normals()
	var node := MeshInstance3D.new()
	node.name = name_text
	node.mesh = surface.commit()
	node.material_override = material(key)
	node.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
	parent.add_child(node)

func make_asset(id: String) -> Node3D:
	var root := Node3D.new()
	match id:
		"scout":
			ellipsoid(root,"Ceramic hull",Vector3.ZERO,Vector3(0.9,0.46,1.9),"shell")
			ellipsoid(root,"Canopy",Vector3(0,0.37,-0.55),Vector3(0.66,0.31,0.94),"glass")
			for side: float in [-1.0,1.0]:
				tube(root,"Swept fin",[Vector3(side*0.6,0,0.4),Vector3(side*1.2,-0.06,0.9),Vector3(side*1.9,0.05,1.7)],[0.43,0.26,0.02],"shell",12)
				ellipsoid(root,"Engine collar",Vector3(side*0.65,0,1.4),Vector3(0.35,0.33,0.45),"trim")
				ellipsoid(root,"Exhaust",Vector3(side*0.65,0,1.78),Vector3(0.22,0.20,0.13),"light",true)
			ellipsoid(root,"Sensor",Vector3(0.65,-0.16,-1.3),Vector3(0.24,0.24,0.28),"light",true)
		"pod":
			for i: int in range(3):
				var theta: float = i*TAU/3
				var tip := Vector3(cos(theta)*0.8,3.0+i*0.35,sin(theta)*0.8)
				tube(root,"Arched stem",[Vector3.ZERO,Vector3(cos(theta)*0.4,1.4,sin(theta)*0.4),tip],[0.19,0.14,0.04],"plant")
				ellipsoid(root,"Seed bladder",tip,Vector3(0.48,0.78,0.48),"light",true)
				for rib: int in range(5):
					var a: float = rib*TAU/5
					tube(root,"Bladder rib",[tip+Vector3(0,-0.8,0),tip+Vector3(cos(a)*0.49,0,sin(a)*0.49),tip+Vector3(0,0.8,0)],[0.035,0.045,0.015],"trim",6)
				var leaf: MeshInstance3D = ellipsoid(root,"Basal leaf",Vector3(cos(theta)*0.6,0.24,sin(theta)*0.6),Vector3(0.32,0.16,0.9),"plant")
				leaf.rotation.y = -theta+PI/2
		"grazer":
			var body: Node3D = group(root,"Body")
			ellipsoid(body,"Bell",Vector3.ZERO,Vector3(1.6,1.1,1.2),"fauna")
			ellipsoid(body,"Underside",Vector3(0,-0.72,0),Vector3(1.1,0.35,0.83),"plant")
			for i: int in range(3):
				var x: float = (i-1)*0.7
				var eye: Node3D = group(body,"Eye_%d" % i,Vector3(x,0.1,-1))
				ellipsoid(eye,"Eye socket",Vector3.ZERO,Vector3(0.37,0.39,0.25),"shell")
				var gaze: Node3D = group(eye,"Gaze_%d" % i)
				ellipsoid(gaze,"Eye",Vector3(0,0,-0.2),Vector3(0.22,0.27,0.15),"glass")
				ellipsoid(gaze,"Catchlight",Vector3(-0.06,0.1,-0.33),Vector3(0.065,0.07,0.035),"light",true)
			var tendrils: Node3D = group(body,"Tendrils")
			for i: int in range(6):
				var a: float = i*TAU/6
				var direction := Vector3(cos(a),0,sin(a))
				var points: Array[Vector3] = []
				var radii: Array[float] = []
				for j: int in range(13):
					var t: float = j/12.0
					points.append(direction*(0.75+0.3*sin(t*PI)+0.7*t*t)+Vector3(0,-0.65-t*2.2+0.35*pow(t,5),0))
					radii.append(0.19*pow(1.0-t,0.7)+0.005)
				tube(tendrils,"Feeding tendril",points,radii,"fauna",8)
			for side: float in [-1.0,1.0]:
				var hinge: Node3D = group(body,"FinLeft" if side < 0 else "FinRight",Vector3(side*1.15,0,0.2))
				var fin: MeshInstance3D = ellipsoid(hinge,"Fin",Vector3(side*0.4,0,0),Vector3(0.8,0.12,0.8),"plant")
				fin.rotation.z = side*0.25
		"relay":
			for side: float in [-1.0,1.0]:
				tube(root,"Broken arch",[Vector3(side*1.3,0,0),Vector3(side*1.2,2,0),Vector3(side*1.0,4.6,0),Vector3(side*0.4,5.7,0)],[0.7,0.55,0.42,0.15],"shell",6)
				tube(root,"Copper inlay",[Vector3(side*0.8,0.4,-0.4),Vector3(side*0.7,2.5,-0.4),Vector3(side*0.5,4.5,-0.3)],[0.075,0.075,0.025],"trim",6)
			ellipsoid(root,"Core",Vector3(0,2.8,0),Vector3(0.42,0.65,0.42),"glass")
	return root
