shader_type spatial;
render_mode unshaded;
//stencil_mode read, compare_not_equal, 1;

uniform float activated: hint_range(0.0, 1.0) = 0.0;

void vertex() {
	VERTEX *= 1.0;
}

void fragment() {
	ALBEDO = vec3(0.0);
	ALPHA = activated * 0.75;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
