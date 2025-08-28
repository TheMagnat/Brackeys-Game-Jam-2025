shader_type spatial;
render_mode cull_disabled;

uniform sampler2D noiseTexture;

void vertex() {
	float timeFactor = 0.1;
	VERTEX.x *= 1.0 + UV.y;
	
	VERTEX.y += texture(noiseTexture, (UV + TIME * timeFactor) * 0.1).r * 50.0;
	VERTEX.x += texture(noiseTexture, (UV + vec2(19.0, -12.65) + TIME * timeFactor) * 0.1).r * 50.0;
	VERTEX.z += texture(noiseTexture, (UV + vec2(39.0, 12.65) + TIME * timeFactor) * 0.1).r * 50.0;
	
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
