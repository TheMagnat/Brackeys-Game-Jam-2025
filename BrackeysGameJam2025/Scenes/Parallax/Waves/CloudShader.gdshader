shader_type spatial;
stencil_mode write, compare_always, 2;
render_mode fog_disabled, unshaded;

uniform sampler2DArray textures: repeat_enable;

const bool y_billboard = true;

varying float textureIndex;

void vertex() {
	
	textureIndex = INSTANCE_CUSTOM.x;
	
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
	vec4 tex = texture(textures, vec3(UV, textureIndex));
	ALBEDO = tex.rgb;
	ALPHA = tex.a;// * 0.5;
	ALPHA_SCISSOR_THRESHOLD = 0.01;
}
