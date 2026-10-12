class_name ObjectView
extends Node2D
## Shows an object of the world: as a painted image if there is one, otherwise as a drawn placeholder.

## States in which an object with a light is dark.
const UNLIT_STATES := ["out", "closed"]
## Radians per second of turning windmill sails.
const SAILS_SPEED := 0.7
## States in which the sails of a mill turn, and which way.
const SAILS_TURNING := {"turning": 1.0, "backwards": -1.0}
## Placeholders that lie on the ground or hang in the sky: a tap never means them.
const UNTOUCHABLE := ["stepping_stones", "distant_light"]
## Where a weather vane points in the grid, by its state.
const VANE_DIRECTIONS := {
	"north": Vector2(0, -1), "east": Vector2(1, 0), "south": Vector2(0, 1), "west": Vector2(-1, 0),
}
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
		cast.material = _sprites.wall_shadow_material(_shown.mirrored)
	else:
		cast.material = _sprites.shadow_material()
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
		"person", "old_man", "woman", "miller":
			_draw_person(Color("5f6f86"), 1.0)
		"fisher":
			_draw_person(Color("4f7f7a"), 1.0)
		"child":
			_draw_person(Color("b0764f"), 0.68)
		"music_box":
			_draw_music_box()
		"vane":
			_draw_vane()
		"field":
			_draw_field()
		"steps":
			_draw_steps()
		"boat":
			_draw_boat()
		"stepping_stones":
			_draw_stepping_stones()
		"big_light":
			_draw_big_light()
		"beacon":
			_draw_beacon()
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
func _draw_person(clothes: Color, height: float) -> void:
	_draw_ground_shadow(22.0 * height)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE * height)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-18, 0), Vector2(18, 0), Vector2(11, -54), Vector2(-11, -54)]), clothes
	)
	draw_circle(Vector2(-2 if _shown.mirrored else 2, -66), 14.0, Color("e6cdb0"))
	draw_arc(Vector2(0, -68), 14.0, PI, TAU, 12, Color("d9d6d0"), 5.0)
	draw_set_transform(Vector2.ZERO)


## A small box with a brass cylinder. Its lid stands open while it plays.
func _draw_music_box() -> void:
	_draw_ground_shadow(20.0)
	draw_rect(Rect2(-18, -22, 36, 22), Color("7a4a34"))
	draw_rect(Rect2(-18, -26, 36, 5), Color("96603f"))
	draw_rect(Rect2(-11, -17, 22, 7), Color("d8b45a"))
	if _shown.state == "playing":
		draw_colored_polygon(
			PackedVector2Array([Vector2(-18, -26), Vector2(18, -26), Vector2(14, -52), Vector2(-22, -52)]), Color("96603f")
		)
		for note: Vector2 in [Vector2(26, -50), Vector2(38, -70), Vector2(22, -84)]:
			draw_circle(note, 4.0, Color("fff3c4"))


## A pole with an arrow that lies in the ground plane and points where the state says.
func _draw_vane() -> void:
	_draw_ground_shadow(14.0)
	var top := Vector2(0, -110)
	draw_line(Vector2.ZERO, top, Color("5b5148"), 5.0)
	var along := Iso.to_point(VANE_DIRECTIONS.get(_shown.state, Vector2(0, -1))).normalized() * 34.0
	var across := Vector2(-along.y, along.x) * 0.35
	draw_line(top - along, top + along, Color("3d3833"), 5.0)
	draw_colored_polygon(
		PackedVector2Array([top + along * 1.45, top + along * 0.7 + across, top + along * 0.7 - across]), Color("b8472f")
	)
	draw_circle(top, 5.0, Color("3d3833"))


## Rows of grain over the whole footprint: golden when grown, stubble when withered.
func _draw_field() -> void:
	var half := Vector2(size) * 0.5
	var grown := _shown.state == "grown"
	draw_colored_polygon(
		PackedVector2Array([
			Iso.to_point(Vector2(-half.x, -half.y)), Iso.to_point(Vector2(half.x, -half.y)),
			Iso.to_point(Vector2(half.x, half.y)), Iso.to_point(Vector2(-half.x, half.y)),
		]),
		Color("b89b4a") if grown else Color("7d6a52")
	)
	var stalk := Vector2(0, -26) if grown else Vector2(0, -7)
	var color := Color("e2c25a") if grown else Color("5d4e3d")
	for row in 7:
		for column in 7:
			var spot := Iso.to_point(Vector2(-half.x, -half.y) + Vector2(column + 0.5, row + 0.5) * Vector2(size) / 7.0)
			draw_line(spot, spot + stalk, color, 4.0)


## A few stone steps leading down over the edge.
func _draw_steps() -> void:
	for step in 4:
		var drop := Vector2(-step * 12.0, step * 12.0)
		draw_colored_polygon(
			PackedVector2Array([
				drop + Vector2(-34, -6), drop + Vector2(0, -22), drop + Vector2(34, -6), drop + Vector2(0, 10),
			]),
			Color("a9abb1").darkened(step * 0.09)
		)


func _draw_boat() -> void:
	_draw_ground_shadow(42.0)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-50, -20), Vector2(50, -20), Vector2(34, 6), Vector2(-34, 6)]), Color("7a5a3c")
	)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-50, -20), Vector2(50, -20), Vector2(40, -12), Vector2(-40, -12)]), Color("5d432c")
	)
	draw_line(Vector2(-14, -12), Vector2(-14, -20), Color("c9b48a"), 4.0)
	draw_line(Vector2(14, -12), Vector2(14, -20), Color("c9b48a"), 4.0)


## Flat stones in the water, two on every cell of the footprint.
func _draw_stepping_stones() -> void:
	var half := Vector2(size) * 0.5
	for y in size.y:
		for x in size.x:
			var centre := Iso.to_point(Vector2(x + 0.5, y + 0.5) - half)
			for offset: Vector2 in [Vector2(-22, -6), Vector2(20, 8)]:
				draw_set_transform(centre + offset, 0.0, Vector2(1.0, 0.5))
				draw_circle(Vector2.ZERO, 22.0, Color("9a9ca3"))
	draw_set_transform(Vector2.ZERO)


## A fire bowl on a stone pillar. Lit, it burns and glows.
func _draw_big_light() -> void:
	_draw_ground_shadow(36.0)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-26, 0), Vector2(26, 0), Vector2(16, -120), Vector2(-16, -120)]), Color("8d8f96")
	)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-40, -120), Vector2(40, -120), Vector2(26, -142), Vector2(-26, -142)]), Color("4a4540")
	)
	if _shown.state == "lit":
		_draw_glow(Vector2(0, -170), 120.0)
		draw_colored_polygon(
			PackedVector2Array([Vector2(-22, -142), Vector2(22, -142), Vector2(8, -176), Vector2(0, -210), Vector2(-10, -172)]),
			Color("ffb347")
		)
		draw_colored_polygon(
			PackedVector2Array([Vector2(-10, -142), Vector2(10, -142), Vector2(0, -180)]), Color("fff0b0")
		)


## A low stone with a light on it that stands for a piece of the valley.
func _draw_beacon() -> void:
	_draw_ground_shadow(20.0)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-18, 0), Vector2(18, 0), Vector2(12, -30), Vector2(-12, -30)]), Color("8d8f96")
	)
	if _shown.state == "lit":
		_draw_glow(Vector2(0, -40), 34.0)
		draw_circle(Vector2(0, -40), 9.0, Color("fff0b0"))
	else:
		draw_circle(Vector2(0, -40), 9.0, Color("4a4f5c"))


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
