extends Node3D
## Shared globe mesh, geography and site coordinates for orbit and map.
const Geography = preload("res://scripts/planet_geography.gd")
var radius: float = 18
var surface: MeshInstance3D
var site_marker: MeshInstance3D
var material := ShaderMaterial.new()

func _ready() -> void:
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius*2
	sphere.radial_segments = 96
	sphere.rings = 48
	surface = MeshInstance3D.new()
	surface.mesh = sphere
	material.shader = preload("res://assets/shaders/morrow_globe.gdshader")
	material.set_shader_parameter("geography_offset",Geography.seed_offset(int(Geography.definition().geography_seed)))
	material.set_shader_parameter("basin_direction",Geography.site_direction())
	surface.material_override = material
	add_child(surface)
	site_marker = MeshInstance3D.new()
	var marker := SphereMesh.new()
	marker.radius = radius*0.014
	marker.height = radius*0.028
	site_marker.mesh = marker
	site_marker.position = Geography.site_direction()*radius*1.01
	var ink := StandardMaterial3D.new()
	ink.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ink.albedo_color = Color("a4f0bc")
	site_marker.material_override = ink
	add_child(site_marker)

func chart(progress: float, layer: bool) -> void:
	material.set_shader_parameter("map_fog",true)
	material.set_shader_parameter("chart_fraction",progress)
	material.set_shader_parameter("survey_layer",layer)
	material.set_shader_parameter("grid_visible",true)
