class_name Session
extends RefCounted
## A running game: the game state together with the worlds it plays in.
## Everything the player does goes through enter() and interact(). Both change the state by the
## rules of the current world and return the effects that took place, so the view can show them.
##
## Conditions (all of a list have to hold; "world" defaults to the world the rule belongs to):
##   {"fact": name, "is": value}      a fact has this value (default true; unset facts are false)
##   {"item": id, "is": bool}         the player carries the item
##   {"note": id, "is": bool}         the notebook has the entry
##   {"fixed": fault, "world": id, "is": bool}   the fault of a world is fixed
##   {"object": id, "world": id, "cell": [x, y], "state": s, "mirrored": b, "hidden": b}
##                                    the object has all the given properties
##   {"not": condition}, {"any": [conditions]}
##
## Effects:
##   {"set": fact, "to": value}       sets a fact (default true)
##   {"give": item}, {"take": item}
##   {"note": id}                     adds a notebook entry
##   {"change": object, "world": id, "cell": [x, y], "state": s, "mirrored": b, "hidden": b}
##   {"break": world}                 turns a world into its broken version
##   {"restore": world}               turns a world back into the intact one
##   {"go": world, "cell": [x, y]}    moves the player to another world (default: its start cell)
##   {"say": text, "who": person}     changes nothing; the view shows the lines of the text, with
##                                    the text "name.<person>" as the speaker
##
## A rule only fires if its conditions hold and its effects are possible. Of several rules for
## the same trigger, only the first one that can fire does.

const WORLD_DIR := "res://data/worlds/"

var state := GameState.new()
## The game definition: "start" (world id), "worlds" (all world ids) and "on_start" (effects).
var definition := {}

var _worlds := {}
var _sources := {}


## Starts a new game. Worlds are read from their files unless their data is given in sources
## (world id -> data), which the tests use.
static func create(game: Dictionary, sources := {}) -> Session:
	var session := Session.new()
	session.definition = game
	session._sources = sources
	session.state.world = game.get("start", "")
	session.state.cell = session.world().start
	session.apply(game.get("on_start", []), session.state.world)
	return session


## Continues a saved game. Returns null if the saved data does not fit the game.
static func resume(game: Dictionary, saved: Variant, sources := {}) -> Session:
	var session := Session.new()
	session.definition = game
	session._sources = sources
	return session if session.load_state(saved) else null


## Replaces the state by saved data. Returns false and changes nothing if the data is unusable.
func load_state(saved: Variant) -> bool:
	var loaded := GameState.from_data(saved)
	if loaded == null or loaded.world not in world_ids():
		return false
	state = loaded
	for world_id: String in _worlds:
		_worlds[world_id].apply(state.objects.get(world_id, {}))
	if not world().is_walkable(state.cell):
		state.cell = world().start
	return true


func world_ids() -> Array:
	return definition.get("worlds", [])


## A world in its current condition. Without an id, the world the player is in.
func world(world_id := "") -> World:
	if world_id.is_empty():
		world_id = state.world
	if not _worlds.has(world_id):
		var loaded: World
		if _sources.has(world_id):
			loaded = World.from_data(_sources[world_id], world_id)
		else:
			loaded = World.from_file(WORLD_DIR + world_id + ".json")
		loaded.apply(state.objects.get(world_id, {}))
		_worlds[world_id] = loaded
	return _worlds[world_id]


## Moves the player onto a cell of the current world and fires the rule for entering it.
## Returns the effects that took place. Does nothing if the player cannot stand there.
func enter(cell: Vector2i) -> Array:
	if not world().is_walkable(cell):
		return []
	state.cell = cell
	return _fire(enter_rule(cell))


## Uses an object of the current world. Returns the effects that took place.
func interact(object_id: String) -> Array:
	return _fire(interact_rule(object_id))


## The rule that would fire when the player enters the cell. Empty if none would.
func enter_rule(cell: Vector2i) -> Dictionary:
	for rule in world().rules:
		if rule.get("on") == "enter" and World.rule_covers(rule, cell) and _can_fire(rule):
			return rule
	return {}


## The rule that would fire when the player uses the object. Empty if none would.
func interact_rule(object_id: String) -> Dictionary:
	if world().object(object_id).get("hidden", true):
		return {}
	for rule in world().rules:
		if rule.get("on") == "interact" and rule.get("object") == object_id and _can_fire(rule):
			return rule
	return {}


## Whether the object reacts to being used at all, now or in some other state.
func is_interactive(object_id: String) -> bool:
	return world().rules.any(
		func(rule: Dictionary) -> bool: return rule.get("on") == "interact" and rule.get("object") == object_id
	)


func holds(conditions: Array, home: String) -> bool:
	for condition: Dictionary in conditions:
		if not _holds(condition, home):
			return false
	return true


## Applies effects without asking whether they are possible. home is the world that effects
## without a "world" of their own refer to.
func apply(effects: Array, home: String) -> void:
	for effect: Dictionary in effects:
		_apply(effect, home)


func is_fixed(world_id: String, fault_id: String) -> bool:
	for fault in world(world_id).faults:
		if fault.get("id") == fault_id:
			return holds(fault.get("fixed_if", []), world_id)
	return false


## Ids of the faults of a world that are not fixed yet.
func open_faults(world_id := "") -> Array[String]:
	if world_id.is_empty():
		world_id = state.world
	var open: Array[String] = []
	for fault in world(world_id).faults:
		if not holds(fault.get("fixed_if", []), world_id):
			open.append(fault.get("id", ""))
	return open


## The game is complete once no world has an open fault.
func is_complete() -> bool:
	for world_id: String in world_ids():
		if not open_faults(world_id).is_empty():
			return false
	return true


## Mood of a world in its current condition. Every dial follows the faults that restore it. Dials
## no fault restores follow the share of open faults.
func mood(world_id := "") -> Mood:
	var here := world(world_id)
	if not here.mood_from.is_empty():
		return mood(here.mood_from)
	var open := open_faults(here.id)
	var general := 0.0 if here.faults.is_empty() else float(open.size()) / here.faults.size()
	var weights := {}
	for dial: String in Mood.DIALS:
		var owners := 0
		var owners_open := 0
		for fault in here.faults:
			if dial in fault.get("restores", []):
				owners += 1
				if fault.get("id", "") in open:
					owners_open += 1
		if owners > 0:
			weights[dial] = float(owners_open) / owners
	return Mood.blend_dials(here.mood, here.mood_wrong, weights, general)


func _fire(rule: Dictionary) -> Array:
	var effects: Array = rule.get("do", [])
	apply(effects, state.world)
	return effects


func _can_fire(rule: Dictionary) -> bool:
	if not holds(rule.get("if", []), state.world):
		return false
	for effect: Dictionary in rule.get("do", []):
		if not _is_possible(effect, state.world):
			return false
	return true


func _holds(condition: Dictionary, home: String) -> bool:
	if condition.has("not"):
		return not _holds(condition["not"], home)
	if condition.has("any"):
		for option: Dictionary in condition["any"]:
			if _holds(option, home):
				return true
		return false
	var expected: Variant = condition.get("is", true)
	var where: String = condition.get("world", home)
	if condition.has("fact"):
		return state.facts.get(condition["fact"], false) == expected
	if condition.has("item"):
		return (condition["item"] in state.items) == expected
	if condition.has("note"):
		return (condition["note"] in state.notes) == expected
	if condition.has("fixed"):
		return is_fixed(where, condition["fixed"]) == expected
	if condition.has("object"):
		var object := world(where).object(condition["object"])
		if object.is_empty():
			return false
		var wanted := World.read_properties(condition)
		for property: String in wanted:
			if object[property] != wanted[property]:
				return false
		return true
	return false


func _is_possible(effect: Dictionary, home: String) -> bool:
	if effect.has("change"):
		var where: String = effect.get("world", home)
		var target := world(where)
		var object := target.object(effect["change"])
		var wanted := World.read_properties(effect)
		if object.is_empty():
			return false
		var solid: bool = object.kind not in World.FLAT_KINDS and not wanted.get("hidden", object.hidden)
		var cell: Vector2i = wanted.get("cell", object.cell)
		if solid and (wanted.has("cell") or wanted.has("hidden")):
			if not target.has_room(object, cell):
				return false
			if where == state.world and Rect2i(cell, object.size).has_point(state.cell):
				return false
	elif effect.has("go"):
		var target := world(effect["go"])
		var cell: Vector2i = World.read_properties(effect).get("cell", target.start)
		return effect["go"] in world_ids() and target.is_walkable(cell)
	return true


func _apply(effect: Dictionary, home: String) -> void:
	var where: String = effect.get("world", home)
	if effect.has("set"):
		state.facts[effect["set"]] = effect.get("to", true)
	elif effect.has("give"):
		state.give(effect["give"])
	elif effect.has("take"):
		state.take(effect["take"])
	elif effect.has("note"):
		state.add_note(effect["note"])
	elif effect.has("change"):
		state.change_object(where, effect["change"], World.read_properties(effect))
		_refresh(where)
	elif effect.has("break"):
		var target := world(effect["break"])
		for object_id: String in target.broken:
			state.change_object(target.id, object_id, target.broken[object_id])
		_refresh(target.id)
	elif effect.has("restore"):
		state.objects.erase(effect["restore"])
		_refresh(effect["restore"])
	elif effect.has("go"):
		state.world = effect["go"]
		state.cell = World.read_properties(effect).get("cell", world().start)


func _refresh(world_id: String) -> void:
	world(world_id).apply(state.objects.get(world_id, {}))
