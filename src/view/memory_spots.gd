class_name MemorySpots
extends Node2D
## The places where standing still would let a memory show through: a faint warm shimmer on the
## ground with a few motes of light drifting up from it. While the player stands there and
## waits, the shimmer grows and the motes gather, so they see that something is coming.

## Radius of the shimmer on one cell, in world pixels across.
const RADIUS := 50.0
## Opacity of the shimmer at rest and at its strongest.
const QUIET := 0.2
const STRONG := 0.55
const COLOR := Color(1.0, 0.9, 0.62)
## Motes per cell, seconds a mote takes to rise, and how high it rises.
const MOTES := 3
const RISE := 3.2
const HEIGHT := 70.0
## Seconds the spots take to come and go.
const FADE := 0.8

## How far the player standing on one of the cells has waited, from 0 to 1.
var progress := 0.0
## Cell the player stands on.
var focus := Vector2i(-1, -1)

var _cells: Array[Vector2i] = []
var _time := 0.0
var _shown := 0.0
var _visible_target := 1.0


func _ready() -> void:
	z_index = 0


## Shows the shimmer on these cells. An empty list lets it fade.
func show_on(cells: Array[Vector2i]) -> void:
	if not cells.is_empty():
		_cells = cells
	_visible_target = 0.0 if cells.is_empty() else 1.0


## Lets the shimmer fade for a while, as while the memory itself shows, or come back.
func hold(quiet: bool) -> void:
	_visible_target = 0.0 if quiet or _cells.is_empty() else 1.0


func _process(delta: float) -> void:
	_time += delta
	_shown = move_toward(_shown, _visible_target, delta / FADE)
	visible = _shown > 0.0
	if visible:
		queue_redraw()


func _draw() -> void:
	for number in _cells.size():
		var cell := _cells[number]
		var here := Iso.to_point(cell)
		var near := 1.0 if cell == focus else 0.0
		var breath := 0.5 + 0.5 * sin(_time * 1.3 + number * 0.7)
		var strength := lerpf(QUIET + 0.03 * breath, STRONG, progress * (0.4 + 0.6 * near)) * _shown
		draw_set_transform(here, 0.0, Vector2(1.0, 0.5))
		for ring in 4:
			draw_circle(Vector2.ZERO, RADIUS * (1.0 - ring * 0.22), Color(COLOR, strength * 0.35))
		draw_set_transform(Vector2.ZERO)
		# Motes rise from the cell; while the player waits there, more of them and brighter.
		var motes := MOTES + int(progress * 6.0 * near)
		for mote in motes:
			var seed := float(number * 13 + mote * 7)
			var age := fmod(_time / RISE + seed * 0.137, 1.0)
			var drift := Vector2(sin(seed * 2.3 + _time * 0.8) * 18.0, -age * HEIGHT * (1.0 + 0.5 * near * progress))
			var spot := here + Vector2(cos(seed) * 22.0, sin(seed * 1.7) * 10.0) + drift
			var alpha := sin(age * PI) * (0.55 + 0.45 * near * progress) * _shown
			draw_circle(spot, 3.0 + near * progress * 2.0, Color(COLOR, alpha))
