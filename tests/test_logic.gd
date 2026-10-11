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
	print("%d checks, %d failed" % [_checks, _failures])
	quit(1 if _failures > 0 else 0)


func _check(condition: bool, what: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		print("FAILED: " + what)


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
	_check(world.player == world.start, "Character does not stand on the start cell")

	_check(not world.is_walkable(Vector2i(0, 0)), "Void is walkable")
	_check(not world.is_walkable(Vector2i(13, 8)), "Water is walkable")
	_check(world.is_walkable(Vector2i(13, 9)), "Bridge is not walkable")
	_check(not world.is_walkable(Vector2i(8, 5)), "House is walkable")
	_check(not world.is_walkable(Vector2i(9, 6)), "Second cell of the house is walkable")
	_check(not world.is_walkable(Vector2i(7, 8)), "Lantern is walkable")
	_check(world.objects.any(func(o: Dictionary) -> bool: return o.kind == "bridge"), "Village has no bridge object")
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

	_check(not world.set_player(Vector2i(13, 8)), "Character can be put into the water")
	_check(world.set_player(target) and world.player == target, "Character cannot be moved")
