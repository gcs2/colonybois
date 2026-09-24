extends Node3D
## Bounded original candidate meshes. State owns positions, firing and losses.
const Combat = preload("res://scripts/surface_combat.gd")
const Parts = preload("res://scripts/hostile_vessel.gd")
var actors: Dictionary = {}
var beams: Dictionary = {}
var fins: Dictionary = {}
var flashes: Dictionary = {}
var last_clock: int = -1
var context: String = ""
var phase: float = 0
func setup(catalog: Dictionary) -> void:
	var kit := Parts.new()
	for id: String in catalog:
		var spec: Dictionary = catalog[id]
		var actor := Node3D.new(); add_child(actor); actors[id] = actor
		actor.visible = false
		var shell: Material = kit.ink(spec.color)
		var inset: Material = kit.ink("253944")
		var eye: Material = kit.ink("c7f3c5",true)
		kit.pod(actor,Vector3.ZERO,Vector3(0.9,0.45,1.7),shell)
		kit.pod(actor,Vector3(0,0.35,-0.7),Vector3(0.6,0.12,0.6),inset)
		kit.pod(actor,Vector3(0,0,-1.6),Vector3(0.45,0.16,0.18),eye)
		fins[id] = []
		for side: float in [-1.0,1.0]:
			var fin := Node3D.new(); actor.add_child(fin); fin.position.x = side*0.7
			fins[id].append(fin)
			var size := Vector3(1.15,0.14,1.4) if spec.shape == "fin" else Vector3(0.35,0.35,1.9) if spec.shape == "claw" else Vector3(0.6,0.55,0.8)
			kit.pod(fin,Vector3(side*0.8,0,0.2),size,shell)
			kit.pod(fin,Vector3(side*0.75,0,1.4),Vector3(0.24,0.19,0.3),eye)
		var beam := MeshInstance3D.new(); var mesh := CylinderMesh.new()
		mesh.top_radius = 0.04; mesh.bottom_radius = 0.07; mesh.height = 1
		beam.mesh = mesh; beam.material_override = eye; beam.visible = false
		add_child(beam); beams[id] = beam; flashes[id] = 0.0
	kit.free()
func refresh(game: RefCounted, delta: float, paused: bool) -> void:
	var local: String = game.field.state.planet_id+":"+game.field.state.flight_mode
	var snap: bool = context != local
	context = local
	if not paused: phase += delta
	if last_clock != game.field.state.time:
		last_clock = int(game.field.state.time)
		for flash: Dictionary in game.fleet.flashes:
			var beam: MeshInstance3D = beams[flash.id]
			var from: Vector3 = Combat.position(flash.origin)
			var to: Vector3 = Combat.position(flash.end)
			var axis: Vector3 = (to-from).normalized()
			var side: Vector3 = axis.cross(Vector3.FORWARD).normalized()
			if side.length() < 0.1: side = axis.cross(Vector3.RIGHT).normalized()
			beam.position = (from+to)*0.5
			beam.basis = Basis(side,axis*from.distance_to(to),side.cross(axis))
			flashes[flash.id] = 0.25
	for id: String in actors:
		var actor: Node3D = actors[id]
		var unit: Dictionary = game.fleet.state.ships.get(id,{})
		var show: bool = unit.get("status") == "active" and not game.traveling()
		var was_visible: bool = actor.visible
		actor.visible = show
		if show:
			var destination: Vector3 = Combat.position(unit.at)
			var motion: Vector3 = destination-actor.position
			if snap or not was_visible: actor.position = destination
			elif not paused: actor.position = actor.position.lerp(destination,minf(1,delta*8))
			if motion.length() > 0.1 and not paused: actor.rotation.y = lerp_angle(actor.rotation.y,atan2(-motion.x,-motion.z),delta*4)
			for i: int in range(2): fins[id][i].rotation.z = sin(phase*2.2+i)*0.075
		if not paused: flashes[id] = maxf(0,float(flashes[id])-delta)
		beams[id].visible = show and flashes[id] > 0
