shader_type spatial;

uniform sampler2D frontTexture: source_color;
uniform sampler2D backTexture: source_color;
uniform vec3 sideColor: source_color;

varying float useSideColor;
varying float useBackTexture;

void vertex() {
	// Front or back
	useBackTexture = step(0.5, UV.x);
	UV.x -= useBackTexture * 0.6;
	
	// Side or face
	useSideColor = step(0.85, UV.y);
	
	UV *= vec2(2.5, 1.25);
}

void fragment() {
	vec3 color = mix(
		texture(frontTexture, UV).rgb,
		texture(backTexture, UV).rgb,
		useBackTexture
	);
	ALBEDO = mix(color, sideColor, useSideColor);
}
