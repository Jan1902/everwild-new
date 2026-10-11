class_name SaveFile
extends RefCounted
## Writes the game state to a file on the device and reads it back.

const DEFAULT_PATH := "user://save.json"


## Writes saved data. The file is written under another name first and then swapped in, so a
## crash while writing never leaves a half-written save behind.
static func write(path: String, data: Dictionary) -> bool:
	var draft := path + ".tmp"
	var file := FileAccess.open(draft, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return DirAccess.rename_absolute(draft, path) == OK


## Reads saved data. Returns null if there is no file or it is not readable.
static func read(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		return null
	return json.data


static func delete(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
