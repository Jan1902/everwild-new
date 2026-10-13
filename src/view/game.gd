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
## Seconds a crossing aboard something takes.
const RIDE_DURATION := 4.0
## The quake a "go" effect can ask for: seconds the ground shakes while the music runs down, how
## far the picture is thrown about at the end (in pixels of the world), seconds the picture takes
## to go dark at the end of the shaking, seconds it stays dark, and seconds the light takes to
## return. The sound (tools/quake_sound.py) is made for the same times.
const QUAKE_DURATION := 2.8
const QUAKE_SHAKE := 16.0
const QUAKE_DARKENING := 0.9
const QUAKE_DARK := 1.6
const QUAKE_DAWN := 4.5
const QUAKE_SOUND := "res://assets/sounds/quake.wav"
## The start of the app: the picture comes out of the colour the engine's splash screen and the
## start screen have, after staying in it for a moment, in this many seconds.
const START_DARK := 0.25
const START_DAWN := 1.6
## A new game: seconds the picture takes to go dark, stays dark and takes to come back.
const NEW_GAME_FADE := 0.5
const NEW_GAME_DARK := 0.7
const NEW_GAME_DAWN := 1.6
## Seconds the player has to stand still before rules that wait for lingering fire.
const LINGER_DELAY := 3.5
## Remembering: seconds the remembered part of the world takes to show through and to fade
## again, how far its colours move towards the remembered ones, how far the music does, and how
## much larger than the remembered cells the part of the picture is that changes.
const MEMORY_FADE_IN := 3.0
const MEMORY_FADE_OUT := 0.8
const MEMORY_STRENGTH := 0.75
const MEMORY_MUSIC := 0.3
const MEMORY_MARGIN := 1.5
## The moment a world becomes whole: how bright the warm light gets that swells over the
## picture, and seconds it takes to come and to go.
const WHOLE_GLOW := 0.28
const WHOLE_GLOW_IN := 0.9
const WHOLE_GLOW_OUT := 3.0

var session: Session
## The world on show, which is the one the player is in.
var stage: Stage
## How far the shown mood has moved from the previous one (0) to the current one (1).
var mood_progress := 1.0:
	set(value):
		mood_progress = value
		_apply_mood()
## How far the remembered part of the world shows through, from 0 to 1.
var memory_progress := 0.0:
	set(value):
		memory_progress = value
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
var _pause := PauseView.new()
var _banner := Banner.new()
var _settings: Settings
var _travelling := false
## The scene a change of worlds is making, if it is one, and its sound.
var _scene: Tween
var _rumble := AudioStreamPlayer.new()
## False while the start screen is up. The music waits for it.
var _started := true
## Seconds the player has been standing still, and whether this standstill has shown its memory.
var _idle := 0.0
var _lingered := false
## Whether the player is remembering, the part of the world that shows through, and the change
## of memory_progress in progress.
var _remembering := false
var _memory_zone := Rect2i()
var _memory: Tween
## File the game is saved to. Empty for a game that is not saved.
var _save_path := SaveFile.DEFAULT_PATH
## Arguments that drive the game for a check (see TestHelper). Only debug builds take any.
var _arguments := OS.get_cmdline_user_args() if OS.is_debug_build() else PackedStringArray()


func _ready() -> void:
	# Runs driven by the test helper leave the player's save and settings alone, unless they
	# name a file.
	var settings_path := Settings.DEFAULT_PATH
	if not _arguments.is_empty():
		_save_path = ""
		settings_path = ""
	var language := ""
	for argument in _arguments:
		if argument.begins_with("--save="):
			_save_path = argument.trim_prefix("--save=")
		elif argument.begins_with("--settings="):
			settings_path = argument.trim_prefix("--settings=")
		elif argument.begins_with("--language="):
			language = argument.trim_prefix("--language=")
	_settings = Settings.read(settings_path)
	Texts.use(language if not language.is_empty() else _settings.language)

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
	# Until sounds have a bus of their own, the one sound there is follows the music volume.
	_rumble.bus = Music.BUS
	if ResourceLoader.exists(QUAKE_SOUND):
		_rumble.stream = load(QUAKE_SOUND)
	add_child(_rumble)
	_music.set_volume(_settings.music_volume)
	add_child(_banner)
	add_child(_notebook)
	add_child(_dialogue)
	_pause.set_volume(_settings.music_volume)
	_pause.volume_changed.connect(_on_volume_changed)
	_pause.language_changed.connect(_on_language_changed)
	_pause.new_game_requested.connect(new_game)
	_pause.closed.connect(_settings.write)
	add_child(_pause)
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
	# Runs driven by the test helper start at once, unless they ask for the fade.
	if _started and (_arguments.is_empty() or "--fade-in" in _arguments):
		_fade_in()

	if not _arguments.is_empty():
		add_child(TestHelper.new())


func _notification(what: int) -> void:
	# The last chance to save before the app goes to the background or closes.
	if what in [NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_WM_GO_BACK_REQUEST]:
		save()
		if _settings:
			_settings.write()
	# The back gesture of the phone pauses the game. Only a second one leaves it.
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and is_node_ready():
		if _started and not _pause.is_open():
			_pause.open()
		else:
			_quit()


func _process(delta: float) -> void:
	_camera.position = _camera_target()
	if memory_progress > 0.0:
		_place_memory()

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


## Throws the game in progress away and starts from the beginning. The picture goes dark and
## comes back and the music starts afresh, so the player sees that a new game has begun even
## where it begins with the picture they were just looking at.
func new_game() -> void:
	var seen := session.state.start_screen_seen
	session = Session.create(_game)
	session.state.start_screen_seen = seen
	save()
	if _scene:
		_scene.kill()
	_rumble.stop()
	_dialogue.clear()
	_notebook.reset()
	# Nothing can be done until the new game is on show.
	_travelling = true
	_scene = create_tween()
	_scene.tween_property(_curtain, "color:a", 1.0, NEW_GAME_FADE)
	_scene.tween_callback(_show_new_game)
	_scene.tween_interval(NEW_GAME_DARK)
	_scene.tween_property(_curtain, "color:a", 0.0, NEW_GAME_DAWN).set_trans(Tween.TRANS_SINE)
	_scene.tween_callback(func() -> void: _travelling = false)


func _show_new_game() -> void:
	_camera.offset = Vector2.ZERO
	# Stopped, the music starts afresh and fades in, even if it is the same track.
	_music.stop()
	_build_stage()


## Writes the game to its save file.
func save() -> void:
	if session and not _save_path.is_empty() and not SaveFile.write(_save_path, session.state.to_data()):
		push_warning("The game could not be saved to " + _save_path)


## Leaves the game. The music has to have died away before Godot closes, otherwise it reports
## a leak.
func _quit() -> void:
	_music.stop()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func is_talking() -> bool:
	return _dialogue.is_open()


func is_paused() -> bool:
	return _pause.is_open()


## Opens the notebook, on a certain note if one is given.
func open_notebook(note := "") -> void:
	_notebook.open(note)


## Seconds the music track has been playing. -1 without music.
func music_position() -> float:
	return _music.position()


func stop_music() -> void:
	_music.stop()


func _on_volume_changed(volume: float) -> void:
	_settings.music_volume = volume
	_music.set_volume(volume)


func _on_language_changed(language: String) -> void:
	_settings.language = language
	_settings.write()
	Texts.use(language)
	_notebook.retranslate()


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


## The player has stood still for a while: rules waiting for that fire. At a place of memory
## one of them lets a part of the world show through as it was.
func _linger() -> void:
	var effects := session.linger()
	_show(effects)
	for effect: Dictionary in effects:
		if effect.has("remember") and not _travelling:
			_remember(effect["remember"])


## Lets the part of the world that belongs to a place of memory slowly show through as it was:
## what is different there appears as it used to be, and colours and music lean towards the
## remembered ones. It stays until the player moves again.
func _remember(memory_id: String) -> void:
	_remembering = true
	_memory_zone = stage.world.memories[memory_id]
	stage.remember(stage.world.remembered(memory_id), MEMORY_FADE_IN)
	_place_memory()
	_change_memory(1.0, MEMORY_FADE_IN)


## Lets the memory fade again.
func _forget() -> void:
	if not _remembering:
		return
	_remembering = false
	stage.forget()
	_change_memory(0.0, MEMORY_FADE_OUT)


func _change_memory(target: float, duration: float) -> void:
	if _memory:
		_memory.kill()
	_memory = create_tween()
	_memory.tween_property(self, "memory_progress", target, duration).set_trans(Tween.TRANS_SINE)


## Tells the colour grading where on screen the remembered part of the world is.
func _place_memory() -> void:
	# Corners of the remembered cells, widened a little, as points of the world.
	var area := Rect2(_memory_zone).grow(MEMORY_MARGIN)
	var on_screen := Rect2()
	for corner: Vector2 in [area.position, Vector2(area.end.x, area.position.y), area.end, Vector2(area.position.x, area.end.y)]:
		# Cells are named by their centre, so their corners lie half a cell before it.
		var point := get_canvas_transform() * Iso.to_point(corner - Vector2(0.5, 0.5))
		on_screen = Rect2(point, Vector2.ZERO) if on_screen == Rect2() else on_screen.expand(point)
	var screen := get_viewport_rect().size
	_grading.set_shader_parameter("memory_centre", on_screen.get_center() / screen)
	_grading.set_shader_parameter("memory_radius", on_screen.size * 0.5 / screen)


## Brings the view up to date after rules have fired.
func _show(effects: Array) -> void:
	if effects.is_empty():
		return
	_forget()
	_notebook.refresh()
	var leaving := effects.find_custom(func(effect: Dictionary) -> bool: return effect.has("go"))
	# What has changed hands since the last thing said. Words alone do not always make that
	# clear, so the next thing said carries it as a mark in the corner of the dialogue.
	var changed_hands := []
	for number in effects.size():
		var effect: Dictionary = effects[number]
		if effect.has("give"):
			changed_hands.append("+ " + Texts.text("item." + effect["give"]))
		if effect.has("take"):
			changed_hands.append("− " + Texts.text("item." + effect["take"]))
		if effect.has("note"):
			_notebook.mark_unread()
		if effect.has("whole"):
			_celebrate(effect["whole"])
		# What is said after leaving waits for the arrival.
		if effect.has("say") and (leaving < 0 or number < leaving):
			_say(effect, "   ".join(changed_hands))
			changed_hands.clear()
	if leaving >= 0:
		_travel(effects[leaving], effects.slice(leaving + 1))
	else:
		stage.sync()
		_change_mood()
	save()


func _say(effect: Dictionary, mark := "") -> void:
	# Lines without a speaker are the player talking to themselves.
	_dialogue.say(Texts.text("name." + effect.get("who", "self")), Texts.lines(effect["say"]), mark)


## Marks the moment a world has become whole: its name appears for a while, the notebook has
## something new to show, and if the player is there, warm light swells over the picture.
func _celebrate(world_id: String) -> void:
	_banner.show_text(Texts.text("banner.whole") % Texts.text("world." + world_id))
	_notebook.mark_unread()
	var here := stage.world
	if world_id != here.id and world_id != here.mood_from:
		return
	var glow := create_tween()
	glow.tween_method(_set_glow, 0.0, WHOLE_GLOW, WHOLE_GLOW_IN).set_trans(Tween.TRANS_SINE)
	glow.tween_method(_set_glow, WHOLE_GLOW, 0.0, WHOLE_GLOW_OUT).set_trans(Tween.TRANS_SINE)


func _set_glow(amount: float) -> void:
	_grading.set_shader_parameter("glow", amount)


## Shows the place the player has been moved to. What is being said is heard out first. Then the
## player crosses aboard what the "go" effect names, the ground quakes if it asks for that, or
## the picture fades to black for a moment. What was said after leaving follows on arrival.
func _travel(go: Dictionary, afterwards: Array) -> void:
	var travelling := session
	_travelling = true
	_target_object = ""
	stage.player.walk([] as Array[Vector2i])
	if _dialogue.is_open():
		await _dialogue.closed
	if go.get("as", "") == "quake" and session == travelling:
		await _quake()
	elif go.has("by") and session == travelling:
		await stage.ride(go["by"], go.get("with", []), RIDE_DURATION).finished
		if session == travelling:
			_build_stage()
	elif session == travelling:
		var fade := create_tween()
		fade.tween_property(_curtain, "color:a", 1.0, TRAVEL_FADE)
		fade.tween_callback(_build_stage)
		fade.tween_property(_curtain, "color:a", 0.0, TRAVEL_FADE)
		await fade.finished
	# A new game may have begun in the meantime. Then this journey is no longer anybody's.
	if session != travelling:
		return
	for effect: Dictionary in afterwards:
		if effect.has("say"):
			_say(effect)
	# A player lying on the ground gets up once they have come to, which is what they say there.
	if stage.player.is_lying():
		if _dialogue.is_open():
			await _dialogue.closed
		if session != travelling:
			return
		await stage.player.get_up().finished
		if session != travelling:
			return
	_travelling = false


## The ground shakes harder and harder while the music runs down, and the picture goes dark.
## After a while in the dark the light slowly returns on the place the player has been moved
## to, where they lie on the ground.
func _quake() -> void:
	# The mood on show stays as it is, so nothing sets the pitch of the music anew.
	if _mood_change:
		_mood_change.kill()
	_music.sink(QUAKE_DURATION)
	_rumble.play()
	_scene = create_tween().set_parallel()
	_scene.tween_method(_shake, 0.0, 1.0, QUAKE_DURATION).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	_scene.tween_property(_curtain, "color:a", 1.0, QUAKE_DARKENING).set_delay(QUAKE_DURATION - QUAKE_DARKENING)
	await _scene.finished
	_shake(0.0)
	# Stopped, the music of the other place starts afresh and fades in.
	_music.stop()
	_build_stage()
	stage.player.lie_down()
	_scene = create_tween()
	_scene.tween_interval(QUAKE_DARK)
	_scene.tween_property(_curtain, "color:a", 0.0, QUAKE_DAWN).set_trans(Tween.TRANS_SINE)
	await _scene.finished


## Throws the picture about, from not at all (0) to as hard as the quake gets (1).
func _shake(strength: float) -> void:
	_camera.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * QUAKE_SHAKE * strength


## Puts the world the player is in on show.
func _build_stage() -> void:
	if stage:
		stage.retire()
	if _memory:
		_memory.kill()
	_remembering = false
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
	memory_progress = 0.0

	_camera.position = _camera_target()
	_camera.reset_smoothing()
	if _started:
		_music.play(world.music)
	_change_mood(true)


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
	RenderingServer.global_shader_parameter_set(&"water_level", m.level)
	RenderingServer.global_shader_parameter_set(&"shadow", m.shadow)
	stage.set_mood(m.light, m.shadow)
	_grading.set_shader_parameter("saturation", m.saturation)
	_grading.set_shader_parameter("tint", Vector3(m.tint.r, m.tint.g, m.tint.b))
	_grading.set_shader_parameter("fog", m.fog)
	# The remembered part of the picture gets the colours of the intact world. The music has no
	# place, so all of it leans that way a little.
	var remembered := session.remembered_mood()
	_grading.set_shader_parameter("memory", memory_progress * MEMORY_STRENGTH)
	_grading.set_shader_parameter("memory_saturation", remembered.saturation)
	_grading.set_shader_parameter("memory_tint", Vector3(remembered.tint.r, remembered.tint.g, remembered.tint.b))
	_grading.set_shader_parameter("memory_fog", remembered.fog)
	var heard := Mood.blend(m, remembered, memory_progress * MEMORY_MUSIC)
	_music.set_mood(heard.pitch, heard.muffle)


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


## Lets the picture come out of the colour of the splash screen, so the game does not cut in.
## While it does, nothing can be done.
func _fade_in() -> void:
	_travelling = true
	_curtain.color = StartScreen.BACKGROUND
	_scene = create_tween()
	_scene.tween_interval(START_DARK)
	_scene.tween_property(_curtain, "color:a", 0.0, START_DAWN).set_trans(Tween.TRANS_SINE)
	# Every other fade goes to black.
	_scene.tween_callback(func() -> void:
		_curtain.color = Color(0, 0, 0, 0)
		_travelling = false
	)


func _build_curtain() -> void:
	_curtain = ColorRect.new()
	_curtain.color = Color(0, 0, 0, 0)
	_curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_curtain.set_anchors_preset(Control.PRESET_FULL_RECT)

	var canvas := CanvasLayer.new()
	canvas.layer = 30
	canvas.add_child(_curtain)
	add_child(canvas)
