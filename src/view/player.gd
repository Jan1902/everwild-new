class_name Player
extends Node2D
## The player character. Walks a path of cells and reports every cell it reaches.
##
## There are images from the front and from behind, both looking to the right. Mirrored, they
## cover the other two directions. Each view has a standing image and four frames of a walk cycle.

signal cell_reached(cell: Vector2i)

## Cells per second.
const SPEED := 3.5
const IMAGE_DIR := "res://assets/objects/"
## Placement of the images, as in ObjectView.IMAGES.
const LAYOUT := {"width": 44.0, "foot": Vector2(0.5, 0.96)}
const BASE_RADIUS := 19.0
## The frames of the walk cycle are wider than the standing image, to leave room for the stride.
## Has to match WIDTH_FACTOR in tools/walk_images.py.
const WALK_WIDTH := 1.4
const WALK_FRAMES := 4
## Frames per second of the walk cycle.
const WALK_SPEED := 7.0

## Cell reached most recently.
var cell := Vector2i.ZERO
## Shadow of the character for the shadow layer. It follows the character by itself.
var shadow := Node2D.new()

var _exact := Vector2.ZERO
var _path: Array[Vector2i] = []
var _stride := 0.0
var _body := Node2D.new()
var _front: Sprite2D
var _back: Sprite2D
## Sprite and frames of the walk cycle for each view.
var _walking_front: Sprite2D
var _walking_back: Sprite2D
var _frames_front: Array[Texture2D] = []
var _frames_back: Array[Texture2D] = []
var _towards_viewer := true
var _cast_front: Sprite2D
var _cast_back: Sprite2D


func _init() -> void:
	add_child(_body)
	_front = ObjectView.build_image(load(IMAGE_DIR + "player_front.png"), LAYOUT, false)
	_back = ObjectView.build_image(load(IMAGE_DIR + "player_back.png"), LAYOUT, false)
	_body.add_child(_front)
	_body.add_child(_back)
	for number in range(1, WALK_FRAMES + 1):
		_frames_front.append(load(IMAGE_DIR + "player_front_walk_%d.png" % number))
		_frames_back.append(load(IMAGE_DIR + "player_back_walk_%d.png" % number))
	var walk_layout := {"width": LAYOUT.width * WALK_WIDTH, "foot": LAYOUT.foot}
	_walking_front = ObjectView.build_image(_frames_front[0], walk_layout, false)
	_walking_back = ObjectView.build_image(_frames_back[0], walk_layout, false)
	_body.add_child(_walking_front)
	_body.add_child(_walking_back)

	var base := Sprite2D.new()
	base.texture = ObjectView.base_blob()
	base.modulate = BoxShadow.COLOR
	base.scale = Vector2(1.0, 0.5) * (BASE_RADIUS * 2.0 / base.texture.get_width())
	shadow.add_child(base)
	_cast_front = _front.duplicate()
	_cast_back = _back.duplicate()
	for cast: Sprite2D in [_cast_front, _cast_back]:
		cast.material = ObjectView.shadow_material()
		shadow.add_child(cast)
	_show_look(false)


func place(new_cell: Vector2i) -> void:
	cell = new_cell
	_exact = Vector2(new_cell)
	_path.clear()
	position = Iso.to_point(_exact)
	shadow.position = position


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
	if _path.is_empty():
		return
	_stride += delta * WALK_SPEED
	var remaining := SPEED * delta
	while remaining > 0.0 and not _path.is_empty():
		var target := Vector2(_path[0])
		var distance := _exact.distance_to(target)
		if distance <= remaining:
			_exact = target
			remaining -= distance
			cell = _path.pop_front()
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
		_body.scale.x = -1.0 if step.x < 0.0 else 1.0
	if _path.is_empty():
		_stride = 0.0
	_show_look(not _path.is_empty())


## Shows the image that fits the direction and whether the character is walking.
func _show_look(walking: bool) -> void:
	var frame := int(_stride) % WALK_FRAMES
	_walking_front.texture = _frames_front[frame]
	_walking_back.texture = _frames_back[frame]
	_front.visible = _towards_viewer and not walking
	_back.visible = not _towards_viewer and not walking
	_walking_front.visible = _towards_viewer and walking
	_walking_back.visible = not _towards_viewer and walking
	_cast_front.visible = _towards_viewer
	_cast_back.visible = not _towards_viewer
	for cast: Sprite2D in [_cast_front, _cast_back]:
		cast.flip_h = _body.scale.x < 0.0