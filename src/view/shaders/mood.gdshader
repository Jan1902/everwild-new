shader_type canvas_item;
// Grades the finished picture of the world: saturation, tint and haze.

uniform sampler2D screen : hint_screen_texture, filter_linear;
uniform float saturation = 1.0;
uniform vec3 tint = vec3(1.0);
uniform float fog = 0.0;
uniform vec3 fog_color = vec3(0.78, 0.8, 0.84);

void fragment() {
	vec3 c = texture(screen, SCREEN_UV).rgb;
	float grey = dot(c, vec3(0.299, 0.587, 0.114));
	c = mix(vec3(grey), c, saturation) * tint;
	COLOR = vec4(mix(c, fog_color, fog), 1.0);
}
