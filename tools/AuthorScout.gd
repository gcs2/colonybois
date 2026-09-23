extends SceneTree
## Authored profile geometry. Export is deterministic; nothing is generated during gameplay.
var spec: Dictionary
var materials: Dictionary = {}

func _initialize() -> void:
	spec = JSON.parse_string(FileAccess.get_file_as_string("res://art/specs/scout_v2.json"))
	for key: String in spec.palette:
		var definition: Dictionary = spec.palette[key]
		var mat := StandardMaterial3D.new()
		mat.resource_name = key
		mat.albedo_color = Color(definition.color)
		mat.roughness = definition.roughness
		if definition.has("emission"):
			mat.emission_enabled = true
			mat.emission = mat.albedo_color
			mat.emission_energy_multiplier = definition.emission
		materials[key] = mat
	var craft := make_scout()
	var authored_triangles: int = triangle_count(craft)
	batch(craft)
	var triangles: int = 0
	var meshes: int = 0
	for node: Node in craft.find_children("*","MeshInstance3D",true,false):
		meshes += 1
		for surface: int in range(node.mesh.get_surface_count()):
			var indices: int = node.mesh.surface_get_array_index_len(surface)
			triangles += (indices if indices > 0 else node.mesh.surface_get_array_len(surface))/3
	print("Scout: ",triangles," triangles, ",meshes," mesh instances, ",materials.size()," materials")
	if triangles != authored_triangles:
		craft.free(); printerr("Batching lost authored geometry"); quit(1); return
	if triangles > int(spec.budgets.triangles_max) or meshes > int(spec.budgets.mesh_instances_max):
		craft.free(); printerr("Scout exceeds authored budget"); quit(1); return
	var document := GLTFDocument.new()
	var state := GLTFState.new()
	var error: Error = document.append_from_scene(craft,state)
	if error == OK: error = document.write_to_filesystem(state,"res://"+spec.output)
	craft.free()
	if error != OK: printerr("Scout export failed: ",error)
	quit(0 if error == OK else 1)

func triangle_count(parent: Node3D) -> int:
	var count: int = 0
	for node: Node in parent.find_children("*","MeshInstance3D",true,false):
		for surface: int in range(node.mesh.get_surface_count()):
			var arrays: Array = node.mesh.surface_get_arrays(surface)
			var indices: int = arrays[Mesh.ARRAY_INDEX].size() if arrays[Mesh.ARRAY_INDEX] != null else 0
			count += (indices if indices > 0 else arrays[Mesh.ARRAY_VERTEX].size())/3
	return count

func group(parent: Node3D, title: String, at: Vector3 = Vector3.ZERO) -> Node3D:
	var node := Node3D.new()
	node.name = title; node.position = at; parent.add_child(node)
	return node

func vertex(surface: SurfaceTool, p: Vector3, normal: Vector3, uv: Vector2) -> void:
	surface.set_normal(normal); surface.set_uv(uv); surface.add_vertex(p)

# Smooth, slightly squared cross-sections along the longitudinal axis. Ends are capped.
func loft(parent: Node3D, title: String, sections: Array, key: String, sides: int = 24, offset: Vector3 = Vector3.ZERO) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings: Array = []
	var normals: Array = []
	for i: int in range(sections.size()):
		var row: Array = sections[i]
		var ring: Array[Vector3] = []
		var norm: Array[Vector3] = []
		var prev: Array = sections[maxi(0,i-1)]
		var next: Array = sections[mini(sections.size()-1,i+1)]
		for j: int in range(sides):
			var a: float = TAU*j/sides
			var sx: float = signf(cos(a))*pow(absf(cos(a)),0.82)
			var sy: float = signf(sin(a))*pow(absf(sin(a)),0.82)
			ring.append(Vector3(sx*float(row[1]),sy*float(row[2])+float(row[3]),row[0])+offset)
			var tangent := Vector3(sx*(float(next[1])-float(prev[1])),sy*(float(next[2])-float(prev[2]))+float(next[3])-float(prev[3]),float(next[0])-float(prev[0]))
			var around := Vector3(-sin(a)*float(row[1]),cos(a)*float(row[2]),0)
			norm.append(around.cross(tangent).normalized())
		rings.append(ring); normals.append(norm)
	for i: int in range(sections.size()-1):
		for j: int in range(sides):
			var k: int = (j+1)%sides
			# Godot clockwise winding, viewed from outside.
			for pair: Vector2i in [Vector2i(i,j),Vector2i(i+1,j),Vector2i(i,k),Vector2i(i,k),Vector2i(i+1,j),Vector2i(i+1,k)]:
				vertex(surface,rings[pair.x][pair.y],normals[pair.x][pair.y],Vector2(float(pair.y)/sides,float(pair.x)/(sections.size()-1)))
	for index: int in [0,sections.size()-1]:
		var row: Array = sections[index]
		var center := Vector3(0,row[3],row[0])+offset
		var normal := Vector3.FORWARD if index == 0 else Vector3.BACK
		for j: int in range(sides):
			var k: int = (j+1)%sides
			vertex(surface,center,normal,Vector2(0.5,0.5))
			vertex(surface,rings[index][j if index == 0 else k],normal,Vector2.ZERO)
			vertex(surface,rings[index][k if index == 0 else j],normal,Vector2.ONE)
	var node := MeshInstance3D.new()
	node.name = title; node.mesh = surface.commit(); node.material_override = materials[key]
	parent.add_child(node)

func nozzle(parent: Node3D, at: Vector3) -> void:
	# Hollow rim; a dark throat behind the light gives depth from the rear.
	var ring := TorusMesh.new()
	ring.inner_radius = 0.19; ring.outer_radius = 0.34; ring.rings = 24; ring.ring_segments = 8
	var rim := MeshInstance3D.new()
	rim.mesh = ring; rim.material_override = materials.structure
	rim.position = at; rim.rotation.x = PI/2; parent.add_child(rim)
	loft(parent,"NozzleThroat",[[-0.16,0.25,0.25,0],[-0.015,0.23,0.23,0]],"recess",24,at)
	loft(parent,"NozzleCore",[[-0.014,0.15,0.15,0],[0,0.15,0.15,0]],"light",16,at)

func make_scout() -> Node3D:
	var craft := Node3D.new(); craft.name = "Scout"
	loft(craft,"VentralFrame",spec.hull_sections_z_width_height_y,"structure")
	# Layered carapace with real dark seams and tapered overhangs.
	loft(craft,"ForwardBrow",[[-2.27,0.18,0.1,0.1],[-1.98,0.63,0.17,0.17],[-1.6,0.99,0.2,0.21],[-1.35,1.04,0.18,0.26]],"shell")
	loft(craft,"VisorGasket",[[-1.81,0.56,0.12,0.29],[-1.45,0.91,0.17,0.34],[-0.78,0.91,0.22,0.38],[-0.65,0.72,0.18,0.39]],"recess")
	loft(craft,"RecessedVisor",[[-1.65,0.56,0.1,0.39],[-1.36,0.81,0.12,0.45],[-0.83,0.81,0.15,0.47]],"glass")
	loft(craft,"DorsalShell",[[-0.78,0.92,0.19,0.48],[-0.48,1.05,0.28,0.44],[0.2,1.07,0.29,0.39],[0.73,0.93,0.24,0.32]],"shell")
	loft(craft,"TailShell",[[0.79,0.9,0.22,0.27],[1.22,0.73,0.2,0.19],[1.73,0.44,0.15,0.1],[1.98,0.13,0.05,0.05]],"shell")
	loft(craft,"DorsalMark",[[-0.54,0.24,0.014,0.733],[-0.2,0.27,0.014,0.719],[0.2,0.26,0.014,0.697],[0.69,0.22,0.014,0.56]],"marking",12)
	loft(craft,"TailMark",[[0.83,0.2,0.015,0.5],[1.23,0.16,0.015,0.387],[1.69,0.08,0.012,0.267]],"marking",12)
	for side: float in [-1.0,1.0]:
		var pivot := Vector3(side*0.82,0,0.15)
		var shield := group(craft,"PortShield" if side < 0 else "StarboardShield",pivot)
		# The pod is fused to the chassis; shields trim independently around it.
		loft(craft,"EnginePod",[[-0.1,0.32,0.26,-0.05],[0.6,0.43,0.38,-0.06],[1.7,0.39,0.34,-0.05],[2.35,0.3,0.29,-0.05]],"structure",20,Vector3(side*1.05,0,0))
		loft(craft,"EngineCowl",[[0.25,0.4,0.13,0.18],[0.78,0.45,0.16,0.24],[1.65,0.37,0.14,0.21],[2.19,0.29,0.07,0.2]],"shell",20,Vector3(side*1.05,0,0))
		nozzle(craft,Vector3(side*1.05,-0.05,2.38))
		var offset := Vector3(side*1.65,0,0)-pivot
		loft(shield,"HookShield",[[-2.2,0.04,0.035,-0.07],[-1.77,0.3,0.09,0],[-0.9,0.63,0.18,0.1],[0.15,0.73,0.22,0.11],[1.03,0.58,0.15,0.08],[1.78,0.23,0.07,0.02],[1.94,0.03,0.025,0]],"shell",24,offset)
		loft(shield,"ShieldMark",[[-1.65,0.12,0.02,0.095],[-1.2,0.32,0.02,0.225],[-0.73,0.36,0.02,0.298]],"marking",16,offset)
		loft(shield,"UnderShield",[[-0.8,0.5,0.06,-0.08],[0.2,0.6,0.07,-0.1],[1.15,0.35,0.05,-0.08]],"recess",16,offset)
		for z: float in [0.2,0.47,0.74]:
			loft(shield,"Gill",[[z,0.17,0.013,0.317],[z+0.105,0.15,0.013,0.302]],"structure",8,offset)
		# Shoulder light and cheek sensor remain inset in dark collars.
		loft(craft,"SensorHousing",[[-2.2,0.14,0.1,-0.1],[-1.82,0.18,0.12,-0.1]],"recess",12,Vector3(side*0.5,0,0))
		loft(craft,"SensorLens",[[-2.22,0.09,0.065,-0.1],[-2.2,0.09,0.065,-0.1]],"light",12,Vector3(side*0.5,0,0))
	# A belly-mounted survey aperture and separate reinforced weapon barrel.
	loft(craft,"InstrumentKeel",[[-1.8,0.2,0.14,-0.32],[-1.2,0.35,0.22,-0.35],[0.65,0.3,0.2,-0.33],[1.0,0.1,0.08,-0.31]],"recess",16)
	loft(craft,"LanceSleeve",[[-2.37,0.1,0.1,-0.22],[-1.61,0.16,0.14,-0.22]],"structure",12)
	loft(craft,"LanceAperture",[[-2.39,0.055,0.055,-0.22],[-2.37,0.055,0.055,-0.22]],"light",12)
	var ring := TorusMesh.new()
	ring.inner_radius = 0.15; ring.outer_radius = 0.24; ring.rings = 24; ring.ring_segments = 6
	var collar := MeshInstance3D.new(); collar.mesh = ring; collar.material_override = materials.structure
	collar.position = Vector3(0,-0.57,-1.3); craft.add_child(collar)
	var lens := CylinderMesh.new(); lens.top_radius = 0.15; lens.bottom_radius = 0.15; lens.height = 0.025; lens.radial_segments = 24
	var aperture := MeshInstance3D.new(); aperture.mesh = lens; aperture.material_override = materials.light
	aperture.position = Vector3(0,-0.605,-1.3); craft.add_child(aperture)
	for id: String in spec.sockets:
		var at: Array = spec.sockets[id]
		group(craft,id,Vector3(at[0],at[1],at[2]))
	return craft

func batch(parent: Node3D) -> void:
	var surfaces: Dictionary = {}
	for child: Node in parent.get_children():
		if child is MeshInstance3D:
			var key: String = child.material_override.resource_name
			if not surfaces.has(key):
				var surface := SurfaceTool.new(); surface.begin(Mesh.PRIMITIVE_TRIANGLES); surfaces[key] = surface
			# Mixing indexed primitives with non-indexed lofts can leave earlier
			# vertices unreferenced. Normalize each part before batching.
			var part := SurfaceTool.new()
			part.create_from(child.mesh,0); part.deindex()
			surfaces[key].append_from(part.commit(),0,child.transform)
		elif child is Node3D: batch(child)
	for child: Node in parent.get_children():
		if child is MeshInstance3D: child.free()
	for key: String in surfaces:
		var node := MeshInstance3D.new(); node.name = key.capitalize()
		surfaces[key].index()
		node.mesh = surfaces[key].commit(); node.material_override = materials[key]; parent.add_child(node)
