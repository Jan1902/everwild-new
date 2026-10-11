class_name BodenAnsicht
extends Node2D
## Zeichnet den Untergrund als Platzhalter, bis es gemalte Bilder gibt.

## Höhe der sichtbaren Abbruchkante am Inselrand.
const KANTE := 90.0
const FARBEN := {
	Welt.Boden.GRAS: Color("7fae6b"),
	Welt.Boden.WEG: Color("d8c394"),
	Welt.Boden.WASSER: Color("74b6cc"),
	Welt.Boden.BRUECKE: Color("a97c52"),
}
const ERDE_HELL := Color("8a6a4f")
const ERDE_DUNKEL := Color("6e533f")

var welt: Welt


func _draw() -> void:
	if welt == null:
		return
	# Erst alle Kanten, dann alle Flächen: so verdecken vordere Flächen die Kanten dahinter.
	for y in welt.groesse.y:
		for x in welt.groesse.x:
			_zeichne_kanten(Vector2i(x, y))
	for y in welt.groesse.y:
		for x in welt.groesse.x:
			_zeichne_flaeche(Vector2i(x, y))


func _zeichne_kanten(zelle: Vector2i) -> void:
	if welt.boden(zelle) == Welt.Boden.LEERE:
		return
	var e := _ecken(zelle)
	var runter := Vector2(0, KANTE)
	var wasser := welt.boden(zelle) == Welt.Boden.WASSER
	if welt.boden(zelle + Vector2i(1, 0)) == Welt.Boden.LEERE:
		var farbe := FARBEN[Welt.Boden.WASSER].darkened(0.15) if wasser else ERDE_HELL
		draw_colored_polygon(PackedVector2Array([e[1], e[2], e[2] + runter, e[1] + runter]), farbe)
	if welt.boden(zelle + Vector2i(0, 1)) == Welt.Boden.LEERE:
		var farbe := FARBEN[Welt.Boden.WASSER].darkened(0.3) if wasser else ERDE_DUNKEL
		draw_colored_polygon(PackedVector2Array([e[2], e[3], e[3] + runter, e[2] + runter]), farbe)


func _zeichne_flaeche(zelle: Vector2i) -> void:
	var art := welt.boden(zelle)
	if art == Welt.Boden.LEERE:
		return
	var e := _ecken(zelle)
	# Leichte Helligkeitsschwankung pro Zelle, damit die Fläche nicht wie ein Raster wirkt.
	var schwankung := 1.0 + (hash(zelle) % 5 - 2) * 0.012
	var farbe: Color = FARBEN[art]
	draw_colored_polygon(e, Color(farbe.r * schwankung, farbe.g * schwankung, farbe.b * schwankung))
	if art == Welt.Boden.BRUECKE:
		for anteil: float in [0.25, 0.5, 0.75]:
			draw_line(e[0].lerp(e[1], anteil), e[3].lerp(e[2], anteil), farbe.darkened(0.25), 2.0)


## Ecken der Raute einer Zelle: hinten, rechts, vorne, links.
func _ecken(zelle: Vector2i) -> PackedVector2Array:
	var mitte := Iso.zu_punkt(zelle)
	var halb := Iso.ZELLE * 0.5
	return PackedVector2Array([
		mitte + Vector2(0, -halb.y),
		mitte + Vector2(halb.x, 0),
		mitte + Vector2(0, halb.y),
		mitte + Vector2(-halb.x, 0),
	])
