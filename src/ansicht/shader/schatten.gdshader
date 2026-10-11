shader_type canvas_item;
// Legt die Silhouette eines Objekts als Schatten flach auf den Boden. Der Fußpunkt des Bildes
// muss im Ursprung liegen.
//
// "schatten" ist der Schattenwurf in der Bodenebene, von oben gesehen: Richtung und Länge pro
// Höhe des Objekts. Die Höhe des Bildes läuft entlang dieser Richtung, seine Breite quer dazu.
// Zum Schluss wird alles auf die halbe Höhe gestaucht, wie jeder Kreis auf dem Boden der Welt.

global uniform vec2 schatten;

void vertex() {
	float breite = VERTEX.x;
	float hoehe = -VERTEX.y;
	vec2 quer = normalize(vec2(-schatten.y, schatten.x));
	vec2 am_boden = breite * quer + hoehe * schatten;
	VERTEX = vec2(am_boden.x, am_boden.y * 0.5);
}

void fragment() {
	COLOR = vec4(0.08, 0.1, 0.22, texture(TEXTURE, UV).a);
}
