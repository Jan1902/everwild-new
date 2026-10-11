shader_type canvas_item;
// Sways an upright object in the wind: the foot stays put, the crown leans in the wind direction
// and wobbles. The image needs a transparent margin on its left and right.

global uniform float wind;

varying vec4 tint;
varying float phase;

void vertex() {
	tint = COLOR;
	// Each object wobbles slightly out of step, depending on where it stands.
	phase = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).x * 0.013;
}

void fragment() {
	float height = 1.0 - UV.y;
	float bend = height * height;
	float wave = sin(TIME * 1.7 + phase + height * 2.0) * 0.6 + sin(TIME * 3.1 + phase * 1.7 + height * 5.0) * 0.4;
	// Mirrored images have UV running backwards; the sign keeps the wind direction the same.
	float shift = (wind * 0.03 + wave * abs(wind) * 0.018) * bend * sign(dFdx(UV.x));
	COLOR = texture(TEXTURE, vec2(UV.x - shift, UV.y)) * tint;
}
