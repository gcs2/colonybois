extends Node3D
## Shared globe mesh, geography and site coordinates for orbit and map.
const Geography = preload("res://scripts/planet_geography.gd")
const Generator = preload("res://scripts/planet_generator.gd")
var planet_definition: Dictionary = {}
var clouds: MeshInstance3D
var atmosphere: MeshInstance3D
var generator: RefCounted
var recovery_maps: Dictionary = {}
var radius: float = 18
var surface: MeshInstance3D
var site_marker: MeshInstance3D
var material := ShaderMaterial.new()

func _ready() -> void:
	if planet_definition.is_empty(): planet_definition = Geography.definition().duplicate(true)
	generator = Generator.new(planet_definition)
	var maps: Dictionary = generator.maps()
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius*2
	sphere.radial_segments = 96
	sphere.rings = 48
	surface = MeshInstance3D.new()
	surface.mesh = sphere
	material.shader = preload("res://assets/shaders/morrow_globe.gdshader")
	material.set_shader_parameter("surface_map",maps.albedo)
	material.set_shader_parameter("substrate_map",maps.substrate)
	material.set_shader_parameter("ice_color",generator.palette.ice)
	material.set_shader_parameter("wet_color",generator.palette.forest)
	material.set_shader_parameter("dry_color",generator.palette.dryland)
	material.set_shader_parameter("condition_map",maps.conditions)
	material.set_shader_parameter("normal_map",maps.normals)
	material.set_shader_parameter("recovered_map",maps.albedo)
	var site_at: Vector3 = Vector3.FORWARD
	if not planet_definition.get("sites",[]).is_empty():
		var site: Dictionary = planet_definition.sites[0]
		site_at = Generator.direction(site.latitude,site.longitude)
	material.set_shader_parameter("basin_direction",site_at)
	surface.material_override = material
	add_child(surface)
	site_marker = MeshInstance3D.new()
	var marker := SphereMesh.new()
	marker.radius = radius*0.014
	marker.height = radius*0.028
	site_marker.mesh = marker
	site_marker.position = site_at*radius*1.015
	var ink := StandardMaterial3D.new()
	ink.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ink.albedo_color = Color("a4f0bc")
	site_marker.material_override = ink
	add_child(site_marker)
	if planet_definition.get("sites",[]).is_empty(): site_marker.hide()
	clouds = MeshInstance3D.new()
	clouds.mesh = sphere
	clouds.scale = Vector3.ONE*1.008
	var cloud_material := ShaderMaterial.new()
	cloud_material.shader = preload("res://assets/shaders/planet_clouds.gdshader")
	cloud_material.set_shader_parameter("condition_map",maps.conditions)
	clouds.material_override = cloud_material
	add_child(clouds)
	atmosphere = MeshInstance3D.new()
	atmosphere.mesh = sphere
	atmosphere.scale = Vector3.ONE*1.025
	var atmosphere_material := ShaderMaterial.new()
	atmosphere_material.shader = preload("res://assets/shaders/planet_atmosphere.gdshader")
	atmosphere_material.set_shader_parameter("tint",generator.palette.atmosphere)
	atmosphere.material_override = atmosphere_material
	add_child(atmosphere)

func advance(delta: float) -> void:
	clouds.rotation.y += delta*0.005

func set_climate(values: Dictionary, base: Vector2, active: bool) -> void:
	material.set_shader_parameter("climate_active",active)
	var scale: float = 0.6 if planet_definition.archetype == "arid" else 1.12
	material.set_shader_parameter("temperature_delta",(float(values.temperature)-base.x)*scale)
	material.set_shader_parameter("moisture_delta",(float(values.atmosphere)-base.y)*0.015)
	var density: float = clampf(float(values.atmosphere)/maxf(1,base.y),0,2)
	clouds.material_override.set_shader_parameter("density",density)
	atmosphere.material_override.set_shader_parameter("density",density)


func chart(progress: float, layer: bool) -> void:
	clouds.visible = false
	material.set_shader_parameter("map_fog",true)
	material.set_shader_parameter("chart_fraction",progress)
	material.set_shader_parameter("survey_layer",layer)
	material.set_shader_parameter("grid_visible",true)

func set_recovery(value: float) -> void:
	var amount: float = clampf(value,0,1)
	if amount > 0 and recovery_maps.is_empty() and planet_definition.get("archetype","temperate") != "temperate":
		var recovered: Dictionary = planet_definition.duplicate(true)
		recovered["climate"] = recovered.get("climate",{}).duplicate(true)
		if planet_definition.archetype == "frozen": recovered.climate["equator_temperature"] = 29.0
		if planet_definition.archetype == "arid": recovered.climate["moisture"] = 0.63
		# Same geology and coastlines; only warming or moisture changes.
		recovery_maps = Generator.new(recovered).maps()
		material.set_shader_parameter("recovered_map",recovery_maps.albedo)
	material.set_shader_parameter("recovery",amount)
