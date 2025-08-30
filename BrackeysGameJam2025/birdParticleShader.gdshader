shader_type spatial;
render_mode cull_disabled, unshaded;
stencil_mode write, compare_always, 2;

uniform sampler2DArray birdsFrames;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0), MODEL_MATRIX[3]);
}

const float repeateDuringAnimation = 60.0;
const float nbFramesInAnimation = 12.0;

void fragment() {
	float particleStep = COLOR.a;
	float animationStep = fract(particleStep * repeateDuringAnimation);
	
	float animationW = round(animationStep * nbFramesInAnimation) - 0.5;
	
	vec4 texCol = texture(birdsFrames, vec3(UV, animationW));
	
	ALBEDO = texCol.rgb;
	ALPHA = texCol.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
