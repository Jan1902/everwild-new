class_name Notebook
extends RefCounted
## What the notebook can hold: memories, pieces of the world and hints, and how they relate.
## Which of them the player has found is part of the game state.

const PATH := "res://data/notes.json"
const KINDS := ["memory", "piece", "hint"]


## All notes of the game: id -> "kind", "world" and "links" (ids of related notes).
static func read() -> Dictionary:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	return data if data is Dictionary else {}


## The found notes in the order they were found. Each has "id", "kind", "world" and "links", a
## list of {"id", "known"}: a related note the player has not found yet shows that something is
## still missing, without giving it away.
static func entries(notes: Dictionary, found: Array[String]) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for id in found:
		if not notes.has(id):
			continue
		var links: Array[Dictionary] = []
		for link: String in notes[id].get("links", []):
			links.append({"id": link, "known": link in found})
		list.append({"id": id, "kind": notes[id].get("kind", ""), "world": notes[id].get("world", ""), "links": links})
	return list


## Problems in the notes. An empty list means they are fine.
static func errors(notes: Dictionary) -> Array[String]:
	var list: Array[String] = []
	for id: String in notes:
		if notes[id].get("kind", "") not in KINDS:
			list.append("Note '%s' has unknown kind '%s'" % [id, notes[id].get("kind", "")])
		for link: String in notes[id].get("links", []):
			if not notes.has(link):
				list.append("Note '%s' links to unknown note '%s'" % [id, link])
			elif id not in notes[link].get("links", []):
				list.append("Note '%s' links to '%s', but not the other way round" % [id, link])
	return list