class_name Kastenschatten
extends Node2D
## Schatten eines kastenförmigen Objekts wie eines Hauses: die Grundfläche, verlängert um den
## Wurf der Wände und des Dachfirsts. Eine gekippte Silhouette passt bei Kästen nicht an die Wände.

const FARBE := Color(0.08, 0.1, 0.22)
## Die Grundfläche wird leicht vergrößert, damit rund um das Objekt ein dunkler Rand bleibt.
const UEBERSTAND := 1.08

var groesse := Vector2i.ONE
var wandhoehe := 0.0
var firsthoehe := 0.0

var _gezeichnet := Vector2.INF


func _process(_delta: float) -> void:
	if ObjektAnsicht.schattenwurf != _gezeichnet:
		queue_redraw()


func _draw() -> void:
	_gezeichnet = ObjektAnsicht.schattenwurf
	var wurf := Vector2(_gezeichnet.x, _gezeichnet.y * 0.5)
	var halb := Vector2(groesse) * 0.5 * UEBERSTAND
	var punkte := PackedVector2Array([wurf * firsthoehe])
	for ecke: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		var am_boden := Iso.zu_punkt(ecke * halb)
		punkte.append(am_boden)
		punkte.append(am_boden + wurf * wandhoehe)
	var huelle := Geometry2D.convex_hull(punkte)
	# convex_hull wiederholt den ersten Punkt am Ende, das Polygon braucht ihn nur einmal.
	huelle.remove_at(huelle.size() - 1)
	draw_colored_polygon(huelle, FARBE)
