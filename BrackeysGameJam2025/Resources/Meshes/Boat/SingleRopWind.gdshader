shader_type spatial;

uniform sampler2D noiseTexture: repeat_enable;
uniform vec3 ropColor: source_color;

void vertex() {
	vec4 worldSpace = MODEL_MATRIX * vec4(VERTEX, 1.0);
	
	float timeFactor = 0.5;
	float noiseScale = 0.02;
	float displacementValue = 20.0;
	//VERTEX.x *= 1.0 + UV.y;
	float height = pow(1.0 - UV.y, 0.6);
	height = worldSpace.y * 0.005;
	
	VERTEX.z += (texture(noiseTexture, (worldSpace.xy * 0.01 + TIME * timeFactor) * noiseScale).r - 0.5) * displacementValue * height;
	VERTEX.x += (texture(noiseTexture, (worldSpace.xy * 0.01 + vec2(19.0, -12.65) + TIME * timeFactor) * noiseScale).r - 0.5) * displacementValue * height * 0.5;
	VERTEX.y += (texture(noiseTexture, (worldSpace.xy * 0.01 + vec2(10.0, -12.65) + TIME * timeFactor) * noiseScale).r - 0.5) * displacementValue * height;
	
	//VERTEX += NORMAL * texture(noiseTexture, (UV + vec2(39.0, 12.65) + TIME * timeFactor) * 0.1).r * 10.0;
}

void fragment() {
	ALBEDO = ropColor;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
