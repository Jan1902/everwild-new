class_name FigureLife
extends Node
## Makes a person in the world look alive without changing anything in the game: they breathe,
## turn towards the player who comes near, bob while they speak, glance about now and then and,
## where the world gives them a stroll, walk it while nobody needs them.
##
## A stroll is only for the place a person has on a good evening (the first cell of their
## "stroll" in the world file). Somewhere else they stand still: after the Rift people wait where
## something comes back to them, and walking again is what they do once their piece is whole.
## Whenever the player comes near, they walk back to their place and face them, so taps and
## talking always happen where the game has them.
##
## People with frames of a walk cycle (<kind>_front_walk_<n> and <kind>_back_walk_<n>) use them;
## the others glide along with a little bob in their step.

## Cells per second when strolling, and the cells around the player within which people stay
## at their place.
const STROLL_SPEED := 1.1
const NEAR := 3
## Seconds people rest at each end of a stroll, at least and at most.
const REST := Vector2(2.5, 5.0)
## Breathing: breaths per second and how far the figure rises.
const BREATH_SPEED := 0.3
const BREATH := 0.014
## A turn is a flip with a little hop: squeezing the image through nothing showed it as the flat
## picture it is (Jan). Seconds the hop takes and how high it goes, and seconds between glances
## about, at least and at most.
const TURN := 0.22
const TURN_HOP := 3.0
const GLANCE := Vector2(5.0, 11.0)
## Frames per second of a walk cycle and the pixels of bob in a gliding step.
const WALK_FPS := 6.0
const BOB := 4.0

## Where the player is, in points of the world, and whether this person is speaking.
var player_point := Vector2.INF
var speaking := false

var _view: Node2D
var _image: Sprite2D
var _sprites: Sprites
var _layout := {}
var _standing: Texture2D
## View ("front", "back") -> frames of the walk cycle. Empty without frames.
var _frames := {}
## Which way the standing image and each view's walk frames face, true for left.
var _faces_left := true
var _walk_faces := {"front": true, "back": false}
## Which way the person faces now, and how far the hop of the last turn has come (0 to 1).
var _facing_left := true
var _turn := 1.0
var _time := 0.0
var _phase := 0.0
var _home := Vector2.ZERO
var _route: Array[Vector2] = []
var _route_index := 0
var _route_step := 1
## Where the person is walking to, and the rest of the way after that. Empty while standing.
var _way: Array[Vector2] = []
var _speed := STROLL_SPEED
var _walk_time := 0.0
var _view_name := "front"
var _rest := 0.0
var _glance := 0.0
## Called when a walk asked for by walk() has arrived.
var _arrived := Callable()


## Sets the life up for a view whose image stands at its foot. stroll lists the cells of the
## stroll (the first is the person's place), empty for none.
func setup(view: Node2D, image: Sprite2D, sprites: Sprites, kind: String, mirrored: bool, stroll: Array[Vector2i]) -> void:
	_view = view
	_image = image
	_sprites = sprites
	_layout = sprites.layout(kind)
	_standing = image.texture
	_faces_left = _layout.get("faces", "right") == "left"
	_facing_left = _faces_left != mirrored
	var walk: Dictionary = _layout.get("walk", {})
	for view_name: String in ["front", "back"]:
		_walk_faces[view_name] = walk.get(view_name, "left" if view_name == "front" else "right") == "left"
		var frames: Array[Texture2D] = []
		for number in range(1, sprites.walk_frames + 1):
			var path := sprites.image_path("%s_%s_walk_%d" % [kind, view_name, number])
			if path.is_empty():
				break
			frames.append(load(path))
		if frames.size() == sprites.walk_frames:
			_frames[view_name] = frames
	_home = view.position
	_phase = randf() * TAU
	_glance = randf_range(GLANCE.x, GLANCE.y)
	if not stroll.is_empty() and Iso.to_cell(_home) == stroll[0]:
		for cell in stroll:
			_route.append(Iso.to_point(Vector2(cell)))
		_rest = randf_range(REST.x, REST.y)


## Walks the person along points of the world at the given cells per second, then calls
## arrived. A stroll in progress is given up.
func walk(points: Array[Vector2], speed: float, arrived := Callable()) -> void:
	_route.clear()
	_way = points.duplicate()
	# Where a scene sends someone, they stay.
	if not points.is_empty():
		_home = points[-1]
	_speed = speed
	_arrived = arrived


## The person's place has moved, because the game has put them somewhere else: they walk there
## and stay. stroll is the one of the object, which only counts if the new place is its first cell.
func go_home(point: Vector2, stroll: Array[Vector2i]) -> void:
	_home = point
	_route.clear()
	_route_index = 0
	_route_step = 1
	if not stroll.is_empty() and Iso.to_cell(point) == stroll[0]:
		for cell in stroll:
			_route.append(Iso.to_point(Vector2(cell)))
		_rest = randf_range(REST.x, REST.y)
	_way = [point]
	_speed = STROLL_SPEED * 1.4


func is_walking() -> bool:
	return not _way.is_empty()


## Turns the person towards a point of the world, unless they already face that way.
func face(point: Vector2) -> void:
	if absf(point.x - _view.position.x) > 4.0:
		_turn_to(point.x < _view.position.x)


func _process(delta: float) -> void:
	_time += delta
	if not _way.is_empty():
		_step(delta)
	else:
		_stand(delta)
	_show()


func _stand(delta: float) -> void:
	var near := player_point != Vector2.INF and _cells_apart(player_point, _home) <= NEAR
	if speaking or near:
		# Back to their place and towards the player.
		if _view.position.distance_to(_home) > 2.0:
			_way = [_home]
			_speed = STROLL_SPEED * 1.4
			_route_index = 0
			_route_step = 1
			return
		if player_point != Vector2.INF:
			face(player_point)
		_rest = maxf(_rest, REST.x)
		return
	if _route.size() > 1:
		_rest -= delta
		if _rest <= 0.0:
			if _route_index + _route_step >= _route.size() or _route_index + _route_step < 0:
				_route_step = -_route_step
			_route_index += _route_step
			_way = [_route[_route_index]]
			_speed = STROLL_SPEED
			_rest = randf_range(REST.x, REST.y)
		return
	# Now and then a glance the other way, and back.
	_glance -= delta
	if _glance <= 0.0:
		_glance = randf_range(GLANCE.x, GLANCE.y)
		var back := _facing_left
		_turn_to(not _facing_left)
		get_tree().create_timer(randf_range(1.2, 2.2)).timeout.connect(func() -> void:
			if _way.is_empty() and not speaking:
				_turn_to(back)
		)


func _step(delta: float) -> void:
	var target := _way[0]
	var pace := _speed * Iso.CELL.x * 0.5 * delta
	var to_go := target - _view.position
	if to_go.length() <= pace:
		_move_to(target)
		_way.pop_front()
		if _way.is_empty():
			_walk_time = 0.0
			if _arrived.is_valid():
				var arrived := _arrived
				_arrived = Callable()
				arrived.call()
		return
	_move_to(_view.position + to_go.normalized() * pace)
	_walk_time += delta
	if absf(to_go.y) > 0.5:
		_view_name = "front" if to_go.y > 0.0 else "back"
	if absf(to_go.x) > 0.5:
		_set_facing(to_go.x < 0.0)


func _move_to(point: Vector2) -> void:
	var shift := point - _view.position
	_view.position = point
	var shadow: Node2D = _view.get("shadow")
	if shadow:
		shadow.position += shift


## Shows the right image, flipped the right way, breathing, bobbing or walking.
func _show() -> void:
	var walking := not _way.is_empty()
	var texture := _standing
	var faces := _faces_left
	var layout := _layout
	if walking and _frames.has(_view_name):
		var frames: Array = _frames[_view_name]
		texture = frames[int(_walk_time * WALK_FPS) % frames.size()]
		faces = _walk_faces[_view_name]
		layout = {"width": _layout.width * _sprites.walk_width, "foot": _layout.foot}
	var flipped := faces != _facing_left
	var placed := _sprites.placement(texture, layout, flipped)
	_image.texture = texture
	_image.flip_h = flipped
	_image.offset = placed.offset
	var breath := sin(_time * TAU * BREATH_SPEED + _phase)
	var scale: Vector2 = placed.scale
	_image.scale = Vector2(scale.x * (1.0 - BREATH * 0.5 * breath), scale.y * (1.0 + BREATH * breath))
	_turn = minf(1.0, _turn + get_process_delta_time() / TURN)
	var lift := 0.0
	if walking and not _frames.has(_view_name):
		lift = absf(sin(_walk_time * TAU * 1.6)) * BOB
		_image.rotation = sin(_walk_time * TAU * 1.6) * 0.04
	else:
		_image.rotation = 0.0
	if speaking:
		lift += absf(sin(_time * 7.0)) * 2.5
	lift += sin(_turn * PI) * TURN_HOP
	_image.position.y = _layout.get("offset", Vector2.ZERO).y - lift


func _turn_to(left: bool) -> void:
	if left == _facing_left:
		return
	_set_facing(left)
	_turn = 0.0


func _set_facing(left: bool) -> void:
	_facing_left = left


static func _cells_apart(a: Vector2, b: Vector2) -> int:
	var difference := Iso.to_cell(a) - Iso.to_cell(b)
	return maxi(absi(difference.x), absi(difference.y))
