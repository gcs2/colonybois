shader_type spatial;
varying vec3 wp;
uniform bool climate_active = false;
uniform float temperature = 50.0;
uniform float pressure = 50.0;
uniform float baseline_temperature = 50.0;
uniform bool frozen = false;
uniform float surface_detail = 0.0;
void vertex(){ wp=VERTEX; }
float hash_dot(vec2 p){ return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float ground_noise(vec2 p){
    vec2 cell=floor(p); vec2 f=fract(p); f=f*f*(3.0-2.0*f);
    return mix(mix(hash_dot(cell),hash_dot(cell+vec2(1.0,0.0)),f.x),
               mix(hash_dot(cell+vec2(0.0,1.0)),hash_dot(cell+vec2(1.0,1.0)),f.x),f.y);
}
void fragment(){
    float macro=ground_noise(wp.xz*0.018);
    float mid=ground_noise(wp.xz*0.075);
    vec3 ground=COLOR.rgb;
    float freeze=0.0;
    if(climate_active){
        float thaw=clamp((temperature-baseline_temperature)/35.0,0.0,1.0);
        float soil=ground_noise(wp.xz*0.065)*0.7+ground_noise(wp.xz*0.21)*0.3;
        if(frozen){ ground=mix(ground,mix(vec3(0.29,0.32,0.31),vec3(0.36,0.35,0.31),soil),thaw); }
        freeze=1.0-smoothstep(0.0,25.0,temperature);
        ground=mix(ground,vec3(0.79,0.87,0.91),freeze*0.8);
        ground=mix(ground,vec3(0.43,0.29,0.2),smoothstep(60.0,95.0,temperature)*0.7);
        ground*=mix(1.08,0.8,pressure/100.0);
    }
    // Two broad noise bands add warm soil/mineral patches without fine speckle.
    float mineral= smoothstep(0.18,0.82,macro*0.72+mid*0.28);
    vec3 mineral_tint=mix(vec3(0.91,0.84,0.76),vec3(1.14,1.04,0.88),mineral);
    float climate_detail=climate_active ? mix(1.0,0.12,freeze) : 1.0;
    float tonal_depth=0.80+macro*0.31+mid*0.12;
    float mottling=1.0;
    float grain=1.0;
    if(surface_detail>0.0){
        float soil_breakup=ground_noise(wp.xz*0.31);
        float fine_grain=ground_noise(wp.xz*1.15);
        mottling=mix(1.0,0.79+soil_breakup*0.34,surface_detail);
        grain=mix(1.0,0.93+fine_grain*0.14,surface_detail);
    }
    ALBEDO=ground*mix(vec3(1.0),mineral_tint,0.65*climate_detail)*tonal_depth*mottling*grain;
    ROUGHNESS=0.88;
}
