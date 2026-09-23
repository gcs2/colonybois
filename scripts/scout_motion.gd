extends RefCounted
## Cosmetic control surfaces follow measured motion; no idle flapping or simulation writes.
var port: Node3D
var starboard: Node3D
var thrust: float = 0
var trim: float = 0

func setup(ship: Node3D) -> void:
	port = ship.find_child("PortShield",true,false)
	starboard = ship.find_child("StarboardShield",true,false)

func advance(delta: float, local_velocity: Vector3, stopped: bool) -> void:
	if stopped: return
	var weight: float = 1.0-exp(-delta*6.0)
	thrust = lerpf(thrust,clampf(local_velocity.length()/16,0,1),weight)
	trim = lerpf(trim,clampf(local_velocity.x/16,-1,1),weight)
	if is_instance_valid(port): port.rotation.z = -thrust*0.16+trim*0.1
	if is_instance_valid(starboard): starboard.rotation.z = thrust*0.16+trim*0.1
