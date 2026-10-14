class_name Cutscene
extends RefCounted
## Plays a scene: a short stretch in which the game takes the controls and shows something
## happen, such as the old man leaving for the evening. The scenes are data in data/scenes.json:
## scene id -> a list of steps, played one after the other.
##
## Steps:
##   {"walk": who, "to": [x, y], "speed": cells/s, "follow": bool}
##                                 a person walks to a cell of the world on show, along the
##                                 shortest path; with "follow" the camera goes along. who is an
##                                 object of the world or an actor of the scene
##   {"enter": who, "object": id}  a person steps into an object, such as an arch, and is gone
##   {"fade": who}                 a person fades away where they stand
##   {"actor": id, "kind": kind, "cell": [x, y]}
##                                 someone who is not part of the world on show appears there
##   {"world": id, "camera": [x, y]}
##                                 the picture goes dark and comes back on another world, with
##                                 the camera on the cell; the player is not in it
##   {"camera": [x, y], "seconds": s, "lift": pixels}
##                                 the camera glides to a cell, lifted up by as many pixels
##   {"light": [x, y], "lift": pixels}
##                                 a light comes on far away, above the cell
##   {"wait": seconds}
## When the scene is over the picture goes dark and comes back on the player's world.

const PATH := "res://data/scenes.json"
## Seconds the picture takes to go dark and to come back when the scene changes worlds.
const FADE := 0.6
const WALK_SPEED := 1.2
const FADE_OUT := 0.8

## The game the scene is played in. It provides the stage, the camera and the curtain.
var _game: Node2D


func _init(game: Node2D) -> void:
	_game = game


## All scenes: id -> steps.
static func read() -> Dictionary:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	return data if data is Dictionary else {}


## Plays the scene. Await it.
func play(scene_id: String) -> void:
	var steps: Array = read().get(scene_id, [])
	var actors := {}
	for step: Dictionary in steps:
		var stage: Stage = _game.stage
		if step.has("walk"):
			var view := _figure(step["walk"], actors)
			if view == null or view.life == null:
				continue
			var from := Iso.to_cell(view.position)
			var path := stage.world.find_path(from, _cell(step["to"]))
			var points: Array[Vector2] = []
			for cell in path.slice(1):
				points.append(Iso.to_point(Vector2(cell)))
			if step.get("follow", false):
				_game.focus_on(view)
			await _walk(view, points, step.get("speed", WALK_SPEED))
		elif step.has("enter"):
			var view := _figure(step["enter"], actors)
			var into := stage.view_of(step.get("object", ""))
			if view and view.life and into:
				var fading := view.create_tween()
				fading.tween_property(view, "modulate:a", 0.0, FADE_OUT).set_delay(0.4)
				await _walk(view, [into.position], step.get("speed", WALK_SPEED))
		elif step.has("fade"):
			var view := _figure(step["fade"], actors)
			if view:
				var fading := view.create_tween()
				fading.tween_property(view, "modulate:a", 0.0, FADE_OUT)
				await fading.finished
		elif step.has("actor"):
			var thing := WorldObject.new()
			thing.id = step["actor"]
			thing.kind = step.get("kind", "")
			thing.cell = _cell(step.get("cell", [0, 0]))
			actors[thing.id] = stage.add_actor(thing)
		elif step.has("world"):
			await _game.fade_curtain(1.0, FADE)
			actors.clear()
			_game.show_world(step["world"])
			_game.focus_on(Iso.to_point(Vector2(_cell(step.get("camera", [0, 0])))))
			await _game.fade_curtain(0.0, FADE)
		elif step.has("camera"):
			var point := Iso.to_point(Vector2(_cell(step["camera"]))) + Vector2(0, -step.get("lift", 0.0))
			await _game.glide_camera(point, step.get("seconds", 2.0))
		elif step.has("light"):
			var point := Iso.to_point(Vector2(_cell(step["light"]))) + Vector2(0, -step.get("lift", 0.0))
			stage.add_far_light(point)
		elif step.has("wait"):
			await _game.get_tree().create_timer(step["wait"]).timeout
	await _game.fade_curtain(1.0, FADE)
	_game.end_scene()
	await _game.fade_curtain(0.0, FADE)


func _walk(view: ObjectView, points: Array[Vector2], speed: float) -> void:
	if points.is_empty():
		return
	var done := [false]
	view.life.walk(points, speed, func() -> void: done[0] = true)
	while not done[0] and is_instance_valid(view):
		await _game.get_tree().process_frame


func _figure(who: String, actors: Dictionary) -> ObjectView:
	if actors.has(who):
		return actors[who]
	return _game.stage.view_of(who)


static func _cell(pair: Array) -> Vector2i:
	return Vector2i(int(pair[0]), int(pair[1]))
