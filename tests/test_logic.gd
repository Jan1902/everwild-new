extends SceneTree
## Checks the game logic without graphics.
##
##   godot --headless --path . --script tests/test_logic.gd

var _failures := 0
var _checks := 0


func _init() -> void:
	_test_iso()
	_test_village()
	_test_mood()
	_test_state()
	_test_rules()
	_test_rule_check()
	_test_village_game()
	_test_story()
	_test_save_file()
	_test_texts()
	_test_settings()
	print("%d checks, %d failed" % [_checks, _failures])
	quit(1 if _failures > 0 else 0)


func _check(condition: bool, what: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		print("FAILED: " + what)


## Uses an object from the first cell it can be used from, however the player would get there.
func _use(session: Session, object_id: String) -> Array:
	var world := session.world()
	session.state.cell = world.cells_beside(world.get_object(object_id))[0]
	return session.interact(object_id)


func _test_iso() -> void:
	var ok := true
	for y in 20:
		for x in 20:
			var cell := Vector2i(x, y)
			var centre := Iso.to_point(cell)
			# The centre and four points just inside the diamond have to give the same cell.
			for offset: Vector2 in [Vector2.ZERO, Vector2(60, 0), Vector2(-60, 0), Vector2(0, 30), Vector2(0, -30)]:
				if Iso.to_cell(centre + offset) != cell:
					ok = false
	_check(ok, "Iso: point and cell do not convert back and forth")


func _test_mood() -> void:
	var intact := Mood.from_data({"wind": 2.0})
	var wrong := Mood.from_data({"water": -1.0, "shadow": [-1.0, 0.5], "tint": [0.5, 0.5, 1.0]}, intact)
	_check(intact.wind == 2.0 and intact.water == 1.0, "Mood does not take over given or normal values")
	_check(wrong.wind == 2.0, "Wrong mood does not inherit from the intact one")
	_check(wrong.shadow == Vector2(-1.0, 0.5), "Shadow direction is not read")
	_check(intact.water == 1.0, "Reading the wrong mood changes the intact one")

	var middle := Mood.blend(intact, wrong, 0.5)
	_check(is_zero_approx(middle.water), "Blending misses the middle")
	_check(is_equal_approx(middle.tint.r, 0.75), "Tint is not blended")
	_check(Mood.blend(intact, wrong, 0.0).water == 1.0, "Weight 0 does not give the intact mood")
	_check(Mood.blend(intact, wrong, 1.0).water == -1.0, "Weight 1 does not give the wrong mood")

	var village := World.from_file("res://data/worlds/village.json")
	_check(village.mood.wind > 0.0 and village.mood_wrong.wind < 0.0, "Wind does not blow the other way in the wrong village")
	_check(not village.music.is_empty(), "Village has no music")


func _test_village() -> void:
	var world := World.from_file("res://data/worlds/village.json")
	_check(world.errors().is_empty(), "Village has data errors: %s" % [world.errors()])
	_check(world.size == Vector2i(20, 20), "Village is not 20x20")
	_check(world.id == "village", "Village does not take its id from the file name")

	_check(not world.is_walkable(Vector2i(0, 0)), "Void is walkable")
	_check(not world.is_walkable(Vector2i(13, 8)), "Water is walkable")
	_check(world.is_walkable(Vector2i(13, 9)), "Bridge is not walkable")
	_check(not world.is_walkable(Vector2i(8, 5)), "House is walkable")
	_check(not world.is_walkable(Vector2i(9, 6)), "Second cell of the house is walkable")
	_check(not world.is_walkable(Vector2i(7, 8)), "Lantern is walkable")
	_check(world.objects.any(func(o: WorldObject) -> bool: return o.kind == "bridge"), "Village has no bridge object")
	_check(not world.is_walkable(Vector2i(-1, 5)), "Cell outside the grid is walkable")

	var target := Vector2i(16, 9)
	var path := world.find_path(world.start, target)
	_check(not path.is_empty(), "No path across the brook")
	_check(Vector2i(13, 9) in path, "Path across the brook does not use the bridge")
	if not path.is_empty():
		_check(path[0] == world.start and path[-1] == target, "Path starts or ends in the wrong place")
	var continuous := true
	for i in path.size():
		if not world.is_walkable(path[i]):
			continuous = false
		if i > 0 and maxi(absi(path[i].x - path[i - 1].x), absi(path[i].y - path[i - 1].y)) != 1:
			continuous = false
	_check(continuous, "Path contains jumps or blocked cells")
	_check(path == world.find_path(world.start, target), "Pathfinding is not deterministic")

	_check(world.find_path(world.start, Vector2i(13, 8)).is_empty(), "Found a path into the water")
	_check(world.find_path(world.start, Vector2i(8, 5)).is_empty(), "Found a path into a house")


## A small world for trying out rules: a corridor of five cells with three niches below it.
##   gate   belongs into the middle niche; in the broken world it blocks the corridor
##   lamp   is out in the broken world and needs the match found on cell 3,0
func _tiny_world() -> Dictionary:
	return {
		"size": [5, 2],
		"start": [0, 0],
		"ground": [".....", ". . ."],
		"mood_wrong": {"wind": -1.0, "light": 0.0, "fog": 1.0},
		"objects": [
			{"id": "gate", "kind": "rock", "cell": [2, 1]},
			{"id": "lamp", "kind": "lantern", "cell": [4, 1], "state": "lit"},
		],
		"broken": {"gate": {"cell": [2, 0]}, "lamp": {"state": "out"}},
		"faults": [
			{"id": "gate", "fixed_if": [{"object": "gate", "cell": [2, 1]}], "restores": ["wind"]},
			{"id": "lamp", "fixed_if": [{"object": "lamp", "state": "lit"}], "restores": ["light"]},
		],
		"rules": [
			{
				"on": "interact", "object": "gate",
				"if": [{"object": "gate", "cell": [2, 0]}],
				"do": [{"change": "gate", "cell": [2, 1]}],
			},
			{
				"on": "enter", "cells": [[3, 0]],
				"if": [{"fact": "found", "is": false}],
				"do": [{"set": "found"}, {"give": "match"}, {"note": "match_found"}],
			},
			{
				"on": "interact", "object": "lamp",
				"if": [{"object": "lamp", "state": "out"}, {"item": "match"}],
				"do": [{"change": "lamp", "state": "lit"}, {"take": "match"}],
			},
			{"on": "interact", "object": "lamp", "do": [{"say": "lamp_is_dark"}]},
		],
	}


func _tiny_game() -> Dictionary:
	return {"start": "tiny", "worlds": ["tiny", "cellar"], "on_start": [{"break": "tiny"}]}


func _tiny_sources() -> Dictionary:
	return {"tiny": _tiny_world(), "cellar": {"size": [2, 1], "start": [0, 0], "ground": [".."]}}


func _test_state() -> void:
	var state := GameState.new()
	state.world = "tiny"
	state.cell = Vector2i(3, 0)
	state.facts["found"] = true
	state.facts["count"] = 2
	state.change_object("tiny", "gate", {"cell": Vector2i(2, 1)})
	state.change_object("tiny", "gate", {"mirrored": true})
	state.give("match")
	state.give("apple")
	state.give("match")
	state.add_note("b")
	state.add_note("a")
	_check(state.items == ["apple", "match"], "Items are not a sorted set")
	_check(state.objects.tiny.gate == {"cell": Vector2i(2, 1), "mirrored": true}, "Object changes are not merged")

	var text := JSON.stringify(state.to_data())
	var loaded := GameState.from_data(JSON.parse_string(text))
	_check(loaded != null and loaded.key() == state.key(), "State changes when saved and loaded")
	_check(loaded != null and loaded.objects.tiny.gate.cell == Vector2i(2, 1), "Cell of an object is not restored")
	_check(loaded != null and loaded.notes == ["b", "a"], "Notes lose their order")
	_check(loaded != null and not loaded.start_screen_seen, "Start screen counts as seen without having been shown")
	state.start_screen_seen = true
	loaded = GameState.from_data(JSON.parse_string(JSON.stringify(state.to_data())))
	_check(loaded != null and loaded.start_screen_seen, "State forgets that the start screen was shown")
	_check(GameState.from_data("nonsense") == null, "Nonsense is accepted as a saved state")
	_check(GameState.from_data({"version": 999, "world": "tiny", "cell": [0, 0]}) == null, "Unknown version is accepted")
	_check(GameState.from_data({"version": 1, "world": "tiny"}) == null, "State without a cell is accepted")
	# Data of the wrong shape must not get through, whatever part of the save it sits in.
	var sound := {"version": 1, "world": "tiny", "cell": [0, 0]}
	_check(GameState.from_data(sound) != null, "Smallest sound state is not accepted")
	for part: Dictionary in [
		{"version": [1]}, {"cell": ["a", "b"]}, {"facts": []}, {"objects": {"tiny": 5}}, {"objects": {"tiny": {"gate": 5}}},
		{"objects": {"tiny": {"gate": {"cell": 3}}}}, {"objects": {"tiny": {"gate": {"hidden": "yes"}}}},
		{"objects": {"tiny": {"gate": {"size": [9, 9]}}}}, {"items": "match"}, {"items": [1]}, {"notes": [{}]},
	]:
		var spoilt := sound.duplicate()
		spoilt.merge(part, true)
		_check(GameState.from_data(spoilt) == null, "Spoilt state is accepted: %s" % [part])


func _test_rules() -> void:
	var session := Session.create(_tiny_game(), _tiny_sources())
	var world := session.world()
	_check(world.errors().is_empty(), "Tiny world has data errors: %s" % [world.errors()])
	_check(world.get_object("gate").cell == Vector2i(2, 0), "Starting the game does not break the world")
	_check(session.open_faults() == ["gate", "lamp"], "Broken world does not have both faults open")
	_check(not world.is_walkable(Vector2i(2, 0)) and world.is_walkable(Vector2i(2, 1)), "Moved object blocks the wrong cell")
	_check(world.find_path(Vector2i(0, 0), Vector2i(4, 0)).is_empty(), "Path leads through the gate")
	_check(RuleCheck.errors(session).is_empty(), "Tiny world has rule errors: %s" % [RuleCheck.errors(session)])
	_check(not session.can_use("lamp") and session.interact("lamp").is_empty(), "Object can be used from afar")

	var mood := session.mood()
	_check(mood.wind == -1.0 and mood.light == 0.0 and mood.fog == 1.0, "Broken world does not have the wrong mood")

	_check(session.enter(Vector2i(2, 0)).is_empty() and session.state.cell == Vector2i(0, 0), "Player can walk into an object")
	_check(_use(session, "lamp") == [{"say": "lamp_is_dark"}], "Later rule does not fire when the first one cannot")
	session.state.cell = Vector2i(0, 0)
	session.enter(Vector2i(1, 0))
	_check(session.interact("gate").size() == 1, "Using the gate does nothing")
	_check(world.get_object("gate").cell == Vector2i(2, 1), "Gate does not move")
	_check(_use(session, "gate").is_empty(), "Rule fires although its condition does not hold")
	_check(not world.find_path(Vector2i(0, 0), Vector2i(4, 0)).is_empty(), "Path is still blocked after the gate moved")
	_check(session.open_faults() == ["lamp"], "Moving the gate does not fix its fault")

	mood = session.mood()
	_check(mood.wind == 1.0 and mood.light == 0.0, "Fixed fault does not restore its own dial only")
	_check(is_equal_approx(mood.fog, 0.5), "Dials without a fault do not follow the share of open faults")

	session.enter(Vector2i(2, 0))
	_check(session.enter(Vector2i(3, 0)).size() == 3, "Entering the cell does not fire its rule")
	_check(session.state.items == ["match"] and session.state.notes == ["match_found"], "Rule does not give item and note")
	_check(session.enter(Vector2i(3, 0)).is_empty(), "Rule for entering fires twice")
	session.enter(Vector2i(4, 0))
	session.interact("lamp")
	_check(session.state.items.is_empty() and world.get_object("lamp").state == "lit", "Lamp is not lit with the match")
	_check(session.is_complete(), "Game is not complete although all faults are fixed")
	_check(session.mood().fog == 0.0, "Repaired world does not have the intact mood")

	# An object cannot be moved onto the player.
	session.apply([{"break": "tiny"}], "tiny")
	session.state.cell = Vector2i(2, 1)
	_check(session.interact("gate").is_empty(), "Gate moves onto the player")

	# Saved and continued, the game is in the same condition.
	var continued := Session.resume(_tiny_game(), JSON.parse_string(JSON.stringify(session.state.to_data())), _tiny_sources())
	_check(continued != null and continued.state.key() == session.state.key(), "Continued game differs from the saved one")
	_check(continued != null and continued.world().get_object("gate").cell == Vector2i(2, 0), "Continued game loses object changes")
	_check(Session.resume(_tiny_game(), {"version": 1, "world": "nowhere", "cell": [0, 0]}, _tiny_sources()) == null, "Save for an unknown world is accepted")
	# A save from an older game may name worlds and objects that are gone.
	var stale := {"version": 1, "world": "tiny", "cell": [0, 0], "objects": {
		"tiny": {"gate": {"cell": [2, 0]}, "torch": {"state": "out"}}, "attic": {"chest": {"hidden": true}},
	}}
	continued = Session.resume(_tiny_game(), stale, _tiny_sources())
	_check(continued != null and continued.state.objects == {"tiny": {"gate": {"cell": Vector2i(2, 0)}}}, "Changes to things that are gone are kept")

	# Effects reach into other worlds, and the player can change worlds.
	session.apply([{"go": "cellar", "cell": [1, 0]}], "tiny")
	_check(session.state.world == "cellar" and session.world().id == "cellar", "Player does not change worlds")
	session.apply([{"change": "lamp", "world": "tiny", "state": "out"}], "cellar")
	_check(session.world("tiny").get_object("lamp").state == "out", "Effect does not reach another world")
	_check(session.holds([{"fixed": "lamp", "world": "tiny", "is": false}], "cellar"), "Condition does not see another world")
	_check(session.holds([{"any": [{"fact": "nope"}, {"not": {"item": "match"}}]}], "cellar"), "'any' and 'not' do not work")

	var result := Solver.check(_tiny_game(), _tiny_sources())
	_check(result.solvable and result.dead_ends == 0 and result.complete, "Tiny world is not solvable: %s" % [result])
	_check(result.solution == ["use gate", "step on 3,0", "use lamp"], "Unexpected solution: %s" % [result.solution])

	# A trap has to be found: using the gate a second time makes the dark lamp vanish for good.
	var trapped := _tiny_sources()
	trapped.tiny.rules.push_front({
		"on": "interact", "object": "gate",
		"if": [{"object": "gate", "cell": [2, 1]}, {"object": "lamp", "state": "out"}],
		"do": [{"change": "lamp", "hidden": true}],
	})
	result = Solver.check(_tiny_game(), trapped)
	_check(result.solvable and result.dead_ends > 0, "Dead end is not found")
	_check(result.dead_end == ["use gate", "use gate"], "Way into the dead end is not reported: %s" % [result.dead_end])

	# Lingering is a move of its own: here the match only shows itself to those who stand still.
	var patient := _tiny_sources()
	patient.tiny.rules[1]["on"] = "linger"
	patient.tiny.rules[1]["zone"] = [3, 0, 2, 1]
	session = Session.create(_tiny_game(), patient)
	_check(session.world().errors().is_empty(), "World with a linger rule has data errors")
	_check(session.linger().is_empty(), "Lingering outside the zone fires the rule")
	_use(session, "gate")
	session.enter(Vector2i(4, 0))
	_check(session.linger().size() == 3 and session.state.items == ["match"], "Lingering in the zone does not fire the rule")
	result = Solver.check(_tiny_game(), patient)
	_check(result.solution == ["use gate", "linger at 3,0", "use lamp"], "Solver does not linger: %s" % [result.solution])

	# A game that cannot be completed at all has to be found as well.
	var hopeless := _tiny_sources()
	hopeless.tiny.rules.clear()
	_check(not Solver.check(_tiny_game(), hopeless).solvable, "Unsolvable game is not found")


## A tiny game that has not started, so rules with slips in them are read but never fire.
func _unstarted(game: Dictionary, sources: Dictionary) -> Session:
	return Session.resume(game, {"version": 1, "world": "tiny", "cell": [0, 0]}, sources)


## Every kind of slip in the rules has to be reported, each exactly once.
func _test_rule_check() -> void:
	var slips := {
		"unknown trigger": {"on": "touch", "do": [{"set": "found"}]},
		"unknown key 'when'": {"on": "always", "when": [], "do": [{"set": "found"}]},
		"unknown object": {"on": "interact", "object": "gatte", "do": [{"set": "found"}]},
		"needs 'cells' or 'zone'": {"on": "enter", "do": [{"set": "found"}]},
		"'zone' is not": {"on": "linger", "zone": [1, 2, 3], "do": [{"set": "found"}]},
		"does nothing": {"on": "always", "if": [{"fact": "found"}], "do": []},
		"needs exactly one of fact": {"on": "always", "if": [{"fakt": "found"}], "do": [{"set": "found"}]},
		"needs exactly one of set": {"on": "always", "do": [{"sett": "found"}]},
		"unknown key 'iss'": {"on": "always", "if": [{"fact": "found", "iss": false}], "do": [{"set": "found"}]},
		"has no such fault": {"on": "always", "if": [{"not": {"fixed": "lammp"}}], "do": [{"set": "found"}]},
		"has no such object": {"on": "always", "if": [{"any": [{"object": "lammp", "state": "out"}]}], "do": [{"set": "found"}]},
		"'state' is not a text": {"on": "always", "do": [{"change": "lamp", "state": 1}]},
		"changes nothing": {"on": "always", "do": [{"change": "lamp"}]},
		"unknown world": {"on": "always", "do": [{"change": "lamp", "world": "attic", "state": "lit"}]},
		"effect go 'attic': unknown world": {"on": "always", "do": [{"go": "attic"}]},
		"nobody can stand on that cell": {"on": "always", "do": [{"go": "cellar", "cell": [5, 5]}]},
		"fact 'fuond' is asked for but never set": {"on": "always", "if": [{"fact": "fuond", "is": false}], "do": [{"set": "found"}]},
		"item 'macth' is asked for but never given": {"on": "always", "do": [{"take": "macth"}]},
		"note 'lost' is asked for but never given": {"on": "always", "if": [{"note": "lost"}], "do": [{"set": "found"}]},
		"the notebook has no such note": {"on": "always", "do": [{"note": "unwritten"}]},
	}
	var notes := {"match_found": {"kind": "hint", "world": "tiny", "links": []}, "lost": {"kind": "hint", "world": "tiny", "links": []}}
	_check(RuleCheck.errors(_unstarted(_tiny_game(), _tiny_sources()), notes).is_empty(), "Sound rules are reported as wrong")
	for expected: String in slips:
		var sources := _tiny_sources()
		sources.tiny.rules.append(slips[expected])
		var found := RuleCheck.errors(_unstarted(_tiny_game(), sources), notes)
		_check(found.size() == 1 and expected in found[0], "Slip '%s' is not reported exactly once: %s" % [expected, found])

	var sources := _tiny_sources()
	sources.tiny.faults.append({"id": "lamp", "fixed_if": [{"object": "lamp", "state": "lit"}], "restores": []})
	_check(RuleCheck.errors(_unstarted(_tiny_game(), sources)).size() == 1, "Fault with a used id is not reported")
	var game := _tiny_game()
	game.on_start.append({"break": "attic"})
	_check(RuleCheck.errors(_unstarted(game, _tiny_sources())).size() == 1, "Slip in the start effects is not reported")


func _test_texts() -> void:
	# Every text the worlds refer to has to exist, in every language.
	var needed := {}
	var game: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/game.json"))
	for world_id: String in game.worlds:
		var world := World.from_file(Session.WORLD_DIR + world_id + ".json")
		for rule in world.rules:
			for effect: Dictionary in rule.get("do", []):
				if effect.has("say"):
					needed[effect["say"]] = true
					needed["name." + effect.get("who", "self")] = true
		needed["world." + world_id] = true
	for key: String in ["start.advice", "start.begin", "notebook.title", "notebook.empty", "notebook.links", "notebook.unknown",
		"pause.title", "pause.volume", "pause.language", "pause.new_game", "pause.continue", "pause.confirm",
		"pause.confirm_yes", "pause.confirm_no",
	]:
		needed[key] = true
	var notes := Notebook.read()
	_check(Notebook.errors(notes).is_empty(), "Notes have errors: %s" % [Notebook.errors(notes)])
	for note: String in notes:
		needed["note.%s.title" % note] = true
		needed["note.%s.text" % note] = true
		needed["kind." + notes[note].kind] = true
		needed["world." + notes[note].world] = true
	var found: Array[String] = ["old_man", "nonsense", "village"]
	var entries := Notebook.entries(notes, found)
	_check(entries.size() == 2 and entries[0].id == "old_man", "Notebook does not list the found notes in order")
	_check(entries[0].links.slice(0, 2) == [{"id": "village", "known": true}, {"id": "evening_walks", "known": false}], "Links do not tell known from unknown notes")

	var reference := Texts.read(Texts.LANGUAGES[0]).keys()
	reference.sort()
	_check(not reference.is_empty(), "No texts found")
	for language: String in Texts.LANGUAGES:
		var texts := Texts.read(language)
		var keys := texts.keys()
		keys.sort()
		_check(keys == reference, "Language '%s' does not have the same texts as '%s'" % [language, Texts.LANGUAGES[0]])
		for key: String in needed:
			_check(texts.has(key), "Text '%s' is missing in language '%s'" % [key, language])
	Texts.use("de")
	_check(Texts.language == "de" and Texts.text("name.old_man") == "Alter Mann", "German texts are not used")
	Texts.use("xx")
	_check(Texts.language == "en", "Unknown language does not fall back to English")
	_check(Texts.lines("old_man.first").size() == 4, "Lines of a dialogue are not read")
	_check(Texts.text("no.such.text") == "no.such.text", "Missing text does not show as its key")


func _test_settings() -> void:
	var path := "user://test_settings.json"
	SaveFile.delete(path)
	var settings := Settings.read(path)
	_check(settings.music_volume == 1.0 and settings.language.is_empty(), "Settings do not start with their normal values")
	settings.music_volume = 0.25
	settings.language = "de"
	settings.write()
	var loaded := Settings.read(path)
	_check(loaded.music_volume == 0.25 and loaded.language == "de", "Settings are not kept")
	SaveFile.write(path, {"music_volume": "loud", "language": 7})
	loaded = Settings.read(path)
	_check(loaded.music_volume == 1.0 and loaded.language.is_empty(), "Spoilt settings are taken over")
	SaveFile.write(path, {"music_volume": 5.0})
	_check(Settings.read(path).music_volume == 1.0, "Volume beyond the range is not limited")
	SaveFile.delete(path)
	# Without a file nothing is written.
	Settings.read("").write()


## Plays the story across the worlds the way it is meant to go, and checks that every step has
## its effect in the other worlds.
func _test_story() -> void:
	var game: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/game.json"))
	var session := Session.create(game)
	var use := func(cell: Vector2i, object_id: String) -> Array:
		session.state.cell = cell
		return session.interact(object_id)

	_check(use.call(Vector2i(15, 13), "arch")[0].get("say") == "arch.closed", "Arch is open before the lanterns burn")
	use.call(Vector2i(11, 9), "rock_bridge")
	for lantern: String in ["lantern_west", "lantern_bridge", "lantern_east"]:
		use.call(session.world().cells_beside(session.world().get_object(lantern))[0], lantern)
	_check(session.world().get_object("arch").state == "open", "Arch does not open when the lanterns burn")
	_check(session.open_faults("village") == ["brook", "wind"], "Village faults do not depend on the other worlds")

	use.call(Vector2i(15, 13), "arch")
	_check(session.state.world == "mill_hill", "Arch of the village does not lead to the mill hill")
	_check(session.mood().wind == 0.0, "There is wind on the mill hill although the mill stands still")
	_check(use.call(Vector2i(8, 5), "mill")[0].get("say") == "mill.stuck", "Mill turns without its crank")
	use.call(Vector2i(10, 6), "miller")
	_check(session.state.facts.get("crank_known", false), "Miller does not tell about the crank")

	use.call(Vector2i(11, 10), "arch_spring")
	_check(session.state.world == "spring", "Arch of the mill hill does not lead to the spring")
	_check(not session.world().is_walkable(Vector2i(7, 7)), "Brook can be crossed without the raft")
	_check(session.enter(Vector2i(6, 7)).size() >= 3, "Missing raft is not noticed")
	use.call(Vector2i(3, 7), "arch_back")
	_check(session.state.world == "village", "Wrongly joined arch of the spring does not lead to the village")

	session.state.world = "house_inside"
	_check(use.call(Vector2i(2, 2), "cupboard").size() >= 3 and "crank" in session.state.items, "Crank is not in the cupboard")
	_check(use.call(Vector2i(2, 2), "cupboard").is_empty(), "Crank can be taken twice")

	session.state.world = "mill_hill"
	use.call(Vector2i(8, 5), "mill")
	_check(session.open_faults("mill_hill") == ["lantern"], "Mill does not turn with the crank")
	_check(session.open_faults("village") == ["brook"], "Turning mill does not bring the wind back to the village")
	_check(session.world("spring").get_object("raft").cell == Vector2i(7, 7), "Turning mill does not drive the raft back")
	use.call(Vector2i(5, 6), "mill_lantern")

	session.state.world = "spring"
	_check(not session.world().find_path(Vector2i(4, 7), Vector2i(9, 5)).is_empty(), "Raft does not carry across the brook")
	use.call(Vector2i(9, 5), "sluice")
	_check(session.open_faults("village").is_empty(), "Open sluice does not let the village brook run right")
	use.call(Vector2i(3, 7), "arch_back")
	_check(session.state.world == "mill_hill", "Arch of the spring is still wrongly joined")
	_check(session.is_complete(), "Story ends with open faults")


func _test_save_file() -> void:
	var path := "user://test_save.json"
	SaveFile.delete(path)
	_check(SaveFile.read(path) == null, "Missing save file is not reported as missing")

	var session := Session.create(_tiny_game(), _tiny_sources())
	session.enter(Vector2i(1, 0))
	session.interact("gate")
	_check(SaveFile.write(path, session.state.to_data()), "Save file cannot be written")
	var continued := Session.resume(_tiny_game(), SaveFile.read(path), _tiny_sources())
	_check(continued != null and continued.state.key() == session.state.key(), "Game read from a file differs from the saved one")
	_check(continued != null and continued.open_faults() == ["lamp"], "Game read from a file loses fixed faults")

	# Saving again replaces the file.
	session.enter(Vector2i(2, 0))
	SaveFile.write(path, session.state.to_data())
	_check(GameState.from_data(SaveFile.read(path)).cell == Vector2i(2, 0), "Second save does not replace the first")
	_check(not FileAccess.file_exists(path + ".tmp"), "Draft of the save file is left behind")

	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{\"version\": 1, \"world\": ")
	file.close()
	_check(Session.resume(_tiny_game(), SaveFile.read(path), _tiny_sources()) == null, "Half-written save file is accepted")

	# A save the game cannot use is set aside, so the next save does not overwrite it.
	SaveFile.set_aside(path)
	_check(not FileAccess.file_exists(path), "Unusable save file stays in place")
	_check(FileAccess.get_file_as_string(path + SaveFile.UNUSABLE).begins_with("{\"version\": 1"), "Unusable save file is not kept")
	SaveFile.write(path, session.state.to_data())
	SaveFile.set_aside(path)
	_check(GameState.from_data(SaveFile.read(path + SaveFile.UNUSABLE)) != null, "A save set aside earlier is not replaced")
	SaveFile.set_aside(path)
	SaveFile.delete(path + SaveFile.UNUSABLE)
	SaveFile.delete(path)

	for track: String in ["village_theme", "room_theme", "mill_theme", "spring_theme"]:
		var music: AudioStreamMP3 = load("res://assets/music/%s.mp3" % track)
		_check(music.loop, "Track '%s' does not loop" % track)


func _test_village_game() -> void:
	var game: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/game.json"))
	var session := Session.create(game)
	var world := session.world()
	_check(world.errors().is_empty(), "Broken village has data errors: %s" % [world.errors()])
	_check(session.open_faults().size() == world.faults.size(), "Not every fault is open in the broken village")
	_check(world.find_path(world.start, Vector2i(16, 9)).is_empty(), "Rock does not block the bridge")
	var slips := RuleCheck.errors(session, Notebook.read())
	_check(slips.is_empty(), "Rules have errors:\n  %s" % "\n  ".join(slips))
	_check(_use(session, "stranger")[0].get("say") == "stranger.lanterns", "Woman does not tell about the lanterns")
	var remembered := world.differences()
	_check(remembered.size() == world.broken.size(), "Memory does not show every changed object")
	_check(remembered.any(func(o: WorldObject) -> bool: return o.id == "rock_bridge" and o.cell == Vector2i(11, 8)), "Memory does not show where the rock belongs")
	_check(session.remembered_mood().wind > 0.0, "Remembered mood is not the intact one")

	var result := Solver.check(game)
	print("village: %d states, solution: %s" % [result.states, ", ".join(result.solution)])
	_check(result.complete, "Search through the game was given up")
	_check(result.solvable, "Game cannot be completed")
	_check(result.dead_ends == 0, "Game has %d dead ends, for example: %s" % [result.dead_ends, result.dead_end])

	# Doors: the wrong village swaps them, the repaired one leads inside.
	session.state.cell = Vector2i(4, 7)
	session.interact("house_west")
	_check(session.state.world == "village" and session.state.cell == Vector2i(10, 6), "Wrong door does not lead to the other house")
	session.interact("house_mid")
	_check(session.state.cell == Vector2i(4, 7), "Wrong door of the other house does not lead back")
	for world_id: String in ["village", "mill_hill", "spring"]:
		session.apply([{"restore": world_id}], world_id)
	session.interact("house_west")
	_check(session.state.world == "house_inside", "Door of the repaired village does not lead inside")
	_check(session.world().errors().is_empty(), "Room has data errors: %s" % [session.world().errors()])
	session.state.cell = Vector2i(3, 2)
	_check(session.interact("old_man")[0].get("say") == "old_man.first", "Old man does not greet the player")
	_check(_use(session, "old_man")[0].get("say") == "old_man.take_it", "Old man does not point to the notebook")
	session.state.cell = Vector2i(4, 2)
	_check("notebook" not in session.state.items, "Player has the notebook before taking it")
	session.interact("table")
	_check("notebook" in session.state.items and session.world().get_object("table").state == "", "Notebook cannot be taken from the table")
	_check(session.interact("table").is_empty(), "Notebook can be taken twice")
	_check(session.world().differences().is_empty(), "Taking the notebook counts as something the break changed")
	_check(_use(session, "old_man")[0].get("say") == "old_man.whole", "Old man does not notice the repaired village")
	for world_id: String in ["village", "mill_hill", "spring"]:
		session.apply([{"break": world_id}], world_id)
	_check(_use(session, "old_man")[0].get("say") == "old_man.hint_wind", "Old man gives no hint about the wind")
	_check(session.mood().wind < 0.0, "Room does not share the mood of the village")
	session.enter(Vector2i(2, 5))
	_check(session.state.world == "village" and session.state.cell == Vector2i(4, 7), "Leaving the room does not lead back in front of the door")
	_check(world.cells_beside(world.get_object("house_mid")) == [Vector2i(10, 6)], "House can be used from a cell other than its door")

	for world_id: String in game.worlds:
		var intact := Session.create({"start": world_id, "worlds": game.worlds})
		_check(intact.world().errors().is_empty(), "World '%s' has data errors: %s" % [world_id, intact.world().errors()])
		_check(intact.open_faults().is_empty(), "Intact world '%s' has open faults: %s" % [world_id, intact.open_faults()])
		_check(intact.world().differences().is_empty(), "Intact world '%s' differs from itself" % world_id)
