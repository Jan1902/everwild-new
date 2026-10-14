class_name Sounds
extends Node
## Plays the small sounds of the game on their own bus ("Sounds" in default_bus_layout.tres), so
## the muffling of the music does not touch them and they have a volume of their own. The sounds
## are computed by tools/sound_effects.py.

const BUS := &"Sounds"
const DIR := "res://assets/sounds/"
## Players that can sound at the same time.
const VOICES := 6
## How much the pitch of a syllable of a voice may vary to either side.
const SYLLABLE_SPREAD := 0.07
## Whether people babble. The computed voices sounded like robots, not people (Jan, 2026-10-14);
## they stay silent until there is a better voice.
const BABBLE := false

var _players: Array[AudioStreamPlayer] = []
var _next := 0
## Name -> stream, loaded when first played. Null for names without a file.
var _streams := {}
## Speaker -> their syllables.
var _syllables := {}


func _ready() -> void:
	# Sounds go on while the game is paused, so the pause page itself is not silent.
	process_mode = Node.PROCESS_MODE_ALWAYS
	for number in VOICES:
		var player := AudioStreamPlayer.new()
		player.bus = BUS
		add_child(player)
		_players.append(player)


## Plays a sound by its file name without extension, for example "kindle".
func play(name: String, volume_db := 0.0, pitch := 1.0) -> void:
	var stream := _stream(name)
	if stream == null:
		return
	var player := _players[_next]
	_next = (_next + 1) % _players.size()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch
	player.play()


## One syllable of the babbling voice of a speaker. Speakers without a voice stay silent.
func syllable(speaker: String) -> void:
	if not BABBLE:
		return
	if not _syllables.has(speaker):
		var found: Array[String] = []
		for number in range(1, 13):
			var name := "voices/%s_%d" % [speaker, number]
			if ResourceLoader.exists(DIR + name + ".wav"):
				found.append(name)
		_syllables[speaker] = found
	var syllables: Array = _syllables[speaker]
	if syllables.is_empty():
		return
	play(syllables.pick_random(), -4.0, randf_range(1.0 - SYLLABLE_SPREAD, 1.0 + SYLLABLE_SPREAD))


## How loud the sounds are as a whole, from 0 (silent) to 1.
func set_volume(volume: float) -> void:
	var bus := AudioServer.get_bus_index(BUS)
	AudioServer.set_bus_mute(bus, volume <= 0.0)
	AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(volume, 0.001)))


func _stream(name: String) -> AudioStream:
	if not _streams.has(name):
		var path := DIR + name + ".wav"
		_streams[name] = load(path) if ResourceLoader.exists(path) else null
	return _streams[name]
