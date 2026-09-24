extends "res://scripts/outpost_visual.gd"
## Three original, distinct footprints; shared primitive kit, authored in metres.
func compose(kind: String, color: String) -> void:
	add_child(caption); caption.hide()
	var armor: Material = material(color); var base: Material = material("35444d")
	var paving: Material = material("637078"); var glass: Material = material("bce4cf",true)
	var shade: Material = material("ddd3b8")
	box(Vector3(0,0.12,0),Vector3(6,0.24,6),paving)
	if kind == "civic":
		var road := TorusMesh.new(); road.inner_radius = 3.2; road.outer_radius = 4.1; road.rings = 32; road.ring_segments = 6
		var ring: MeshInstance3D = part(road,Vector3(0,0.1,0),base); ring.scale.y = 0.15
		box(Vector3.ZERO,Vector3(14,0.12,1.1),base)
		cylinder(Vector3(0,1,0),2.5,1.7,armor,2.2)
		cylinder(Vector3(0,2.4,-0.4),2.1,1.2,shade,1.6)
		cylinder(Vector3(0,3.3,-0.6),1.6,0.8,armor,0.8)
		box(Vector3(0,1.2,2.3),Vector3(0.8,1.7,0.4),base)
		for x: float in [-1.2,1.2]:
			var eye := SphereMesh.new(); eye.radius = 0.45; eye.height = 0.9
			var window: MeshInstance3D = part(eye,Vector3(x,2,1.8),glass); window.scale = Vector3(1,0.7,0.3)
		cylinder(Vector3(0,4.3,-0.6),0.12,1.4,base)
		var fin: MeshInstance3D
		var mesh := PrismMesh.new(); mesh.size = Vector3(1.7,1.2,0.18)
		fin = part(mesh,Vector3(0.6,5,-0.6),armor); fin.rotation.z = -0.3
	elif kind == "housing":
		for i: int in range(2):
			var x: float = -1.5+i*3
			box(Vector3(x,1.2,i-0.5),Vector3(2.4,2.2,4.8),armor)
			cylinder(Vector3(x,2.4,i-0.5),1.3,0.6,shade,0.8)
			for z: float in [-1.3,0,1.3]: box(Vector3(x-1.22,1.4,z+i-0.5),Vector3(0.08,0.65,0.7),glass)
		box(Vector3(0,0.7,0),Vector3(0.6,0.5,3),shade)
	else:
		box(Vector3(0,1.2,0),Vector3(5,2,4),armor)
		box(Vector3(0,2.4,-0.9),Vector3(5.2,0.4,1.6),base)
		for i: int in range(3):
			var x: float = -1.6+i*1.6
			cylinder(Vector3(x,3+i*0.3,-1),0.48,1.4+i*0.6,shade,0.34)
			box(Vector3(x,0.6,2.4),Vector3(1.2,0.8,0.7),base)
		box(Vector3(0,1.5,2.02),Vector3(3.5,0.4,0.08),glass)
