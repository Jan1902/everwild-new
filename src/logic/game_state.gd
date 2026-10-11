class_name GameState
extends RefCounted
## Everything the game remembers: where the player is and what has changed in every world.
## Pure data. It can be written to a file and read back without any difference.

## Version of the saved format. Raise it when the format changes and convert older data in
## from_data.
const VERSION := 1

## Id of the world the player is in, and the cell they stand on.
var world := ""
var cell := Vector2i.ZERO
## Named facts shared by all worlds, for example "met_old_man": true.
var facts := {}
## What differs from the intact worlds: world id -> object id -> changed properties
## ("cell" as Vector2i, "mirrored", "hidden", "state").
var objects := {}
## Ids of the things the player carries. Kept sorted.
var items: Array[String] = []
## Ids of the notebook entries, in the order they were found.
var notes: Array[String] = []


func change_object(world_id: String, object_id: String, properties: Dictionary) -> void:
	if properties.is_empty():
		return
	if not objects.has(world_id):
		objects[world_id] = {}
	if not objects[world_id].has(object_id):
		objects[world_id][object_id] = {}
	objects[world_id][object_id].merge(properties, true)


func give(item: String) -> void:
	if item not in items:
		items.append(item)
		items.sort()


func take(item: String) -> void:
	items.erase(item)


func add_note(note: String) -> void:
	if note not in notes:
		notes.append(note)


## The state as plain data for a save file.
func to_data() -> Dictionary:
	var changed := {}
	for world_id: String in objects:
		changed[world_id] = {}
		for object_id: String in objects[world_id]:
			var properties: Dictionary = objects[world_id][object_id].duplicate()
			if properties.has("cell"):
				properties.cell = [properties.cell.x, properties.cell.y]
			changed[world_id][object_id] = properties
	return {
		"version": VERSION,
		"world": world,
		"cell": [cell.x, cell.y],
		"facts": facts.duplicate(),
		"objects": changed,
		"items": items.duplicate(),
		"notes": notes.duplicate(),
	}


## Reads a state from plain data. Returns null if the data is not a usable save.
static func from_data(data: Variant) -> GameState:
	if not data is Dictionary or int(data.get("version", 0)) != VERSION:
		return null
	if not data.get("world") is String or not _is_pair(data.get("cell")):
		return null
	var state := GameState.new()
	state.world = data.world
	state.cell = Vector2i(int(data.cell[0]), int(data.cell[1]))
	var saved_facts: Variant = data.get("facts", {})
	var saved_objects: Variant = data.get("objects", {})
	if not saved_facts is Dictionary or not saved_objects is Dictionary:
		return null
	for fact: String in saved_facts:
		state.facts[fact] = _whole(saved_facts[fact])
	for world_id: String in saved_objects:
		for object_id: String in saved_objects[world_id]:
			var properties: Dictionary = saved_objects[world_id][object_id].duplicate()
			if _is_pair(properties.get("cell")):
				properties.cell = Vector2i(int(properties.cell[0]), int(properties.cell[1]))
			state.change_object(world_id, object_id, properties)
	state.items.assign(data.get("items", []))
	state.items.sort()
	state.notes.assign(data.get("notes", []))
	return state


## Text that is equal for two states exactly if they are the same state.
func key() -> String:
	var data := to_data()
	data.notes.sort()
	return JSON.stringify(data, "", true)


static func _is_pair(value: Variant) -> bool:
	return value is Array and value.size() == 2


## JSON only knows one kind of number. Whole numbers become integers again, so a state that was
## saved and loaded equals the original.
static func _whole(value: Variant) -> Variant:
	if value is float and value == floorf(value):
		return int(value)
	return value
