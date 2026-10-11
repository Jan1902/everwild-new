class_name TargetMarker
extends Node2D
## Brief feedback for a tap: a small ring on the ground that widens and fades.

const DURATION := 0.45
const RADIUS := 26.0
const COLOR := Color(1, 1, 1, 0.8)

## From 0 (just tapped) to 1 (gone).
var progress := 1.0:
	set(value):
		progress = value
		queue_redraw()

var _pop: Tween


## Shows the ring at a point of the world.
func show_at(point: Vector2) -> void:
	position = point
	if _pop:
		_pop.kill()
	progress = 0.0
	_pop = create_tween()
	_pop.tween_property(self, "progress", 1.0, DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _draw() -> void:
	if progress >= 1.0:
		return
	# Half as high as wide, so the ring lies flat on the ground.
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
	draw_arc(Vector2.ZERO, RADIUS * (0.35 + 0.65 * progress), 0.0, TAU, 32, Color(COLOR, COLOR.a * (1.0 - progress)), 3.0, true)