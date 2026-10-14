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
## How bright the picture flares at the start of the quake, from 0 to 1.
const QUAKE_FLASH := 0.85
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
## Seconds without anything going on before the hint the world has for the moment shows, and how
## far above an object it floats.
const HINT_DELAY := 1.6
const HINT_LIFT := 0.0
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
const WHOLE_GLOW := 0.36
## Motes of light that rise when a world becomes whole.
const WHOLE_MOTES := 90
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
var _sounds := Sounds.new()
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
## Seconds nothing has been going on, for the hints.
var _hint_wait := 0.0
## What the camera follows during a scene instead of the player: a node or a point of the world
## (Vector2.INF for none).
var _focus_node: Node2D
var _focus_point := Vector2.INF
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
	add_child(_sounds)
	_rumble.bus = Sounds.BUS
	if ResourceLoader.exists(QUAKE_SOUND):
		_rumble.stream = load(QUAKE_SOUND)
	add_child(_rumble)
	_music.set_volume(_settings.music_volume)
	_sounds.set_volume(_settings.sound_volume)
	_notebook.sounds = _sounds
	_notebook.dialogue = _dialogue
	_notebook.opened.connect(_on_notebook_opened)
	_notebook.thought.connect(_show)
	add_child(_notebook)
	_dialogue.line_begun.connect(_sounds.voice)
	add_child(_dialogue)
	_pause.set_volume(_settings.music_volume, _settings.sound_volume)
	_pause.volume_changed.connect(_on_volume_changed)
	_pause.sound_volume_changed.connect(_on_sound_volume_changed)
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
	stage.speaker = _dialogue.speaker()
	# Standing on a place of memory, the player sees it gather while they wait.
	var spots := stage.memory_spots
	spots.focus = stage.player.cell
	var waiting := 0.0 if _lingered or walking else clampf(_idle / LINGER_DELAY, 0.0, 1.0)
	spots.progress = move_toward(spots.progress, waiting, delta * 2.0)
	_update_hint(delta, walking)


## Shows the hint the world has for this moment once the player has stood about for a while
## without anything going on, and takes it away as soon as they do something.
func _update_hint(delta: float, walking: bool) -> void:
	var calm := not walking and not _travelling and _started and not _dialogue.is_open() and not _notebook.is_open()
	_hint_wait = _hint_wait + delta if calm else 0.0
	var hint := session.hint() if _hint_wait >= HINT_DELAY else {}
	var target := Vector2.INF
	if hint.has("object"):
		var view := stage.view_of(hint["object"])
		if view:
			target = view.position + Vector2(0, -view.height() - HINT_LIFT)
	elif hint.has("cell"):
		target = Iso.to_point(World.read_properties(hint).cell)
	stage.hint.point_at(target, hint.has("cell"))
	_notebook.hint(hint.get("notebook", false))


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
	_hint_wait = 0.0
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


## The first time the notebook is opened ends the hint that points at it. While the book is
## open, the character stops where they are, so nothing starts talking behind it.
func _on_notebook_opened() -> void:
	session.state.facts["notebook_read"] = true
	_target_object = ""
	stage.player.walk([] as Array[Vector2i])
	save()


func _on_sound_volume_changed(volume: float) -> void:
	_settings.sound_volume = volume
	_sounds.set_volume(volume)


func _on_language_changed(language: String) -> void:
	_settings.language = language
	_settings.write()
	Texts.use(language)
	_notebook.retranslate()


func _on_start_dismissed() -> void:
	_started = true
	session.state.start_screen_seen = true
	save()
	_music.play(session.music())


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
	stage.memory_spots.hold(true)
	_place_memory()
	_change_memory(1.0, MEMORY_FADE_IN)


## Lets the memory fade again.
func _forget() -> void:
	if not _remembering:
		return
	_remembering = false
	stage.forget()
	stage.memory_spots.hold(false)
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
	var scene := effects.find_custom(func(effect: Dictionary) -> bool: return effect.has("scene"))
	# What is said after a scene or after leaving waits for the end of the scene or the arrival.
	var cut := leaving if scene < 0 or (leaving >= 0 and leaving < scene) else scene
	# What has changed hands since the last thing said. Words alone do not always make that
	# clear, so the next thing said carries it as a mark in the corner of the dialogue.
	var changed_hands := []
	for number in effects.size():
		var effect: Dictionary = effects[number]
		if effect.has("give"):
			changed_hands.append("+ " + Texts.text("item." + effect["give"]))
		if effect.has("take"):
			changed_hands.append("− " + Texts.text("item." + effect["take"]))

		if effect.has("whole"):
			_celebrate(effect["whole"])
		if effect.has("say") and (cut < 0 or number < cut):
			_say(effect, "   ".join(changed_hands))
			changed_hands.clear()
	if cut >= 0 and cut == scene:
		if _started:
			_music.play(session.music())
		_play_scene(effects[scene]["scene"], effects.slice(scene + 1))
	elif leaving >= 0:
		_travel(effects[leaving], effects.slice(leaving + 1))
	else:
		stage.sync()
		stage.memory_spots.show_on(session.memory_cells())
		_change_mood()
		_greet_whole()
		# Something may have started or stopped playing, such as the music box.
		if _started:
			_music.play(session.music())
	save()


## Plays a scene once what is being said has been heard out, then shows what the rule does
## after it: what is said, and leaving if it leaves.
func _play_scene(scene_id: String, afterwards: Array) -> void:
	var playing := session
	_travelling = true
	_target_object = ""
	stage.player.walk([] as Array[Vector2i])
	if _dialogue.is_open():
		await _dialogue.closed
	if session != playing:
		return
	await Cutscene.new(self).play(scene_id)
	if session != playing:
		return
	_travelling = false
	var leaving := afterwards.find_custom(func(effect: Dictionary) -> bool: return effect.has("go"))
	for number in afterwards.size():
		if afterwards[number].has("say") and (leaving < 0 or number < leaving):
			_say(afterwards[number])
	if leaving >= 0:
		_travel(afterwards[leaving], afterwards.slice(leaving + 1))
	save()


## Puts another world on show for a scene, without the player in it.
func show_world(world_id: String) -> void:
	if stage:
		stage.retire()
	stage = Stage.new(session.world(world_id), _sprites, Vector2i(-1, -1))
	stage.player.visible = false
	stage.player.shadow.visible = false
	add_child(stage)
	_mood_from = session.mood(world_id)
	_mood_to = _mood_from
	mood_progress = 1.0


## Ends a scene: the player's world is on show again and the camera follows them.
func end_scene() -> void:
	_focus_node = null
	_focus_point = Vector2.INF
	_build_stage()


## Lets the camera follow a node, or rest on a point of the world.
func focus_on(target: Variant) -> void:
	_focus_node = target if target is Node2D else null
	_focus_point = target if target is Vector2 else Vector2.INF


## Lets the camera glide to a point of the world over the given seconds. Await it.
func glide_camera(point: Vector2, seconds: float) -> void:
	var from := _camera_target()
	_focus_node = null
	_focus_point = from
	var glide := create_tween()
	glide.tween_property(self, "_focus_point", point, seconds).set_trans(Tween.TRANS_SINE)
	await glide.finished


## Lets the curtain over the picture go to an opacity over the given seconds. Await it.
func fade_curtain(alpha: float, seconds: float) -> void:
	var fade := create_tween()
	fade.tween_property(_curtain, "color:a", alpha, seconds)
	await fade.finished


func _say(effect: Dictionary, mark := "") -> void:
	# Lines without a speaker are the player talking to themselves, which is not heard.
	var who: String = effect.get("who", "self")
	_dialogue.say(Texts.text("name." + who), Texts.lines(effect["say"]), mark, who)


## Marks the moment a world has become whole: the notebook has something new to show, and if
## the player is there, warm light swells over the picture. What it means is for those who live
## there to say (see _greet_whole).
func _celebrate(world_id: String) -> void:
	_notebook.mark_unread()
	var here := stage.world
	if world_id != here.id and world_id != here.mood_from:
		return
	# The moment belongs to the world, not to the words: it waits for what is said and for a
	# crossing to be over.
	var celebrating := session
	while _dialogue.is_open() or _travelling:
		await get_tree().process_frame
	if session != celebrating:
		return
	var glow := create_tween()
	glow.tween_method(_set_glow, 0.0, WHOLE_GLOW, WHOLE_GLOW_IN).set_trans(Tween.TRANS_SINE)
	glow.tween_method(_set_glow, WHOLE_GLOW, 0.0, WHOLE_GLOW_OUT).set_trans(Tween.TRANS_SINE)
	_sounds.play("whole")
	_rise_motes()


## Motes of warm light that rise over the whole picture and fade, as a world becomes whole.
func _rise_motes() -> void:
	var screen := get_viewport_rect().size
	var motes := CPUParticles2D.new()
	motes.amount = WHOLE_MOTES
	motes.one_shot = true
	motes.explosiveness = 0.25
	motes.lifetime = 4.5
	motes.position = Vector2(screen.x * 0.5, screen.y + 20.0)
	motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	motes.emission_rect_extents = Vector2(screen.x * 0.5, 40.0)
	motes.direction = Vector2.UP
	motes.spread = 12.0
	motes.gravity = Vector2.ZERO
	motes.initial_velocity_min = 140.0
	motes.initial_velocity_max = 320.0
	motes.scale_amount_min = 4.0
	motes.scale_amount_max = 10.0
	var fade := Gradient.new()
	fade.set_color(0, Color(1.0, 0.9, 0.6, 0.0))
	fade.add_point(0.2, Color(1.0, 0.92, 0.65, 0.85))
	fade.set_color(fade.get_point_count() - 1, Color(1.0, 0.85, 0.5, 0.0))
	motes.color_ramp = fade
	var layer := CanvasLayer.new()
	layer.layer = 11
	layer.add_child(motes)
	add_child(layer)
	motes.finished.connect(layer.queue_free)
	motes.emitting = true


## The first time the player is in a world that has become whole, someone there says so: that
## it is suddenly as it used to be, and that they remember. A world that became whole while the
## player was elsewhere greets them when they come back.
func _greet_whole() -> void:
	var here := stage.world
	if here.whole_says.is_empty() or here.id in session.state.whole_greeted:
		return
	if here.id not in session.whole_worlds() or not session.holds(here.whole_says.get("if", []), here.id):
		return
	session.state.whole_greeted.append(here.id)
	_say(here.whole_says)
	save()


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
	_greet_whole()
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
	# First it grows bright as noon for a moment, as the child will remember it.
	var flash := create_tween()
	flash.tween_method(_set_glow, 0.0, QUAKE_FLASH, 0.3).set_trans(Tween.TRANS_SINE)
	flash.tween_method(_set_glow, QUAKE_FLASH, 0.0, 1.4).set_trans(Tween.TRANS_SINE)
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
	stage.kindled.connect(_on_kindled)
	add_child(stage)
	stage.memory_spots.show_on(session.memory_cells())
	memory_progress = 0.0

	_camera.position = _camera_target()
	_camera.reset_smoothing()
	if _started:
		_music.play(session.music())
	_change_mood(true)


## A light has come on: a flame catches with a soft rush, an open way hums lower and longer.
func _on_kindled(object_id: String) -> void:
	var lamp := object_id.is_empty() or stage.world.get_object(object_id).kind != "arch"
	_sounds.play("kindle", 0.0 if lamp else -4.0, 1.0 if lamp else 0.6)


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
	stage.set_mood(m.light, m.shadow, m.wind)
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
	if is_instance_valid(_focus_node):
		return _focus_node.position + Vector2(0, -40)
	if _focus_point != Vector2.INF:
		return _focus_point
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
