extends Node2D
## Main scene: runs a session, shows the world the player is in and turns taps into moves.

const GAME_PATH := "res://data/game.json"
const ZOOM := 1.5
const SKY_TOP := Color("9db7c9")
const SKY_BOTTOM := Color("f1dcc0")
const SHADOW_OPACITY := 0.3
const MUSIC_VOLUME := -6.0
## Seconds the mood takes to follow a change of the world.
const MOOD_CHANGE_DURATION := 2.5

var session: Session
## The world on show, which is the one the player is in.
var world: World
var player: Player
## How far the shown mood has moved from the previous one (0) to the current one (1).
var mood_progress := 1.0:
	set(value):
		mood_progress = value
		_apply_mood()

## Everything that belongs to the world on show. Built anew when the player changes worlds.
var _stage: Node2D
var _flat: Node2D
var _shadows: CanvasGroup
var _layer: Node2D
var _views := {}
var _marker: TargetMarker
var _camera: Camera2D
var _grading: ShaderMaterial
var _music: AudioStreamPlayer
var _muffler: AudioEffectLowPassFilter
var _mood_from := Mood.new()
var _mood_to := Mood.new()
var _mood_change: Tween
## Where the walk in progress leads, and the object to use on arrival (empty for none).
var _destination := Vector2i.ZERO
var _target_object := ""


func _ready() -> void:
	var game: Variant = JSON.parse_string(FileAccess.get_file_as_string(GAME_PATH))
	session = Session.create(game)

	_build_sky()
	_build_grading()
	_build_music()
	_camera = Camera2D.new()
	_camera.zoom = Vector2.ONE * ZOOM
	_camera.position_smoothing_enabled = true
	add_child(_camera)
	_build_stage()

	if not OS.get_cmdline_user_args().is_empty():
		add_child(TestHelper.new())


func _exit_tree() -> void:
	ObjectView.cleanup()


func _process(_delta: float) -> void:
	_camera.position = _camera_target()


func _unhandled_input(event: InputEvent) -> void:
	var touch := event as InputEventScreenTouch
	if touch and touch.pressed:
		tap(get_canvas_transform().affine_inverse() * touch.position)
	# Temporary, for trying things out: F switches between the intact and the broken world.
	var key := event as InputEventKey
	if key and key.pressed and not key.echo and key.physical_keycode == KEY_F:
		set_broken(session.open_faults().is_empty())


## Reacts to a tap on a point of the world: uses the object there, otherwise walks to the cell.
func tap(point: Vector2) -> bool:
	var object_id := _object_at(point)
	if not object_id.is_empty():
		return use(object_id)
	return walk_to(Iso.to_cell(point))


## Sends the character to a cell. Returns false if there is no path to it.
func walk_to(cell: Vector2i) -> bool:
	var path := world.find_path(player.next_stop(), cell)
	if path.is_empty():
		return false
	_target_object = ""
	_marker.show_at(cell)
	_walk(path)
	return true


## Sends the character next to an object and uses it on arrival. Returns false if there is no
## path to it.
func use(object_id: String) -> bool:
	var best: Array[Vector2i] = []
	for cell in world.cells_beside(world.object(object_id)):
		var path := world.find_path(player.next_stop(), cell)
		if not path.is_empty() and (best.is_empty() or path.size() < best.size()):
			best = path
	if best.is_empty():
		return false
	_target_object = object_id
	_walk(best)
	return true


## Turns the world on show into its broken or its intact version. For trying things out.
func set_broken(enabled: bool, instant := false) -> void:
	session.apply([{("break" if enabled else "restore"): world.id}], world.id)
	_sync_objects()
	_change_mood(instant)


## Seconds the music track has been playing. -1 without music.
func music_position() -> float:
	return _music.get_playback_position() if _music.playing else -1.0


func stop_music() -> void:
	_music.stop()
	_music.stream = null


func _walk(path: Array[Vector2i]) -> void:
	_destination = path[-1]
	player.walk(path)
	if not player.is_walking():
		_arrive()


func _on_cell_reached(cell: Vector2i) -> void:
	var effects := session.enter(cell)
	if not effects.is_empty():
		_show(effects)
		if session.state.world != world.id:
			return
		# The rule may have changed what is in the way, so the rest of the path is found anew.
		player.walk(world.find_path(cell, _destination))
	if not player.is_walking():
		_arrive()


func _arrive() -> void:
	if _target_object.is_empty():
		return
	var object_id := _target_object
	_target_object = ""
	if player.cell in world.cells_beside(world.object(object_id)):
		_show(session.interact(object_id))


## Brings the view up to date after rules have fired.
func _show(effects: Array) -> void:
	if effects.is_empty():
		return
	if session.state.world != world.id:
		_build_stage()
		return
	_sync_objects()
	_change_mood()


## The interactive object whose image is under the point, the one furthest in front first.
## Otherwise the interactive object standing on the tapped cell. Empty if there is none.
func _object_at(point: Vector2) -> String:
	var found := ""
	var front := -INF
	for object_id: String in _views:
		var view: ObjectView = _views[object_id]
		if session.is_interactive(object_id) and view.covers(point) and view.position.y > front:
			found = object_id
			front = view.position.y
	if found.is_empty():
		var object := world.object_at(Iso.to_cell(point))
		if not object.is_empty() and session.is_interactive(object.id):
			found = object.id
	return found


func _build_stage() -> void:
	if _stage:
		_stage.queue_free()
	_views.clear()
	_target_object = ""
	world = session.world()
	for message in world.errors():
		push_error(message)

	_stage = Node2D.new()
	add_child(_stage)
	_build_ground()

	var water := WaterView.new()
	water.world = world
	_stage.add_child(water)

	# Flat objects such as the bridge lie directly on the ground; the character always walks over them.
	_flat = Node2D.new()
	_stage.add_child(_flat)

	# All shadows lie on the ground together. Drawn as one group, they do not get darker where
	# they overlap.
	_shadows = CanvasGroup.new()
	_shadows.fit_margin = 400.0
	_shadows.clear_margin = 400.0
	_shadows.self_modulate = Color(1, 1, 1, SHADOW_OPACITY)
	_stage.add_child(_shadows)

	_marker = TargetMarker.new()
	_stage.add_child(_marker)

	# All other objects and the character share one layer that sorts by y: whatever stands
	# further in front covers what is behind.
	_layer = Node2D.new()
	_layer.y_sort_enabled = true
	_stage.add_child(_layer)
	for object in world.objects:
		_add_object(object)

	player = Player.new()
	player.place(session.state.cell)
	player.cell_reached.connect(_on_cell_reached)
	_layer.add_child(player)

	_camera.position = _camera_target()
	_camera.reset_smoothing()
	_play_music(world.music)
	_change_mood(true)


func _add_object(object: Dictionary) -> void:
	var view := ObjectView.new()
	view.setup(object)
	(_flat if object.kind in World.FLAT_KINDS else _layer).add_child(view)
	var shadow := view.build_shadow()
	if shadow:
		_shadows.add_child(shadow)
	_views[object.id] = view


## Lets the views follow the objects of the world: moved ones slide, changed ones are built anew.
func _sync_objects() -> void:
	for object in world.objects:
		var view: ObjectView = _views[object.id]
		if view.is_current(object) or view.follow(object):
			continue
		if view.shadow:
			view.shadow.queue_free()
		view.queue_free()
		_add_object(object)


## Starts the change from the mood on show to the mood the world has now.
func _change_mood(instant := false) -> void:
	_mood_from = Mood.blend(_mood_from, _mood_to, mood_progress)
	_mood_to = session.mood()
	if _mood_change:
		_mood_change.kill()
	if instant:
		mood_progress = 1.0
		return
	mood_progress = 0.0
	_mood_change = create_tween()
	_mood_change.tween_property(self, "mood_progress", 1.0, MOOD_CHANGE_DURATION).set_trans(Tween.TRANS_SINE)


func _apply_mood() -> void:
	var m := Mood.blend(_mood_from, _mood_to, mood_progress)
	RenderingServer.global_shader_parameter_set(&"wind", m.wind)
	RenderingServer.global_shader_parameter_set(&"water", m.water)
	RenderingServer.global_shader_parameter_set(&"shadow", m.shadow)
	ObjectView.light = m.light
	ObjectView.shadow_cast = m.shadow
	_grading.set_shader_parameter("saturation", m.saturation)
	_grading.set_shader_parameter("tint", Vector3(m.tint.r, m.tint.g, m.tint.b))
	_grading.set_shader_parameter("fog", m.fog)
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
		_stage.add_child(placeholder)
		return
	var image := Sprite2D.new()
	image.texture = load(path)
	image.centered = false
	image.position = Vector2(world.ground_image.origin[0], world.ground_image.origin[1])
	image.scale = Vector2.ONE / world.ground_image.scale
	_stage.add_child(image)


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


## A bus of its own for the music, so the muffling does not hit any other sounds.
func _build_music() -> void:
	var bus := AudioServer.bus_count
	AudioServer.add_bus(bus)
	AudioServer.set_bus_name(bus, "Music")
	_muffler = AudioEffectLowPassFilter.new()
	AudioServer.add_bus_effect(bus, _muffler)

	_music = AudioStreamPlayer.new()
	_music.bus = "Music"
	add_child(_music)


## Fades in the track of a world. A track that is already playing just keeps playing.
func _play_music(path: String) -> void:
	if _music.stream and _music.stream.resource_path == path:
		return
	_music.stop()
	_music.stream = null
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	var track: AudioStream = load(path)
	if track is AudioStreamMP3:
		track.loop = true
	_music.stream = track
	_music.volume_db = -40.0
	_music.play()
	create_tween().tween_property(_music, "volume_db", MUSIC_VOLUME, 3.0)
