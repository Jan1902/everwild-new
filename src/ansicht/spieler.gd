class_name Spieler
extends Node2D
## Die Spielfigur als Platzhalter. Läuft einen Weg aus Zellen ab und meldet jede erreichte Zelle.

signal zelle_erreicht(zelle: Vector2i)

## Zellen pro Sekunde.
const TEMPO := 3.5

## Zuletzt erreichte Zelle.
var zelle := Vector2i.ZERO

var _genau := Vector2.ZERO
var _weg: Array[Vector2i] = []
var _schritt := 0.0
var _blick := 1.0


func setze(neue_zelle: Vector2i) -> void:
	zelle = neue_zelle
	_genau = Vector2(neue_zelle)
	_weg.clear()
	position = Iso.zu_punkt(_genau)


## Zelle, von der aus ein neuer Weg beginnen muss: das Ziel des laufenden Schritts.
func naechster_halt() -> Vector2i:
	return zelle if _weg.is_empty() else _weg[0]


## Ersetzt den aktuellen Weg. Der Weg muss bei naechster_halt() beginnen.
func gehe(weg: Array[Vector2i]) -> void:
	_weg = weg


func _process(delta: float) -> void:
	if _weg.is_empty():
		return
	var rest := TEMPO * delta
	while rest > 0.0 and not _weg.is_empty():
		var ziel := Vector2(_weg[0])
		var abstand := _genau.distance_to(ziel)
		if abstand <= rest:
			_genau = ziel
			rest -= abstand
			zelle = _weg.pop_front()
			zelle_erreicht.emit(zelle)
		else:
			_genau = _genau.move_toward(ziel, rest)
			rest = 0.0
	var neu := Iso.zu_punkt(_genau)
	if absf(neu.x - position.x) > 0.01:
		_blick = signf(neu.x - position.x)
	position = neu
	_schritt = 0.0 if _weg.is_empty() else _schritt + delta * 12.0
	queue_redraw()


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, 22.0, Color(0, 0, 0, 0.2))
	# Leichtes Wippen beim Gehen
	draw_set_transform(Vector2(0, -absf(sin(_schritt)) * 5.0))
	draw_colored_polygon(
		PackedVector2Array([Vector2(-18, 0), Vector2(18, 0), Vector2(11, -54), Vector2(-11, -54)]), Color("b5533c")
	)
	draw_circle(Vector2(3.0 * _blick, -66), 14.0, Color("f0d2b0"))
	draw_set_transform(Vector2.ZERO)
