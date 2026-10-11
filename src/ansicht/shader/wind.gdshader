shader_type canvas_item;
// Wiegt ein aufrechtes Objekt im Wind: Der Fuß bleibt stehen, die Krone neigt sich in
// Windrichtung und schwankt. Das Bild braucht links und rechts einen durchsichtigen Rand.

global uniform float wind;

varying vec4 farbe;
varying float phase;

void vertex() {
	farbe = COLOR;
	// Jedes Objekt schwankt je nach Standort leicht versetzt.
	phase = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).x * 0.013;
}

void fragment() {
	float hoehe = 1.0 - UV.y;
	float biegung = hoehe * hoehe;
	float welle = sin(TIME * 1.7 + phase + hoehe * 2.0) * 0.6 + sin(TIME * 3.1 + phase * 1.7 + hoehe * 5.0) * 0.4;
	// Bei gespiegelten Bildern läuft UV rückwärts; das Vorzeichen hält die Windrichtung gleich.
	float versatz = (wind * 0.03 + welle * abs(wind) * 0.018) * biegung * sign(dFdx(UV.x));
	COLOR = texture(TEXTURE, vec2(UV.x - versatz, UV.y)) * farbe;
}
