shader_type canvas_item;
// Färbt das fertige Bild der Welt: Sättigung, Farbstich und Dunst.

uniform sampler2D schirm : hint_screen_texture, filter_linear;
uniform float saettigung = 1.0;
uniform vec3 farbe = vec3(1.0);
uniform float nebel = 0.0;
uniform vec3 nebelfarbe = vec3(0.78, 0.8, 0.84);

void fragment() {
	vec3 c = texture(schirm, SCREEN_UV).rgb;
	float grau = dot(c, vec3(0.299, 0.587, 0.114));
	c = mix(vec3(grau), c, saettigung) * farbe;
	COLOR = vec4(mix(c, nebelfarbe, nebel), 1.0);
}
