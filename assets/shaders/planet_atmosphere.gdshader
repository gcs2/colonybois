shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_back;
uniform vec4 tint : source_color = vec4(0.45,0.78,0.83,1.0);
void fragment(){
    float rim=pow(1.0-clamp(dot(normalize(NORMAL),normalize(VIEW)),0.0,1.0),4.0);
    ALBEDO=tint.rgb;
    ALPHA=rim*0.34;
}
