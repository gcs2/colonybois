extends Node3D
## Capped presentation of authoritative units, aim volumes and in-flight ordnance.
const Combat = preload("res://scripts/surface_combat.gd")
const Hostile = preload("res://scripts/hostile_vessel.gd")
var actors: Dictionary = {}
var aims: Dictionary = {}
var labels: Dictionary = {}
var missiles: Array[MeshInstance3D] = []
var zones: Array[MeshInstance3D] = []
var blasts: Array[MeshInstance3D] = []
var pennant: MeshInstance3D
var planet: String
func material(color: Color, transparent: bool = false) -> StandardMaterial3D:
	var ink := StandardMaterial3D.new(); ink.albedo_color = color; ink.roughness = 0.85
	if transparent:
		ink.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ink.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ink.cull_mode = BaseMaterial3D.CULL_DISABLED
	return ink
func ball(at: Vector3, scale_value: Vector3, ink: Material, parent: Node3D) -> MeshInstance3D:
	var node := MeshInstance3D.new(); var sphere := SphereMesh.new()
	sphere.radius = 1; sphere.height = 2; sphere.radial_segments = 16; sphere.rings = 8
	node.mesh = sphere; node.material_override = ink; node.position = at; node.scale = scale_value
	parent.add_child(node); return node
func setup(id: String) -> void:
	planet = id
	for target: String in Combat.profiles(planet):
		var spec: Dictionary = Combat.profiles(planet)[target]
		var actor := Node3D.new(); add_child(actor)
		if spec.get("civilian",false):
			var building := preload("res://scripts/colony_structure.gd").new(); actor.add_child(building); building.position.y = -2
			building.compose(target,spec.color)
		elif spec.kind == "air":
			var flyer := Hostile.new(); actor.add_child(flyer)
			flyer.build({"chase":4,"color":spec.color}); flyer.scale = Vector3.ONE*0.7
		else:
			var ink: Material = material(Color(spec.color))
			ball(Vector3.ZERO,Vector3(2,0.6,2),ink,actor)
			ball(Vector3(0,0.7,0),Vector3(0.55,0.7,0.55),material(Color("ecad71")),actor)
			for spoke: int in range(3):
				var at := Vector3(cos(TAU*spoke/3),0,sin(TAU*spoke/3))
				ball(at*1.7+Vector3(0,-0.8,0),Vector3(0.45,1.15,0.45),material(Color("34464a")),actor)
		if target == "civic":
			pennant = MeshInstance3D.new(); var flag := QuadMesh.new(); flag.size = Vector2(1.7,1.0)
			pennant.mesh = flag; pennant.position = Vector3(1.0,4.8,0)
			var ink: StandardMaterial3D = material(Color(spec.color)); ink.cull_mode = BaseMaterial3D.CULL_DISABLED
			pennant.material_override = ink; actor.add_child(pennant)
		actor.position = Combat.home(planet,target); actors[target] = actor
		var label := Label3D.new(); label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.position.y = 4; label.font_size = 24; label.pixel_size = 0.025
		actor.add_child(label); labels[target] = label
		aims[target] = ball(Vector3.ZERO,Vector3.ONE*float(spec.radius),material(Color(1,0.35,0.2,0.04),true),self)
		for axis: int in range(3):
			var ring := MeshInstance3D.new(); var torus := TorusMesh.new()
			torus.inner_radius = 0.98; torus.outer_radius = 1.0; torus.rings = 32; torus.ring_segments = 4
			ring.mesh = torus; ring.material_override = material(Color(1,0.4,0.2,0.55),true)
			if axis == 1: ring.rotation.x = PI/2
			if axis == 2: ring.rotation.z = PI/2
			ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			aims[target].add_child(ring)
		aims[target].hide()
	for i: int in range(2):
		missiles.append(ball(Vector3.ZERO,Vector3.ONE*0.5,material(Color("f6db9f")),self))
		zones.append(ball(Vector3.ZERO,Vector3(7,0.15,7),material(Color(1,0.7,0.3,0.2),true),self))
		missiles.back().hide(); zones.back().hide()
	for i: int in range(4):
		blasts.append(ball(Vector3.ZERO,Vector3.ONE,material(Color(1,0.8,0.4,0.3),true),self))
		blasts.back().hide()
func refresh(game: RefCounted, selected: String, fraction: float, delta: float, stopped: bool) -> void:
	visible = game.field.state.flight_mode == "surface"
	if not visible: return
	var events: Array = game.combat.impacts.filter(func(event: Dictionary) -> bool: return event.planet == planet)
	for i: int in range(blasts.size()):
		blasts[i].hide()
		if i >= events.size() or stopped: continue
		var event: Dictionary = events[i]
		var age: float = game.field.state.time+fraction-event.time
		if age < 0 or age > 0.7: continue
		blasts[i].position = Combat.position(event.at)
		blasts[i].scale = Vector3.ONE*float(event.radius)*(0.2+age)
		blasts[i].material_override.albedo_color = Color(1,0.8,0.4,(1.0-age/0.7)*0.35)
		blasts[i].show()
	var local: Dictionary = game.combat.world(planet)
	for id: String in actors:
		var unit: Dictionary = local.units[id]
		var actor: Node3D = actors[id]
		var at: Vector3 = Combat.position(unit.at)
		actor.position = actor.position.lerp(at,minf(1,delta*12)) if not stopped else at
		var civic: bool = Combat.profiles(planet)[id].get("civilian",false)
		var phase: String = game.territory.world(planet).phase
		actor.visible = civic or phase not in ["annexed","ruined"] or unit.hull == 0
		actor.rotation.z = 0.65 if unit.hull <= 0 and not civic else 0.0
		if id == "civic" and pennant != null:
			pennant.visible = phase != "ruined"
			pennant.material_override.albedo_color = Color("f5eedb") if phase == "surrendered" else Color("78d7b8") if phase == "annexed" else Color(Combat.profiles(planet)[id].color)
		actor.scale.y = 0.2 if civic and (unit.hull <= 0 or phase == "ruined") else 1.0
		var label: Label3D = labels[id]
		label.visible = selected == id
		label.text = ("SALVAGE" if not unit.salvaged else "CLEARED") if unit.hull <= 0 else "%s  %d/%d" % [Combat.profiles(planet)[id].name,unit.hull,Combat.profiles(planet)[id].hull]
		if civic: label.text = Combat.profiles(planet)[id].name+" · "+("RUINED" if phase == "ruined" or unit.hull == 0 else "SURRENDERED" if phase == "surrendered" else "%d hull" % unit.hull)
		aims[id].visible = unit.fire_at > game.field.state.time and not stopped
		aims[id].position = Combat.position(unit.aim)
		if not stopped and unit.hull > 0:
			for child: Node in actor.get_children():
				if child is Hostile: child.advance(delta)
	for i: int in range(missiles.size()):
		missiles[i].hide(); zones[i].hide()
		if i >= local.shots.size(): continue
		var shot: Dictionary = local.shots[i]
		var end: Vector3 = Combat.position(shot.point)
		if shot.weapon == "seeker": end = Combat.position(local.units[shot.target].at)
		var progress: float = clampf((game.field.state.time+fraction-shot.launch)/float(shot.impact-shot.launch),0,1)
		missiles[i].position = Combat.position(shot.origin).lerp(end,progress)
		missiles[i].show()
		if shot.weapon == "ground_bomb": zones[i].position = end+Vector3(0,0.25,0); zones[i].show()
