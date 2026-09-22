extends RefCounted
static var cache: Dictionary = {}
static func get_material(kind: String, tint: Color = Color.WHITE) -> StandardMaterial3D:
	var key: String = kind+tint.to_html()
	if cache.has(key): return cache[key]
	var material := StandardMaterial3D.new()
	var paths: Dictionary = {"wall":"shell-wall-v1","roof":"scale-roof-v1","paving":"civic-paving-v1"}
	material.albedo_texture = load("res://assets/materials/"+paths[kind]+".png")
	material.albedo_color = tint
	material.roughness = 0.87
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	material.uv1_triplanar = true
	material.uv1_scale = Vector3.ONE*0.75
	cache[key] = material
	return material
