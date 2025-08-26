shader_type spatial;

uniform sampler3D noiseTexture: repeat_enable;

void vertex() {

	float t = TIME * 0.0;
	vec3 uv = vec3(UV + t, t * 0.1) * 0.5;

	float offset = 0.2;
	float right = texture(noiseTexture, uv + vec3(offset, 0.0, 0.0)).r;
	float left = texture(noiseTexture, uv + vec3(-offset, 0.0, 0.0)).r;
	float up = texture(noiseTexture, uv + vec3(0.0, 0.0, offset)).r;
	float down = texture(noiseTexture, uv + vec3(0.0, 0.0, -offset)).r;
	float noiseValue = texture(noiseTexture, uv).r;

	vec3 normal = normalize(vec3(right-left, 0.5, down-up));
	NORMAL = normal;

	VERTEX.y += noiseValue * 1000.0;
}

void fragment() {
	ALBEDO = vec3(0.1, 0.2, 0.8);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
