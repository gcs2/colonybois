extends Node3D
## Original modular hostile silhouettes; material/socket specification in art/specs.
var eye: MeshInstance3D
var vanes: Array[Node3D] = []
var phase: float = 0
var disabled: bool = false
func ink(color: String, luminous: bool = false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color); material.roughness = 0.82
	if luminous: material.emission_enabled = true; material.emission = Color(color)*0.7
	return material
func pod(parent: Node3D, at: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new(); var mesh := SphereMesh.new()
	mesh.radius = 1; mesh.height = 2; mesh.radial_segments = 24; mesh.rings = 12
	node.mesh = mesh; node.position = at; node.scale = size; node.material_override = material
	parent.add_child(node)
	return node
func build(profile: Dictionary) -> void:
	var shell: Material = ink(profile.color)
	var inset: Material = ink("263741")
	var trim: Material = ink("d8d0b5")
	var glow: Material = ink("f6bc78",true)
	if int(profile.chase) > 0:
		# A narrow armored back and two forward claws leave a readable open jaw.
		pod(self,Vector3.ZERO,Vector3(1.2,0.65,2.7),shell)
		pod(self,Vector3(0,0.55,-0.6),Vector3(0.7,0.25,1.2),inset)
		for side: float in [-1.0,1.0]:
			var arm := Node3D.new(); arm.position = Vector3(side*1.3,0,0)
			add_child(arm); vanes.append(arm)
			pod(arm,Vector3(side*0.65,0,-0.6),Vector3(0.65,0.3,2.3),shell)
			pod(arm,Vector3(side*0.5,0,-2.6),Vector3(0.45,0.22,0.8),trim)
			pod(arm,Vector3(0,-0.15,1.8),Vector3(0.5,0.4,0.7),inset)
			pod(arm,Vector3(0,-0.15,2.35),Vector3(0.27,0.23,0.2),glow)
		eye = pod(self,Vector3(0,0.15,-2.1),Vector3(0.55,0.2,0.35),glow)
	else:
		# A heavy bell with a suspended focusing eye and three folding antenna fins.
		pod(self,Vector3(0,0.6,0),Vector3(2.5,0.9,2.5),shell)
		pod(self,Vector3(0,-0.1,0),Vector3(1.8,0.5,1.8),inset)
		pod(self,Vector3(0,1.25,0),Vector3(0.7,0.45,0.7),trim)
		for i: int in range(3):
			var fin := Node3D.new(); fin.rotation.y = TAU*i/3
			add_child(fin); vanes.append(fin)
			pod(fin,Vector3(2.4,-0.3,0),Vector3(0.6,0.25,0.8),trim)
			pod(fin,Vector3(2.6,-0.8,0),Vector3(0.18,0.65,0.28),inset)
		eye = pod(self,Vector3(0,-0.65,0),Vector3(0.75,0.6,0.75),glow)
func advance(delta: float) -> void:
	if disabled: return
	phase += delta
	for i: int in range(vanes.size()): vanes[i].rotation.z = sin(phase*1.6+i)*0.035
