class_name Zielmarke
extends Node2D
## Kurze Rückmeldung auf dem Boden, wohin die Figur läuft.

var _blende: Tween


func _ready() -> void:
	modulate.a = 0.0


func zeige(zelle: Vector2i) -> void:
	position = Iso.zu_punkt(zelle)
	modulate.a = 1.0
	if _blende:
		_blende.kill()
	_blende = create_tween()
	_blende.tween_property(self, "modulate:a", 0.0, 0.9)


func _draw() -> void:
	var halb := Iso.ZELLE * 0.32
	var raute := PackedVector2Array([
		Vector2(0, -halb.y), Vector2(halb.x, 0), Vector2(0, halb.y), Vector2(-halb.x, 0), Vector2(0, -halb.y),
	])
	draw_polyline(raute, Color(1, 1, 1, 0.85), 3.0, true)
