extends Node3D
## Local orbital space shares the expedition state; no second economy or scene tick.
const Globe = preload("res://scripts/planet_globe.gd")
var planet := Globe.new()
var environment: WorldEnvironment
const APPROACH := Vector3(0,8,8)

func _ready() -> void:
	planet.position = Vector3(-14,-8,-14)
	add_child(planet)
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
