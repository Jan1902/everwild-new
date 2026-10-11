class_name Mood
extends RefCounted
## All the dials that make a world feel right or wrong. Pure data.

## Wind direction and strength. Positive blows to the right, negative to the left.
var wind := 1.0
## Flow direction and speed of the water. Negative flows backwards.
var water := 1.0
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
	var m := Mood.new()
	m.wind = lerpf(a.wind, b.wind, weight)
	m.water = lerpf(a.water, b.water, weight)
	m.shadow = a.shadow.lerp(b.shadow, weight)
	m.saturation = lerpf(a.saturation, b.saturation, weight)
	m.tint = a.tint.lerp(b.tint, weight)
	m.fog = lerpf(a.fog, b.fog, weight)
	m.light = lerpf(a.light, b.light, weight)
	m.pitch = lerpf(a.pitch, b.pitch, weight)
	m.muffle = lerpf(a.muffle, b.muffle, weight)
	return m
