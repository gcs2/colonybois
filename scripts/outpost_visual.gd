extends Node3D
## Bounded modular construction silhouette. No hidden population or vehicle agents.
var caption := Label3D.new()
func material(color: String, glowing: bool = false) -> StandardMaterial3D:
	var ink := StandardMaterial3D.new()
	ink.albedo_color = Color(color)
	ink.roughness = 0.8
	if glowing: ink.emission_enabled = true; ink.emission = Color(color)*0.6
	return ink
func part(mesh: Mesh, at: Vector3, ink: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = mesh; node.position = at; node.material_override = ink
	add_child(node)
	return node
func box(at: Vector3, dimensions: Vector3, ink: Material) -> void:
	var mesh := BoxMesh.new(); mesh.size = dimensions; part(mesh,at,ink)
func cylinder(at: Vector3, radius: float, height: float, ink: Material, top: float = -1) -> void:
	var mesh := CylinderMesh.new()
	mesh.bottom_radius = radius; mesh.top_radius = radius if top < 0 else top
	mesh.height = height; mesh.radial_segments = 24
	part(mesh,at,ink)
func build(stage: int, module: String) -> void:
	var dark: Material = material("354953")
	var shell: Material = material("d0cbb4")
	var copper: Material = material("c78169")
	var glass: Material = material("65a9a5",true)
	var warning: Material = material("e9b65c",true)
	for at: Vector3 in [Vector3(-4,0.8,-4),Vector3(4,0.8,-4),Vector3(-4,0.8,4),Vector3(4,0.8,4)]:
		cylinder(at,0.12,1.6,dark)
		cylinder(at+Vector3(0,0.85,0),0.22,0.18,warning)
	if stage == 0:
		for index: int in range(4):
			var at := Vector3(-2+(index%2)*3,0.65,-2+(index/2)*2)
			box(at,Vector3(2,1.3,1.2),shell)
			box(at+Vector3(0,0.1,0.63),Vector3(0.4,0.8,0.06),copper)
	else:
		box(Vector3(0,0.3,0),Vector3(8,1.2,8),dark)
		for x: float in [-2.4,2.4]:
			box(Vector3(x,2.2,-1),Vector3(0.25,3.4,0.25),copper)
		box(Vector3(0,3.9,-1),Vector3(5.2,0.3,0.3),copper)
		if stage >= 2:
			cylinder(Vector3(0,1.7,0),2.6,1.8,shell)
			cylinder(Vector3(0,2.85,0),2.7,0.6,copper,1.8)
			cylinder(Vector3(0,3.2,0),1.9,0.3,shell,0.8)
			box(Vector3(0,1.5,2.58),Vector3(1.1,1.6,0.15),dark)
			for x: float in [-1.8,1.8]: box(Vector3(x,2,2.05),Vector3(0.75,0.65,0.3),glass)
			cylinder(Vector3(0,4,0),0.1,1.7,dark)
			var dish := SphereMesh.new(); dish.radius = 0.65; dish.height = 1.3
			var node: MeshInstance3D = part(dish,Vector3(0,4.7,0),glass); node.scale = Vector3(1,0.24,1)
		if stage == 3:
			box(Vector3(-3,1.2,2.5),Vector3(1.2,0.7,1.3),shell)
			if module == "water":
				for x: float in [-2.5,0,2.5]: cylinder(Vector3(x,2,-3),0.65,2.5,glass)
			elif module == "alloy":
				box(Vector3(0,1.4,-3),Vector3(4,1,1.4),dark)
				for x: float in [-1.5,0,1.5]: cylinder(Vector3(x,2,-3),0.45,1.4,copper,0.2)
			elif module == "glass":
				for x: float in [-1.5,1.5]:
					cylinder(Vector3(x,2,-3),0.9,2,copper)
					cylinder(Vector3(x,3.4,-3),0.32,0.9,dark)
	caption.position = Vector3(0,6,0)
	caption.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	caption.font_size = 64; caption.pixel_size = 0.012
	caption.modulate = Color("d5e6d4")
	add_child(caption)
