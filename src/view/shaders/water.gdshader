shader_type canvas_item;
render_mode blend_add;
// Streaks of light drifting over the painted water. Direction and speed come from the mood of
// the world.

global uniform float water;
uniform sampler2D noise : repeat_enable, filter_linear;

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	// The brook follows the y axis of the grid, which on screen runs down and to the left.
	// Across it lies the perpendicular, not the other grid axis: otherwise the streaks are skewed.
	float along = dot(world_pos, normalize(vec2(-2.0, 1.0)));
	float across = dot(world_pos, normalize(vec2(1.0, 2.0)));
	float a = texture(noise, vec2(along * 0.003 - TIME * 0.1 * water, across * 0.03)).r;
	float b = texture(noise, vec2(along * 0.005 - TIME * 0.17 * water + 0.37, across * 0.045 + 0.5)).r;
	float glint = smoothstep(0.58, 0.78, a * 0.6 + b * 0.4);
	COLOR = vec4(vec3(1.0), glint * 0.26);
}
