class_name Stimmung
extends RefCounted
## Alle Regler, mit denen sich eine Welt richtig oder falsch anfühlt. Reine Daten.

## Windrichtung und -stärke. Positiv weht nach rechts, negativ nach links.
var wind := 1.0
## Fließrichtung und -tempo des Wassers. Negativ fließt es rückwärts.
var wasser := 1.0
## Schattenwurf in der Bodenebene, von oben gesehen: Richtung und Länge pro Höhe des Objekts.
## x zeigt auf dem Bildschirm nach rechts, y zum Betrachter hin.
var schatten := Vector2(0.5, 0.2)
## Farbsättigung des ganzen Bildes, 1 ist normal.
var saettigung := 1.0
## Farbstich des ganzen Bildes, Weiß ist keiner.
var farbe := Color.WHITE
## Dunst über dem ganzen Bild, 0 bis 1.
var nebel := 0.0
## Helligkeit der Lichter in der Welt.
var licht := 1.0
## Tonhöhe und Tempo der Musik, 1 ist normal.
var tonhoehe := 1.0
## Wie dumpf die Musik klingt, 0 bis 1.
var daempfung := 0.0


## Liest eine Stimmung. Nicht genannte Regler kommen aus der Basis oder bleiben auf dem Normalwert.
static func aus_daten(daten: Dictionary, basis: Stimmung = null) -> Stimmung:
	var s := mische(basis, basis, 0.0) if basis else Stimmung.new()
	s.wind = daten.get("wind", s.wind)
	s.wasser = daten.get("wasser", s.wasser)
	s.saettigung = daten.get("saettigung", s.saettigung)
	s.nebel = daten.get("nebel", s.nebel)
	s.licht = daten.get("licht", s.licht)
	s.tonhoehe = daten.get("tonhoehe", s.tonhoehe)
	s.daempfung = daten.get("daempfung", s.daempfung)
	if daten.has("schatten"):
		s.schatten = Vector2(daten.schatten[0], daten.schatten[1])
	if daten.has("farbe"):
		s.farbe = Color(daten.farbe[0], daten.farbe[1], daten.farbe[2])
	return s


## Zwischenstand zwischen zwei Stimmungen: anteil 0 ergibt a, anteil 1 ergibt b.
static func mische(a: Stimmung, b: Stimmung, anteil: float) -> Stimmung:
	var s := Stimmung.new()
	s.wind = lerpf(a.wind, b.wind, anteil)
	s.wasser = lerpf(a.wasser, b.wasser, anteil)
	s.schatten = a.schatten.lerp(b.schatten, anteil)
	s.saettigung = lerpf(a.saettigung, b.saettigung, anteil)
	s.farbe = a.farbe.lerp(b.farbe, anteil)
	s.nebel = lerpf(a.nebel, b.nebel, anteil)
	s.licht = lerpf(a.licht, b.licht, anteil)
	s.tonhoehe = lerpf(a.tonhoehe, b.tonhoehe, anteil)
	s.daempfung = lerpf(a.daempfung, b.daempfung, anteil)
	return s
