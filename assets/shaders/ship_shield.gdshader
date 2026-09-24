shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_opaque, cull_back;
uniform vec4 tint : source_color = vec4(0.54,0.85,0.83,1.0);
uniform float phase = 0.0;
uniform float impact = 0.0;
void fragment() {
	float rim = pow(1.0 - max(dot(normalize(NORMAL),normalize(VIEW)),0.0),2.4);
	float wave = pow(max(0.0,sin(UV.y*52.0-phase*5.0)),14.0);
	ALBEDO = tint.rgb + vec3(impact*0.3);
	ALPHA = clamp(rim*(0.42+impact*0.35)+wave*0.045+impact*0.07,0.0,0.82);
}
