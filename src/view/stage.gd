class_name Stage
extends Node2D
## One world on show: its ground, water, shadows, objects and the player character. A new stage
## is built whenever the player changes worlds.

const SHADOW_OPACITY := 0.3
## Objects as the player remembers them show through in this colour.
const GHOST_COLOR := Color(1.15, 1.1, 1.0, 0.6)
const GHOST_FADE_OUT := 0.8
## Seconds something takes to appear that was not there before.
const APPEAR_DURATION := 2.5
## Where those aboard a vehicle stand, relative to its foot: the player first, then the others.
const SEATS: Array[Vector2] = [Vector2(-20, -8), Vector2(18, 4), Vector2(0, 0)]

var world: World
var player: Player

var _sprites: Sprites
var _flat := Node2D.new()
var _shadows := CanvasGroup.new()
var _marker := TargetMarker.new()
var _layer := Node2D.new()
var _wind: WindView
## Object id -> its view.
var _views := {}
var _ghosts: Array[ObjectView] = []
var _appear: Tween
var _light := 1.0
var _shadow_cast := Vector2(0.5, 0.2)


func _init(shown: World, sprites: Sprites, player_cell: Vector2i) -> void:
	world = shown
	_sprites = sprites
	_build_ground()
	add_child(WaterView.new(world, sprites))

	# Flat objects such as the bridge lie directly on the ground; the character always walks over them.
	add_child(_flat)

	# All shadows lie on the ground together. Drawn as one group, they do not get darker where
	# they overlap.
	_shadows.fit_margin = 400.0
	_shadows.clear_margin = 400.0
	_shadows.self_modulate = Color(1, 1, 1, SHADOW_OPACITY)
	add_child(_shadows)
	add_child(_marker)

	# All other objects and the character share one layer that sorts by y: whatever stands
	# further in front covers what is behind.
	_layer.y_sort_enabled = true
	add_child(_layer)
	for object in world.objects:
		_add_object(object)

	player = Player.new(sprites)
	player.place(player_cell)
	_layer.add_child(player)
	_shadows.add_child(player.shadow)

	# The wind is in the air, above everything that stands.
	_wind = WindView.new(_views)
	add_child(_wind)


## Takes the stage down. The character stops at once, so it reports no more cells.
func retire() -> void:
	player.set_process(false)
	queue_free()


## Lets the views follow the objects of the world: moved ones slide, changed ones are built anew.
func sync() -> void:
	for object in world.objects:
		var view: ObjectView = _views[object.id]
		if view.is_current(object) or view.follow(object):
			continue
		var was_visible := view.visible
		var was_lit := view.is_lit()
		if view.shadow:
			view.shadow.queue_free()
		view.queue_free()
		_add_object(object)
		# A light that has just been lit comes on, it does not snap on.
		if was_visible and not was_lit:
			_views[object.id].light_up()
		if not was_visible and not object.hidden:
			_views[object.id].modulate.a = 0.0
			create_tween().tween_property(_views[object.id], "modulate:a", 1.0, APPEAR_DURATION).set_trans(Tween.TRANS_SINE)


## The object under the point that is_usable (a function taking an object id) accepts: the one
## whose image is there, the one furthest in front first, otherwise the one standing on the
## tapped cell. Empty if there is none.
func object_at(point: Vector2, is_usable: Callable) -> String:
	var found := ""
	var front := -INF
	for object_id: String in _views:
		var view: ObjectView = _views[object_id]
		if view.covers(point) and view.position.y > front and is_usable.call(object_id):
			found = object_id
			front = view.position.y
	if found.is_empty():
		var object := world.object_at(Iso.to_cell(point))
		if object != null and is_usable.call(object.id):
			found = object.id
	return found


## Lets an object carry the player, and the given other objects with them, to the cell the
## world already has it on. Returns the movement, which takes the given number of seconds.
func ride(vehicle_id: String, passenger_ids: Array, duration: float) -> Tween:
	var vehicle: ObjectView = _views[vehicle_id]
	var way := vehicle.point_of(world.get_object(vehicle_id).cell) - vehicle.position
	var aboard: Array[Node2D] = [player]
	for passenger_id: String in passenger_ids:
		aboard.append(_views[passenger_id])
	player.shadow.visible = false
	var crossing := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	crossing.tween_property(vehicle, "position", vehicle.position + way, duration)
	if vehicle.shadow:
		crossing.tween_property(vehicle.shadow, "position", vehicle.shadow.position + way, duration)
	for number in aboard.size():
		var seat := vehicle.position + SEATS[number % SEATS.size()]
		# Standing a little in front of its foot, they are drawn over the vehicle. The crossing
		# starts from the seat whatever happens before its first step: a player who walked up to
		# the vehicle is still put on the cell they arrived on once more.
		crossing.tween_property(aboard[number], "position", seat + way, duration).from(seat)
	return crossing


## Brief feedback for a tap on a point of the world.
func mark(point: Vector2) -> void:
	_marker.show_at(point)


## Brightness of the lights, the shadow cast and the wind, from the mood of the world.
func set_mood(light: float, shadow_cast: Vector2, wind: float) -> void:
	_light = light
	_shadow_cast = shadow_cast
	# Indoors the air stands still.
	_wind.wind = wind if world.mood_from.is_empty() else 0.0
	for view: ObjectView in _views.values():
		view.light = light
		view.set_shadow_cast(shadow_cast)


## Lets the given objects show through as they were, appearing over the given number of seconds.
func remember(remembered: Array[WorldObject], fade_in: float) -> void:
	forget()
	if remembered.is_empty():
		return
	_appear = create_tween().set_parallel()
	for object in remembered:
		var ghost := ObjectView.new()
		ghost.setup(object, _sprites)
		ghost.light = _light
		ghost.modulate = Color(GHOST_COLOR, 0.0)
		ghost.z_index = 1
		_layer.add_child(ghost)
		_ghosts.append(ghost)
		_appear.tween_property(ghost, "modulate:a", GHOST_COLOR.a, fade_in).set_trans(Tween.TRANS_SINE)


## Lets the memory fade again.
func forget() -> void:
	if _appear:
		_appear.kill()
	for ghost in _ghosts:
		var fade := ghost.create_tween()
		fade.tween_property(ghost, "modulate:a", 0.0, GHOST_FADE_OUT)
		fade.tween_callback(ghost.queue_free)
	_ghosts.clear()


func _add_object(object: WorldObject) -> void:
	var view := ObjectView.new()
	view.setup(object, _sprites)
	view.light = _light
	(_flat if object.is_flat() else _layer).add_child(view)
	var shadow := view.build_shadow()
	if shadow:
		_shadows.add_child(shadow)
	view.set_shadow_cast(_shadow_cast)
	_views[object.id] = view


## Uses the painted ground image of the world. If there is none, the ground is drawn as a placeholder.
func _build_ground() -> void:
	var path: String = world.ground_image.get("path", "")
	if path.is_empty() or not ResourceLoader.exists(path):
		var placeholder := GroundView.new()
		placeholder.world = world
		add_child(placeholder)
		return
	var image := Sprite2D.new()
	image.texture = load(path)
	image.centered = false
	image.position = Vector2(world.ground_image.origin[0], world.ground_image.origin[1])
	image.scale = Vector2.ONE / world.ground_image.scale
	add_child(image)
