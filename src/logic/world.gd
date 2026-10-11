class_name World
extends RefCounted
## A world as pure data: ground grid, objects, position of the player character.
## Knows nothing about rendering, so it also runs without graphics.

enum Ground { VOID, GRASS, PATH, WATER, BRIDGE }

## Characters used to write the ground in world files.
const SYMBOLS := {
	" ": Ground.VOID,
	".": Ground.GRASS,
	"=": Ground.PATH,
	"~": Ground.WATER,
	"#": Ground.BRIDGE,
}
const WALKABLE := [Ground.GRASS, Ground.PATH, Ground.BRIDGE]
## Object kinds that lie flat on the ground: they block nothing and the character walks over them.
const FLAT_KINDS := ["bridge"]

var title := ""
var size := Vector2i.ZERO
var start := Vector2i.ZERO
var player := Vector2i.ZERO
## Entries with "kind" (String), "cell" (Vector2i, rear corner), "size" (Vector2i)
## and "mirrored" (bool).
var objects: Array[Dictionary] = []
## Path of the music track, empty for none.
var music := ""
## Mood of the intact world and of its wrong version.
var mood := Mood.new()
var mood_wrong := Mood.new()
## Painted ground image with "path", "scale" (image pixels per world pixel) and "origin"
## (world point of the image's top left corner). Empty while the world has none.
var ground_image := {}

var _ground := PackedInt32Array()
var _occupied := {}
var _paths := AStarGrid2D.new()
var _errors: Array[String] = []


static func from_file(path: String) -> World:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not data is Dictionary:
		var empty := World.new()
		empty._errors.append("World file is not readable: " + path)
		return empty
	return from_data(data)


static func from_data(data: Dictionary) -> World:
	var world := World.new()
	world.title = data.get("title", "")
	world.size = _to_cell(data.get("size", [0, 0]))
	world.start = _to_cell(data.get("start", [0, 0]))
	world.player = world.start
	world.ground_image = data.get("ground_image", {})
	world.music = data.get("music", "")
	world.mood = Mood.from_data(data.get("mood", {}))
	world.mood_wrong = Mood.from_data(data.get("mood_wrong", {}), world.mood)
	world._read_ground(data.get("ground", []))
	for entry: Dictionary in data.get("objects", []):
		world.objects.append({
			"kind": entry.get("kind", ""),
			"cell": _to_cell(entry.get("cell", [0, 0])),
			"size": _to_cell(entry.get("size", [1, 1])),
			"mirrored": entry.get("mirrored", false),
		})
	world._build_paths()
	return world


## Problems in the world data. An empty list means the world is fine.
func errors() -> Array[String]:
	var list := _errors.duplicate()
	if not is_walkable(start):
		list.append("Start cell %s is not walkable" % start)
	for object in objects:
		var expected := Ground.BRIDGE if object.kind == "bridge" else Ground.GRASS
		for cell in occupied_cells(object):
			if ground(cell) != expected:
				list.append("Object '%s' at %s stands on the wrong ground" % [object.kind, cell])
	return list


func ground(cell: Vector2i) -> Ground:
	if not Rect2i(Vector2i.ZERO, size).has_point(cell):
		return Ground.VOID
	return _ground[cell.y * size.x + cell.x] as Ground


func is_walkable(cell: Vector2i) -> bool:
	return ground(cell) in WALKABLE and not _occupied.has(cell)


func occupied_cells(object: Dictionary) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in object.size.y:
		for x in object.size.x:
			cells.append(object.cell + Vector2i(x, y))
	return cells


## Shortest path including the start and target cell. Empty if there is none.
func find_path(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	if not is_walkable(from) or not is_walkable(to):
		return []
	return _paths.get_id_path(from, to)


## Puts the player character on a cell. Returns false if it cannot stand there.
func set_player(cell: Vector2i) -> bool:
	if not is_walkable(cell):
		return false
	player = cell
	return true


func _read_ground(rows: Array) -> void:
	_ground.resize(size.x * size.y)
	if rows.size() != size.y:
		_errors.append("Ground has %d rows, expected %d" % [rows.size(), size.y])
	for y in size.y:
		var row: String = rows[y] if y < rows.size() else ""
		if row.length() != size.x:
			_errors.append("Ground row %d has %d characters, expected %d" % [y, row.length(), size.x])
		for x in size.x:
			var symbol := row[x] if x < row.length() else " "
			if not SYMBOLS.has(symbol):
				_errors.append("Unknown ground symbol '%s' at %s" % [symbol, Vector2i(x, y)])
			_ground[y * size.x + x] = SYMBOLS.get(symbol, Ground.VOID)


func _build_paths() -> void:
	for object in objects:
		if object.kind in FLAT_KINDS:
			continue
		for cell in occupied_cells(object):
			_occupied[cell] = true
	_paths.region = Rect2i(Vector2i.ZERO, size)
	_paths.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_paths.update()
	for y in size.y:
		for x in size.x:
			if not is_walkable(Vector2i(x, y)):
				_paths.set_point_solid(Vector2i(x, y), true)


static func _to_cell(pair: Array) -> Vector2i:
	return Vector2i(int(pair[0]), int(pair[1]))
