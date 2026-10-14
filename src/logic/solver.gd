class_name Solver
extends RefCounted
## Plays a game through in every possible way and checks that it can always be completed.
##
## A move is using an object, stepping onto a cell whose rule fires, lingering where a rule
## waits for it, or drawing two notes of the notebook together into an insight. Walking around without firing a rule changes nothing, so the player's cell only
## counts as "which connected area".
##
## Two states count as the same if they differ only in what no rule ever asks for, such as notes
## that are just there to be read. Moves that change nothing but that are left out.

## Search is given up beyond this many states.
const LIMIT := 200000
## Effects that never change what a rule can ask for.
const IDLE_EFFECTS := ["say", "remember", "scene"]

var _session: Session
## Names of facts, items and notes that some condition asks for.
var _asked := {"fact": {}, "item": {}, "note": {}}
## World id -> cells that rules for entering or lingering name, and objects that have rules.
var _enter_cells := {}
var _linger_cells := {}
var _used_objects := {}
## What is where in a world -> its connected areas (see _divide).
var _areas := {}


## Returns
##   "states"     number of different states the game can be in
##   "complete"   false if the search was given up. States it did not get to then count as
##                fine: every dead end reported is a real one, but there may be more
##   "solution"   shortest list of moves from the start to the completed game, as texts
##   "solvable"   whether there is a solution
##   "dead_ends"  number of reachable states from which the game can no longer be completed
##   "dead_end"   moves up to the one that spoils a game which could still be completed before
##                (empty if there is none, or if the game cannot be completed from the start)
static func check(game: Dictionary, sources := {}) -> Dictionary:
	var solver := Solver.new()
	solver._session = Session.create(game, sources)
	return solver._search()


func _search() -> Dictionary:
	_read_rules()
	_settle()

	var saved: Array[GameState] = [_session.state.copy()]
	var index := {_key(): 0}
	var parent := [-1]
	var move := [""]
	var followers := [[]]
	var goals: Array[int] = []
	var complete := true

	var next := 0
	while next < saved.size():
		if saved.size() > LIMIT:
			complete = false
			break
		_session.restore(saved[next].copy())
		if _session.is_complete():
			goals.append(next)
		for step: Dictionary in _moves():
			_session.restore(saved[next].copy())
			if step.has("combine"):
				_session.combine(step.combine[0], step.combine[1])
			elif step.has("object"):
				# The cell lies in the area, so walking there fires nothing.
				_session.state.cell = step.cell
				_session.interact(step.object)
			elif step.has("linger"):
				_session.state.cell = step.cell
				_session.linger()
			else:
				_session.enter(step.cell)
			_settle()
			var key := _key()
			if not index.has(key):
				index[key] = saved.size()
				saved.append(_session.state.copy())
				parent.append(next)
				move.append(_describe(step))
				followers.append([])
			followers[next].append(index[key])
		next += 1

	# Everything from which a completed state can be reached, found by walking backwards.
	var leaders := []
	leaders.resize(saved.size())
	for i in saved.size():
		leaders[i] = []
	for i in saved.size():
		for follower: int in followers[i]:
			leaders[follower].append(i)
	var good := {}
	var queue := goals.duplicate()
	for goal in goals:
		good[goal] = true
	# Nothing is known about states the search did not get to.
	for unexplored in range(next, saved.size()):
		if not good.has(unexplored):
			good[unexplored] = true
			queue.append(unexplored)
	while not queue.is_empty():
		var current: int = queue.pop_back()
		for leader: int in leaders[current]:
			if not good.has(leader):
				good[leader] = true
				queue.append(leader)

	var first_dead_end := -1
	for i in saved.size():
		if not good.has(i) and first_dead_end < 0 and good.has(parent[i]):
			first_dead_end = i
	return {
		"states": saved.size(),
		"complete": complete,
		"solvable": not goals.is_empty(),
		"solution": _trail(goals[0], parent, move) if not goals.is_empty() else [],
		"dead_ends": saved.size() - good.size(),
		"dead_end": _trail(first_dead_end, parent, move) if first_dead_end >= 0 else [],
	}


## Goes through all rules once and notes what they ask for and where they wait for the player.
func _read_rules() -> void:
	_note_asked(_session.definition.get("complete_if", []))
	# Notes that make an insight together matter as much as the insight does.
	var notes := _session.notes()
	for note: String in notes:
		for source: String in notes[note].get("from", []):
			_asked.note[source] = true
			_asked.item[Session.NOTEBOOK] = true
	for world_id: String in _session.world_ids():
		var world := _session.world(world_id)
		_enter_cells[world_id] = {}
		_linger_cells[world_id] = {}
		_used_objects[world_id] = {}
		for fault in world.faults:
			_note_asked(fault.get("fixed_if", []))
		for rule in world.rules:
			_note_asked(rule.get("if", []))
			match rule.get("on"):
				"interact":
					_used_objects[world_id][rule.get("object", "")] = true
				"enter":
					for cell in _cells_of(rule, world):
						_enter_cells[world_id][cell] = true
				"linger":
					for cell in _cells_of(rule, world):
						_linger_cells[world_id][cell] = true


func _note_asked(conditions: Array) -> void:
	for condition: Dictionary in conditions:
		if condition.has("not"):
			_note_asked([condition["not"]])
		elif condition.has("any"):
			_note_asked(condition["any"])
		else:
			for kind: String in _asked:
				if condition.has(kind):
					_asked[kind][condition[kind]] = true


## The cells a rule covers. A rule that names none covers the whole world.
func _cells_of(rule: Dictionary, world: World) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var everywhere := not (rule.has("cells") or rule.has("zone"))
	for y in world.size.y:
		for x in world.size.x:
			if everywhere or World.rule_covers(rule, Vector2i(x, y)):
				cells.append(Vector2i(x, y))
	return cells


## Whether a rule changes nothing a condition could ask for.
func _is_idle(rule: Dictionary) -> bool:
	for effect: Dictionary in rule.get("do", []):
		if IDLE_EFFECTS.any(func(kind: String) -> bool: return effect.has(kind)):
			continue
		if effect.has("note") and not _asked.note.has(effect["note"]):
			continue
		if effect.has("set") and not _asked.fact.has(effect["set"]):
			continue
		return false
	return true


## Text that is equal for two states exactly if no rule can tell them apart.
func _key() -> String:
	var state := _session.state
	var facts := {}
	for fact: String in state.facts:
		if _asked.fact.has(fact):
			facts[fact] = state.facts[fact]
	var notes := state.notes.filter(func(note: String) -> bool: return _asked.note.has(note))
	notes.sort()
	var items := state.items.filter(func(item: String) -> bool: return _asked.item.has(item))
	return JSON.stringify([state.world, state.cell, state.objects, facts, items, notes], "", true)


## All moves possible in the current state: {"cell"} to step onto, {"object", "cell"} to use
## the object from that cell, {"linger", "cell"} to stand still there, or {"combine"} with the
## two notes to draw together.
func _moves() -> Array[Dictionary]:
	var moves: Array[Dictionary] = []
	for open: Array in _session.open_insights():
		if _asked.note.has(open[2]):
			moves.append({"combine": [open[0], open[1]]})
	var world := _session.world()
	var area := _area()
	for cell: Vector2i in area.doors:
		moves.append({"cell": cell})
	# One move per rule that waits for the player to linger, from any cell of the area it covers.
	var lingering := []
	for cell: Vector2i in area.lingering:
		var rule := _session.linger_rule(cell)
		if not rule.is_empty() and not lingering.has(rule):
			lingering.append(rule)
			if not _is_idle(rule):
				moves.append({"linger": true, "cell": cell})
	for object_id: String in _used_objects[world.id]:
		var rule := _session.interact_rule(object_id)
		if rule.is_empty() or _is_idle(rule):
			continue
		for cell in world.cells_beside(world.get_object(object_id)):
			if area.cells.has(cell):
				moves.append({"object": object_id, "cell": cell})
				break
	return moves


## The area the player is in: "cells" they can walk to without firing a rule (as a set), "home"
## (one fixed cell of it), "doors" (cells beside it whose rule fires when stepped on) and
## "lingering" (its cells that rules for lingering name).
func _area() -> Dictionary:
	var world := _session.world()
	var doors := {}
	for cell: Vector2i in _enter_cells[world.id]:
		if not _session.enter_rule(cell).is_empty():
			doors[cell] = true
	var layout := [world.id, doors.keys()]
	for thing in world.objects:
		layout.append(thing.cell)
		layout.append(thing.hidden)
	var key := str(layout)
	if not _areas.has(key):
		_areas[key] = _divide(world, doors)
	var found: Dictionary = _areas[key]
	var cell := _session.state.cell
	if found.of.has(cell):
		return found.parts[found.of[cell]]
	# The player stands on a cell that is none of the areas, such as one whose rule fires.
	return _spread(world, cell, doors)


## Divides the walkable cells of a world into connected areas. Returns "of" (cell -> number of
## its area) and "parts" (the areas).
func _divide(world: World, doors: Dictionary) -> Dictionary:
	var of := {}
	var parts: Array[Dictionary] = []
	for y in world.size.y:
		for x in world.size.x:
			var cell := Vector2i(x, y)
			if of.has(cell) or doors.has(cell) or not world.is_walkable(cell):
				continue
			var part := _spread(world, cell, doors)
			for member: Vector2i in part.cells:
				of[member] = parts.size()
			parts.append(part)
	return {"of": of, "parts": parts}


func _spread(world: World, from: Vector2i, doors: Dictionary) -> Dictionary:
	var cells := {from: true}
	var beside := {}
	var home := from
	var open: Array[Vector2i] = [from]
	while not open.is_empty():
		var cell: Vector2i = open.pop_back()
		if cell.y < home.y or (cell.y == home.y and cell.x < home.x):
			home = cell
		for step in World.NEIGHBOURS:
			var next := cell + step
			if cells.has(next) or not world.is_walkable(next):
				continue
			if doors.has(next):
				beside[next] = true
				continue
			cells[next] = true
			open.append(next)
	var lingering: Array[Vector2i] = []
	for cell: Vector2i in _linger_cells[world.id]:
		if cells.has(cell):
			lingering.append(cell)
	return {"cells": cells, "home": home, "doors": beside.keys(), "lingering": lingering}


## Puts the player on a fixed cell of the area they are in, so equal situations give equal states.
func _settle() -> void:
	_session.state.cell = _area().home


static func _describe(step: Dictionary) -> String:
	if step.has("combine"):
		return "think %s + %s" % step.combine
	if step.has("object"):
		return "use %s" % step.object
	if step.has("linger"):
		return "linger at %d,%d" % [step.cell.x, step.cell.y]
	return "step on %d,%d" % [step.cell.x, step.cell.y]


static func _trail(state: int, parent: Array, move: Array) -> Array[String]:
	var trail: Array[String] = []
	while state > 0:
		trail.push_front(move[state])
		state = parent[state]
	return trail
