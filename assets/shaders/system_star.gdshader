shader_type spatial;
render_mode unshaded;

// Stylized chart star: limb darkening and small fixed convection cells.
// No astronomical scale or stellar-physics simulation is implied.
void fragment() {
	float facing = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	float cells = sin(UV.x * 271.0 + sin(UV.y * 119.0)) * sin(UV.y * 187.0 + sin(UV.x * 157.0));
	vec3 edge = vec3(0.93, 0.31, 0.065);
	vec3 core = vec3(1.0, 0.88, 0.55);
	ALBEDO = mix(edge, core, pow(facing, 0.42)) * (0.96 + cells * 0.04);
}
