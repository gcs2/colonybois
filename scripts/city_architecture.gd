extends RefCounted
const Materials = preload("res://scripts/city_materials.gd")
## Reusable courtyard and shell-roof kit. Geometry follows the actual lot footprint.
static func draw(app: Node3D, root: Node3D, cell: Dictionary, key: String) -> bool:
	if cell.type not in ["habitat","service","industry","police","fire","clinic","transit"]: return false
	var variant: int = absi(key.hash())%4
	var plaster: Color = [Color("dfd5bb"),Color("b4ccc1"),Color("d0ad8e"),Color("a6babd")][variant]
	var glass := Color("244b58")
	var roof := Color("386b70")
	var trim := Color("ecd8a7")
	var height: float = 0.5+int(cell.level)*0.48+variant*0.09
	if int(cell.get("damaged_until",0)) > app.sim.state.tick: plaster = Color("61575b"); roof = Color("473e44")
	app._box(root,Vector3(0,0.09,0),Vector3(0.96,0.12,0.96),Color("8b9790"))
	if cell.type == "transit":
		app._box(root,Vector3(0,0.2,0),Vector3(0.86,0.18,0.65),trim)
		for x: float in [-0.32,0.32]: app._box(root,Vector3(x,0.6,-0.17),Vector3(0.035,0.8,0.035),glass)
		_shell(app,root,Vector3(0,1.05,0),Vector3(0.48,0.13,0.36),Color("e8bc74"))
		app._box(root,Vector3(0,0.38,0.13),Vector3(0.55,0.12,0.13),roof)
		_finish(root,plaster)
		return true
	if cell.type == "industry":
		app._box(root,Vector3(0,0.37,0),Vector3(0.83,0.5,0.76),plaster.darkened(0.15))
		for x: float in [-0.24,0,0.24]:
			_shell(app,root,Vector3(x,0.66,0),Vector3(0.145,0.17,0.4),roof)
			app._box(root,Vector3(x,0.36,0.39),Vector3(0.14,0.26,0.018),glass)
		app._box(root,Vector3(0.30,0.95,-0.24),Vector3(0.12,0.9,0.12),trim)
		_finish(root,plaster)
		return true
	# Open courtyard, asymmetric main wing and lower street wing.
	app._box(root,Vector3(-0.25,height/2,0),Vector3(0.35,height,0.82),plaster)
	app._box(root,Vector3(0.12,height*0.37,-0.25),Vector3(0.5,height*0.74,0.32),plaster.lightened(0.06))
	for floor_index: int in range(int(cell.level)+2):
		var y: float = 0.25+floor_index*0.29
		if y > height-0.1: continue
		app._box(root,Vector3(-0.25,y,0.419),Vector3(0.29,0.105,0.02),glass,0.08)
		app._box(root,Vector3(-0.066,y,0),Vector3(0.018,0.10,0.68),glass,0.08)
	_shell(app,root,Vector3(-0.25,height+0.07,0),Vector3(0.23,0.15,0.46),roof)
	_shell(app,root,Vector3(0.12,height*0.74+0.07,-0.25),Vector3(0.28,0.12,0.21),roof)
	app._box(root,Vector3(0.13,0.18,0.14),Vector3(0.45,0.05,0.43),Color("547e6d"))
	app._box(root,Vector3(0.12,0.26,0.37),Vector3(0.51,0.12,0.08),trim)
	app._sphere(root,Vector3(0.21,0.45,0.12),0.16,Color("bd9fa9"))
	app._box(root,Vector3(-0.24,0.32,0.435),Vector3(0.12,0.32,0.02),Color("142f36"))
	if cell.type in ["police","fire","clinic","service"]:
		var accent: Color = {"police":Color("83b9ed"),"fire":Color("ed8e74"),"clinic":Color("d6f0c4"),"service":Color("e9bd79")}[cell.type]
		_shell(app,root,Vector3(0,0.62,0.37),Vector3(0.38,0.06,0.19),accent)
		app._sphere(root,Vector3(-0.25,height+0.28,0),0.1,accent,0.3)
	_finish(root,plaster)
	return true

static func _finish(root: Node3D, plaster: Color) -> void:
	for child: Node in root.get_children():
		if not child is MeshInstance3D: continue
		var material := child.material_override as StandardMaterial3D
		if material == null: continue
		var color: Color = material.albedo_color
		if color == plaster or color == plaster.lightened(0.06) or color == plaster.darkened(0.15): child.material_override = Materials.get_material("wall",color.lightened(0.35))
		elif color == Color("8b9790"): child.material_override = Materials.get_material("paving")

static func _shell(app: Node3D, root: Node3D, position: Vector3, size: Vector3, color: Color) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = 1
	mesh.height = 2
	mesh.radial_segments = 12
	mesh.rings = 6
	var node: MeshInstance3D = app._mesh(root,mesh,position,color)
	node.scale = size
	node.material_override = Materials.get_material("roof",color.lightened(0.65))
