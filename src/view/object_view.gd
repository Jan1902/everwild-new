class_name ObjectView
extends Node2D
## Shows an object of the world: as a painted image if there is one, otherwise as a drawn placeholder.

const IMAGE_DIR := "res://assets/objects/"
## Transparent margin on the left and right as a fraction of the content width. Has to match
## tools/crop_sprites.py. The wind shader needs it as room to sway.
const MARGIN := 0.12
## How the images sit in the world:
##   width   width of the image content in world pixels
##   foot    spot in the image content (fraction of width and height) that stands on the ground
##   offset  position of that spot relative to the centre of the footprint
##   wind    sways in the wind
##   light   spot of a light source, in world pixels relative to the foot
##   base    radius of the soft shadow right at the foot, which anchors the object to the ground
##   box     wall and ridge height in world pixels; the shadow is then computed from the
##           footprint instead of the silhouette
const IMAGES := {
	"house": {"width": 298.0, "foot": Vector2(0.51, 0.985), "offset": Vector2(0, 64), "box": Vector2(105, 215)},
	"tree": {"width": 190.0, "foot": Vector2(0.49, 0.97), "wind": true, "base": 38.0},
	"rock": {"width": 84.0, "foot": Vector2(0.5, 0.78), "base": 50.0},
	"lantern": {"width": 85.0, "foot": Vector2(0.19, 0.97), "light": Vector2(48, -70), "base": 18.0},
	"bridge": {"width": 180.0, "foot": Vector2(0.5, 0.45)},
}
const LIGHT_COLOR := Color(1.0, 0.78, 0.42)
## Colour laid over a lantern that is out.
const UNLIT := Color(0.62, 0.66, 0.78)
## Seconds an object takes to slide to another cell.
const MOVE_DURATION := 0.45

## Brightness of all lights, set from the mood of the world.
static var light := 1.0
## Shadow cast in the ground plane, set from the mood of the world.
static var shadow_cast := Vector2(0.5, 0.2)

static var _wind_material: ShaderMaterial
static var _shadow_material: ShaderMaterial
static var _light_blob: GradientTexture2D
static var _base_blob: GradientTexture2D
## Kind -> which pixels of its image are painted, for telling what a tap hits.
static var _masks := {}

var kind := ""
var size := Vector2i.ONE
## Shadow of the object for the shadow layer, made by build_shadow(). Null if it casts none.
var shadow: Node2D

var _shown := {}
var _image: Sprite2D
var _glow: Sprite2D
var _flicker := 0.0


## Sets the object up. The node sits at the centre of its footprint so that depth sorting by y
## works.
func setup(object: Dictionary) -> void:
	_shown = object.duplicate()
	kind = object.kind
	size = object.size
	position = _point(object.cell)
	visible = not object.hidden

	var path := IMAGE_DIR + kind + ".png"
	if not IMAGES.has(kind) or not ResourceLoader.exists(path):
		return
	var layout: Dictionary = IMAGES[kind]
	var mirrored: bool = object.mirrored
	var lit: bool = object.state != "out"
	_image = _build_image(load(path), layout, mirrored)
	if layout.get("wind", false):
		_image.material = _get_wind_material()
	if not lit:
		_image.modulate = UNLIT
	add_child(_image)

	if layout.has("light") and lit:
		var spot: Vector2 = layout.light
		_glow = Sprite2D.new()
		_glow.texture = _get_light_blob()
		_glow.position = _image.position + Vector2(-spot.x if mirrored else spot.x, spot.y)
		var add_material := CanvasItemMaterial.new()
		add_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		_glow.material = add_material
		_flicker = position.x * 0.05
		add_child(_glow)


## Whether the view shows the object as it is now.
func is_current(object: Dictionary) -> bool:
	return _shown == object


## Slides to the object's cell if that is all that changed. Returns false if the view has to be
## built anew instead.
func follow(object: Dictionary) -> bool:
	var moved := _shown.duplicate()
	moved.cell = object.cell
	if moved != object:
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
	if _image == null or not visible:
		return false
	var pixel := Vector2i((point - position - _image.position) / _image.scale - _image.offset)
	var mask := _get_mask(kind, _image.texture)
	if not Rect2i(Vector2i.ZERO, mask.get_size()).has_point(pixel):
		return false
	if _image.flip_h:
		pixel.x = mask.get_size().x - 1 - pixel.x
	return mask.get_bitv(pixel)


## Builds the shadow of the object as a separate node for the shadow layer. Null if it casts none.
func build_shadow() -> Node2D:
	if _image == null or kind in World.FLAT_KINDS or not visible:
		return null
	var layout: Dictionary = IMAGES[kind]
	shadow = Node2D.new()

	if layout.has("box"):
		shadow.position = position
		var box := BoxShadow.new()
		box.size = size
		box.wall_height = layout.box.x
		box.ridge_height = layout.box.y
		shadow.add_child(box)
		return shadow

	shadow.position = position + _image.position
	# Soft blob right at the foot. Without it the object looks as if it hovers above the ground.
	var base := Sprite2D.new()
	base.texture = _get_base_blob()
	base.modulate = BoxShadow.COLOR
	base.scale = Vector2(1.0, 0.5) * (layout.base * 2.0 / base.texture.get_width())
	shadow.add_child(base)

	var cast := _image.duplicate() as Sprite2D
	cast.position = Vector2.ZERO
	cast.material = _get_shadow_material()
	shadow.add_child(cast)
	return shadow


func _process(delta: float) -> void:
	if _glow == null:
		return
	_flicker += delta
	var jitter := 0.88 + 0.08 * sin(_flicker * 9.0) + 0.04 * sin(_flicker * 23.0)
	_glow.modulate = Color(LIGHT_COLOR, 0.45 * light * jitter)
	_glow.scale = Vector2.ONE * (1.0 + 0.06 * sin(_flicker * 6.0))


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


## Image with its foot point at the sprite's origin, so mirroring and shadows can hinge on it.
func _build_image(texture: Texture2D, layout: Dictionary, mirrored: bool) -> Sprite2D:
	var content := texture.get_width() / (1.0 + 2.0 * MARGIN)
	var foot: Vector2 = layout.foot
	var fraction := 1.0 - foot.x if mirrored else foot.x
	var image := Sprite2D.new()
	image.texture = texture
	image.centered = false
	image.flip_h = mirrored
	image.offset = -Vector2((MARGIN + fraction) * content, foot.y * texture.get_height())
	image.scale = Vector2.ONE * (layout.width / content)
	image.position = layout.get("offset", Vector2.ZERO)
	return image


## Releases the shared materials. Needed on exit, otherwise Godot reports a leak.
static func cleanup() -> void:
	_wind_material = null
	_shadow_material = null
	_light_blob = null
	_base_blob = null
	_masks.clear()


static func _get_wind_material() -> ShaderMaterial:
	if _wind_material == null:
		_wind_material = ShaderMaterial.new()
		_wind_material.shader = preload("res://src/view/shaders/wind.gdshader")
	return _wind_material


static func _get_shadow_material() -> ShaderMaterial:
	if _shadow_material == null:
		_shadow_material = ShaderMaterial.new()
		_shadow_material.shader = preload("res://src/view/shaders/shadow.gdshader")
	return _shadow_material


static func _get_mask(image_kind: String, texture: Texture2D) -> BitMap:
	if not _masks.has(image_kind):
		var mask := BitMap.new()
		mask.create_from_image_alpha(texture.get_image())
		_masks[image_kind] = mask
	return _masks[image_kind]


static func _get_light_blob() -> GradientTexture2D:
	if _light_blob == null:
		_light_blob = _build_blob(0.0)
	return _light_blob


static func _get_base_blob() -> GradientTexture2D:
	if _base_blob == null:
		_base_blob = _build_blob(0.6)
	return _base_blob


## Round blob that is fully opaque up to the fraction core and fades out towards the rim.
static func _build_blob(core: float) -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 1))
	gradient.set_color(1, Color(1, 1, 1, 0))
	if core > 0.0:
		gradient.add_point(core, Color(1, 1, 1, 1))
	var blob := GradientTexture2D.new()
	blob.gradient = gradient
	blob.fill = GradientTexture2D.FILL_RADIAL
	blob.fill_from = Vector2(0.5, 0.5)
	blob.fill_to = Vector2(1.0, 0.5)
	blob.width = 160
	blob.height = 160
	return blob


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
