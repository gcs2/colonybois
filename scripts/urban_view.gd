extends RefCounted
## Batched background city and modular alien architecture; no simulation agents.

static func draw_context(game: Node3D) -> void:
	var bodies: Array[Transform3D] = []
	var bands: Array[Transform3D] = []
	var slabs: Array[Transform3D] = []
	var roads: Array[Transform3D] = []
	var gardens: Array[Transform3D] = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 907
	# City-wide scenery is batched. Unequal borough extents and a river break symmetry.
	game._box(game.world,Vector3(0,-0.18,0),Vector3(270,0.12,240),Color("455b50"))
	game._box(game.world,Vector3(-112,-0.09,0),Vector3(34,0.06,240),Color("234657"))
	for bx: int in range(-9,12):
		for bz: int in range(-8,10):
			var center := Vector2(bx*10.0,bz*10.0)
			var edge: float = pow((center.x-12)/109.0,2)+pow((center.y+3)/88.0,2)
			if edge > 1.0+0.07*sin(bz*1.3): continue
			var shift: float = sin(float(bz)*0.4)*2.2
			if absf(center.x) >= 20 or absf(center.y) >= 20:
				roads.append(Transform3D(Basis.from_scale(Vector3(10,0.08,1.1)),Vector3(center.x+shift,0.015,center.y-5)))
				roads.append(Transform3D(Basis.from_scale(Vector3(1.1,0.08,10)),Vector3(center.x-5+shift,0.015,center.y)))
			var park: bool = (bx*7+bz*3)%13 == 0
			for dx: int in range(3):
				for dz: int in range(3):
					var x: float = center.x+shift-3.0+dx*2.8
					var z: float = center.y-3.0+dz*2.8
					if x > -13 and x < 14 and z > -11 and z < 12: continue
					if park or rng.randf() < 0.12:
						gardens.append(Transform3D(Basis.from_scale(Vector3(0.7,0.85,0.7)),Vector3(x,0.5,z)))
						continue
					var downtown: float = maxf(0,1.0-Vector2(x-48,z+22).length()/28.0)
					var height: float = rng.randf_range(1.4,3.8)+downtown*8
					var width: float = rng.randf_range(1.1,1.8)
					var transform := Transform3D(Basis.from_scale(Vector3(width,height,width)),Vector3(x,height/2,z))
					if (bx+bz)%3 == 0: slabs.append(transform)
					else: bodies.append(transform)
					for floor_index: int in range(1,int(height/0.55)):
						bands.append(Transform3D(Basis.from_scale(Vector3(width*1.015,0.075,width*1.015)),Vector3(x,float(floor_index)*0.55,z)))
	var shell := CylinderMesh.new()
	shell.top_radius = 0.42
	shell.bottom_radius = 0.5
	shell.height = 1
	shell.radial_segments = 8
	var slab := BoxMesh.new()
	slab.size = Vector3(1,1,0.75)
	var road := BoxMesh.new()
	road.size = Vector3.ONE
	var leaf := SphereMesh.new()
	leaf.radius = 0.5
	leaf.height = 1
	leaf.radial_segments = 8
	leaf.rings = 4
	_batch(game,shell,bodies,Color("9a9baf"))
	_batch(game,slab,slabs,Color("baab97"))
	_batch(game,shell,bands,Color("405f64"))
	_batch(game,road,roads,Color("34464a"))
	_batch(game,leaf,gardens,Color("6e9585"))
	for point: Vector3 in [Vector3(-35,0.12,-15),Vector3(55,0.12,35),Vector3(25,0.12,-45)]:
		var ring := TorusMesh.new()
		ring.inner_radius = 2.1
		ring.outer_radius = 3.2
		ring.rings = 24
		ring.ring_segments = 8
		game._mesh(game.world,ring,point,Color("34464a"))
		game._sphere(game.world,point+Vector3(0,1.0,0),1.2,Color("8691ac"))
	for pair: Array in [[Vector3(-10,0.14,-8),Vector3(11,0.14,-8)],[Vector3(11,0.14,-8),Vector3(11,0.14,9)],[Vector3(11,0.14,9),Vector3(-10,0.14,9)],[Vector3(-10,0.14,9),Vector3(-10,0.14,-8)]]:
		game._line(game.world,pair[0],pair[1],Color("79e5c0"),0.035)
	game._world_label(game.world,"SOUTH LOOP",Vector3(0,1,12),Color("79e5c0"),22)

static func _batch(game: Node3D, shape: Mesh, transforms: Array[Transform3D], color: Color) -> void:
	var instances := MultiMesh.new()
	instances.transform_format = MultiMesh.TRANSFORM_3D
	instances.mesh = shape
	instances.instance_count = transforms.size()
	for i: int in range(transforms.size()): instances.set_instance_transform(i,transforms[i])
	var node := MultiMeshInstance3D.new()
	node.multimesh = instances
	node.material_override = game._material(color)
	game.world.add_child(node)

static func draw_building(game: Node3D, parent: Node3D, pos: Vector3, cell: Dictionary, connected: bool) -> bool:
	if cell.type not in ["habitat","service"] or int(cell.level) == 0: return false
	var height: float = 0.8+float(cell.level)*0.55
	var body := CylinderMesh.new()
	body.top_radius = 0.30
	body.bottom_radius = 0.40
	body.height = height
	body.radial_segments = 8
	var color := Color("b3a4ca") if cell.type == "habitat" else Color("80b8bc")
	game._mesh(parent,body,pos+Vector3(0,height/2,0),color)
	for floor_index: int in range(int(cell.level)+1):
		var band := TorusMesh.new()
		band.inner_radius = 0.30
		band.outer_radius = 0.38
		band.rings = 12
		band.ring_segments = 6
		game._mesh(parent,band,pos+Vector3(0,0.35+floor_index*0.44,0),Color("adebd9") if connected else Color("526071"),0.2 if connected else 0.0)
	# Paired roof organs read as strange civic technology, without humanoid towers.
	for side: float in [-0.17,0.17]:
		game._sphere(parent,pos+Vector3(side,height+0.08,0),0.14,color.lightened(0.1))
	return true
