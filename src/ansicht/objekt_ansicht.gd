class_name ObjektAnsicht
extends Node2D
## Zeigt ein Objekt der Welt. Bis auf die Laterne sind alle Objekte gezeichnete Platzhalter.

const LATERNE := "res://assets/objekte/laterne.png"
## Fußpunkt des Pfostens im Laternenbild und Maßstab des Bildes in der Welt.
const LATERNE_FUSS := Vector2(610, 950)
const LATERNE_MASS := 0.2

var art := ""
var groesse := Vector2i.ONE


## Richtet das Objekt ein. Der Knoten sitzt in der Mitte seiner Grundfläche, damit die
## Tiefensortierung nach y stimmt.
func richte_ein(objekt: Dictionary) -> void:
	art = objekt.art
	groesse = objekt.groesse
	position = Iso.zu_punkt(Vector2(objekt.zelle) + Vector2(groesse - Vector2i.ONE) * 0.5)
	if art == "laterne":
		var bild := Sprite2D.new()
		bild.texture = load(LATERNE)
		bild.centered = false
		bild.offset = -LATERNE_FUSS
		bild.scale = Vector2.ONE * LATERNE_MASS
		add_child(bild)


func _draw() -> void:
	match art:
		"baum":
			_zeichne_baum()
		"stein":
			_zeichne_stein()
		"haus":
			_zeichne_haus()
		"laterne":
			_zeichne_schatten(18.0)


func _zeichne_schatten(radius: float) -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, radius, Color(0, 0, 0, 0.16))
	draw_set_transform(Vector2.ZERO)


func _zeichne_baum() -> void:
	_zeichne_schatten(40.0)
	draw_rect(Rect2(-7, -52, 14, 54), Color("7a5a3c"))
	draw_circle(Vector2(-22, -76), 30.0, Color("4f8a55"))
	draw_circle(Vector2(24, -80), 28.0, Color("4f8a55"))
	draw_circle(Vector2(0, -98), 44.0, Color("5c9a5e"))
	draw_circle(Vector2(-10, -110), 22.0, Color("71ad6c"))


func _zeichne_stein() -> void:
	_zeichne_schatten(34.0)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-34, 0), Vector2(-26, -26), Vector2(4, -38), Vector2(32, -20), Vector2(36, 2), Vector2(4, 12)]),
		Color("8d8f96")
	)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-26, -26), Vector2(4, -38), Vector2(32, -20), Vector2(2, -12)]),
		Color("a9abb1")
	)


func _zeichne_haus() -> void:
	var halb := Vector2(groesse) * 0.5
	# Ecken der Grundfläche, relativ zur Mitte: hinten, rechts, vorne, links.
	var hinten := Iso.zu_punkt(Vector2(-halb.x, -halb.y))
	var rechts := Iso.zu_punkt(Vector2(halb.x, -halb.y))
	var vorne := Iso.zu_punkt(Vector2(halb.x, halb.y))
	var links := Iso.zu_punkt(Vector2(-halb.x, halb.y))
	var hoch := Vector2(0, -96)
	var first := (hinten + vorne) * 0.5 + hoch + Vector2(0, -78)

	draw_colored_polygon(PackedVector2Array([links, vorne, vorne + hoch, links + hoch]), Color("d9c7a6"))
	draw_colored_polygon(PackedVector2Array([vorne, rechts, rechts + hoch, vorne + hoch]), Color("efe0c1"))
	# Tür an der rechten Wand
	var tuer_a := vorne.lerp(rechts, 0.4)
	var tuer_b := vorne.lerp(rechts, 0.62)
	draw_colored_polygon(
		PackedVector2Array([tuer_a, tuer_b, tuer_b + Vector2(0, -58), tuer_a + Vector2(0, -58)]), Color("7a5a3c")
	)
	# Dach: erst die beiden hinteren Flächen, dann die vorderen
	draw_colored_polygon(PackedVector2Array([hinten + hoch, links + hoch, first]), Color("a8523f"))
	draw_colored_polygon(PackedVector2Array([hinten + hoch, rechts + hoch, first]), Color("b65a44"))
	draw_colored_polygon(PackedVector2Array([links + hoch, vorne + hoch, first]), Color("b65a44"))
	draw_colored_polygon(PackedVector2Array([vorne + hoch, rechts + hoch, first]), Color("c96a50"))
