shader_type canvas_item;
// Grades the finished picture of the world: saturation, tint and haze.

uniform sampler2D screen : hint_screen_texture, filter_linear;
uniform float saturation = 1.0;
uniform vec3 tint = vec3(1.0);
uniform float fog = 0.0;
uniform vec3 fog_color = vec3(0.78, 0.8, 0.84);
// Warm light that swells over the picture for a moment, 0 to 1.
uniform float glow = 0.0;
uniform vec3 glow_color = vec3(1.0, 0.86, 0.6);

// A part of the picture that is graded as the player remembers it instead: how far (0 to 1),
// its centre and its radius in both directions (in fractions of the screen), and the
// remembered grading. It fades out softly towards its rim.
uniform float memory = 0.0;
uniform vec2 memory_centre = vec2(0.5);
uniform vec2 memory_radius = vec2(0.2);
uniform float memory_saturation = 1.0;
uniform vec3 memory_tint = vec3(1.0);
uniform float memory_fog = 0.0;

vec3 grade(vec3 c, float with_saturation, vec3 with_tint, float with_fog) {
	float grey = dot(c, vec3(0.299, 0.587, 0.114));
	return mix(mix(vec3(grey), c, with_saturation) * with_tint, fog_color, with_fog);
}

void fragment() {
	vec3 seen = texture(screen, SCREEN_UV).rgb;
	vec3 c = grade(seen, saturation, tint, fog);
	if (memory > 0.0) {
		float distance_from_centre = length((SCREEN_UV - memory_centre) / memory_radius);
		float share = memory * (1.0 - smoothstep(0.45, 1.0, distance_from_centre));
		c = mix(c, grade(seen, memory_saturation, memory_tint, memory_fog), share);
	}
	// Brightens like light falling on the picture: dark parts gain most, nothing burns out.
	COLOR = vec4(c + (1.0 - c) * glow_color * glow, 1.0);
}
