shader_type canvas_item;
    uniform float cloudStrength = 0.4;
    uniform float speed = 2.2;
    uniform vec3 color = vec3(0.95, 0.95, 0.90);
    uniform float light = 1.0;
    
    float rand(vec2 coord){
    	return fract(sin(dot(coord, vec2(12.9898,78.233))) * 43758.5453);
    }
    
    float noise(vec2 coord){
    	vec2 i = floor(coord);
    	vec2 f = fract(coord);
    
    	// 4 corners of a rectangle surrounding our point
    	float a = rand(i);
    	float b = rand(i + vec2(1.0, 0.0));
    	float c = rand(i + vec2(0.0, 1.0));
    	float d = rand(i + vec2(1.0, 1.0));
    
    	vec2 cubic = f * f * (3.0 - 2.0 * f);
    
    	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
    }
    
    void fragment() {
    	vec2 coord = UV * 20.0;
    
    	vec2 motion = vec2( noise(coord + vec2(TIME * -speed, TIME * speed)) );
    
    	float final = noise(coord + motion);
    	
    	COLOR = vec4(color*light, final * cloudStrength);
    }
void fragment() {
	vec2 coord = UV * 20.0;

	vec2 motion = vec2( fbm(coord + vec2(TIME * 5.0, TIME * -0.0)) );

	float final = fbm(coord + motion);

	COLOR = vec4(color, final * 0.5);
}