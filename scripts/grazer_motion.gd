extends RefCounted
## Bounded visual behavior, not an ecosystem agent. One controller per visible grazer.
const TENDRIL = preload("res://assets/encounter/tendril.gdshader")
var actor: Node3D
var body: Node3D
var eyes: Array[Node3D] = []
var pupils: Array[Node3D] = []
var fin_left: Node3D
var fin_right: Node3D
var tendril_material := ShaderMaterial.new()
var age: float = 0
var phase: float = 0
var index: int = 0
var mode: String = "foraging"
var velocity := Vector3.ZERO
var alarm: float = 0
var interest: float = 0
var curl: float = 0
var blink_start: float = -10
var next_blink: float = 2
var rng := RandomNumberGenerator.new()
var home := Vector3.ZERO

func configure(node: Node3D, number: int) -> void:
	actor = node
	index = number
	home = node.position
	phase = number*2.17
	rng.seed = 716+number
	next_blink = rng.randf_range(1.4,4.6)
	body = node.find_child("Body",true,false)
	fin_left = node.find_child("FinLeft",true,false)
	fin_right = node.find_child("FinRight",true,false)
	for i: int in range(3):
		var eye: Node3D = node.find_child("Eye_%d" % i,true,false)
		eyes.append(eye)
		pupils.append(eye.get_node("Gaze_%d" % i))
	tendril_material.shader = TENDRIL
	var tendrils: Node3D = node.find_child("Tendrils",true,false)
	for mesh: Node in tendrils.get_children():
		if mesh is MeshInstance3D:
			mesh.material_override = tendril_material
			mesh.extra_cull_margin = 3

func react(tool: String, at: Vector3) -> void:
	var gap: float = actor.position.distance_to(at)
	if tool in ["collect","warm"] and gap < 15:
		alarm = 2.2 if tool == "collect" else 4.0
	elif tool in ["scan","seed"] and gap < 16:
		interest = 5.0

func advance(delta: float, ship: Vector3) -> void:
	if delta <= 0: return
	age += delta
	alarm = maxf(0,alarm-delta)
	interest = maxf(0,interest-delta)
	var to_ship: Vector3 = ship-actor.position
	var gap: float = to_ship.length()
	if gap < 3.2: alarm = maxf(alarm,1.0)
	mode = "startled" if alarm > 0 else ("curious" if gap < 11 or interest > 0 else "foraging")
	var destination: Vector3
	var speed: float = 1.5
	match mode:
		"startled":
			var away: Vector3 = -to_ship.normalized()
			if away.is_zero_approx(): away = Vector3.FORWARD
			destination = actor.position+away*5+Vector3(0,1.6,0)
			destination.y = minf(destination.y,8.5)
			speed = 4.5
		"curious":
			var angle: float = phase+sin(age*0.32+phase)*0.45
			destination = ship+Vector3(sin(angle)*5.7,0.5,cos(angle)*5.7)
			destination.y = clampf(ship.y+sin(age*1.2+phase)*0.25,4.0,8)
			speed = 2.2
		_:
			var feed: float = age*0.18+phase
			destination = home+Vector3(sin(feed)*3.3,-1.1+sin(age*1.6+phase)*0.22,cos(feed)*3.0)
	var radial := Vector2(destination.x,destination.z).limit_length(25)
	destination.x = radial.x
	destination.z = radial.y
	var desired: Vector3 = (destination-actor.position).limit_length(speed)
	velocity = velocity.lerp(desired,1.0-exp(-delta*2.8))
	actor.position += velocity*delta
	var face: Vector3 = to_ship if mode == "curious" else velocity
	if face.length() > 0.1:
		actor.rotation.y = lerp_angle(actor.rotation.y,atan2(-face.x,-face.z),1.0-exp(-delta*2.7))
	var local_velocity: Vector3 = velocity.rotated(Vector3.UP,-actor.rotation.y)
	actor.rotation.x = lerpf(actor.rotation.x,clampf(-local_velocity.z*0.055,-0.22,0.22),1.0-exp(-delta*3))
	actor.rotation.z = lerpf(actor.rotation.z,clampf(-local_velocity.x*0.075,-0.22,0.22),1.0-exp(-delta*3))
	var frequency: float = 5.5 if mode == "startled" else 2.0
	var pulse: float = sin(age*frequency+phase)
	body.scale = Vector3(1.0+pulse*0.035,1.0-pulse*0.065,1.0+pulse*0.035)
	fin_left.rotation.z = -0.25+sin(age*(frequency+1.5)+phase)*0.3
	fin_right.rotation.z = 0.25-sin(age*(frequency+1.5)+phase+0.3)*0.3
	curl = lerpf(curl,1.0 if mode == "startled" else (0.28 if mode == "curious" else 0.0),1.0-exp(-delta*4))
	tendril_material.set_shader_parameter("clock",age+phase)
	tendril_material.set_shader_parameter("curl",curl)
	tendril_material.set_shader_parameter("trail",Vector2(-local_velocity.x,-local_velocity.z))
	if age >= next_blink:
		blink_start = age
		next_blink = age+rng.randf_range(2.8,6.3)
	var local_gaze: Vector3 = to_ship.rotated(Vector3.UP,-actor.rotation.y).normalized()
	for i: int in range(eyes.size()):
		var t: float = (age-blink_start-i*0.045)/0.23
		var blink: float = sin(t*PI) if t > 0 and t < 1 else 0.0
		eyes[i].scale.y = 1.0-blink*0.94
		pupils[i].position = Vector3(clampf(local_gaze.x*0.1,-0.09,0.09),clampf(local_gaze.y*0.1,-0.08,0.08),0) if mode == "curious" else Vector3.ZERO
