class_name Iso
extends RefCounted
## Converts between cells of the logic grid and points in the isometric view.

## Width and height of one cell as a diamond on screen.
const CELL := Vector2(128, 64)


## Centre of a cell. Accepts fractional values so characters can walk between cells.
static func to_point(cell: Vector2) -> Vector2:
	return Vector2((cell.x - cell.y) * CELL.x * 0.5, (cell.x + cell.y) * CELL.y * 0.5)


## Cell whose diamond contains the point.
static func to_cell(point: Vector2) -> Vector2i:
	var a := point.x / (CELL.x * 0.5)
	var b := point.y / (CELL.y * 0.5)
	return Vector2i(floori((a + b) * 0.5 + 0.5), floori((b - a) * 0.5 + 0.5))
