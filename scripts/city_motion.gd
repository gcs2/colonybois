extends Node3D
## Bounded visual traffic. Economy and population never depend on rendered vehicles.
var vehicles: Array[Dictionary] = []
var age: float = 0.0
var game: Node3D

func setup(app: Node3D) -> void:
	game = app
	var colony: Dictionary = app.sim.state.colonies[app.planet_id]
	var stops: Array = colony.service_sites.transit
	for i: int in range(1,mini(stops.size(),4)):
		var route: Array[Vector3] = road_route(colony,Vector2i(stops[i-1]),Vector2i(stops[i]))
		if route.size() < 2: continue
		for step: int in range(1,route.size()): app._line(self,route[step-1]+Vector3(0,0.12,0),route[step]+Vector3(0,0.12,0),Color("edce8c"),0.025)
		var shuttle := Node3D.new()
		add_child(shuttle)
		app._box(shuttle,Vector3(0,0.3,0),Vector3(0.21,0.22,0.6),Color("e9d9b6"))
		app._box(shuttle,Vector3(0,0.40,-0.13),Vector3(0.23,0.1,0.25),Color("326d7a"))
		vehicles.append({"node":shuttle,"path":route,"rate":1.6,"offset":float(i)*2})
	if not (app.sim.state.has("urban") and app.planet_id == "s0p0" and app.overlay == "natural"): return
	# The harbor belongs to the surrounding city. These boats are ambience, not freight accounting.
	app._box(self,Vector3(-96,0.1,25),Vector3(7,0.5,22),Color("8f998f"))
	for z: float in [18,27,36]:
		app._box(self,Vector3(-102,0.15,z),Vector3(12,0.5,2),Color("afa48f"))
		app._box(self,Vector3(-95,1.5,z),Vector3(0.4,3,0.4),Color("d7bd83"))
		app._box(self,Vector3(-98,3,z),Vector3(6,0.3,0.3),Color("d7bd83"))
	for i: int in range(3):
		var ship := Node3D.new()
		add_child(ship)
		app._box(ship,Vector3(0,0.1,0),Vector3(1.8,0.6,5),Color("435b68"))
		app._box(ship,Vector3(0,0.6,1.5),Vector3(1.4,0.9,1),Color("dfd1b6"))
		for z: float in [-1.5,-0.3,0.8]: app._box(ship,Vector3(0,0.7,z),Vector3(1.2,0.65,0.9),Color("bf9876") if i%2 == 0 else Color("88afb0"))
		app._box(ship,Vector3(0,-0.03,3.2),Vector3(1.4,0.025,1.5),Color("81afae"))
		var route: Array[Vector3] = [Vector3(-110-i*3,0,36-i*12),Vector3(-116-i*3,0,60),Vector3(-116-i*3,0,115)]
		vehicles.append({"node":ship,"path":route,"rate":0.024,"offset":float(i)*0.6})

func _process(delta: float) -> void:
	if not is_instance_valid(game): return
	age += delta*game.speed
	for vehicle: Dictionary in vehicles:
		var path: Array = vehicle.path
		var step: float = fposmod(age*float(vehicle.rate)+float(vehicle.offset),float(path.size()-1)*2)
		var returning: bool = step > path.size()-1
		if returning: step = (path.size()-1)*2-step
		var index: int = mini(floori(step),path.size()-2)
		var node: Node3D = vehicle.node
		node.position = path[index].lerp(path[index+1],step-index)
		var direction: Vector3 = path[index+1]-path[index]
		if returning: direction = -direction
		if direction.length_squared() > 0.01: node.rotation.y = atan2(direction.x,direction.z)

static func road_route(colony: Dictionary, start: Vector2i, finish: Vector2i) -> Array[Vector3]:
	var queue: Array[Vector2i] = [start]
	var previous: Dictionary = {start:start}
	var head: int = 0
	while head < queue.size():
		var current: Vector2i = queue[head]
		head += 1
		if current == finish:
			var result: Array[Vector3] = []
			while current != start:
				result.push_front(Vector3(current.x-31.5,0,current.y-31.5))
				current = previous[current]
			result.push_front(Vector3(start.x-31.5,0,start.y-31.5))
			return result
		for delta: Vector2i in [Vector2i.UP,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT]:
			var next: Vector2i = current+delta
			var key: String = "%d,%d" % [next.x,next.y]
			if previous.has(next): continue
			if next != finish and colony.cells.get(key,{}).get("type","") not in ["road","spaceport"]: continue
			previous[next] = current
			queue.append(next)
	return []
