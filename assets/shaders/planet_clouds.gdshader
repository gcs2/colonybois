shader_type spatial;
render_mode depth_draw_never, cull_back;
uniform sampler2D condition_map : filter_linear_mipmap, repeat_enable;
varying vec3 local_position;
void vertex(){local_position=VERTEX;}
void fragment(){
    vec3 p=normalize(local_position);
    vec2 coord=vec2(atan(p.x,p.z)/6.2831853+0.5,0.5-asin(clamp(p.y,-1.0,1.0))/3.14159265);
    float cloud=texture(condition_map,coord).a;
    ALBEDO=vec3(0.87,0.93,0.91);
    ROUGHNESS=1.0;
    SPECULAR=0.0;
    ALPHA=cloud*0.42;
}
