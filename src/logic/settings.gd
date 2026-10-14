class_name Settings
extends RefCounted
## What the player has set for the game as a whole. Kept in a file of its own, apart from the
## saved game, so it outlasts a new game.

const DEFAULT_PATH := "user://settings.json"

## How loud the music and the sounds are, from 0 (silent) to 1.
var music_volume := 1.0
var sound_volume := 1.0
## Language of the texts. Empty for the language of the device.
var language := ""

var _path := ""


## Reads the settings from a file. Whatever is missing or unusable keeps its normal value.
## With an empty path the settings are not kept.
static func read(path: String) -> Settings:
	var settings := Settings.new()
	settings._path = path
	var data: Variant = SaveFile.read(path) if not path.is_empty() else null
	if data is Dictionary:
		settings.music_volume = _volume(data.get("music_volume"), settings.music_volume)
		settings.sound_volume = _volume(data.get("sound_volume"), settings.sound_volume)
		if data.get("language") is String:
			settings.language = data.language
	return settings


## Writes the settings to the file they were read from.
func write() -> void:
	if not _path.is_empty():
		SaveFile.write(_path, {"music_volume": music_volume, "sound_volume": sound_volume, "language": language})


## A volume from saved data, or the given one if it is none.
static func _volume(saved: Variant, otherwise: float) -> float:
	if (saved is float or saved is int) and saved >= 0.0 and saved <= 1.0:
		return saved
	return otherwise
