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
    float fleck=hash_dot(floor(wp.xz*9.0));
    float band=sin(wp.x*2.0+sin(wp.z*0.7)*3.0)*0.5+0.5;
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
    ALBEDO=ground*(0.91+fleck*0.1+band*0.04);
    ROUGHNESS=0.95;
}
