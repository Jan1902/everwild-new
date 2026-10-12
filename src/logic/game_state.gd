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
## Whether the player has seen the start screen with the advice on headphones. It only shows on
## the very first start, so this outlasts a new game.
var start_screen_seen := false


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
		"start_screen_seen": start_screen_seen,
	}


## Reads a state from plain data. Returns null if the data is not a usable save.
static func from_data(data: Variant) -> GameState:
	if not data is Dictionary or not _is_number(data.get("version")) or int(data.version) != VERSION:
		return null
	if not data.get("world") is String or not _is_pair(data.get("cell")):
		return null
	var state := GameState.new()
	state.world = data.world
	state.cell = Vector2i(int(data.cell[0]), int(data.cell[1]))
	var saved_facts: Variant = data.get("facts", {})
	var saved_objects: Variant = data.get("objects", {})
	var saved_items: Variant = data.get("items", [])
	var saved_notes: Variant = data.get("notes", [])
	if not saved_facts is Dictionary or not saved_objects is Dictionary:
		return null
	if not _is_texts(saved_items) or not _is_texts(saved_notes):
		return null
	for fact: Variant in saved_facts:
		state.facts[str(fact)] = _whole(saved_facts[fact])
	for world_id: Variant in saved_objects:
		if not saved_objects[world_id] is Dictionary:
			return null
		for object_id: Variant in saved_objects[world_id]:
			var properties: Variant = _read_properties(saved_objects[world_id][object_id])
			if properties == null:
				return null
			state.change_object(str(world_id), str(object_id), properties)
	state.items.assign(saved_items)
	state.items.sort()
	state.notes.assign(saved_notes)
	state.start_screen_seen = data.get("start_screen_seen", false) == true
	return state


## The changed properties of an object from saved data, with the kinds of values the game
## works with. Null if they are not usable.
static func _read_properties(saved: Variant) -> Variant:
	if not saved is Dictionary:
		return null
	var properties := {}
	for property: Variant in saved:
		var value: Variant = saved[property]
		match property:
			"cell":
				if not _is_pair(value):
					return null
				properties.cell = Vector2i(int(value[0]), int(value[1]))
			"mirrored", "hidden":
				if not value is bool:
					return null
				properties[property] = value
			"state":
				if not value is String:
					return null
				properties.state = value
			_:
				return null
	return properties


## Text that is equal for two states exactly if they are the same state.
func key() -> String:
	var data := to_data()
	data.notes.sort()
	return JSON.stringify(data, "", true)


static func _is_number(value: Variant) -> bool:
	return value is float or value is int


static func _is_pair(value: Variant) -> bool:
	return value is Array and value.size() == 2 and _is_number(value[0]) and _is_number(value[1])


static func _is_texts(value: Variant) -> bool:
	return value is Array and value.all(func(entry: Variant) -> bool: return entry is String)


## JSON only knows one kind of number. Whole numbers become integers again, so a state that was
## saved and loaded equals the original.
static func _whole(value: Variant) -> Variant:
	if value is float and value == floorf(value):
		return int(value)
	return value
