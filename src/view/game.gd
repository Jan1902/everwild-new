extends Node2D
## Main scene: loads a world, builds its view and turns taps into movement.

const WORLD_PATH := "res://data/worlds/village.json"
const ZOOM := 1.5
const SKY_TOP := Color("9db7c9")
const SKY_BOTTOM := Color("f1dcc0")
const SHADOW_OPACITY := 0.3
const MUSIC_VOLUME := -6.0
## Seconds the change between the intact and the wrong mood takes.
const MOOD_CHANGE_DURATION := 2.5

var world: World
var player: Player
## Current state between the intact (0) and the wrong (1) mood.
var wrongness := 0.0:
	set(value):
		wrongness = value
		_apply_mood()

var _marker: TargetMarker
var _camera: Camera2D
var _grading: ShaderMaterial
var _music: AudioStreamPlayer
var _muffler: AudioEffectLowPassFilter
var _mood_change: Tween
var _is_wrong := false


func _ready() -> void:
	world = World.from_file(WORLD_PATH)
	for message in world.errors():
		push_error(message)

	_build_sky()
	_build_ground()

	var water := WaterView.new()
	water.world = world
	add_child(water)

	# Flat objects such as the bridge lie directly on the ground; the character always walks over them.
	var flat := Node2D.new()
	add_child(flat)

	# All shadows lie on the ground together. Drawn as one group, they do not get darker where
	# they overlap.
	var shadows := CanvasGroup.new()
	shadows.fit_margin = 400.0
	shadows.clear_margin = 400.0
	shadows.self_modulate = Color(1, 1, 1, SHADOW_OPACITY)
	add_child(shadows)

	_marker = TargetMarker.new()
	add_child(_marker)

	# All other objects and the character share one layer that sorts by y: whatever stands
	# further in front covers what is behind.
	var layer := Node2D.new()
	layer.y_sort_enabled = true
	add_child(layer)
	for object in world.objects:
		var view := ObjectView.new()
		view.setup(object)
		(flat if object.kind in World.FLAT_KINDS else layer).add_child(view)
		var shadow := view.build_shadow()
		if shadow:
			shadows.add_child(shadow)

	player = Player.new()
	player.place(world.player)
	player.cell_reached.connect(world.set_player)
	layer.add_child(player)

	_camera = Camera2D.new()
	_camera.zoom = Vector2.ONE * ZOOM
	_camera.position = _camera_target()
	_camera.position_smoothing_enabled = true
	add_child(_camera)

	_build_grading()
	_build_music()
	_apply_mood()

	if not OS.get_cmdline_user_args().is_empty():
		add_child(TestHelper.new())


func _exit_tree() -> void:
	ObjectView.cleanup()


func _process(_delta: float) -> void:
	_camera.position = _camera_target()


func _unhandled_input(event: InputEvent) -> void:
	var touch := event as InputEventScreenTouch
	if touch and touch.pressed:
		walk_to(Iso.to_cell(get_canvas_transform().affine_inverse() * touch.position))
	# Temporary, for trying things out: F switches between the intact and the wrong mood.
	var key := event as InputEventKey
	if key and key.pressed and not key.echo and key.physical_keycode == KEY_F:
		set_wrong(not _is_wrong)


## Sends the character to a cell. Returns false if there is no path to it.
func walk_to(cell: Vector2i) -> bool:
	var path := world.find_path(player.next_stop(), cell)
	if path.is_empty():
		return false
	player.walk(path)
	_marker.show_at(cell)
	return true


## Fades to the wrong mood of the world or back to the intact one.
func set_wrong(enabled: bool, instant := false) -> void:
	_is_wrong = enabled
	if _mood_change:
		_mood_change.kill()
	var target := 1.0 if enabled else 0.0
	if instant:
		wrongness = target
		return
	_mood_change = create_tween()
	_mood_change.tween_property(self, "wrongness", target, MOOD_CHANGE_DURATION).set_trans(Tween.TRANS_SINE)


## Seconds the music track has been playing. -1 without music.
func music_position() -> float:
	return _music.get_playback_position() if _music and _music.playing else -1.0


func stop_music() -> void:
	if _music:
		_music.stop()
		_music.stream = null


func _apply_mood() -> void:
	var m := Mood.blend(world.mood, world.mood_wrong, wrongness)
	RenderingServer.global_shader_parameter_set(&"wind", m.wind)
	RenderingServer.global_shader_parameter_set(&"water", m.water)
	RenderingServer.global_shader_parameter_set(&"shadow", m.shadow)
	ObjectView.light = m.light
	ObjectView.shadow_cast = m.shadow
	if _grading:
		_grading.set_shader_parameter("saturation", m.saturation)
		_grading.set_shader_parameter("tint", Vector3(m.tint.r, m.tint.g, m.tint.b))
		_grading.set_shader_parameter("fog", m.fog)
	if _music:
		_music.pitch_scale = m.pitch
		# From open (20 kHz) to heavily muffled (800 Hz), spread evenly by ear.
		_muffler.cutoff_hz = 20000.0 * pow(0.04, m.muffle)


func _camera_target() -> Vector2:
	return player.position + Vector2(0, -40)


## Uses the painted ground image of the world. If there is none, the ground is drawn as a placeholder.
func _build_ground() -> void:
	var path: String = world.ground_image.get("path", "")
	if path.is_empty() or not ResourceLoader.exists(path):
		var placeholder := GroundView.new()
		placeholder.world = world
		add_child(placeholder)
		return
	var image := Sprite2D.new()
	image.texture = load(path)
	image.centered = false
	image.position = Vector2(world.ground_image.origin[0], world.ground_image.origin[1])
	image.scale = Vector2.ONE / world.ground_image.scale
	add_child(image)


func _build_sky() -> void:
	var gradient := Gradient.new()
	gradient.set_color(0, SKY_TOP)
	gradient.set_color(1, SKY_BOTTOM)
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0, 0)
	texture.fill_to = Vector2(0, 1)

	var rect := TextureRect.new()
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)

	var canvas := CanvasLayer.new()
	canvas.layer = -1
	canvas.add_child(rect)
	add_child(canvas)


## Lays the colour grading of the mood over the finished picture of sky and world.
func _build_grading() -> void:
	_grading = ShaderMaterial.new()
	_grading.shader = preload("res://src/view/shaders/mood.gdshader")

	var rect := ColorRect.new()
	rect.material = _grading
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)

	var canvas := CanvasLayer.new()
	canvas.layer = 10
	canvas.add_child(rect)
	add_child(canvas)


func _build_music() -> void:
	if world.music.is_empty() or not ResourceLoader.exists(world.music):
		return
	var track: AudioStream = load(world.music)
	if track is AudioStreamMP3:
		track.loop = true

	# A bus of its own for the music, so the muffling does not hit any other sounds.
	var bus := AudioServer.bus_count
	AudioServer.add_bus(bus)
	AudioServer.set_bus_name(bus, "Music")
	_muffler = AudioEffectLowPassFilter.new()
	AudioServer.add_bus_effect(bus, _muffler)

	_music = AudioStreamPlayer.new()
	_music.stream = track
	_music.bus = "Music"
	_music.volume_db = -40.0
	add_child(_music)
	_music.play()
	create_tween().tween_property(_music, "volume_db", MUSIC_VOLUME, 3.0)
