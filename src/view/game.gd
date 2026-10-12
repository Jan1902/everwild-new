extends Node2D
## Main scene: runs a session, shows the world the player is in and turns taps into moves.
## The world on show is a Stage, the music a Music; this script brings them together with the
## session and decides what happens when.

const GAME_PATH := "res://data/game.json"
const ZOOM := 1.5
const SKY_TOP := Color("9db7c9")
const SKY_BOTTOM := Color("f1dcc0")
## Seconds the mood takes to follow a change of the world.
const MOOD_CHANGE_DURATION := 2.5
## Seconds the picture takes to fade to black, and again to come back, when changing worlds.
const TRAVEL_FADE := 0.35
## Seconds the player has to stand still before the memory of the intact world shows through,
## and seconds it stays.
const LINGER_DELAY := 3.5
const MEMORY_DURATION := 4.5
## How far the mood moves towards the remembered one meanwhile.
const MEMORY_STRENGTH := 0.5

var session: Session
## The world on show, which is the one the player is in.
var stage: Stage
## How far the shown mood has moved from the previous one (0) to the current one (1).
var mood_progress := 1.0:
	set(value):
		mood_progress = value
		_apply_mood()

var _sprites := Sprites.new()
var _camera: Camera2D
var _grading: ShaderMaterial
var _music := Music.new()
var _mood_from := Mood.new()
var _mood_to := Mood.new()
var _mood_change: Tween
## Where the walk in progress leads, and the object to use on arrival (empty for none).
var _destination := Vector2i.ZERO
var _target_object := ""
var _game := {}
## Black cover for the change between worlds. While it is up, taps are ignored.
var _curtain: ColorRect
var _dialogue := DialogueBox.new()
var _notebook := NotebookView.new()
var _travelling := false
## False while the start screen is up. The music waits for it.
var _started := true
## Seconds the player has been standing still, and whether this standstill has shown its memory.
var _idle := 0.0
var _lingered := false
## Ends the memory that is showing through.
var _memory: Tween
## File the game is saved to. Empty for a game that is not saved.
var _save_path := SaveFile.DEFAULT_PATH
## Arguments that drive the game for a check (see TestHelper). Only debug builds take any.
var _arguments := OS.get_cmdline_user_args() if OS.is_debug_build() else PackedStringArray()


func _ready() -> void:
	# Runs driven by the test helper leave the player's save alone, unless they name a file.
	if not _arguments.is_empty():
		_save_path = ""
	var language := ""
	for argument in _arguments:
		if argument.begins_with("--save="):
			_save_path = argument.trim_prefix("--save=")
		elif argument.begins_with("--language="):
			language = argument.trim_prefix("--language=")
	Texts.use(language)

	_game = JSON.parse_string(FileAccess.get_file_as_string(GAME_PATH))
	if not _save_path.is_empty():
		session = Session.resume(_game, SaveFile.read(_save_path))
		if session == null:
			# A save the game cannot read is kept, not overwritten by the new game.
			SaveFile.set_aside(_save_path)
	if session == null:
		session = Session.create(_game)
	if OS.is_debug_build():
		for message in RuleCheck.errors(session, Notebook.read()):
			push_error(message)

	_build_sky()
	_build_grading()
	_build_curtain()
	add_child(_music)
	add_child(_notebook)
	add_child(_dialogue)
	_camera = Camera2D.new()
	_camera.zoom = Vector2.ONE * ZOOM
	_camera.position_smoothing_enabled = true
	add_child(_camera)
	# The start screen only shows on the very first start. Runs driven by the test helper skip
	# it, unless they ask for it.
	if (_arguments.is_empty() and not session.state.start_screen_seen) or "--start-screen" in _arguments:
		_started = false
		var start := StartScreen.new()
		start.dismissed.connect(_on_start_dismissed)
		add_child(start)
	_build_stage()

	if not _arguments.is_empty():
		add_child(TestHelper.new())


func _notification(what: int) -> void:
	# The last chance to save before the app goes to the background or closes.
	if what in [NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_WM_GO_BACK_REQUEST]:
		save()


func _process(delta: float) -> void:
	_camera.position = _camera_target()

	var walking := stage.player.is_walking()
	if walking:
		_lingered = false
	if walking or _travelling or not _started or _dialogue.is_open() or _notebook.is_open():
		_idle = 0.0
	elif not _lingered:
		_idle += delta
		if _idle >= LINGER_DELAY:
			_lingered = true
			_linger()


func _unhandled_input(event: InputEvent) -> void:
	# Only the first finger counts; a second one resting on the screen is no tap.
	var touch := event as InputEventScreenTouch
	if touch and touch.pressed and touch.index == 0 and not _travelling:
		tap(get_canvas_transform().affine_inverse() * touch.position)
	if not OS.is_debug_build():
		return
	# For trying things out: F switches between the intact and the broken world, N throws the
	# saved game away and starts a new one.
	var key := event as InputEventKey
	if key and key.pressed and not key.echo and key.physical_keycode == KEY_F:
		set_broken(session.open_faults().is_empty())
	if key and key.pressed and not key.echo and key.physical_keycode == KEY_N:
		new_game()


## Reacts to a tap on a point of the world: uses the object there, otherwise walks to the cell.
func tap(point: Vector2) -> bool:
	_idle = 0.0
	_forget()
	# Objects with nothing to do at the moment let the tap through to the ground.
	var object_id := stage.object_at(point, func(id: String) -> bool: return not session.interact_rule(id).is_empty())
	var understood := use(object_id) if not object_id.is_empty() else walk_to(Iso.to_cell(point))
	if understood:
		stage.mark(point)
	return understood


## Sends the character to a cell. Returns false if there is no path to it.
func walk_to(cell: Vector2i) -> bool:
	var path := stage.world.find_path(stage.player.next_stop(), cell)
	if path.is_empty():
		return false
	_target_object = ""
	_walk(path)
	return true


## Sends the character next to an object and uses it on arrival. Returns false if there is no
## path to it.
func use(object_id: String) -> bool:
	var world := stage.world
	var best: Array[Vector2i] = []
	for cell in world.cells_beside(world.get_object(object_id)):
		var path := world.find_path(stage.player.next_stop(), cell)
		if not path.is_empty() and (best.is_empty() or path.size() < best.size()):
			best = path
	if best.is_empty():
		return false
	_target_object = object_id
	_walk(best)
	return true


## Turns the world on show into its broken or its intact version. For trying things out.
func set_broken(enabled: bool, instant := false) -> void:
	session.apply([{("break" if enabled else "restore"): stage.world.id}], stage.world.id)
	stage.sync()
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
	if session and not _save_path.is_empty() and not SaveFile.write(_save_path, session.state.to_data()):
		push_warning("The game could not be saved to " + _save_path)


func is_talking() -> bool:
	return _dialogue.is_open()


## Opens the notebook, on a certain note if one is given.
func open_notebook(note := "") -> void:
	_notebook.open(note)


## Seconds the music track has been playing. -1 without music.
func music_position() -> float:
	return _music.position()


func stop_music() -> void:
	_music.stop()


func _on_start_dismissed() -> void:
	_started = true
	session.state.start_screen_seen = true
	save()
	_music.play(stage.world.music)


func _walk(path: Array[Vector2i]) -> void:
	_destination = path[-1]
	stage.player.walk(path)
	if not stage.player.is_walking():
		_arrive()


func _on_cell_reached(cell: Vector2i) -> void:
	var effects := session.enter(cell)
	if not effects.is_empty():
		_show(effects)
		if _travelling:
			return
		# The rule may have changed what is in the way, so the rest of the path is found anew.
		stage.player.walk(stage.world.find_path(cell, _destination))
	if not stage.player.is_walking():
		_arrive()


func _arrive() -> void:
	save()
	if _target_object.is_empty():
		return
	var object_id := _target_object
	_target_object = ""
	_show(session.interact(object_id))


## The player has stood still for a while: rules waiting for that fire, and the memory of the
## intact world shows through. Everything that is different now appears as it was, and the mood
## leans towards the remembered one.
func _linger() -> void:
	_show(session.linger())
	if _travelling or not stage.remember():
		return
	_memory = create_tween()
	_memory.tween_interval(Stage.GHOST_FADE_IN + MEMORY_DURATION)
	_memory.tween_callback(_forget)
	_change_mood(false, Mood.blend(session.mood(), session.remembered_mood(), MEMORY_STRENGTH))


## Lets the memory fade again.
func _forget() -> void:
	if not stage.is_remembering():
		return
	_memory.kill()
	stage.forget()
	_change_mood()


## Brings the view up to date after rules have fired.
func _show(effects: Array) -> void:
	if effects.is_empty():
		return
	_forget()
	_notebook.refresh()
	for effect: Dictionary in effects:
		if effect.has("note"):
			_notebook.mark_unread()
		if effect.has("say"):
			# Lines without a speaker are the player talking to themselves.
			_dialogue.say(Texts.text("name." + effect.get("who", "self")), Texts.lines(effect["say"]))
	if effects.any(func(effect: Dictionary) -> bool: return effect.has("go")):
		_travel()
	else:
		stage.sync()
		_change_mood()
	save()


## Shows the place the player has been moved to, with a short fade to black in between.
func _travel() -> void:
	_travelling = true
	_target_object = ""
	stage.player.walk([] as Array[Vector2i])
	var fade := create_tween()
	fade.tween_property(_curtain, "color:a", 1.0, TRAVEL_FADE)
	fade.tween_callback(_build_stage)
	fade.tween_property(_curtain, "color:a", 0.0, TRAVEL_FADE)
	fade.tween_callback(func() -> void: _travelling = false)


## Puts the world the player is in on show.
func _build_stage() -> void:
	if stage:
		stage.retire()
	if _memory:
		_memory.kill()
	_target_object = ""
	_notebook.session = session
	_notebook.refresh()
	var world := session.world()
	if OS.is_debug_build():
		for message in world.errors():
			push_error(message)

	stage = Stage.new(world, _sprites, session.state.cell)
	stage.player.cell_reached.connect(_on_cell_reached)
	add_child(stage)

	_camera.position = _camera_target()
	_camera.reset_smoothing()
	if _started:
		_music.play(world.music)
	_change_mood(true)


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
	stage.set_mood(m.light, m.shadow)
	_grading.set_shader_parameter("saturation", m.saturation)
	_grading.set_shader_parameter("tint", Vector3(m.tint.r, m.tint.g, m.tint.b))
	_grading.set_shader_parameter("fog", m.fog)
	_music.set_mood(m.pitch, m.muffle)


func _camera_target() -> Vector2:
	return stage.player.position + Vector2(0, -40)


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
