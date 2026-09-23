shader_type spatial;
render_mode cull_disabled;
uniform vec4 skin : source_color = vec4(0.87,0.61,0.54,1.0);
uniform float clock = 0.0;
uniform float curl = 0.0;
uniform vec2 trail = vec2(0.0);

void vertex() {
	// Root stays attached. Distal sections respond more and trail the turn.
	float length = max(0.0, -VERTEX.y - 0.65);
	float phase = atan(VERTEX.z, VERTEX.x);
	float weight = length * length;
	VERTEX.x += sin(clock * 2.1 + length * 1.8 + phase) * weight * 0.075 + trail.x * weight * 0.10;
	VERTEX.z += cos(clock * 1.8 + length * 1.5 + phase) * weight * 0.065 + trail.y * weight * 0.10;
	VERTEX.y += curl * weight * 0.24;
}

void fragment() {
	ALBEDO = skin.rgb;
	ROUGHNESS = 0.72;
}
