class_name Player
extends Node2D
## The player character as a placeholder. Walks a path of cells and reports every cell it reaches.

signal cell_reached(cell: Vector2i)

## Cells per second.
const SPEED := 3.5

## Cell reached most recently.
var cell := Vector2i.ZERO

var _exact := Vector2.ZERO
var _path: Array[Vector2i] = []
var _stride := 0.0
var _facing := 1.0


func place(new_cell: Vector2i) -> void:
	cell = new_cell
	_exact = Vector2(new_cell)
	_path.clear()
	position = Iso.to_point(_exact)


## Cell a new path has to start from: the target of the step in progress.
func next_stop() -> Vector2i:
	return cell if _path.is_empty() else _path[0]


## Replaces the current path. The path has to start at next_stop().
func walk(path: Array[Vector2i]) -> void:
	_path = path


func _process(delta: float) -> void:
	if _path.is_empty():
		return
	var remaining := SPEED * delta
	while remaining > 0.0 and not _path.is_empty():
		var target := Vector2(_path[0])
		var distance := _exact.distance_to(target)
		if distance <= remaining:
			_exact = target
			remaining -= distance
			cell = _path.pop_front()
			cell_reached.emit(cell)
		else:
			_exact = _exact.move_toward(target, remaining)
			remaining = 0.0
	var new_position := Iso.to_point(_exact)
	if absf(new_position.x - position.x) > 0.01:
		_facing = signf(new_position.x - position.x)
	position = new_position
	_stride = 0.0 if _path.is_empty() else _stride + delta * 12.0
	queue_redraw()


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, 22.0, Color(0, 0, 0, 0.2))
	# Slight bobbing while walking
	draw_set_transform(Vector2(0, -absf(sin(_stride)) * 5.0))
	draw_colored_polygon(
		PackedVector2Array([Vector2(-18, 0), Vector2(18, 0), Vector2(11, -54), Vector2(-11, -54)]), Color("b5533c")
	)
	draw_circle(Vector2(3.0 * _facing, -66), 14.0, Color("f0d2b0"))
	draw_set_transform(Vector2.ZERO)
