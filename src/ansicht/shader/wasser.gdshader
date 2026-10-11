shader_type canvas_item;
render_mode blend_add;
// Lichtstreifen, die über das gemalte Wasser ziehen. Richtung und Tempo kommen aus der
// Stimmung der Welt.

global uniform float wasser;
uniform sampler2D rauschen : repeat_enable, filter_linear;

varying vec2 ort;

void vertex() {
	ort = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	// Der Bach folgt der y-Achse des Rasters, auf dem Bildschirm also nach links unten.
	// Quer dazu steht die Senkrechte, nicht die andere Rasterachse: sonst liegen die Streifen schief.
	float entlang = dot(ort, normalize(vec2(-2.0, 1.0)));
	float quer = dot(ort, normalize(vec2(1.0, 2.0)));
	float a = texture(rauschen, vec2(entlang * 0.003 - TIME * 0.1 * wasser, quer * 0.03)).r;
	float b = texture(rauschen, vec2(entlang * 0.005 - TIME * 0.17 * wasser + 0.37, quer * 0.045 + 0.5)).r;
	float glanz = smoothstep(0.58, 0.78, a * 0.6 + b * 0.4);
	COLOR = vec4(vec3(1.0), glanz * 0.26);
}
