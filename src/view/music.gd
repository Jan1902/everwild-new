class_name Music
extends Node
## Plays the track of the world and fades over to another one when the world changes. The mood
## of the world sets pitch and muffling; music that is off pitch wavers as well. The music has a bus of its own (default_bus_layout.tres),
## so the muffling does not hit any other sounds.

const BUS := &"Music"
const VOLUME := -6.0
const SILENT := -40.0
## Seconds a track takes to fade in, and the previous one to fade out.
const CROSSFADE := 3.0
## Pitch the music has run down to when it has sunk away.
const SUNK_PITCH := 0.45
## Music that is off pitch also wavers, like a tape that does not run evenly: how far the pitch
## swings to either side for a pitch that is off by one (it is never off by that much), and the
## two speeds of the swinging in turns per second.
const WAVER := 0.28
const WAVER_SPEEDS := [0.37, 1.13]

## Two players that swap roles: one plays the current track, the other one lets the previous
## track fade out.
var _current := AudioStreamPlayer.new()
var _leaving := AudioStreamPlayer.new()
## Player -> the fade in progress on it.
var _fades := {}
var _muffler: AudioEffectLowPassFilter
## Pitch the mood asks for, and seconds the wavering around it has been going on.
var _pitch := 1.0
var _waver_time := 0.0
## While the music runs down, its pitch belongs to that.
var _sinking := false


func _ready() -> void:
	# The music plays on while the game is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	for player: AudioStreamPlayer in [_current, _leaving]:
		player.bus = BUS
		add_child(player)
	var bus := AudioServer.get_bus_index(BUS)
	for effect in AudioServer.get_bus_effect_count(bus):
		if AudioServer.get_bus_effect(bus, effect) is AudioEffectLowPassFilter:
			_muffler = AudioServer.get_bus_effect(bus, effect)


func _process(delta: float) -> void:
	if _sinking:
		return
	_waver_time += delta
	var swing := 0.6 * sin(TAU * WAVER_SPEEDS[0] * _waver_time) + 0.4 * sin(TAU * WAVER_SPEEDS[1] * _waver_time)
	var pitch := _pitch * (1.0 + absf(1.0 - _pitch) * WAVER * swing)
	_current.pitch_scale = pitch
	_leaving.pitch_scale = pitch


## Fades in a track while the previous one fades out. A track that is already playing just keeps
## playing. An empty path fades to silence.
func play(path: String) -> void:
	if _current.stream and _current.stream.resource_path == path:
		return
	var leaving := _current
	_current = _leaving
	_leaving = leaving
	if leaving.playing:
		_fade(leaving, SILENT).tween_callback(leaving.stop)
	# The player that takes over may still be fading out an earlier track.
	_stop_fade(_current)
	_current.stop()
	_current.stream = null
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	_current.stream = load(path)
	_current.volume_db = SILENT
	_current.play()
	_fade(_current, VOLUME)


## Lets the music run down like a music box: slower, deeper and quieter, until it is gone after
## the given number of seconds. stop() ends that; the next track then starts afresh.
func sink(duration: float) -> void:
	_sinking = true
	_stop_fade(_current)
	var sinking := create_tween().set_parallel()
	sinking.tween_property(_current, "pitch_scale", _current.pitch_scale * SUNK_PITCH, duration)
	sinking.tween_property(_current, "volume_db", SILENT, duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	_fades[_current] = sinking


## Stops everything at once.
func stop() -> void:
	_sinking = false
	for player: AudioStreamPlayer in [_current, _leaving]:
		_stop_fade(player)
		player.stop()
		player.stream = null


## Seconds the current track has been playing. -1 without music.
func position() -> float:
	return _current.get_playback_position() if _current.playing else -1.0


## How loud the music is as a whole, from 0 (silent) to 1.
func set_volume(volume: float) -> void:
	var bus := AudioServer.get_bus_index(BUS)
	AudioServer.set_bus_mute(bus, volume <= 0.0)
	AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(volume, 0.001)))


## Pitch (1 is normal) and muffling (0 to 1) from the mood of the world.
func set_mood(pitch: float, muffle: float) -> void:
	_pitch = pitch
	if _muffler:
		# From open (20 kHz) to heavily muffled (800 Hz), spread evenly by ear.
		_muffler.cutoff_hz = 20000.0 * pow(0.04, muffle)


func _fade(player: AudioStreamPlayer, volume: float) -> Tween:
	_stop_fade(player)
	var fade := create_tween()
	fade.tween_property(player, "volume_db", volume, CROSSFADE)
	_fades[player] = fade
	return fade


func _stop_fade(player: AudioStreamPlayer) -> void:
	if _fades.has(player):
		_fades[player].kill()
		_fades.erase(player)
