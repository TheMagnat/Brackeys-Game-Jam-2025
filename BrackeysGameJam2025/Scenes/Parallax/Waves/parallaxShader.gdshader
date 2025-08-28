shader_type spatial;
render_mode diffuse_toon, specular_toon, unshaded;

uniform sampler2D parallaxTexture: repeat_enable, filter_linear;
uniform float repeatScale;
uniform float timeScale;
uniform float offset;

uniform sampler2D noiseTexture: repeat_enable;

float rand(float co) { return fract(sin(co*(91.3458)) * 47453.5453); }


void vertex() {
	float t = (offset + timeScale * 5.0) + TIME * 0.25;
	float d = sign(repeatScale);
	float f = min(0.0, d);
	
	float xUv = f - UV.x * d;
	
	float noiseValue = texture(noiseTexture, vec2(xUv * 0.25 + t * 0.1, t * 0.1)).r * 20.0;
	
	if (UV.y < 1.0)
		VERTEX.y += noiseValue;// * (1.0 - UV.y);
	else
		VERTEX.y -= 100.0;
}

void fragment() {
	float t = offset + TIME * timeScale * 2.0;
	
	vec2 uv = UV;
	uv.x *= -repeatScale;
	uv.x -= t;
	
	
	
	// Cylindre
	//uv.y = (UV.y + 0.0) * 1.9;
	
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
