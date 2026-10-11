class_name Iso
extends RefCounted
## Umrechnung zwischen Zellen des Logikrasters und Punkten in der isometrischen Ansicht.

## Breite und Höhe einer Zelle als Raute auf dem Bildschirm.
const ZELLE := Vector2(128, 64)


## Mittelpunkt einer Zelle. Nimmt auch Zwischenwerte, damit Figuren zwischen Zellen laufen können.
static func zu_punkt(zelle: Vector2) -> Vector2:
	return Vector2((zelle.x - zelle.y) * ZELLE.x * 0.5, (zelle.x + zelle.y) * ZELLE.y * 0.5)


## Zelle, in deren Raute der Punkt liegt.
static func zu_zelle(punkt: Vector2) -> Vector2i:
	var a := punkt.x / (ZELLE.x * 0.5)
	var b := punkt.y / (ZELLE.y * 0.5)
	return Vector2i(floori((a + b) * 0.5 + 0.5), floori((b - a) * 0.5 + 0.5))
