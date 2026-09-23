shader_type spatial;
render_mode diffuse_burley;
uniform sampler2D surface_map : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D condition_map : filter_linear_mipmap, repeat_enable;
uniform sampler2D normal_map : filter_linear_mipmap, repeat_enable;
uniform sampler2D recovered_map : source_color, filter_linear_mipmap, repeat_enable;
uniform float recovery : hint_range(0,1) = 0.0;
uniform vec3 basin_direction = vec3(0,0.2747,0.9615);
uniform bool map_fog = false;
uniform float chart_fraction : hint_range(0,1) = 0.0;
uniform bool survey_layer = false;
uniform bool grid_visible = false;
varying vec3 local_position;
void vertex(){local_position=VERTEX;}
void fragment(){
    vec3 p=normalize(local_position);
    float lon=(atan(p.x,p.z)+3.14159265)/6.2831853;
    float lat=asin(clamp(p.y,-1.0,1.0))/3.14159265+0.5;
    vec2 coord=vec2(lon,1.0-lat);
    vec3 ground=mix(texture(surface_map,coord).rgb,texture(recovered_map,coord).rgb,recovery);
    vec4 conditions=texture(condition_map,coord);
    float local_chart=smoothstep(0.991,0.997,dot(p,normalize(basin_direction)));
    float orbital_chart=chart_fraction >= 1.0 ? 1.0 : (chart_fraction <= 0.0 ? 0.0 : 1.0-smoothstep(chart_fraction-0.008,chart_fraction+0.008,lon));
    float known=max(local_chart,orbital_chart);
    if(survey_layer){ground=mix(vec3(0.32,0.25,0.56),vec3(0.20,0.65,0.40),local_chart);}
    if(map_fog){ground=mix(vec3(0.055,0.047,0.09),ground,known);}
    if(grid_visible){
        vec2 cell=abs(fract(vec2(lon*24.0,lat*12.0)+0.5)-0.5);
        float grid=1.0-smoothstep(0.009,0.025,min(cell.x,cell.y));
        ground=mix(ground,vec3(0.40,0.34,0.54),grid*0.35);
    }
    vec3 relief_normal=normalize(texture(normal_map,coord).rgb*2.0-1.0);
    if(!map_fog){NORMAL=normalize((VIEW_MATRIX*MODEL_MATRIX*vec4(relief_normal,0.0)).xyz);}
    ALBEDO=ground;
    EMISSION=map_fog ? ground*0.24 : ground*0.035;
    SPECULAR=0.18;
    ROUGHNESS=map_fog ? 0.95 : mix(0.56,0.94,smoothstep(0.495,0.505,conditions.r));
}
