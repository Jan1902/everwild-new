class_name WindView
extends Node2D
## Makes the wind of a world visible: faint streaks that drift across the picture the way the
## wind blows, more and faster the harder it does. Behind tall things lies their lee, where no
## streak goes; that is how one sees what shelters a flame.

## Streaks on screen for a wind of strength 1, and the most there ever are.
const DENSITY := 38.0
const MOST := 64
## Pixels of the world a streak travels per second in a wind of strength 1.
const SPEED := 260.0
## Seconds a streak lives.
const LIFETIME := 2.6
const COLOR := Color(1.0, 1.0, 0.96)
const OPACITY := 0.7
## The wind that blows the right way is a breeze: its streaks are this much fainter than those
## of a wind that blows the wrong way.
const BREEZE := 0.5
const WIDTH := 3.0
## A streak is a short wavy line: its points, and how far it sways up and down.
const POINTS := 8
const SWAY := 5.0
## Kinds that stop the wind, with half their width and their height in pixels of the world.
const SHELTERS := {"cart": Vector2(58, 136), "house": Vector2(140, 210), "mill": Vector2(140, 300)}
## How far the lee reaches behind a shelter, and how fast a streak dies in it and recovers
## outside it (per second).
const LEE_LENGTH := 170.0
const CALMING := 7.0
const RECOVERY := 1.5

## Direction and strength of the wind, from the mood of the world. Positive blows to the right.
var wind := 0.0

## Object id -> view, as the stage keeps it. The shelters among them are looked up every frame,
## since they move and are rebuilt.
var _views: Dictionary
var _streaks: Array[Dictionary] = []
var _time := 0.0


func _init(views: Dictionary) -> void:
	_views = views


func _process(delta: float) -> void:
	_time += delta
	var strength := absf(wind)
	var wanted := mini(int(DENSITY * strength), MOST)
	var area := _visible_area()
	var lees := _lees()
	while _streaks.size() > wanted:
		_streaks.pop_back()
	while _streaks.size() < wanted:
		# New ones start at any age, so they do not all appear and fade together.
		_streaks.append(_new_streak(area, lees, randf()))

	var direction := signf(wind)
	for number in _streaks.size():
		var streak := _streaks[number]
		streak.head.x += direction * SPEED * strength * streak.pace * delta
		streak.age += delta / LIFETIME
		var sheltered := lees.any(func(lee: Rect2) -> bool: return lee.has_point(streak.head))
		streak.calm = move_toward(streak.calm, 1.0 if sheltered else 0.0, (CALMING if sheltered else RECOVERY) * delta)
		if streak.age >= 1.0 or not area.has_point(streak.head):
			_streaks[number] = _new_streak(area, lees, 0.0)
	queue_redraw()


func _draw() -> void:
	var direction := signf(wind)
	var opacity := OPACITY * (BREEZE if wind > 0.0 else 1.0)
	for streak in _streaks:
		var strength: float = sin(streak.age * PI) * (1.0 - streak.calm) * opacity
		if strength <= 0.01:
			continue
		var points := PackedVector2Array()
		var colors := PackedColorArray()
		for point in POINTS:
			var along := float(point) / (POINTS - 1)
			var sway := sin(streak.phase + along * 3.0 + _time * 2.4) * SWAY
			# The head leads; the line thins out towards its tail.
			points.append(streak.head + Vector2(-direction * streak.length * along, sway))
			colors.append(Color(COLOR, strength * (1.0 - along)))
		draw_polyline_colors(points, colors, WIDTH, true)


## A streak somewhere on screen, outside every lee if one is found quickly.
func _new_streak(area: Rect2, lees: Array[Rect2], age: float) -> Dictionary:
	var head := Vector2.ZERO
	for attempt in 4:
		head = area.position + Vector2(randf(), randf()) * area.size
		if not lees.any(func(lee: Rect2) -> bool: return lee.has_point(head)):
			break
	return {
		"head": head, "age": age, "calm": 0.0, "phase": randf() * TAU,
		"length": randf_range(90.0, 170.0), "pace": randf_range(0.75, 1.25),
	}


## The part of the world that is on screen, with a margin.
func _visible_area() -> Rect2:
	return (get_canvas_transform().affine_inverse() * get_viewport_rect()).grow(120.0)


## The lee of every shelter: the shelter itself and the stretch behind it, seen from the wind.
func _lees() -> Array[Rect2]:
	var lees: Array[Rect2] = []
	for view: ObjectView in _views.values():
		if not is_instance_valid(view) or not view.visible or not SHELTERS.has(view.kind):
			continue
		var bulk: Vector2 = SHELTERS[view.kind]
		var left := view.position.x - bulk.x - (LEE_LENGTH if wind < 0.0 else 0.0)
		var right := view.position.x + bulk.x + (LEE_LENGTH if wind > 0.0 else 0.0)
		lees.append(Rect2(left, view.position.y - bulk.y, right - left, bulk.y + 26.0))
	return lees
