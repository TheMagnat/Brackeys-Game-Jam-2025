shader_type spatial;
render_mode cull_disabled;

uniform sampler2D noiseTexture;

void vertex() {
	float timeFactor = 0.5;
	//VERTEX.x *= 1.0 + UV.y;
	
	VERTEX.z += (texture(noiseTexture, (UV + TIME * timeFactor) * 0.1).r - 0.5) * 10.0;
	VERTEX.x += (texture(noiseTexture, (UV + vec2(19.0, -12.65) + TIME * timeFactor) * 0.1).r - 0.5) * 10.0;
	
	VERTEX += NORMAL * texture(noiseTexture, (UV + vec2(39.0, 12.65) + TIME * timeFactor) * 0.1).r * 10.0;
	
}

void fragment() {
	ALBEDO = vec3(0.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
