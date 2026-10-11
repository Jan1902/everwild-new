class_name BoxShadow
extends Node2D
## Shadow of a box-shaped object such as a house: its footprint, extended by the cast of the
## walls and the roof ridge. A tilted silhouette does not line up with the walls of a box.

const COLOR := Color(0.08, 0.1, 0.22)
## The footprint is enlarged slightly so a dark rim remains all around the object.
const OVERHANG := 1.08

var size := Vector2i.ONE
var wall_height := 0.0
var ridge_height := 0.0

var _drawn := Vector2.INF


func _process(_delta: float) -> void:
	if ObjectView.shadow_cast != _drawn:
		queue_redraw()


func _draw() -> void:
	_drawn = ObjectView.shadow_cast
	var cast := Vector2(_drawn.x, _drawn.y * 0.5)
	var half := Vector2(size) * 0.5 * OVERHANG
	var points := PackedVector2Array([cast * ridge_height])
	for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		var on_ground := Iso.to_point(corner * half)
		points.append(on_ground)
		points.append(on_ground + cast * wall_height)
	var hull := Geometry2D.convex_hull(points)
	# convex_hull repeats the first point at the end; the polygon needs it only once.
	hull.remove_at(hull.size() - 1)
	draw_colored_polygon(hull, COLOR)
