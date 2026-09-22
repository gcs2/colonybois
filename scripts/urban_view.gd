extends RefCounted
## Batched background city and modular alien architecture; no simulation agents.

static func draw_context(game: Node3D) -> void:
	var bodies: Array[Transform3D] = []
	var bands: Array[Transform3D] = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 907
	for x: int in range(12,54,2):
		for z: int in range(10,56,2):
			if x >= 21 and x <= 43 and z >= 23 and z <= 41: continue
			if x % 8 == 0 or z % 8 == 0: continue
			if game.sim.terrain("s0p0",x,z) != "land": continue
			var height: float = rng.randf_range(1.0,3.0)
			var pos := Vector3(x-31.5,height/2,z-31.5)
			bodies.append(Transform3D(Basis.from_scale(Vector3(1,height,1)),pos))
			bands.append(Transform3D(Basis.from_scale(Vector3(1.03,0.12,1.03)),pos+Vector3(0,height*0.2,0)))
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.54
	cylinder.bottom_radius = 0.68
	cylinder.height = 1
	cylinder.radial_segments = 8
	_batch(game,cylinder,bodies,Color("a3b8c9"))
	_batch(game,cylinder,bands,Color("85e2c1"))
	for coordinate: int in range(16,53,8):
		for segment: Vector2 in [Vector2(10,23),Vector2(42,56)]:
			game._box(game.world,Vector3(coordinate-31.5,0.05,(segment.x+segment.y)/2-31.5),Vector3(1.1,0.07,segment.y-segment.x),Color("435e70"))
		game._box(game.world,Vector3(-14,0.05,coordinate-31.5),Vector3(10,0.07,1.1),Color("435e70"))
		game._box(game.world,Vector3(17,0.05,coordinate-31.5),Vector3(10,0.07,1.1),Color("435e70"))
	for x: int in [16,48]:
		for z: int in [16,48]:
			var ring := TorusMesh.new()
			ring.inner_radius = 0.55
			ring.outer_radius = 1.1
			ring.rings = 16
			ring.ring_segments = 8
			game._mesh(game.world,ring,Vector3(x-31.5,0.1,z-31.5),Color("435e70"))
	# The border denotes authority, not a physical barrier between city districts.
	for pair: Array in [[Vector3(-10,0.14,-8),Vector3(11,0.14,-8)],[Vector3(11,0.14,-8),Vector3(11,0.14,9)],[Vector3(11,0.14,9),Vector3(-10,0.14,9)],[Vector3(-10,0.14,9),Vector3(-10,0.14,-8)]]:
		game._line(game.world,pair[0],pair[1],Color("79e5c0"),0.035)
	game._world_label(game.world,"SOUTH LOOP · YOUR DISTRICT",Vector3(0,0.4,10),Color("79e5c0"),19)

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
