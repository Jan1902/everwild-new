class_name WorldObject
extends RefCounted
## One thing in a world: a house, a tree, a person, a bridge. Pure data.

## Properties that can change during the game.
const CHANGEABLE := ["cell", "mirrored", "hidden", "state"]
## Kinds that lie flat on the ground: they block nothing and the character walks over them.
const FLAT_KINDS := ["bridge", "raft", "stepping_stones"]

var id := ""
var kind := ""
## Rear corner of the footprint.
var cell := Vector2i.ZERO
var size := Vector2i.ONE
var mirrored := false
var hidden := false
## What condition the object is in. The meaning depends on the kind.
var state := ""
## Cells the object can be used from, such as the one in front of a door. Empty means every cell
## beside it.
var access: Array[Vector2i] = []


func is_flat() -> bool:
	return kind in FLAT_KINDS


func copy() -> WorldObject:
	var twin := WorldObject.new()
	twin.id = id
	twin.kind = kind
	twin.size = size
	twin.access = access.duplicate()
	twin.change(properties())
	return twin


## The changeable properties as they are now.
func properties() -> Dictionary:
	var current := {}
	for property: String in CHANGEABLE:
		current[property] = get(property)
	return current


## Sets the given changeable properties. Anything else in the dictionary is ignored.
func change(wanted: Dictionary) -> void:
	for property: String in CHANGEABLE:
		if wanted.has(property):
			set(property, wanted[property])


## Whether the object has all the given properties.
func matches(wanted: Dictionary) -> bool:
	for property: String in wanted:
		if property not in CHANGEABLE or get(property) != wanted[property]:
			return false
	return true


func occupied_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in size.y:
		for x in size.x:
			cells.append(cell + Vector2i(x, y))
	return cells
