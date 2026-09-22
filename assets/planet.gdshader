shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;
uniform int climate = 0;
uniform float world_seed = 0.0;
uniform float recovery = 0.0;
varying vec3 sphere_pos;

float hash(vec3 p) {
    p = fract(p * 0.3183099 + vec3(0.1, 0.2, 0.3));
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}
float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f*f*(3.0-2.0*f);
    return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),
                   mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),
               mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),
                   mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z);
}
void vertex() { sphere_pos = VERTEX; }
void fragment() {
    vec3 p = normalize(sphere_pos);
    vec3 q = p * 3.2 + vec3(world_seed * 0.17);
    float n = noise(q)*0.6 + noise(q*2.03)*0.27 + noise(q*4.01)*0.13;
    float coast = smoothstep(0.46,0.51,n);
    vec3 ocean = vec3(0.035,0.15,0.24);
    vec3 land = mix(vec3(0.13,0.34,0.25),vec3(0.46,0.52,0.33),smoothstep(0.5,0.75,n));
    vec3 color = mix(ocean,land,coast);
    if (climate == 1) {
        vec3 ice = mix(vec3(0.21,0.40,0.52),vec3(0.77,0.87,0.88),smoothstep(0.3,0.68,n));
        color = mix(ice,color,recovery*0.8);
    }
    if (climate == 2) {
        vec3 desert = mix(vec3(0.28,0.13,0.085),vec3(0.69,0.45,0.24),smoothstep(0.3,0.7,n));
        color = mix(desert,color,recovery*0.7);
    }
    float polar = smoothstep(0.75,0.94,abs(p.y)+n*0.12);
    color = mix(color,vec3(0.84,0.91,0.91),polar*(climate == 2 ? 0.18 : 0.85));
    float clouds = smoothstep(0.63,0.76,noise(q*2.6+vec3(7.0)));
    ALBEDO = mix(color,vec3(0.85,0.91,0.93),clouds*0.25);
    ROUGHNESS = 0.9;
}
