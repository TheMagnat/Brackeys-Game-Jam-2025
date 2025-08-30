shader_type spatial;
stencil_mode write, compare_always, 2;
render_mode fog_disabled, unshaded;

uniform sampler2DArray textures: repeat_enable;
//uniform sampler2D screenTexture: hint_screen_texture;

const bool y_billboard = true;

float rand(float x) {
    return fract(sin(x) * 43758.5453123);
}

void vertex() {
	// You can comment out this function if you don't need billboarding
	//if (y_billboard == true) {
		//MODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0), MODEL_MATRIX[3]);
	//}
	//else {
		//MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	//}
	// Billboard Mode: Particles
	mat4 mat_world = mat4(
			normalize(INV_VIEW_MATRIX[0]),
			normalize(INV_VIEW_MATRIX[1]),
			normalize(INV_VIEW_MATRIX[2]),
			MODEL_MATRIX[3]);
	mat_world = mat_world * mat4(
			vec4(cos(INSTANCE_CUSTOM.x), -sin(INSTANCE_CUSTOM.x), 0.0, 0.0),
			vec4(sin(INSTANCE_CUSTOM.x), cos(INSTANCE_CUSTOM.x), 0.0, 0.0),
			vec4(0.0, 0.0, 1.0, 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_MATRIX = VIEW_MATRIX * mat_world;

	// Billboard Keep Scale: Enabled
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
			vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
			vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
			vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));

	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	
}

void fragment() {
	float r = rand(COLOR.r);
	
	vec4 tex = texture(textures, vec3(UV, round(r * 9.0) - 0.5));
	ALBEDO = tex.rgb;
	ALPHA = tex.a;// * 0.5;
	ALPHA_SCISSOR_THRESHOLD = 0.01;
	//ALPHA_HASH_SCALE = 0.1;
	//ALBEDO = vec3();
	
	//ALBEDO = mix(tex.rgb, texture(screenTexture, SCREEN_UV).rgb, 1.0 - COLOR.a);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
