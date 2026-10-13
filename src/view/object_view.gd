class_name ObjectView
extends Node2D
## Shows an object of the world: as a painted image if there is one, otherwise as a drawn placeholder.

## States in which an object with a light is dark.
const UNLIT_STATES := ["out", "closed", "dark"]
## Radians per second of turning windmill sails.
const SAILS_SPEED := 0.7
## States in which the sails of a mill turn, and which way.
const SAILS_TURNING := {"turning": 1.0, "backwards": -1.0}
## Placeholders that hang in the sky: a tap never means them.
const UNTOUCHABLE := ["distant_light"]
## How far an arrow is turned that points along the grid, by the state of its object. Its image
## points along the x axis of the grid.
const ARROW_TURNS := {"east": 0.0, "south": 0.25, "west": 0.5, "north": 0.75}
const LIGHT_COLOR := Color(1.0, 0.78, 0.42)
## Colour laid over a lantern that is out.
const UNLIT := Color(0.62, 0.66, 0.78)
## Where the notebook lies on the table, relative to the table's foot.
const NOTEBOOK_SPOT := Vector2(-12, -38)
## Seconds an object takes to slide to another cell.
const MOVE_DURATION := 0.45

var kind := ""
var size := Vector2i.ONE
## Shadow of the object for the shadow layer, made by build_shadow(). Null if it casts none.
var shadow: Node2D
## Brightness of the object's light, from the mood of the world.
var light := 1.0

var _sprites: Sprites
var _shown: WorldObject
var _layout := {}
var _image: Sprite2D
var _box_shadow: BoxShadow
var _glow: Sprite2D
var _sails: Sprite2D
var _flicker := 0.0


## Sets the object up. The node sits at the centre of its footprint so that depth sorting by y
## works.
func setup(object: WorldObject, sprites: Sprites) -> void:
	_sprites = sprites
	_shown = object.copy()
	kind = object.kind
	size = object.size
	position = _point(object.cell)
	visible = not object.hidden
	set_process(false)

	_layout = sprites.layout(kind)
	if _layout.is_empty():
		return
	var layout := _layout
	var path := sprites.image_path(layout.get("image", kind), object.state)
	if path.is_empty():
		return
	var mirrored := object.mirrored
	var lit := object.state not in UNLIT_STATES
	_image = sprites.build_image(load(path), layout, mirrored)
	if layout.get("wind", false):
		_image.material = sprites.wind_material()
	if not lit:
		_image.modulate = UNLIT
	add_child(_image)
	if kind == "table" and object.state == "notebook":
		add_child(_build_notebook())
	var sails_path := sprites.image_path("sails")
	if layout.has("sails") and not sails_path.is_empty():
		# The sails are painted from the front. Laid into the plane of the right wall, they turn
		# like a wheel seen at an angle.
		var hub: Vector2 = layout.sails.hub
		var plane := Node2D.new()
		plane.transform = Transform2D(
			Vector2(0.87, -0.435), Vector2(0, 1), _image.position + Vector2(-hub.x if mirrored else hub.x, hub.y)
		)
		_sails = Sprite2D.new()
		_sails.texture = load(sails_path)
		_sails.scale = Vector2.ONE * (layout.sails.size / _sails.texture.get_width())
		_sails.rotation = position.x * 0.01
		plane.add_child(_sails)
		add_child(plane)
		set_process(SAILS_TURNING.has(object.state))

	var arrow_path := sprites.image_path(kind + "_arrow")
	if layout.has("arrow") and not arrow_path.is_empty():
		# The arrow is painted from above. Laid into the ground plane, it turns like a real one.
		var plane := Node2D.new()
		plane.transform = Transform2D(
			Iso.to_point(Vector2(1, 0)).normalized(), Iso.to_point(Vector2(0, 1)).normalized(),
			_image.position + layout.arrow.hub
		)
		var arrow := Sprite2D.new()
		arrow.texture = load(arrow_path)
		arrow.scale = Vector2.ONE * (layout.arrow.size / arrow.texture.get_width())
		arrow.rotation = TAU * ARROW_TURNS.get(object.state, 0.0)
		plane.add_child(arrow)
		add_child(plane)

	if layout.has("light") and lit:
		var spot: Vector2 = layout.light
		_glow = Sprite2D.new()
		_glow.texture = sprites.light_blob()
		_glow.position = _image.position + Vector2(-spot.x if mirrored else spot.x, spot.y)
		var add_material := CanvasItemMaterial.new()
		add_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		_glow.material = add_material
		_flicker = position.x * 0.05
		add_child(_glow)
		set_process(true)


## A small closed book lying on the table, drawn from a few flat areas like the painted images.
func _build_notebook() -> Node2D:
	var book := Node2D.new()
	book.position = _image.position + NOTEBOOK_SPOT
	var along := Vector2(10, 5)
	var across := Vector2(-7, 3.5)
	var thick := Vector2(0, 3)
	var top := PackedVector2Array([-along - across, along - across, along + across, -along + across])
	var parts := [
		[PackedVector2Array([top[3], top[2], top[2] + thick, top[3] + thick]), Color("efe6d0")],
		[PackedVector2Array([top[2], top[1], top[1] + thick, top[2] + thick]), Color("d9cdb2")],
		[top, Color("8c3b2e")],
	]
	for part: Array in parts:
		var area := Polygon2D.new()
		area.polygon = part[0]
		area.color = part[1]
		book.add_child(area)
	return book


## Whether the view shows the object as it is now.
func is_current(object: WorldObject) -> bool:
	return _shown.matches(object.properties())


## Slides to the object's cell if that is all that changed. Returns false if the view has to be
## built anew instead.
func follow(object: WorldObject) -> bool:
	var moved := _shown.copy()
	moved.cell = object.cell
	if not moved.matches(object.properties()):
		return false
	_shown = moved
	var target := _point(object.cell)
	var slide := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	slide.tween_property(self, "position", target, MOVE_DURATION)
	if shadow:
		slide.tween_property(shadow, "position", shadow.position + target - position, MOVE_DURATION)
	return true


## Whether the image of the object is under this point of the world.
func covers(point: Vector2) -> bool:
	if not visible:
		return false
	if _image == null:
		# Placeholders are drawn about one cell wide and a person tall.
		return kind not in UNTOUCHABLE and Rect2(-40, -84, 80, 96).has_point(point - position)
	var pixel := Vector2i((point - position - _image.position) / _image.scale - _image.offset)
	if _image.flip_h:
		pixel.x = _image.texture.get_width() - 1 - pixel.x
	return _sprites.is_painted(_image.texture, pixel)


## Builds the shadow of the object as a separate node for the shadow layer. Null if it casts none.
func build_shadow() -> Node2D:
	if _image == null or _shown.is_flat() or not visible:
		return null
	var layout := _layout
	shadow = Node2D.new()

	if layout.has("box"):
		shadow.position = position
		_box_shadow = BoxShadow.new()
		_box_shadow.size = size
		_box_shadow.wall_height = layout.box.x
		_box_shadow.ridge_height = layout.box.y
		shadow.add_child(_box_shadow)
		return shadow

	shadow.position = position + _image.position
	# Soft blob right at the foot. Without it the object looks as if it hovers above the ground.
	# Objects that stand on two legs with air in between, like an arch, have none.
	if layout.has("base"):
		shadow.add_child(_sprites.build_base(layout.base))

	var cast := _image.duplicate() as Sprite2D
	cast.position = Vector2.ZERO
	if layout.get("wall", false):
		_sprites.make_cast(cast, _sprites.wall_shadow_material(_shown.mirrored))
	else:
		_sprites.make_cast(cast, _sprites.shadow_material())
	shadow.add_child(cast)
	return shadow


## Shadows computed from the footprint follow the shadow cast of the mood. The others get it
## from the shader.
func set_shadow_cast(cast: Vector2) -> void:
	if _box_shadow:
		_box_shadow.cast = cast


func _process(delta: float) -> void:
	if _sails:
		_sails.rotation += SAILS_SPEED * SAILS_TURNING.get(_shown.state, 0.0) * delta
	if _glow == null:
		return
	_flicker += delta
	var jitter := 0.88 + 0.08 * sin(_flicker * 9.0) + 0.04 * sin(_flicker * 23.0)
	_glow.modulate = Color(LIGHT_COLOR, 0.45 * light * jitter)
	_glow.scale = Vector2.ONE * (1.0 + 0.06 * sin(_flicker * 6.0))


## Where the view is when its object stands on this cell.
func point_of(cell: Vector2i) -> Vector2:
	return _point(cell)


## Centre of the footprint of an object standing on this cell.
func _point(cell: Vector2i) -> Vector2:
	return Iso.to_point(Vector2(cell) + Vector2(size - Vector2i.ONE) * 0.5)


func _draw() -> void:
	if _image:
		return
	match kind:
		"tree":
			_draw_tree()
		"rock":
			_draw_rock()
		"house":
			_draw_house()
		"person", "old_man", "woman", "miller", "fisher":
			_draw_person(1.0)
		"child":
			_draw_person(0.68)
		"distant_light":
			_draw_glow(Vector2(-60, -150), 46.0)


func _draw_ground_shadow(radius: float) -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, radius, Color(0, 0, 0, 0.16))
	draw_set_transform(Vector2.ZERO)


func _draw_tree() -> void:
	_draw_ground_shadow(40.0)
	draw_rect(Rect2(-7, -52, 14, 54), Color("7a5a3c"))
	draw_circle(Vector2(-22, -76), 30.0, Color("4f8a55"))
	draw_circle(Vector2(24, -80), 28.0, Color("4f8a55"))
	draw_circle(Vector2(0, -98), 44.0, Color("5c9a5e"))
	draw_circle(Vector2(-10, -110), 22.0, Color("71ad6c"))


## A person as a placeholder, like the player character but in muted colours.
func _draw_person(height: float) -> void:
	_draw_ground_shadow(22.0 * height)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE * height)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-18, 0), Vector2(18, 0), Vector2(11, -54), Vector2(-11, -54)]), Color("5f6f86")
	)
	draw_circle(Vector2(-2 if _shown.mirrored else 2, -66), 14.0, Color("e6cdb0"))
	draw_arc(Vector2(0, -68), 14.0, PI, TAU, 12, Color("d9d6d0"), 5.0)
	draw_set_transform(Vector2.ZERO)


## A soft light in the distance.
func _draw_glow(centre: Vector2, radius: float) -> void:
	for ring in 5:
		draw_circle(centre, radius * (1.0 - ring * 0.18), Color(1.0, 0.78, 0.42, 0.1))


func _draw_rock() -> void:
	_draw_ground_shadow(34.0)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-34, 0), Vector2(-26, -26), Vector2(4, -38), Vector2(32, -20), Vector2(36, 2), Vector2(4, 12)]),
		Color("8d8f96")
	)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-26, -26), Vector2(4, -38), Vector2(32, -20), Vector2(2, -12)]),
		Color("a9abb1")
	)


func _draw_house() -> void:
	var half := Vector2(size) * 0.5
	# Corners of the footprint, relative to its centre: back, right, front, left.
	var back := Iso.to_point(Vector2(-half.x, -half.y))
	var right := Iso.to_point(Vector2(half.x, -half.y))
	var front := Iso.to_point(Vector2(half.x, half.y))
	var left := Iso.to_point(Vector2(-half.x, half.y))
	var up := Vector2(0, -96)
	var ridge := (back + front) * 0.5 + up + Vector2(0, -78)

	draw_colored_polygon(PackedVector2Array([left, front, front + up, left + up]), Color("d9c7a6"))
	draw_colored_polygon(PackedVector2Array([front, right, right + up, front + up]), Color("efe0c1"))
	# Door in the right wall
	var door_a := front.lerp(right, 0.4)
	var door_b := front.lerp(right, 0.62)
	draw_colored_polygon(
		PackedVector2Array([door_a, door_b, door_b + Vector2(0, -58), door_a + Vector2(0, -58)]), Color("7a5a3c")
	)
	# Roof: the two rear faces first, then the front ones
	draw_colored_polygon(PackedVector2Array([back + up, left + up, ridge]), Color("a8523f"))
	draw_colored_polygon(PackedVector2Array([back + up, right + up, ridge]), Color("b65a44"))
	draw_colored_polygon(PackedVector2Array([left + up, front + up, ridge]), Color("b65a44"))
	draw_colored_polygon(PackedVector2Array([front + up, right + up, ridge]), Color("c96a50"))
