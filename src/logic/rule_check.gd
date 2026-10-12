class_name RuleCheck
extends RefCounted
## Reads all rules, faults and start effects of a game and reports everything Session would not
## understand: unknown keys, and names of worlds, objects, faults, notes, facts and items that
## do not exist. Session itself takes such a rule silently: a misspelt condition just never
## holds, a misspelt effect does nothing.

const TRIGGERS := ["interact", "enter", "linger", "always"]
const RULE_KEYS := ["on", "object", "cells", "zone", "if", "do"]
const FAULT_KEYS := ["id", "fixed_if", "restores"]
## Kind of condition -> the other keys it may have.
const CONDITIONS := {
	"fact": ["is"],
	"item": ["is"],
	"note": ["is"],
	"fixed": ["world", "is"],
	"whole": ["is"],
	"object": ["world", "cell", "state", "mirrored", "hidden"],
	"not": [],
	"any": [],
}
## Kind of effect -> the other keys it may have.
const EFFECTS := {
	"set": ["to"],
	"give": [],
	"take": [],
	"note": [],
	"change": ["world", "cell", "state", "mirrored", "hidden"],
	"break": [],
	"restore": [],
	"go": ["cell", "by", "with"],
	"say": ["who"],
	"remember": [],
}

var _session: Session
var _notes := {}
var _list: Array[String] = []
## Names that are asked for, each with the first place that does, and names that are provided.
var _facts_asked := {}
var _facts_set := {}
var _items_asked := {}
var _items_given := {}
var _notes_asked := {}
var _notes_given := {}


## Problems in the rules of a game. An empty list means they are fine. With the notes of the
## game given (see Notebook.read), notes named by rules are checked against them.
static func errors(session: Session, notes := {}) -> Array[String]:
	var check := RuleCheck.new()
	check._session = session
	check._notes = notes
	check._run()
	return check._list


func _run() -> void:
	var worlds := _session.world_ids()
	var definition := _session.definition
	if definition.get("start", "") not in worlds:
		_add("game", "start world '%s' is not one of the worlds" % definition.get("start", ""))
	_check_effects(definition.get("on_start", []), definition.get("start", ""), "game, on_start")
	_check_conditions(definition.get("complete_if", []), definition.get("start", ""), "game, complete_if")

	for world_id: String in worlds:
		var world := _session.world(world_id)
		if not world.mood_from.is_empty() and world.mood_from not in worlds:
			_add(world_id, "shares the mood of unknown world '%s'" % world.mood_from)
		var seen := {}
		for fault in world.faults:
			var place := "%s, fault '%s'" % [world_id, fault.get("id", "")]
			_check_keys(fault, FAULT_KEYS, place, "fault")
			if not fault.get("id") is String or fault.get("id", "").is_empty():
				_add(place, "has no id")
			elif seen.has(fault.id):
				_add(place, "exists twice")
			seen[fault.get("id")] = true
			_check_conditions(fault.get("fixed_if"), world_id, place)
		for number in world.rules.size():
			_check_rule(world.rules[number], world, "%s, rule %d" % [world_id, number + 1])

	_report_missing(_facts_asked, _facts_set, "fact '%s' is asked for but never set")
	_report_missing(_items_asked, _items_given, "item '%s' is asked for but never given")
	_report_missing(_notes_asked, _notes_given, "note '%s' is asked for but never given")


func _check_rule(rule: Dictionary, world: World, place: String) -> void:
	var trigger: Variant = rule.get("on")
	place += " (%s%s)" % [trigger, " " + str(rule.get("object")) if rule.has("object") else ""]
	_check_keys(rule, RULE_KEYS, place, "rule")
	if trigger not in TRIGGERS:
		_add(place, "unknown trigger")
	if trigger == "interact":
		if world.get_object(str(rule.get("object", ""))) == null:
			_add(place, "unknown object")
	elif rule.has("object"):
		_add(place, "only 'interact' rules have an object")
	if trigger == "enter" and not (rule.has("cells") or rule.has("zone")):
		_add(place, "needs 'cells' or 'zone'")
	if rule.has("cells"):
		var cells: Variant = rule["cells"]
		if not cells is Array or cells.is_empty() or not cells.all(_is_cell):
			_add(place, "'cells' is not a list of [x, y]")
	if rule.has("zone"):
		var zone: Variant = rule["zone"]
		if not zone is Array or zone.size() != 4 or not zone.all(_is_number):
			_add(place, "'zone' is not [x, y, w, h]")
	_check_conditions(rule.get("if", []), world.id, place)
	if not rule.get("do") is Array or rule.get("do").is_empty():
		_add(place, "does nothing")
	_check_effects(rule.get("do", []), world.id, place)


func _check_conditions(conditions: Variant, home: String, place: String) -> void:
	if not conditions is Array:
		_add(place, "conditions are not a list")
		return
	for condition: Variant in conditions:
		_check_condition(condition, home, place)


func _check_condition(condition: Variant, home: String, place: String) -> void:
	var kind := _kind_of(condition, CONDITIONS, place, "condition")
	if kind.is_empty():
		return
	if kind == "not":
		_check_condition(condition["not"], home, place)
		return
	if kind == "any":
		_check_conditions(condition["any"], home, place)
		return
	if not condition[kind] is String:
		_add(place, "condition '%s' does not name anything" % kind)
		return
	var name: String = condition[kind]
	var what := "condition %s '%s'" % [kind, name]
	var where := _world_of(condition, home, place, what)
	if kind != "object" and kind != "fact" and not condition.get("is", true) is bool:
		_add(place, what + ": 'is' is not true or false")
	match kind:
		"fact":
			_remember(_facts_asked, name, place)
		"item":
			_remember(_items_asked, name, place)
		"note":
			_check_note(name, place, what)
			_remember(_notes_asked, name, place)
		"fixed":
			if not where.is_empty() and not _has_fault(where, name):
				_add(place, "%s: world '%s' has no such fault" % [what, where])
		"whole":
			if name not in _session.world_ids():
				_add(place, what + ": unknown world")
			elif _session.world(name).faults.is_empty():
				_add(place, what + ": that world has no faults")
		"object":
			_check_object(condition, name, where, place, what)


func _check_effects(effects: Variant, home: String, place: String) -> void:
	if not effects is Array:
		_add(place, "effects are not a list")
		return
	for effect: Variant in effects:
		var kind := _kind_of(effect, EFFECTS, place, "effect")
		if kind.is_empty():
			continue
		if not effect[kind] is String:
			_add(place, "effect '%s' does not name anything" % kind)
			continue
		var name: String = effect[kind]
		var what := "effect %s '%s'" % [kind, name]
		var where := _world_of(effect, home, place, what)
		match kind:
			"set":
				_facts_set[name] = true
			"give":
				_items_given[name] = true
			"take":
				_remember(_items_asked, name, place)
			"note":
				_check_note(name, place, what)
				_notes_given[name] = true
			"change":
				_check_object(effect, name, where, place, what)
				if World.read_properties(effect).is_empty():
					_add(place, what + ": changes nothing")
			"remember":
				if not home.is_empty() and not _session.world(home).memories.has(name):
					_add(place, "%s: world '%s' has no such place of memory" % [what, home])
			"break", "restore":
				if name not in _session.world_ids():
					_add(place, what + ": unknown world")
			"go":
				if name not in _session.world_ids():
					_add(place, what + ": unknown world")
				elif effect.has("cell"):
					if not _is_cell(effect["cell"]):
						_add(place, what + ": 'cell' is not [x, y]")
					elif _session.world(name).ground(World.read_properties(effect).cell) not in World.WALKABLE:
						_add(place, what + ": nobody can stand on that cell")
				var aboard: Array = effect.get("with", []) if effect.get("with", []) is Array else [null]
				for object_id: Variant in [effect.get("by", "")] + aboard:
					if not object_id is String:
						_add(place, what + ": 'by' is not an object and 'with' not a list of objects")
					elif not object_id.is_empty() and not home.is_empty() and _session.world(home).get_object(object_id) == null:
						_add(place, "%s: world '%s' has no object '%s' to travel with" % [what, home, object_id])


## The one key of a condition or effect that says what it is. Empty if there is none, more than
## one, or the entry is no dictionary; all of that is reported, and so are keys that do not
## belong to it.
func _kind_of(entry: Variant, known: Dictionary, place: String, what: String) -> String:
	if not entry is Dictionary:
		_add(place, "%s is not an entry with keys: %s" % [what, JSON.stringify(entry)])
		return ""
	var kinds: Array = entry.keys().filter(func(key: Variant) -> bool: return known.has(key))
	if kinds.size() != 1:
		_add(place, "%s needs exactly one of %s: %s" % [what, ", ".join(known.keys()), JSON.stringify(entry)])
		return ""
	_check_keys(entry, [kinds[0]] + known[kinds[0]], place, "%s '%s'" % [what, kinds[0]])
	return kinds[0]


func _check_keys(entry: Dictionary, allowed: Array, place: String, what: String) -> void:
	for key: Variant in entry:
		if key not in allowed:
			_add(place, "%s has the unknown key '%s'" % [what, key])


## The world a condition or effect refers to. Empty if it names one the game does not have.
func _world_of(entry: Dictionary, home: String, place: String, what: String) -> String:
	if not entry.has("world"):
		return home
	if not entry["world"] is String or entry["world"] not in _session.world_ids():
		_add(place, what + ": unknown world")
		return ""
	return entry["world"]


func _check_object(entry: Dictionary, object_id: String, where: String, place: String, what: String) -> void:
	if not where.is_empty() and _session.world(where).get_object(object_id) == null:
		_add(place, "%s: world '%s' has no such object" % [what, where])
	if entry.has("cell") and not _is_cell(entry["cell"]):
		_add(place, what + ": 'cell' is not [x, y]")
	if entry.has("state") and not entry["state"] is String:
		_add(place, what + ": 'state' is not a text")
	for property: String in ["mirrored", "hidden"]:
		if entry.has(property) and not entry[property] is bool:
			_add(place, "%s: '%s' is not true or false" % [what, property])


func _check_note(note: String, place: String, what: String) -> void:
	if not _notes.is_empty() and not _notes.has(note):
		_add(place, what + ": the notebook has no such note")


func _has_fault(world_id: String, fault_id: String) -> bool:
	return _session.world(world_id).faults.any(func(fault: Dictionary) -> bool: return fault.get("id") == fault_id)


func _remember(asked: Dictionary, name: String, place: String) -> void:
	if not asked.has(name):
		asked[name] = place


func _report_missing(asked: Dictionary, provided: Dictionary, message: String) -> void:
	for name: String in asked:
		if not provided.has(name):
			_add(asked[name], message % name)


func _add(place: String, message: String) -> void:
	_list.append("%s: %s" % [place, message])


static func _is_number(value: Variant) -> bool:
	return value is float or value is int


static func _is_cell(value: Variant) -> bool:
	return value is Array and value.size() == 2 and value.all(_is_number)
