class_name Texts
extends RefCounted
## Everything the game shows as text, by key, in the language of the device.
## A text is one string, or a list of strings for the lines of a dialogue.

const DIR := "res://data/texts/"
## Languages the game has texts for. The first one is used when the device has another language.
const LANGUAGES := ["en", "de"]

static var language := ""

static var _texts := {}


## Loads the texts of a language. Without one, the language of the device.
static func use(wanted := "") -> void:
	if wanted.is_empty():
		wanted = OS.get_locale_language()
	language = wanted if wanted in LANGUAGES else LANGUAGES[0]
	_texts = read(language)


## All texts of a language as they are in its file.
static func read(of_language: String) -> Dictionary:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(DIR + of_language + ".json"))
	return data if data is Dictionary else {}


static func has(key: String) -> bool:
	return _texts.has(key)


## The text for a key. A missing text shows as its key, so the gap is easy to spot.
static func text(key: String) -> String:
	return "\n".join(lines(key))


static func lines(key: String) -> Array[String]:
	var found: Array[String] = []
	var value: Variant = _texts.get(key, key)
	if value is Array:
		found.assign(value)
	else:
		found.append(str(value))
	return found