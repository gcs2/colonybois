extends Node3D
## Local orbital space shares the expedition state; no second economy or scene tick.
const Globe = preload("res://scripts/planet_globe.gd")
const WRECK_POSITION := Vector3(32,8,32)
var planet := Globe.new()
var environment: WorldEnvironment
var wreck := Node3D.new()
var field_ring: MeshInstance3D
var pulse_core: MeshInstance3D
var phase: float = 0.0
const APPROACH := Vector3(0,8,8)

func _ready() -> void:
	planet.position = Vector3(-14,-8,-14)
	add_child(planet)
	_build_wreck()
	var stars := MultiMesh.new()
	stars.transform_format = MultiMesh.TRANSFORM_3D
	var star := SphereMesh.new()
	star.radius = 0.13
	star.height = 0.26
	star.radial_segments = 4
	star.rings = 2
	stars.mesh = star
	stars.instance_count = 320
	var rng := RandomNumberGenerator.new()
	rng.seed = 1948
	for i: int in range(stars.instance_count):
		var at := Vector3(rng.randf_range(-1,1),rng.randf_range(-1,1),rng.randf_range(-1,1)).normalized()*180
		stars.set_instance_transform(i,Transform3D(Basis.IDENTITY,at))
	var field := MultiMeshInstance3D.new()
	field.multimesh = stars
	var star_material := StandardMaterial3D.new()
	star_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	star_material.albedo_color = Color("b9cadb")
	field.material_override = star_material
	add_child(field)
	environment = WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("030713")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("607ca1")
	env.ambient_light_energy = 0.3
	environment.environment = env
	add_child(environment)

func advance(delta: float) -> void:
	planet.rotation.y += delta*0.018
	phase += delta
	wreck.rotation.y += delta*0.18
	field_ring.scale = Vector3.ONE*(1+sin(phase*TAU/6)*0.025)
	pulse_core.scale = Vector3.ONE*(0.94+sin(phase*TAU/6)*0.16)

func _material(color: Color) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	result.albedo_color = color
	result.emission_enabled = true
	result.emission = color
	result.emission_energy_multiplier = 1.6
	return result

func _build_wreck() -> void:
	wreck.position = WRECK_POSITION
	add_child(wreck)
	# A broken, asymmetrical vessel at the center of a visible six-second field.
	for fragment: Vector3 in [Vector3(-1.4,0,-0.5),Vector3(0.7,0,0.25),Vector3(1.6,0.4,1.0)]:
		var shard := MeshInstance3D.new()
		var shape := BoxMesh.new()
		shape.size = Vector3(1.5,0.65,3.8) if fragment.x < 0 else Vector3(0.9,0.5,1.8)
		shard.mesh = shape
		shard.position = fragment
		shard.rotation.y = fragment.x*0.6
		shard.material_override = _material(Color("79738a"))
		wreck.add_child(shard)
	pulse_core = MeshInstance3D.new()
	var orb := SphereMesh.new()
	orb.radius = 1.1
	orb.height = 2.2
	pulse_core.mesh = orb
	pulse_core.position = Vector3(0,1.2,0)
	pulse_core.material_override = _material(Color("a17ed4"))
	wreck.add_child(pulse_core)
	field_ring = MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 18.8
	torus.outer_radius = 19.1
	torus.rings = 96
	torus.ring_segments = 6
	field_ring.mesh = torus
	field_ring.material_override = _material(Color("81639e"))
	field_ring.position = WRECK_POSITION
	add_child(field_ring)
