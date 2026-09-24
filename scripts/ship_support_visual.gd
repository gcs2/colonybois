extends Node3D
## Bounded view effects. State and durations belong to the field simulation.
var shell: MeshInstance3D
var halo: MeshInstance3D
var pulse: MeshInstance3D
var phase: float = 0
func _ready() -> void:
	shell = MeshInstance3D.new(); var sphere := SphereMesh.new(); sphere.radius = 3.9; sphere.height = 6.2; sphere.radial_segments = 32; sphere.rings = 16
	shell.mesh = sphere; var skin := ShaderMaterial.new(); skin.shader = preload("res://assets/shaders/ship_shield.gdshader"); shell.material_override = skin
	shell.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF; add_child(shell); shell.hide()
	halo = ring(3.5,Color("dba5df")); halo.rotation.x = 0.3
	pulse = ring(3.5,Color("dba5df"))
func ring(radius: float, tint: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new(); var mesh := TorusMesh.new(); mesh.inner_radius = radius-0.06; mesh.outer_radius = radius; mesh.rings = 48; mesh.ring_segments = 4
	node.mesh = mesh; var ink := StandardMaterial3D.new(); ink.albedo_color = tint; ink.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA; ink.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	node.material_override = ink; node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF; add_child(node); node.hide(); return node
func refresh(field: RefCounted, at: Vector3, delta: float, stopped: bool) -> void:
	position = at
	if not stopped: phase += delta
	shell.visible = field.Support.active(field,"shield")
	halo.visible = field.Support.active(field,"rally_call"); pulse.visible = halo.visible
	shell.material_override.set_shader_parameter("phase",phase)
	shell.material_override.set_shader_parameter("impact",0.8 if field.shield_hit_time == int(field.state.time) else 0.0)
	halo.rotation.y = phase*0.9
	var progress: float = fmod(phase*0.65,1.0)
	pulse.scale = Vector3.ONE*(1.0+progress*2.0)
	pulse.material_override.albedo_color = Color(0.86,0.65,0.87,(1.0-progress)*0.45)
