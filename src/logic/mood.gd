class_name Mood
extends RefCounted
## All the dials that make a world feel right or wrong. Pure data.

## Names of all dials, as used in world files.
const DIALS := ["wind", "water", "level", "shadow", "saturation", "tint", "fog", "light", "pitch", "muffle"]

## Wind direction and strength. Positive blows to the right, negative to the left.
var wind := 1.0
## Flow direction and speed of the water. Negative flows backwards.
var water := 1.0
## Level of the water, from dry (0) to full (1). As it falls, the bed comes out from the banks.
var level := 1.0
## Shadow cast in the ground plane, seen from above: direction and length per unit of object
## height. x points right on screen, y towards the viewer.
var shadow := Vector2(0.5, 0.2)
## Colour saturation of the whole picture, 1 is normal.
var saturation := 1.0
## Colour tint of the whole picture, white is none.
var tint := Color.WHITE
## Haze over the whole picture, 0 to 1.
var fog := 0.0
## Brightness of the lights in the world.
var light := 1.0
## Pitch and tempo of the music, 1 is normal.
var pitch := 1.0
## How muffled the music sounds, 0 to 1.
var muffle := 0.0


## Reads a mood. Dials that are not given come from the base or stay at their normal value.
static func from_data(data: Dictionary, base: Mood = null) -> Mood:
	var m := blend(base, base, 0.0) if base else Mood.new()
	m.wind = data.get("wind", m.wind)
	m.water = data.get("water", m.water)
	m.level = data.get("level", m.level)
	m.saturation = data.get("saturation", m.saturation)
	m.fog = data.get("fog", m.fog)
	m.light = data.get("light", m.light)
	m.pitch = data.get("pitch", m.pitch)
	m.muffle = data.get("muffle", m.muffle)
	if data.has("shadow"):
		m.shadow = Vector2(data.shadow[0], data.shadow[1])
	if data.has("tint"):
		m.tint = Color(data.tint[0], data.tint[1], data.tint[2])
	return m


## State between two moods: weight 0 gives a, weight 1 gives b.
static func blend(a: Mood, b: Mood, weight: float) -> Mood:
	return blend_dials(a, b, {}, weight)


## Like blend, but with a weight of its own for every dial named in weights. All other dials use
## the general weight.
static func blend_dials(a: Mood, b: Mood, weights: Dictionary, general := 0.0) -> Mood:
	var m := Mood.new()
	for dial: String in DIALS:
		m.set(dial, lerp(a.get(dial), b.get(dial), float(weights.get(dial, general))))
	return m
