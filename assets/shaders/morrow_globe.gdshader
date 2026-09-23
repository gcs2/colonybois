shader_type spatial;
uniform vec3 geography_offset = vec3(3,7,11);
uniform vec3 basin_direction = vec3(0,0.2747,0.9615);
uniform bool map_fog = false;
uniform float chart_fraction : hint_range(0,1) = 0.0;
uniform bool survey_layer = false;
uniform bool grid_visible = false;
varying vec3 local_position;

float hash3(vec3 p){return fract(sin(dot(p,vec3(127.1,311.7,74.7)))*43758.5453);}
float noise3(vec3 p){
    vec3 i=floor(p); vec3 f=fract(p); f=f*f*(3.0-2.0*f);
    return mix(mix(mix(hash3(i),hash3(i+vec3(1,0,0)),f.x),mix(hash3(i+vec3(0,1,0)),hash3(i+vec3(1,1,0)),f.x),f.y),
    mix(mix(hash3(i+vec3(0,0,1)),hash3(i+vec3(1,0,1)),f.x),mix(hash3(i+vec3(0,1,1)),hash3(i+vec3(1,1,1)),f.x),f.y),f.z);
}
float fbm(vec3 p){return noise3(p)*0.57+noise3(p*2.07)*0.28+noise3(p*4.13)*0.15;}
void vertex(){local_position=VERTEX;}
void fragment(){
    vec3 p=normalize(local_position);
    float basin=dot(p,normalize(basin_direction));
    float land=fbm(p*3.8+geography_offset);
    // The authored surface belongs on mineral land, never under the ocean.
    land=max(land,0.56*smoothstep(0.96,0.985,basin+(noise3(p*16.0)-0.5)*0.015));
    vec3 sea=mix(vec3(0.018,0.045,0.095),vec3(0.055,0.31,0.34),smoothstep(0.35,0.50,land));
    vec3 earth=mix(vec3(0.19,0.16,0.25),vec3(0.62,0.40,0.30),fbm(p*12.0+geography_offset));
    vec3 ground=mix(sea,earth,smoothstep(0.49,0.515,land));
    ground=mix(ground,vec3(0.72,0.8,0.83),smoothstep(0.82,0.99,abs(p.y)));
    float cloud=fbm(p*14.0+vec3(p.y*6.0,2,0));
    ground=mix(ground,vec3(0.76,0.8,0.84),smoothstep(0.59,0.76,cloud)*0.58);
    float lon=(atan(p.x,p.z)+3.14159265)/6.2831853;
    float lat=asin(clamp(p.y,-1.0,1.0))/3.14159265+0.5;
    float local_chart=smoothstep(0.991,0.997,basin);
    float orbital_chart=chart_fraction >= 1.0 ? 1.0 : (chart_fraction <= 0.0 ? 0.0 : 1.0-smoothstep(chart_fraction-0.008,chart_fraction+0.008,lon));
    float known=max(local_chart,orbital_chart);
    if(survey_layer){ground=mix(vec3(0.32,0.25,0.56),vec3(0.20,0.65,0.40),local_chart);}
    if(map_fog){ground=mix(vec3(0.055,0.047,0.09),ground,known);}
    if(grid_visible){
        vec2 cell=abs(fract(vec2(lon*24.0,lat*12.0)+0.5)-0.5);
        float grid=1.0-smoothstep(0.009,0.025,min(cell.x,cell.y));
        ground=mix(ground,vec3(0.40,0.34,0.54),grid*0.35);
    }
    ALBEDO=ground;
    EMISSION=map_fog ? ground*0.24 : vec3(0);
    // Fog masks all geographic channels, including specular response.
    SPECULAR=map_fog ? 0.08 : 0.45;
    ROUGHNESS=map_fog ? 0.95 : mix(0.32,0.85,smoothstep(0.49,0.515,land));
}
