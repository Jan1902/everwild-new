class_name Player
extends Node2D
## The player character. Walks a path of cells and reports every cell it reaches.
##
## There are images from the front and from behind, both looking to the right. Mirrored, they
## cover the other two directions. Each view has a standing image and the frames of a walk cycle.

signal cell_reached(cell: Vector2i)

## Cells per second.
const SPEED := 3.5
## Frames per second of the walk cycle.
const WALK_SPEED := 7.0
const VIEWS := ["front", "back"]
## How far the standing image is tipped over while the character lies on the ground, and seconds
## the character takes to get up.
const LYING := -PI * 0.5
const GET_UP_DURATION := 1.6

## Cell reached most recently.
var cell := Vector2i.ZERO
## Shadow of the character for the shadow layer. It follows the character by itself.
var shadow := Node2D.new()

var _exact := Vector2.ZERO
var _path: Array[Vector2i] = []
var _body := AnimatedSprite2D.new()
## Animation -> where its images have to sit (see Sprites.placement). The frames of the walk
## cycle are wider than the standing image, to leave room for the stride.
var _placements := {}
var _towards_viewer := true
var _facing_left := false
## View -> the standing image as the shadow it casts.
var _casts := {}
## Seconds the character has been around, for breathing.
var _time := 0.0


func _init(sprites: Sprites) -> void:
	var layout := sprites.player
	var walk_layout := {"width": layout.width * sprites.walk_width, "foot": layout.foot}
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	shadow.add_child(sprites.build_base(layout.base))
	for view: String in VIEWS:
		var standing: Texture2D = load(sprites.image_path("player_" + view))
		frames.add_animation("stand_" + view)
		frames.add_frame("stand_" + view, standing)
		_placements["stand_" + view] = sprites.placement(standing, layout)

		frames.add_animation("walk_" + view)
		frames.set_animation_speed("walk_" + view, WALK_SPEED)
		for number in range(1, sprites.walk_frames + 1):
			frames.add_frame("walk_" + view, load(sprites.image_path("player_%s_walk_%d" % [view, number])))
		_placements["walk_" + view] = sprites.placement(frames.get_frame_texture("walk_" + view, 0), walk_layout)

		var cast := sprites.build_image(standing, layout)
		sprites.make_cast(cast, sprites.shadow_material())
		shadow.add_child(cast)
		_casts[view] = cast
	_body.sprite_frames = frames
	_body.centered = false
	add_child(_body)
	_show_look()


func place(new_cell: Vector2i) -> void:
	cell = new_cell
	_exact = Vector2(new_cell)
	_path.clear()
	position = Iso.to_point(_exact)
	shadow.position = position
	_show_look()


## Lays the character on the ground where it is. There is no image of that; the standing one is
## tipped over at the feet.
func lie_down() -> void:
	_body.rotation = LYING
	shadow.visible = false


func is_lying() -> bool:
	return _body.rotation != 0.0


## Lets the character get up. Returns the movement.
func get_up() -> Tween:
	var rising := create_tween()
	rising.tween_property(_body, "rotation", 0.0, GET_UP_DURATION).set_trans(Tween.TRANS_SINE)
	rising.tween_callback(shadow.show)
	return rising


## Cell a new path has to start from: the target of the step in progress.
func next_stop() -> Vector2i:
	return cell if _path.is_empty() else _path[0]


func is_walking() -> bool:
	return not _path.is_empty()


## Replaces the current path. The path has to start at next_stop(). An empty path stops the
## character on the cell it reaches next.
func walk(path: Array[Vector2i]) -> void:
	# A character standing exactly on the first cell has reached it already.
	if not path.is_empty() and Vector2(path[0]) == _exact:
		path = path.slice(1)
	_path = path


func _process(delta: float) -> void:
	_time += delta
	if _path.is_empty():
		_breathe()
		return
	var remaining := SPEED * delta
	while remaining > 0.0 and not _path.is_empty():
		var target := Vector2(_path[0])
		var distance := _exact.distance_to(target)
		if distance <= remaining:
			_exact = target
			remaining -= distance
			cell = _path.pop_front()
			# Whoever listens may give the character another path.
			cell_reached.emit(cell)
		else:
			_exact = _exact.move_toward(target, remaining)
			remaining = 0.0
	var step := Iso.to_point(_exact) - position
	position += step
	shadow.position = position
	# Sideways steps keep front or back as it was, steps straight up or down keep the side.
	if absf(step.y) >= 0.01:
		_towards_viewer = step.y > 0.0
	if absf(step.x) >= 0.01:
		_facing_left = step.x < 0.0
	_show_look()


## Standing, the character breathes like the people of the world (see FigureLife).
func _breathe() -> void:
	var placed: Dictionary = _placements[_body.animation]
	var breath := sin(_time * TAU * FigureLife.BREATH_SPEED)
	var side := -1.0 if _facing_left else 1.0
	_body.scale = placed.scale * Vector2(side * (1.0 - FigureLife.BREATH * 0.5 * breath), 1.0 + FigureLife.BREATH * breath)


## Shows the animation that fits the direction and whether the character is walking.
func _show_look() -> void:
	var view: String = VIEWS[0] if _towards_viewer else VIEWS[1]
	var look := ("walk_" if is_walking() else "stand_") + view
	if _body.animation != look:
		# Turning in mid-stride keeps the stride.
		var in_stride := is_walking() and _body.animation.begins_with("walk_")
		var frame := _body.frame
		var progress := _body.frame_progress
		_body.play(look)
		if in_stride:
			_body.set_frame_and_progress(frame, progress)
	var placed: Dictionary = _placements[look]
	_body.offset = placed.offset
	_body.scale = placed.scale * Vector2(-1.0 if _facing_left else 1.0, 1.0)
	for cast_view: String in _casts:
		_casts[cast_view].visible = cast_view == view
		_casts[cast_view].flip_h = _facing_left
