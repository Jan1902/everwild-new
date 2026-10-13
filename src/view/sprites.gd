class_name Sprites
extends RefCounted
## How the painted images sit in the world, and everything the views of a game share: materials,
## the soft blobs of light and shadow, and which pixels of an image are painted. One of these
## belongs to the running game and is handed to every view.
##
## The placement comes from data/sprites.json, which the image tools read as well:
##   margin       transparent margin on the left and right of every image, as a fraction of the
##                content width. The wind shader needs it as room to sway
##   walk_width   width of a frame of the walk cycle as a multiple of the standing image
##   walk_frames  number of frames of the walk cycle
##   player       placement of the player character, like a kind
##   kinds        placement of each kind of object:
##     width   width of the image content in world pixels
##     foot    spot in the image content (fraction of width and height) that stands on the ground
##     offset  position of that spot relative to the centre of the footprint
##     wind    sways in the wind
##     light   spot of a light source, in world pixels relative to the foot
##     base    radius of the soft shadow right at the foot, which anchors the object to the ground
##     box     wall and ridge height in world pixels; the shadow is then computed from the
##             footprint instead of the silhouette
##     wall    the object is flat and upright and stands along a ground axis, like an arch or a
##             gate; its shadow is cast from that plane instead of from a flat silhouette
##     image   name of the image file if it is not the kind
##     sails   windmill sails that turn in the plane of the right wall: "hub" is their centre
##             relative to the foot, "size" their diameter in world pixels
##     arrow   an arrow that lies in the ground plane above the object and points where the
##             state of the object says: "hub" is its centre relative to the foot, "size" the
##             width of its image in world pixels
## An object in a certain state uses the image "<name>_<state>.png" if there is one.

const PATH := "res://data/sprites.json"
const IMAGE_DIR := "res://assets/objects/"
const SHADOW_COLOR := Color(0.08, 0.1, 0.22)

var margin := 0.0
var walk_width := 1.0
var walk_frames := 1
var player := {}

var _kinds := {}
var _wind_material: ShaderMaterial
var _shadow_material: ShaderMaterial
## Shadow materials for upright flat objects, one per direction they can stand in.
var _wall_shadow_materials := {}
var _light_blob: GradientTexture2D
var _base_blob: GradientTexture2D
var _water_noise: NoiseTexture2D
## Path of an image -> which of its pixels are painted, for telling what a tap hits.
var _masks := {}


func _init() -> void:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if not data is Dictionary:
		push_error("Sprite placement is not readable: " + PATH)
		return
	margin = data.get("margin", margin)
	walk_width = data.get("walk_width", walk_width)
	walk_frames = int(data.get("walk_frames", walk_frames))
	player = _read_layout(data.get("player", {}))
	var kinds: Dictionary = data.get("kinds", {})
	for kind: String in kinds:
		_kinds[kind] = _read_layout(kinds[kind])


## Placement of a kind of object. Empty if it has no image.
func layout(kind: String) -> Dictionary:
	return _kinds.get(kind, {})


## Path of the image for a name in a state. Empty if there is none.
func image_path(image: String, state := "") -> String:
	for candidate: String in [IMAGE_DIR + image + "_" + state + ".png", IMAGE_DIR + image + ".png"]:
		if ResourceLoader.exists(candidate):
			return candidate
	return ""


## Where an image has to sit so that its foot point is at the origin: "offset" and "scale" for a
## sprite that is not centred. Mirroring and shadows can then hinge on the foot.
func placement(texture: Texture2D, of_layout: Dictionary, mirrored := false) -> Dictionary:
	var content := texture.get_width() / (1.0 + 2.0 * margin)
	var foot: Vector2 = of_layout.foot
	var fraction := 1.0 - foot.x if mirrored else foot.x
	return {
		"offset": -Vector2((margin + fraction) * content, foot.y * texture.get_height()),
		"scale": Vector2.ONE * (of_layout.width / content),
	}


## Image with its foot point at the sprite's origin.
func build_image(texture: Texture2D, of_layout: Dictionary, mirrored := false) -> Sprite2D:
	var placed := placement(texture, of_layout, mirrored)
	var image := Sprite2D.new()
	image.texture = texture
	image.centered = false
	image.flip_h = mirrored
	image.offset = placed.offset
	image.scale = placed.scale
	image.position = of_layout.get("offset", Vector2.ZERO)
	return image


## Soft blob for the shadow right at the foot of something, lying flat on the ground.
func build_base(radius: float) -> Sprite2D:
	var base := Sprite2D.new()
	base.texture = _get_base_blob()
	base.modulate = SHADOW_COLOR
	base.scale = Vector2(1.0, 0.5) * (radius * 2.0 / base.texture.get_width())
	return base


## Makes an image, placed by build_image(), the shadow it casts. The shader lays the image down
## beside where it stands, which the engine does not know: it would stop drawing the shadow as
## soon as the upright image has left the screen. So the image is given the area a shadow can
## reach, for any shadow cast no longer than the object is high.
func make_cast(image: Sprite2D, material: ShaderMaterial) -> void:
	image.material = material
	var upright := image.get_rect()
	var far := upright.position.abs().max(upright.end.abs())
	var reach := (far.x + far.y) * 1.5
	RenderingServer.canvas_item_set_custom_rect(image.get_canvas_item(), true, Rect2(-reach, -reach, reach * 2.0, reach * 2.0))


## Whether the pixel of an image is painted.
func is_painted(texture: Texture2D, pixel: Vector2i) -> bool:
	var path := texture.resource_path
	if not _masks.has(path):
		var mask := BitMap.new()
		mask.create_from_image_alpha(texture.get_image())
		_masks[path] = mask
	var found: BitMap = _masks[path]
	return Rect2i(Vector2i.ZERO, found.get_size()).has_point(pixel) and found.get_bitv(pixel)


func wind_material() -> ShaderMaterial:
	if _wind_material == null:
		_wind_material = ShaderMaterial.new()
		_wind_material.shader = preload("res://src/view/shaders/wind.gdshader")
	return _wind_material


## Material that lays the silhouette of a sprite flat on the ground as its shadow.
func shadow_material() -> ShaderMaterial:
	if _shadow_material == null:
		_shadow_material = ShaderMaterial.new()
		_shadow_material.shader = preload("res://src/view/shaders/shadow.gdshader")
	return _shadow_material


## Material for the shadow of an upright flat object.
func wall_shadow_material(mirrored: bool) -> ShaderMaterial:
	if not _wall_shadow_materials.has(mirrored):
		var material := ShaderMaterial.new()
		material.shader = preload("res://src/view/shaders/wall_shadow.gdshader")
		material.set_shader_parameter("axis", -1.0 if mirrored else 1.0)
		_wall_shadow_materials[mirrored] = material
	return _wall_shadow_materials[mirrored]


## Round glow of a light source.
func light_blob() -> GradientTexture2D:
	if _light_blob == null:
		_light_blob = _build_blob(0.0)
	return _light_blob


## Noise the streaks of light on the water are made of.
func water_noise() -> NoiseTexture2D:
	if _water_noise == null:
		var noise := FastNoiseLite.new()
		noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		noise.frequency = 0.02
		_water_noise = NoiseTexture2D.new()
		_water_noise.noise = noise
		_water_noise.seamless = true
		_water_noise.width = 256
		_water_noise.height = 256
	return _water_noise


func _get_base_blob() -> GradientTexture2D:
	if _base_blob == null:
		_base_blob = _build_blob(0.6)
	return _base_blob


## Round blob that is fully opaque up to the fraction core and fades out towards the rim.
func _build_blob(core: float) -> GradientTexture2D:
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


## A placement as the views use it: pairs of numbers become vectors.
static func _read_layout(data: Dictionary) -> Dictionary:
	var read := {}
	for key: String in data:
		var value: Variant = data[key]
		if value is Array and value.size() == 2:
			read[key] = Vector2(value[0], value[1])
		elif value is Dictionary:
			read[key] = _read_layout(value)
		else:
			read[key] = value
	return read
