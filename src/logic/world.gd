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
const NEIGHBOURS: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]

var id := ""
var size := Vector2i.ZERO
var start := Vector2i.ZERO
## Everything that stands or lies in the world, as it is at the moment.
var objects: Array[WorldObject] = []
## What happens when the player does something, in the order of the world file. Each rule has
## "on" ("interact" with "object", "enter" with "cells" or "zone", "linger", anywhere or
## limited by "cells" or "zone", or "always" for something that happens by itself as soon as its
## conditions hold), "if" (conditions) and "do" (effects). See Session for conditions and effects.
var rules: Array[Dictionary] = []
## What is wrong with the broken version of this world. Each fault has "id", "fixed_if"
## (conditions) and "restores" (the mood dials that return to normal once it is fixed).
var faults: Array[Dictionary] = []
## The broken version: object id -> properties that differ from the intact world.
var broken := {}
## Places of memory: id -> the part of the world (cells, as Rect2i) that shows through as it was
## while the player remembers there. Where the player has to stand for it is up to the rule that
## has the effect "remember".
var memories := {}
## Memory id -> ids of objects that never show through there, even if they stood in that part
## of the world: what the player moves about themselves would only mislead as a memory.
var memory_omits := {}
## What someone says the first time the player is here once the world is whole: "say" (a text),
## "who" (the speaker, the player without one) and "if" (conditions that have to hold as well).
## Empty if nobody does.
var whole_says := {}
## Hints that show the player what to do next, for the first steps of the game. Each names what
## it points at, "object" (an id), "cell" ([x, y]) or "notebook" (true: the notebook button), and
## "if" (conditions). Only the first whose conditions hold shows.
var hints: Array[Dictionary] = []
## Path of the music track, empty for none.
var music := ""
## Tracks that play instead while their conditions hold: each with "if" (conditions) and "music"
## (path). The first that holds wins. The music box in the old man's room is one.
var music_if: Array[Dictionary] = []
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
var _bridged := {}
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
	world.size = _to_cell(data.get("size", [0, 0]))
	world.start = _to_cell(data.get("start", [0, 0]))
	world.ground_image = data.get("ground_image", {})
	world.music = data.get("music", "")
	world.music_if.assign(data.get("music_if", []))
	world.hints.assign(data.get("hints", []))
	world.mood = Mood.from_data(data.get("mood", {}))
	world.mood_wrong = Mood.from_data(data.get("mood_wrong", {}), world.mood)
	world.mood_from = data.get("mood_from", "")
	world._read_ground(data.get("ground", []))
	for entry: Dictionary in data.get("objects", []):
		var thing := WorldObject.new()
		thing.kind = entry.get("kind", "")
		thing.cell = _to_cell(entry.get("cell", [0, 0]))
		thing.id = entry.get("id", "%s_%d_%d" % [thing.kind, thing.cell.x, thing.cell.y])
		thing.size = _to_cell(entry.get("size", [1, 1]))
		thing.mirrored = entry.get("mirrored", false)
		thing.hidden = entry.get("hidden", false)
		thing.state = entry.get("state", "")
		thing.access.assign(entry.get("access", []).map(_to_cell))
		thing.stroll.assign(entry.get("stroll", []).map(_to_cell))
		if world._by_id.has(thing.id):
			world._errors.append("Object id '%s' is used twice" % thing.id)
		world.objects.append(thing)
		world._by_id[thing.id] = thing
		world._intact[thing.id] = thing.copy()
	world.rules.assign(data.get("rules", []))
	world.whole_says = data.get("whole_says", {})
	world.faults.assign(data.get("faults", []))
	for memory: Dictionary in data.get("memories", []):
		var zone: Variant = memory.get("zone")
		var memory_id: String = memory.get("id", "")
		if memory_id.is_empty() or world.memories.has(memory_id):
			world._errors.append("Memory '%s' has no id of its own" % memory_id)
		if zone is Array and zone.size() == 4:
			world.memories[memory_id] = Rect2i(int(zone[0]), int(zone[1]), int(zone[2]), int(zone[3]))
			world.memory_omits[memory_id] = memory.get("without", [])
		else:
			world._errors.append("Memory '%s' has a zone that is not [x, y, w, h]" % memory_id)
	var broken_data: Dictionary = data.get("broken", {})
	for object_id: String in broken_data:
		world.broken[object_id] = read_properties(broken_data[object_id])
	world._update_occupied()
	return world


## Picks the changeable object properties out of an entry of a world file.
static func read_properties(data: Dictionary) -> Dictionary:
	var properties := {}
	for property: String in WorldObject.CHANGEABLE:
		if data.has(property):
			properties[property] = _to_cell(data[property]) if property == "cell" else data[property]
	return properties


## What the break changed and has not been put right yet: the objects of the broken version that
## still differ from the intact world, as they were. Things the player has changed otherwise,
## such as something taken along, are not part of it.
func differences() -> Array[WorldObject]:
	var list: Array[WorldObject] = []
	for thing in objects:
		var intact: WorldObject = _intact[thing.id]
		if broken.has(thing.id) and not thing.matches(intact.properties()):
			list.append(intact.copy())
	return list


## What shows through at a place of memory: the differences that stand in its part of the world.
func remembered(memory_id: String) -> Array[WorldObject]:
	var zone: Rect2i = memories.get(memory_id, Rect2i())
	var omitted: Array = memory_omits.get(memory_id, [])
	return differences().filter(func(thing: WorldObject) -> bool:
		return thing.id not in omitted and zone.intersects(Rect2i(thing.cell, thing.size))
	)


## Puts all objects back to the intact world and lays the given changes over it
## (object id -> properties).
func apply(changes: Dictionary) -> void:
	for thing in objects:
		thing.change(_intact[thing.id].properties())
		thing.change(changes.get(thing.id, {}))
	_update_occupied()


## Problems in the world data and in the current placement. An empty list means the world is fine.
func errors() -> Array[String]:
	var list := _errors.duplicate()
	if not is_walkable(start):
		list.append("Start cell %s is not walkable" % start)
	var seen := {}
	for thing in objects:
		if thing.hidden:
			continue
		var flat := thing.is_flat()
		for cell in thing.occupied_cells():
			var fits := ground(cell) == Ground.BRIDGE if flat else ground(cell) in FIRM
			if thing.is_wet():
				fits = ground(cell) == Ground.WATER
			if not fits:
				list.append("Object '%s' at %s stands on the wrong ground" % [thing.id, cell])
			if not flat and seen.has(cell):
				list.append("Objects '%s' and '%s' share cell %s" % [seen[cell], thing.id, cell])
			if not flat:
				seen[cell] = thing.id
	for object_id: String in broken:
		if not _by_id.has(object_id):
			list.append("Broken version names unknown object '%s'" % object_id)
	for memory_id: String in memory_omits:
		for object_id: Variant in memory_omits[memory_id]:
			if not _by_id.has(object_id):
				list.append("Memory '%s' leaves out unknown object '%s'" % [memory_id, object_id])
	for fault in faults:
		for dial: String in fault.get("restores", []):
			if dial not in Mood.DIALS:
				list.append("Fault '%s' restores unknown dial '%s'" % [fault.get("id", ""), dial])
	return list


func ground(cell: Vector2i) -> Ground:
	if not Rect2i(Vector2i.ZERO, size).has_point(cell):
		return Ground.VOID
	return _ground[cell.y * size.x + cell.x] as Ground


## A cell can be walked on if its ground allows it and nothing stands there. Water marked for a
## crossing only carries while a bridge or raft lies on it.
func is_walkable(cell: Vector2i) -> bool:
	var kind := ground(cell)
	if kind == Ground.BRIDGE:
		return _bridged.has(cell)
	return kind in WALKABLE and not _occupied.has(cell)


## The object with this id. Null if there is none.
func get_object(object_id: String) -> WorldObject:
	return _by_id.get(object_id)


## The object that blocks this cell. Null if there is none.
func object_at(cell: Vector2i) -> WorldObject:
	return _by_id.get(_occupied.get(cell, ""))


## Walkable cells from where the player can use the object: its access cells if it has any,
## otherwise all cells right next to it.
func cells_beside(thing: WorldObject) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if not thing.access.is_empty():
		for cell in thing.access:
			if is_walkable(cell):
				cells.append(cell)
		return cells
	for cell in thing.occupied_cells():
		for step in NEIGHBOURS:
			if is_walkable(cell + step) and cell + step not in cells:
				cells.append(cell + step)
	return cells


## Whether the object could stand on this cell: fitting ground and nothing else in the way.
func has_room(thing: WorldObject, cell: Vector2i) -> bool:
	for y in thing.size.y:
		for x in thing.size.x:
			var spot := cell + Vector2i(x, y)
			if ground(spot) not in FIRM:
				return false
			if _occupied.get(spot, thing.id) != thing.id:
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
	_bridged.clear()
	for thing in objects:
		if thing.hidden:
			continue
		for cell in thing.occupied_cells():
			if thing.is_flat():
				_bridged[cell] = thing.id
			else:
				_occupied[cell] = thing.id
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
