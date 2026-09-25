shader_type spatial;
varying vec3 wp;
uniform bool climate_active = false;
uniform float temperature = 50.0;
uniform float pressure = 50.0;
uniform float baseline_temperature = 50.0;
uniform bool frozen = false;
void vertex(){ wp=VERTEX; }
float hash_dot(vec2 p){ return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float ground_noise(vec2 p){
    vec2 cell=floor(p); vec2 f=fract(p); f=f*f*(3.0-2.0*f);
    return mix(mix(hash_dot(cell),hash_dot(cell+vec2(1.0,0.0)),f.x),
               mix(hash_dot(cell+vec2(0.0,1.0)),hash_dot(cell+vec2(1.0,1.0)),f.x),f.y);
}
void fragment(){
    float fleck=hash_dot(floor(wp.xz*3.5));
    float macro=ground_noise(wp.xz*0.018);
    float mid=ground_noise(wp.xz*0.075);
    float grain=ground_noise(wp.xz*0.34);
    vec3 ground=COLOR.rgb;
    if(climate_active){
        float thaw=clamp((temperature-baseline_temperature)/35.0,0.0,1.0);
        float soil=ground_noise(wp.xz*0.065)*0.7+ground_noise(wp.xz*0.21)*0.3;
        if(frozen){ ground=mix(ground,mix(vec3(0.29,0.32,0.31),vec3(0.36,0.35,0.31),soil),thaw); }
        float freeze=1.0-smoothstep(0.0,25.0,temperature);
        ground=mix(ground,vec3(0.79,0.87,0.91),freeze*0.8);
        ground=mix(ground,vec3(0.43,0.29,0.2),smoothstep(60.0,95.0,temperature)*0.7);
        ground*=mix(1.08,0.8,pressure/100.0);
    }
    // Layered mineral/soil variation adds broad patches plus restrained grain.
    float terrain_texture = 0.76 + macro*0.24 + mid*0.16 + grain*0.06;
    // Keep surface ripples subtle so they do not read as repeated etched stripes.
    float ripple = sin(wp.x * 0.8 + wp.z * 0.37) * 0.025;
    NORMAL = normalize(NORMAL + vec3(ripple, 0.0, ripple * 0.5));
    ALBEDO=ground*terrain_texture*(0.97+fleck*0.04);
    ROUGHNESS=0.88;
}
