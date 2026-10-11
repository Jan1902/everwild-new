class_name TargetMarker
extends Node2D
## Brief feedback on the ground showing where the character is heading.

var _fade: Tween


func _ready() -> void:
	modulate.a = 0.0


func show_at(cell: Vector2i) -> void:
	position = Iso.to_point(cell)
	modulate.a = 1.0
	if _fade:
		_fade.kill()
	_fade = create_tween()
	_fade.tween_property(self, "modulate:a", 0.0, 0.9)


func _draw() -> void:
	var half := Iso.CELL * 0.32
	var diamond := PackedVector2Array([
		Vector2(0, -half.y), Vector2(half.x, 0), Vector2(0, half.y), Vector2(-half.x, 0), Vector2(0, -half.y),
	])
	draw_polyline(diamond, Color(1, 1, 1, 0.85), 3.0, true)
