class_name HintView
extends Node2D
## A quiet hint at what to tap next: a fingertip that taps gently, with a ring spreading from
## where it touches. Over an object it floats above it, on a cell it touches the ground. It
## comes and goes softly and never says anything.

const COLOR := Color(1.0, 0.97, 0.9)
## Seconds the hint takes to come and to go, and seconds of one tap.
const FADE := 0.5
const BEAT := 1.4
const RING := 42.0

var _target := Vector2.INF
var _on_ground := false
## Whether the hint is to show; it comes and goes over FADE seconds.
var _wanted := false
var _shown := 0.0
var _time := 0.0


func _ready() -> void:
	# Above everything that stands in the world.
	z_index = 5


## Points at a spot of the world. Vector2.INF takes the hint away.
func point_at(target: Vector2, on_ground := false) -> void:
	if target != Vector2.INF and target != _target:
		if _shown <= 0.0:
			_time = 0.0
		_target = target
		_on_ground = on_ground
	elif target == Vector2.INF and _shown <= 0.0:
		_target = Vector2.INF
	_wanted = target != Vector2.INF


func _process(delta: float) -> void:
	_shown = move_toward(_shown, 1.0 if _wanted else 0.0, delta / FADE)
	visible = _shown > 0.0 and _target != Vector2.INF
	if visible:
		_time += delta
		position = _target
		queue_redraw()


func _draw() -> void:
	var beat := fmod(_time / BEAT, 1.0)
	# The finger comes down in the first half of the beat and lifts in the second.
	var press := sin(beat * PI)
	var flat := Vector2(1.0, 0.5) if _on_ground else Vector2.ONE
	# The ring spreads from the moment of touching.
	var spread := clampf((beat - 0.35) / 0.65, 0.0, 1.0)
	if spread > 0.0:
		draw_set_transform(Vector2.ZERO, 0.0, flat)
		draw_arc(Vector2.ZERO, RING * (0.4 + spread), 0.0, TAU, 32, Color(COLOR, (1.0 - spread) * 0.8 * _shown), 3.0, true)
		draw_set_transform(Vector2.ZERO)
	var tip := Vector2(0, -20.0 + 14.0 * press)
	draw_circle(tip + Vector2(0, 2), 14.0, Color(0, 0, 0, 0.18 * _shown), true, -1.0, true)
	draw_circle(tip, 13.0, Color(COLOR, 0.92 * _shown), true, -1.0, true)
	draw_circle(tip, 13.0, Color(0.35, 0.3, 0.25, 0.5 * _shown), false, 2.5, true)
