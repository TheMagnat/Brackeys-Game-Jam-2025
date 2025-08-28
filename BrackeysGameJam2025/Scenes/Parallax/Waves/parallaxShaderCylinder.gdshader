shader_type spatial;
render_mode diffuse_toon, specular_toon, cull_front, unshaded;

uniform sampler2D noiseTexture;

uniform sampler2D parallaxTexture: repeat_enable, filter_linear;
uniform float repeatScale;
uniform float timeScale;

varying vec3 normal;

float rand(float co) { return fract(sin(co*(91.3458)) * 47453.5453); }

varying float seed;

void vertex() {
	float t = seed + TIME * 1.0;
	
	seed = rand(timeScale);
	normal = NORMAL;
	
	float noiseValue = texture(noiseTexture, vec2(UV.x, t) * 0.1).r;
	//VERTEX.y += noiseValue * 20.0;
}

void fragment() {
	if (abs(normal.y) > 0.1) discard;
	
	float t = seed + TIME * timeScale;
	
	vec2 uv = UV;
	uv.x *= -repeatScale;
	uv.x -= t;
	
	// Cylindre
	uv.y = (UV.y + 0.0) * 1.9;
	
	vec4 color = texture(parallaxTexture, uv);
	ALBEDO = color.rgb;
	ALPHA = color.a;
	ALPHA_SCISSOR_THRESHOLD = 0.05;
	
	//ALBEDO = vec3(UV, 0.0);
	//ALPHA = 1.0;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
