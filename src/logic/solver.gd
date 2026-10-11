class_name Solver
extends RefCounted
## Plays a game through in every possible way and checks that it can always be completed.
##
## A move is using an object, stepping onto a cell whose rule fires, or lingering where a rule
## waits for it. Walking around without firing a rule changes nothing, so the player's cell only
## counts as "which connected area".

## Search is given up beyond this many states.
const LIMIT := 200000


## Returns
##   "states"     number of different states the game can be in
##   "complete"   false if the search was given up
##   "solution"   shortest list of moves from the start to the completed game, as texts
##   "solvable"   whether there is a solution
##   "dead_ends"  number of reachable states from which the game can no longer be completed
##   "dead_end"   moves up to the one that spoils a game which could still be completed before
##                (empty if there is none, or if the game cannot be completed from the start)
static func check(game: Dictionary, sources := {}) -> Dictionary:
	var session := Session.create(game, sources)
	_settle(session)

	var saved := [session.state.to_data()]
	var index := {session.state.key(): 0}
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
		session.load_state(saved[next])
		if session.is_complete():
			goals.append(next)
		for step: Dictionary in _moves(session):
			session.load_state(saved[next])
			if step.has("object"):
				# The cell lies in the area, so walking there fires nothing.
				session.state.cell = step.cell
				session.interact(step.object)
			elif step.has("linger"):
				session.state.cell = step.cell
				session.linger()
			else:
				session.enter(step.cell)
			_settle(session)
			var key := session.state.key()
			if not index.has(key):
				index[key] = saved.size()
				saved.append(session.state.to_data())
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


## All moves possible in the current state: {"cell"} to step onto, {"object", "cell"} to use
## the object from that cell, or {"linger", "cell"} to stand still there.
static func _moves(session: Session) -> Array[Dictionary]:
	var moves: Array[Dictionary] = []
	var world := session.world()
	var area := _area(session)
	for cell: Vector2i in area:
		for step in World.NEIGHBOURS:
			var beside := cell + step
			if not area.has(beside) and world.is_walkable(beside) and not session.enter_rule(beside).is_empty():
				if not moves.any(func(m: Dictionary) -> bool: return m.cell == beside):
					moves.append({"cell": beside})
	# One move per rule that waits for the player to linger, from any cell of the area it covers.
	var lingering := []
	for cell: Vector2i in area:
		var rule := session.linger_rule(cell)
		if not rule.is_empty() and not lingering.has(rule):
			lingering.append(rule)
			moves.append({"linger": true, "cell": cell})
	for object in world.objects:
		if session.interact_rule(object.id).is_empty():
			continue
		for cell in world.cells_beside(object):
			if area.has(cell):
				moves.append({"object": object.id, "cell": cell})
				break
	return moves


## Cells the player can walk to without firing a rule, as a set.
static func _area(session: Session) -> Dictionary:
	var world := session.world()
	var area := {session.state.cell: true}
	var open: Array[Vector2i] = [session.state.cell]
	while not open.is_empty():
		var cell: Vector2i = open.pop_back()
		for step in World.NEIGHBOURS:
			var beside := cell + step
			if area.has(beside) or not world.is_walkable(beside):
				continue
			if not session.enter_rule(beside).is_empty():
				continue
			area[beside] = true
			open.append(beside)
	return area


## Puts the player on a fixed cell of the area they are in, so equal situations give equal states.
static func _settle(session: Session) -> void:
	var best := session.state.cell
	for cell: Vector2i in _area(session):
		if cell.y < best.y or (cell.y == best.y and cell.x < best.x):
			best = cell
	session.state.cell = best


static func _describe(step: Dictionary) -> String:
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
