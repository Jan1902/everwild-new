class_name World
extends RefCounted
## A world as pure data: ground grid, objects, rules and faults.
## Knows nothing about rendering, so it also runs without graphics.
##
## The world file describes the intact world. What differs from it at the moment (moved objects
## and the like) comes from the game state and is laid over it with apply().

enum Ground { VOID, GRASS, PATH, WATER, BRIDGE, FLOOR }

## Characters used to write the ground in world files.
const SYMBOLS := {
	" ": Ground.VOID,
	".": Ground.GRASS,
	"=": Ground.PATH,
	"~": Ground.WATER,
	"#": Ground.BRIDGE,
	"_": Ground.FLOOR,
}
const WALKABLE := [Ground.GRASS, Ground.PATH, Ground.BRIDGE, Ground.FLOOR]
## Ground that objects can stand on.
const FIRM := [Ground.GRASS, Ground.PATH, Ground.FLOOR]
## Object kinds that lie flat on the ground: they block nothing and the character walks over them.
const FLAT_KINDS := ["bridge"]
## Properties of an object that can change during the game.
const CHANGEABLE := ["cell", "mirrored", "hidden", "state"]
const NEIGHBOURS: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]

var id := ""
var title := ""
var size := Vector2i.ZERO
var start := Vector2i.ZERO
## Entries with "id" and "kind" (String), "cell" (Vector2i, rear corner), "size" (Vector2i),
## "mirrored" and "hidden" (bool), "state" (String, meaning depends on the kind) and "access"
## (cells the object can be used from, such as the one in front of a door; empty means every
## cell beside it).
var objects: Array[Dictionary] = []
## What happens when the player does something, in the order of the world file. Each rule has
## "on" ("interact" with "object", "enter" with "cells" or "zone", or "linger", anywhere or
## limited by "cells" or "zone"), "if" (conditions) and "do" (effects). See Session for
## conditions and effects.
var rules: Array[Dictionary] = []
## What is wrong with the broken version of this world. Each fault has "id", "fixed_if"
## (conditions) and "restores" (the mood dials that return to normal once it is fixed).
var faults: Array[Dictionary] = []
## The broken version: object id -> properties that differ from the intact world.
var broken := {}
## Path of the music track, empty for none.
var music := ""
## Mood of the intact world and of its wrong version.
var mood := Mood.new()
var mood_wrong := Mood.new()
## Id of the world whose mood this one shares, for example the village around a room. Empty if
## it has its own.
var mood_from := ""
## Painted ground image with "path", "scale" (image pixels per world pixel) and "origin"
## (world point of the image's top left corner). Empty while the world has none.
var ground_image := {}

var _ground := PackedInt32Array()
var _intact := {}
var _by_id := {}
var _occupied := {}
var _paths := AStarGrid2D.new()
var _paths_outdated := true
var _errors: Array[String] = []


static func from_file(path: String) -> World:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not data is Dictionary:
		var empty := World.new()
		empty._errors.append("World file is not readable: " + path)
		return empty
	return from_data(data, path.get_file().get_basename())


static func from_data(data: Dictionary, world_id := "") -> World:
	var world := World.new()
	world.id = world_id
	world.title = data.get("title", "")
	world.size = _to_cell(data.get("size", [0, 0]))
	world.start = _to_cell(data.get("start", [0, 0]))
	world.ground_image = data.get("ground_image", {})
	world.music = data.get("music", "")
	world.mood = Mood.from_data(data.get("mood", {}))
	world.mood_wrong = Mood.from_data(data.get("mood_wrong", {}), world.mood)
	world.mood_from = data.get("mood_from", "")
	world._read_ground(data.get("ground", []))
	for entry: Dictionary in data.get("objects", []):
		var cell := _to_cell(entry.get("cell", [0, 0]))
		var object := {
			"id": entry.get("id", "%s_%d_%d" % [entry.get("kind", ""), cell.x, cell.y]),
			"kind": entry.get("kind", ""),
			"cell": cell,
			"size": _to_cell(entry.get("size", [1, 1])),
			"mirrored": entry.get("mirrored", false),
			"hidden": entry.get("hidden", false),
			"state": entry.get("state", ""),
			"access": entry.get("access", []).map(_to_cell),
		}
		if world._by_id.has(object.id):
			world._errors.append("Object id '%s' is used twice" % object.id)
		world.objects.append(object)
		world._by_id[object.id] = object
		world._intact[object.id] = object.duplicate()
	world.rules.assign(data.get("rules", []))
	world.faults.assign(data.get("faults", []))
	var broken_data: Dictionary = data.get("broken", {})
	for object_id: String in broken_data:
		world.broken[object_id] = read_properties(broken_data[object_id])
	world._update_occupied()
	return world


## Picks the changeable object properties out of an entry of a world file.
static func read_properties(data: Dictionary) -> Dictionary:
	var properties := {}
	for property: String in CHANGEABLE:
		if data.has(property):
			properties[property] = _to_cell(data[property]) if property == "cell" else data[property]
	return properties


## The objects of the intact world that are different at the moment, as they were.
func differences() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for object in objects:
		if object != _intact[object.id]:
			list.append(_intact[object.id].duplicate())
	return list


## Puts all objects back to the intact world and lays the given changes over it
## (object id -> properties).
func apply(changes: Dictionary) -> void:
	for object in objects:
		object.merge(_intact[object.id], true)
		object.merge(changes.get(object.id, {}), true)
	_update_occupied()


## Problems in the world data and in the current placement. An empty list means the world is fine.
func errors() -> Array[String]:
	var list := _errors.duplicate()
	if not is_walkable(start):
		list.append("Start cell %s is not walkable" % start)
	var seen := {}
	for object in objects:
		if object.hidden:
			continue
		var flat: bool = object.kind in FLAT_KINDS
		for cell in occupied_cells(object):
			var fits := ground(cell) == Ground.BRIDGE if flat else ground(cell) in FIRM
			if not fits:
				list.append("Object '%s' at %s stands on the wrong ground" % [object.id, cell])
			if not flat and seen.has(cell):
				list.append("Objects '%s' and '%s' share cell %s" % [seen[cell], object.id, cell])
			if not flat:
				seen[cell] = object.id
	for object_id: String in broken:
		if not _by_id.has(object_id):
			list.append("Broken version names unknown object '%s'" % object_id)
	for rule in rules:
		if rule.get("on") == "interact" and not _by_id.has(rule.get("object", "")):
			list.append("Rule names unknown object '%s'" % rule.get("object", ""))
		elif rule.get("on") not in ["interact", "enter", "linger"]:
			list.append("Rule has unknown trigger '%s'" % rule.get("on", ""))
	for fault in faults:
		for dial: String in fault.get("restores", []):
			if dial not in Mood.DIALS:
				list.append("Fault '%s' restores unknown dial '%s'" % [fault.get("id", ""), dial])
	return list


func ground(cell: Vector2i) -> Ground:
	if not Rect2i(Vector2i.ZERO, size).has_point(cell):
		return Ground.VOID
	return _ground[cell.y * size.x + cell.x] as Ground


func is_walkable(cell: Vector2i) -> bool:
	return ground(cell) in WALKABLE and not _occupied.has(cell)


## The object with this id. Empty if there is none.
func object(object_id: String) -> Dictionary:
	return _by_id.get(object_id, {})


## The object that blocks this cell. Empty if there is none.
func object_at(cell: Vector2i) -> Dictionary:
	return _by_id.get(_occupied.get(cell, ""), {})


func occupied_cells(object: Dictionary) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in object.size.y:
		for x in object.size.x:
			cells.append(object.cell + Vector2i(x, y))
	return cells


## Walkable cells from where the player can use the object: its access cells if it has any,
## otherwise all cells right next to it.
func cells_beside(object: Dictionary) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if not object.access.is_empty():
		for cell: Vector2i in object.access:
			if is_walkable(cell):
				cells.append(cell)
		return cells
	for cell in occupied_cells(object):
		for step in NEIGHBOURS:
			if is_walkable(cell + step) and cell + step not in cells:
				cells.append(cell + step)
	return cells


## Whether the object could stand on this cell: fitting ground and nothing else in the way.
func has_room(object: Dictionary, cell: Vector2i) -> bool:
	for y in object.size.y:
		for x in object.size.x:
			var spot := cell + Vector2i(x, y)
			if ground(spot) not in FIRM:
				return false
			if _occupied.get(spot, object.id) != object.id:
				return false
	return true


## Whether the cell belongs to the area of a rule: its cells listed one by one as "cells", or a
## rectangle "zone" [x, y, w, h].
static func rule_covers(rule: Dictionary, cell: Vector2i) -> bool:
	for pair: Array in rule.get("cells", []):
		if _to_cell(pair) == cell:
			return true
	var zone: Array = rule.get("zone", [])
	return zone.size() == 4 and Rect2i(int(zone[0]), int(zone[1]), int(zone[2]), int(zone[3])).has_point(cell)


## Shortest path including the start and target cell. Empty if there is none.
func find_path(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	if not is_walkable(from) or not is_walkable(to):
		return []
	if _paths_outdated:
		_build_paths()
	return _paths.get_id_path(from, to)


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


func _update_occupied() -> void:
	_occupied.clear()
	for object in objects:
		if object.kind in FLAT_KINDS or object.hidden:
			continue
		for cell in occupied_cells(object):
			_occupied[cell] = object.id
	_paths_outdated = true


func _build_paths() -> void:
	_paths.region = Rect2i(Vector2i.ZERO, size)
	_paths.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_paths.update()
	for y in size.y:
		for x in size.x:
			_paths.set_point_solid(Vector2i(x, y), not is_walkable(Vector2i(x, y)))
	_paths_outdated = false


static func _to_cell(pair: Array) -> Vector2i:
	return Vector2i(int(pair[0]), int(pair[1]))
