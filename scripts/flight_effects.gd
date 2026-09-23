extends Node3D
## Capped cosmetic effects. No simulation commands, random gameplay or saved particles.
const MAX_PARTICLES := 184
const TINTS := {"scan":Color("9cdeb2"),"collect":Color("efb884"),"warm":Color("ffd576"),"seed":Color("c3a8fa")}
var exhaust: Array[CPUParticles3D] = []
var tool_particles: CPUParticles3D
var dust: CPUParticles3D
var burst: CPUParticles3D
var sweep := MeshInstance3D.new()
var sweep_material := StandardMaterial3D.new()
var thrust: float = 0.0
var tool_active: bool = false
var current_tool: String = ""
var ship: Node3D
var dormant: bool = true

func setup(actor: Node3D) -> void:
	ship = actor
	for side: float in [-1.0,1.0]:
		var jet: CPUParticles3D = _emitter(48,0.38,Color("9aeed8"),0.4)
		jet.name = "PortExhaust" if side < 0 else "StarboardExhaust"
		jet.reparent(ship)
		jet.position = Vector3(side*0.65,0,1.93)
		jet.direction = Vector3.BACK
		jet.local_coords = true
		jet.spread = 9
		jet.initial_velocity_min = 7
		jet.initial_velocity_max = 12
		exhaust.append(jet)
	tool_particles = _emitter(40,0.55,TINTS.scan,0.23)
	tool_particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	tool_particles.emission_sphere_radius = 0.45
	burst = _emitter(24,0.65,TINTS.scan,0.27)
	burst.one_shot = true
	burst.explosiveness = 1
	burst.spread = 180
	burst.initial_velocity_min = 1.3
	burst.initial_velocity_max = 3.6
	dust = _emitter(24,0.7,Color("cdb29c"),0.75)
	dust.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	dust.emission_sphere_radius = 1.2
	dust.spread = 78
	dust.direction = Vector3.UP
	dust.initial_velocity_min = 0.8
	dust.initial_velocity_max = 2.4
	var ring := TorusMesh.new()
	ring.inner_radius = 0.93
	ring.outer_radius = 1.0
	ring.rings = 40
	ring.ring_segments = 6
	sweep.mesh = ring
	sweep_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sweep_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sweep.material_override = sweep_material
	sweep.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(sweep)
	sweep.hide()
	reset()

func _emitter(count: int, life: float, tint: Color, width: float) -> CPUParticles3D:
	var emitter := CPUParticles3D.new()
	emitter.emitting = false
	emitter.amount = count
	emitter.lifetime = life
	emitter.fixed_fps = 30
	emitter.gravity = Vector3.ZERO
	emitter.local_coords = false
	emitter.use_fixed_seed = true
	emitter.seed = 2407+count
	emitter.visibility_aabb = AABB(Vector3(-30,-30,-30),Vector3(60,60,60))
	emitter.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE*width
	var ink := StandardMaterial3D.new()
	ink.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ink.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ink.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	ink.vertex_color_use_as_albedo = true
	ink.albedo_texture = preload("res://assets/ui/flight/particle_glow.svg")
	quad.material = ink
	emitter.mesh = quad
	emitter.color = tint
	var fade := Gradient.new()
	fade.offsets = PackedFloat32Array([0,0.1,0.65,1])
	fade.colors = PackedColorArray([Color(1,1,1,0),Color(1,1,1,0.85),Color(1,1,1,0.45),Color(1,1,1,0)])
	emitter.color_ramp = fade
	add_child(emitter)
	return emitter

func reset() -> void:
	thrust = 0
	tool_active = false
	current_tool = ""
	dormant = true
	for emitter: CPUParticles3D in all_emitters():
		emitter.restart(true)
		emitter.emitting = false
		emitter.visible = false
	sweep.hide()

func all_emitters() -> Array[CPUParticles3D]:
	var list: Array[CPUParticles3D] = exhaust.duplicate()
	for emitter: CPUParticles3D in [tool_particles,dust,burst]:
		if is_instance_valid(emitter): list.append(emitter)
	return list

func update(delta: float, speed: float, stopped: bool, orbital: bool, ground: float, tool: String, active: bool, at: Vector3, fraction: float) -> void:
	if stopped:
		if not dormant: reset()
		return
	dormant = false
	# Same speed normalization and response as flight_audio.gd; no independent thrust fiction.
	thrust = lerpf(thrust,clampf(speed/16.0,0,1),minf(1,delta*5))
	for jet: CPUParticles3D in exhaust:
		jet.visible = thrust > 0.02
		jet.emitting = thrust > 0.03
		jet.initial_velocity_min = 3+thrust*8
		jet.initial_velocity_max = 5+thrust*12
		jet.scale_amount_min = 0.45+thrust*0.55
		jet.scale_amount_max = 0.75+thrust*0.75
	dust.position = Vector3(ship.position.x,ground+0.15,ship.position.z)
	dust.visible = not orbital and ship.position.y-ground < 7 and thrust > 0.15
	dust.emitting = dust.visible
	tool_active = active and not orbital
	tool_particles.visible = tool_active
	tool_particles.emitting = tool_active
	sweep.visible = tool_active
	burst.visible = true
	if not tool_active: return
	if tool != current_tool:
		current_tool = tool
		tool_particles.color = TINTS[tool]
		tool_particles.restart(true)
	var origin: Vector3 = ship.position if tool == "seed" else at
	var end: Vector3 = at if tool == "seed" else ship.position
	tool_particles.position = origin
	if tool in ["collect","seed"]:
		tool_particles.direction = (end-origin).normalized()
		tool_particles.spread = 4
		tool_particles.initial_velocity_min = origin.distance_to(end)*1.3
		tool_particles.initial_velocity_max = origin.distance_to(end)*1.7
	else:
		tool_particles.direction = Vector3.UP
		tool_particles.spread = 60 if tool == "scan" else 18
		tool_particles.initial_velocity_min = 0.6
		tool_particles.initial_velocity_max = 2.3 if tool == "warm" else 1.0
	sweep.position = at
	sweep.scale = Vector3.ONE*(0.7+fraction*2.5)
	var color: Color = TINTS[tool]
	color.a = 0.25+sin(fraction*PI)*0.55
	sweep_material.albedo_color = color

func confirm(at: Vector3, tool: String) -> void:
	burst.position = at
	burst.color = TINTS[tool]
	burst.visible = true
	burst.restart(true)
	burst.emitting = true
