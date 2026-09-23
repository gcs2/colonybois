extends Node3D
## Local orbital space shares the expedition state; no second economy or scene tick.
var planet := Node3D.new()
var environment: WorldEnvironment
const APPROACH := Vector3(0,8,8)

func _ready() -> void:
	planet.position = Vector3(-14,-8,-14)
	add_child(planet)
	var sphere := SphereMesh.new()
	sphere.radius = 18
	sphere.height = 36
	sphere.radial_segments = 64
	sphere.rings = 32
	var globe := MeshInstance3D.new()
	globe.mesh = sphere
	var shader := Shader.new()
	shader.code = """shader_type spatial;
	varying vec3 local_position;
	float hash(vec3 p){return fract(sin(dot(p,vec3(127.1,311.7,74.7)))*43758.5453);}
	float noise3(vec3 p){
		vec3 i=floor(p); vec3 f=fract(p); f=f*f*(3.0-2.0*f);
		return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),
		mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z);
	}
	float fbm(vec3 p){return noise3(p)*0.57+noise3(p*2.07)*0.28+noise3(p*4.13)*0.15;}
	void vertex(){local_position=VERTEX;}
	void fragment(){
		vec3 p=normalize(local_position);
		float land=fbm(p*3.8+vec3(3,7,11));
		vec3 sea=mix(vec3(0.025,0.07,0.12),vec3(0.06,0.23,0.28),smoothstep(0.35,0.49,land));
		vec3 earth=mix(vec3(0.23,0.22,0.29),vec3(0.53,0.39,0.32),fbm(p*12.0));
		vec3 ground=mix(sea,earth,smoothstep(0.49,0.515,land));
		ground=mix(ground,vec3(0.72,0.8,0.83),smoothstep(0.82,0.99,abs(p.y)));
		float cloud=fbm(p*14.0+vec3(p.y*6.0,2,0));
		ALBEDO=mix(ground,vec3(0.76,0.8,0.84),smoothstep(0.57,0.76,cloud)*0.68);
		ROUGHNESS=0.85;
	}"""
	var material := ShaderMaterial.new()
	material.shader = shader
	globe.material_override = material
	planet.add_child(globe)
	# Surface marker is a child of the rotating globe, so it cannot slide over land.
	var site := MeshInstance3D.new()
	var beacon := SphereMesh.new()
	beacon.radius = 0.18
	beacon.height = 0.36
	site.mesh = beacon
	site.position = Vector3(0,5,17.5).normalized()*18.15
	var light := StandardMaterial3D.new()
	light.albedo_color = Color("91d9df")
	light.emission_enabled = true
	light.emission = light.albedo_color
	site.material_override = light
	planet.add_child(site)
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
