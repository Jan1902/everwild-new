class_name FarLight
extends Node2D
## A light far away, as the great light seen from below: a bright core in a wide warm halo. It
## swells when it comes on, flares a little and settles into a slow breathing.

const CORE := Color(1.0, 0.97, 0.85)
const HALO := Color(1.0, 0.78, 0.45)
const RADIUS := 18.0
const HALO_RADIUS := 95.0
## Seconds it takes to come on.
const KINDLE := 1.4

var _lit := 0.0
var _time := 0.0


func _ready() -> void:
	var kindle := create_tween().set_trans(Tween.TRANS_SINE)
	kindle.tween_property(self, "_lit", 1.35, KINDLE)
	kindle.tween_property(self, "_lit", 1.0, KINDLE)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var breath := 1.0 + 0.05 * sin(_time * 1.7)
	var strength := minf(_lit, 1.0)
	var size := _lit * breath
	for ring in 14:
		var fraction := 1.0 - ring / 14.0
		draw_circle(Vector2.ZERO, HALO_RADIUS * fraction * size, Color(HALO, 0.045 * strength))
	for ring in 4:
		draw_circle(Vector2.ZERO, RADIUS * (1.6 - ring * 0.3) * size, Color(CORE, 0.35 * strength))
	draw_circle(Vector2.ZERO, RADIUS * 0.55 * size, Color(CORE, strength))
