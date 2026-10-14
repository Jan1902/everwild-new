class_name Notebook
extends RefCounted
## What the notebook can hold: memories, pieces of the world, hints, what people recall of the
## Rift, and insights, and how they relate.
## Which of them the player has found is part of the game state.
##
## An insight is not found but thought: the player draws two notes together in the notebook
## ("from" names them), and if they belong together the insight is written down (see
## Session.combine). A note can also be crossed out while conditions hold ("crossed_if"), as
## the plans of the evening are after the Rift.

const PATH := "res://data/notes.json"
const KINDS := ["memory", "piece", "hint", "rift", "insight"]

static var _cache := {}


## All notes of the game: id -> "kind", "world", "links" (ids of related notes) and, for an
## insight, "from" (the two notes it comes from).
static func read() -> Dictionary:
	if _cache.is_empty():
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
		_cache = data if data is Dictionary else {}
	return _cache


## The insight two notes make together. Empty if they make none.
static func insight_of(notes: Dictionary, first: String, second: String) -> String:
	for id: String in notes:
		var sources: Array = notes[id].get("from", [])
		if sources.size() == 2 and first in sources and second in sources and first != second:
			return id
	return ""


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
		var kind: String = notes[id].get("kind", "")
		if kind not in KINDS:
			list.append("Note '%s' has unknown kind '%s'" % [id, kind])
		var sources: Array = notes[id].get("from", [])
		if (kind == "insight") != (sources.size() == 2):
			list.append("Note '%s' is an insight without two notes it comes from, or the other way round" % id)
		for source: Variant in sources:
			if not notes.has(source) or source == id:
				list.append("Insight '%s' comes from unknown note '%s'" % [id, source])
		for link: String in notes[id].get("links", []):
			if not notes.has(link):
				list.append("Note '%s' links to unknown note '%s'" % [id, link])
			elif id not in notes[link].get("links", []):
				list.append("Note '%s' links to '%s', but not the other way round" % [id, link])
	return list
