extends Node2D
## Main scene: runs a session, shows the world the player is in and turns taps into moves.

const GAME_PATH := "res://data/game.json"
const ZOOM := 1.5
const SKY_TOP := Color("9db7c9")
const SKY_BOTTOM := Color("f1dcc0")
const SHADOW_OPACITY := 0.3
const MUSIC_VOLUME := -6.0
## Seconds a track takes to fade in, and the previous one to fade out.
const MUSIC_CROSSFADE := 3.0
## Seconds the mood takes to follow a change of the world.
const MOOD_CHANGE_DURATION := 2.5
## Seconds the picture takes to fade to black, and again to come back, when changing worlds.
const TRAVEL_FADE := 0.35
## Seconds the player has to stand still before the memory of the intact world shows through,
## and seconds it stays.
const LINGER_DELAY := 3.5
const MEMORY_DURATION := 4.5
## How far the mood moves towards the remembered one meanwhile.
const MEMORY_STRENGTH := 0.75
const GHOST_COLOR := Color(1.15, 1.1, 1.0, 0.6)

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
## The track that is fading out while another one fades in.
var _music_leaving: AudioStreamPlayer
var _muffler: AudioEffectLowPassFilter
var _mood_from := Mood.new()
var _mood_to := Mood.new()
var _mood_change: Tween
## Where the walk in progress leads, and the object to use on arrival (empty for none).
var _destination := Vector2i.ZERO
var _target_object := ""
var _game := {}
## Black cover for the change between worlds. While it is up, taps are ignored.
var _curtain: ColorRect
var _dialogue: DialogueBox
var _notebook: NotebookView
var _travelling := false
## False while the start screen is up. The music waits for it.
var _started := true
## Seconds the player has been standing still, and whether this standstill has shown its memory.
var _idle := 0.0
var _lingered := false
## Images of the objects as the player remembers them, while the memory shows through.
var _ghosts: Array[ObjectView] = []
var _memory: Tween
## File the game is saved to. Empty for a game that is not saved.
var _save_path := SaveFile.DEFAULT_PATH


func _ready() -> void:
	# Runs driven by the test helper leave the player's save alone, unless they name a file.
	var arguments := OS.get_cmdline_user_args()
	if not arguments.is_empty():
		_save_path = ""
	var language := ""
	for argument in arguments:
		if argument.begins_with("--save="):
			_save_path = argument.trim_prefix("--save=")
		elif argument.begins_with("--language="):
			language = argument.trim_prefix("--language=")
	Texts.use(language)

	_game = JSON.parse_string(FileAccess.get_file_as_string(GAME_PATH))
	if not _save_path.is_empty():
		session = Session.resume(_game, SaveFile.read(_save_path))
	if session == null:
		session = Session.create(_game)

	_build_sky()
	_build_grading()
	_build_curtain()
	_build_music()
	_notebook = NotebookView.new()
	add_child(_notebook)
	_dialogue = DialogueBox.new()
	add_child(_dialogue)
	_camera = Camera2D.new()
	_camera.zoom = Vector2.ONE * ZOOM
	_camera.position_smoothing_enabled = true
	add_child(_camera)
	# The start screen only shows on the very first start. Runs driven by the test helper skip
	# it, unless they ask for it.
	if (arguments.is_empty() and not session.state.start_screen_seen) or "--start-screen" in arguments:
		_started = false
		var start := StartScreen.new()
		start.dismissed.connect(_on_start_dismissed)
		add_child(start)
	_build_stage()

	if not arguments.is_empty():
		add_child(TestHelper.new())


func _exit_tree() -> void:
	ObjectView.cleanup()


func _notification(what: int) -> void:
	# The last chance to save before the app goes to the background or closes.
	if what in [NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_WM_GO_BACK_REQUEST]:
		save()


func _process(delta: float) -> void:
	_camera.position = _camera_target()

	if player.is_walking():
		_lingered = false
	if player.is_walking() or _travelling or not _started or _dialogue.is_open() or _notebook.is_open():
		_idle = 0.0
	elif not _lingered:
		_idle += delta
		if _idle >= LINGER_DELAY:
			_lingered = true
			_linger()


func _unhandled_input(event: InputEvent) -> void:
	var touch := event as InputEventScreenTouch
	if touch and touch.pressed and not _travelling:
		tap(get_canvas_transform().affine_inverse() * touch.position)
	# Temporary, for trying things out: F switches between the intact and the broken world.
	var key := event as InputEventKey
	if key and key.pressed and not key.echo and key.physical_keycode == KEY_F:
		set_broken(session.open_faults().is_empty())
	# Temporary as well: N throws the saved game away and starts a new one.
	if key and key.pressed and not key.echo and key.physical_keycode == KEY_N:
		new_game()


## Reacts to a tap on a point of the world: uses the object there, otherwise walks to the cell.
func tap(point: Vector2) -> bool:
	_idle = 0.0
	_forget()
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
	save()


## Throws the game in progress away and starts from the beginning.
func new_game() -> void:
	var seen := session.state.start_screen_seen
	session = Session.create(_game)
	session.state.start_screen_seen = seen
	_build_stage()
	save()


## Writes the game to its save file.
func save() -> void:
	if session and not _save_path.is_empty():
		SaveFile.write(_save_path, session.state.to_data())


func is_talking() -> bool:
	return _dialogue.is_open()


## Opens the notebook, on a certain note if one is given.
func open_notebook(note := "") -> void:
	_notebook.open(note)


## Seconds the music track has been playing. -1 without music.
func music_position() -> float:
	return _music.get_playback_position() if _music.playing else -1.0


func stop_music() -> void:
	for music: AudioStreamPlayer in [_music, _music_leaving]:
		music.stop()
		music.stream = null


func _on_start_dismissed() -> void:
	_started = true
	session.state.start_screen_seen = true
	save()
	_play_music(world.music)


func _walk(path: Array[Vector2i]) -> void:
	_destination = path[-1]
	player.walk(path)
	if not player.is_walking():
		_arrive()


func _on_cell_reached(cell: Vector2i) -> void:
	var effects := session.enter(cell)
	if not effects.is_empty():
		_show(effects)
		if _travelling:
			return
		# The rule may have changed what is in the way, so the rest of the path is found anew.
		player.walk(world.find_path(cell, _destination))
	if not player.is_walking():
		_arrive()


func _arrive() -> void:
	save()
	if _target_object.is_empty():
		return
	var object_id := _target_object
	_target_object = ""
	if player.cell in world.cells_beside(world.object(object_id)):
		_show(session.interact(object_id))


## The player has stood still for a while: rules waiting for that fire, and the memory of the
## intact world shows through. Everything that is different now appears as it was, and the mood
## leans towards the remembered one.
func _linger() -> void:
	_show(session.linger())
	if _travelling:
		return
	var remembered := world.differences()
	if remembered.is_empty():
		return
	_memory = create_tween().set_parallel()
	for object in remembered:
		var ghost := ObjectView.new()
		ghost.setup(object)
		ghost.modulate = Color(GHOST_COLOR, 0.0)
		ghost.z_index = 1
		_layer.add_child(ghost)
		_ghosts.append(ghost)
		_memory.tween_property(ghost, "modulate:a", GHOST_COLOR.a, 1.2).set_trans(Tween.TRANS_SINE)
	_memory.chain().tween_interval(MEMORY_DURATION)
	_memory.chain().tween_callback(_forget)
	_change_mood(false, Mood.blend(session.mood(), session.remembered_mood(), MEMORY_STRENGTH))


## Lets the memory fade again.
func _forget() -> void:
	if _ghosts.is_empty():
		return
	_memory.kill()
	var fade := create_tween().set_parallel()
	for ghost in _ghosts:
		fade.tween_property(ghost, "modulate:a", 0.0, 0.8)
		fade.tween_callback(ghost.queue_free).set_delay(0.8)
	_ghosts.clear()
	_change_mood()


## Brings the view up to date after rules have fired.
func _show(effects: Array) -> void:
	if effects.is_empty():
		return
	_forget()
	for effect: Dictionary in effects:
		if effect.has("note"):
			_notebook.mark_unread()
		if effect.has("say"):
			var who: String = effect.get("who", "")
			_dialogue.say("" if who.is_empty() else Texts.text("name." + who), Texts.lines(effect["say"]))
	if effects.any(func(effect: Dictionary) -> bool: return effect.has("go")):
		_travel()
	else:
		_sync_objects()
		_change_mood()
	save()


## Shows the place the player has been moved to, with a short fade to black in between.
func _travel() -> void:
	_travelling = true
	_target_object = ""
	player.walk([] as Array[Vector2i])
	var fade := create_tween()
	fade.tween_property(_curtain, "color:a", 1.0, TRAVEL_FADE)
	fade.tween_callback(_build_stage)
	fade.tween_property(_curtain, "color:a", 0.0, TRAVEL_FADE)
	fade.tween_callback(func() -> void: _travelling = false)


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
	_ghosts.clear()
	_target_object = ""
	world = session.world()
	_notebook.session = session
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
	_shadows.add_child(player.shadow)

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


## Starts the change from the mood on show to the mood the world has now, or to the given one.
func _change_mood(instant := false, target: Mood = null) -> void:
	_mood_from = Mood.blend(_mood_from, _mood_to, mood_progress)
	_mood_to = target if target else session.mood()
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
	_music_leaving.pitch_scale = m.pitch
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


func _build_curtain() -> void:
	_curtain = ColorRect.new()
	_curtain.color = Color(0, 0, 0, 0)
	_curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_curtain.set_anchors_preset(Control.PRESET_FULL_RECT)

	var canvas := CanvasLayer.new()
	canvas.layer = 30
	canvas.add_child(_curtain)
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
	_music_leaving = AudioStreamPlayer.new()
	_music_leaving.bus = "Music"
	add_child(_music_leaving)


## Fades in the track of a world while the previous one fades out. A track that is already
## playing just keeps playing.
func _play_music(path: String) -> void:
	if not _started or (_music.stream and _music.stream.resource_path == path):
		return
	# The two players swap roles: the one that was playing leaves.
	var leaving := _music
	_music = _music_leaving
	_music_leaving = leaving
	if leaving.playing:
		var fade := create_tween()
		fade.tween_property(leaving, "volume_db", -40.0, MUSIC_CROSSFADE)
		fade.tween_callback(leaving.stop)
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
	create_tween().tween_property(_music, "volume_db", MUSIC_VOLUME, MUSIC_CROSSFADE)
