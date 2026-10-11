class_name GroundView
extends Node2D
## Draws the ground as a placeholder until there is a painted image.

## Height of the visible broken-off edge at the rim of the island.
const EDGE := 90.0
const COLORS := {
	World.Ground.GRASS: Color("7fae6b"),
	World.Ground.PATH: Color("d8c394"),
	World.Ground.WATER: Color("74b6cc"),
	World.Ground.BRIDGE: Color("a97c52"),
	World.Ground.FLOOR: Color("b89468"),
}
const EARTH_LIGHT := Color("8a6a4f")
const EARTH_DARK := Color("6e533f")

var world: World


func _draw() -> void:
	if world == null:
		return
	# All edges first, then all faces: that way faces in front cover the edges behind them.
	for y in world.size.y:
		for x in world.size.x:
			_draw_edges(Vector2i(x, y))
	for y in world.size.y:
		for x in world.size.x:
			_draw_face(Vector2i(x, y))


func _draw_edges(cell: Vector2i) -> void:
	if world.ground(cell) == World.Ground.VOID:
		return
	var c := _corners(cell)
	var down := Vector2(0, EDGE)
	var is_water := world.ground(cell) == World.Ground.WATER
	if world.ground(cell + Vector2i(1, 0)) == World.Ground.VOID:
		var color := COLORS[World.Ground.WATER].darkened(0.15) if is_water else EARTH_LIGHT
		draw_colored_polygon(PackedVector2Array([c[1], c[2], c[2] + down, c[1] + down]), color)
	if world.ground(cell + Vector2i(0, 1)) == World.Ground.VOID:
		var color := COLORS[World.Ground.WATER].darkened(0.3) if is_water else EARTH_DARK
		draw_colored_polygon(PackedVector2Array([c[2], c[3], c[3] + down, c[2] + down]), color)


func _draw_face(cell: Vector2i) -> void:
	var kind := world.ground(cell)
	if kind == World.Ground.VOID:
		return
	var c := _corners(cell)
	# Slight brightness variation per cell so the surface does not read as a grid.
	var variation := 1.0 + (hash(cell) % 5 - 2) * 0.012
	var color: Color = COLORS[kind]
	draw_colored_polygon(c, Color(color.r * variation, color.g * variation, color.b * variation))
	if kind == World.Ground.BRIDGE:
		for fraction: float in [0.25, 0.5, 0.75]:
			draw_line(c[0].lerp(c[1], fraction), c[3].lerp(c[2], fraction), color.darkened(0.25), 2.0)


## Corners of a cell's diamond: back, right, front, left.
func _corners(cell: Vector2i) -> PackedVector2Array:
	var centre := Iso.to_point(cell)
	var half := Iso.CELL * 0.5
	return PackedVector2Array([
		centre + Vector2(0, -half.y),
		centre + Vector2(half.x, 0),
		centre + Vector2(0, half.y),
		centre + Vector2(-half.x, 0),
	])
