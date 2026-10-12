class_name TestHelper
extends Node
## Drives the running game through command line arguments so it can be checked automatically.
## Only debug builds take the arguments.
##
##   godot --path . -- --tap=16,9 --wait=6 --screenshot=C:/path/image.png
##
## --tap=x,y          taps the cell
## --touch=x,y        taps a point of the screen, in pixels of the base resolution (1920x1080),
##                    to reach the notebook button or the dialogue
## --notebook[=note]  opens the notebook, on this note if one is given
## --back             does what the back gesture of a phone does
##                    (these four may be given several times and happen in the order given,
##                    with --wait seconds after each)
## --wait=s           waiting time after each step, default 1
## --mouse            taps come from the mouse, as on a computer, instead of a finger
## --screenshot=path  saves a screenshot at the end
## --intact           starts in the intact version of the world
## --save=path        loads the game from this file and saves it there (without it, runs with
##                    arguments neither load nor save)
## --settings=path    the same for the settings of the pause page
## --start-screen     shows the start screen, which runs with arguments skip otherwise
## --language=code    shows the texts in this language instead of the one of the device
## Afterwards the character's cell, the open faults, whether a dialogue is open, whether the game
## is paused, the music position and the language are printed and the game quits.

var _by_mouse := false


func _ready() -> void:
	var arguments := OS.get_cmdline_user_args()
	var steps: Array[Callable] = []
	var wait := 1.0
	var screenshot := ""
	var game := get_parent()
	_by_mouse = "--mouse" in arguments
	for argument in arguments:
		if argument.begins_with("--tap="):
			steps.append(_tap_cell.bind(game, _pair(argument)))
		elif argument.begins_with("--touch="):
			steps.append(_tap.bind(Vector2(_pair(argument))))
		elif argument.begins_with("--notebook"):
			steps.append(game.open_notebook.bind(argument.trim_prefix("--notebook").trim_prefix("=")))
		elif argument == "--back":
			steps.append(game.notification.bind(NOTIFICATION_WM_GO_BACK_REQUEST))
		elif argument.begins_with("--wait="):
			wait = float(argument.trim_prefix("--wait="))
		elif argument.begins_with("--screenshot="):
			screenshot = argument.trim_prefix("--screenshot=")

	if "--intact" in arguments:
		game.set_broken(false, true)
	await get_tree().create_timer(0.5).timeout
	for step in steps:
		step.call()
		await get_tree().create_timer(wait).timeout
	if steps.is_empty():
		await get_tree().create_timer(wait).timeout

	if not screenshot.is_empty():
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(screenshot)
	print("player=%d,%d open_faults=%s talking=%s paused=%s music=%.1f language=%s" % [
		game.stage.player.cell.x, game.stage.player.cell.y, ",".join(game.session.open_faults()), game.is_talking(),
		game.is_paused(), game.music_position(), Texts.language,
	])
	# The music has to have died away before Godot closes, otherwise it reports a leak.
	game.stop_music()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


## The two numbers of an argument like --tap=3,7.
func _pair(argument: String) -> Vector2i:
	var parts := argument.get_slice("=", 1).split(",")
	return Vector2i(int(parts[0]), int(parts[1]))


## Taps the screen position of a cell, so the conversion is checked as well.
func _tap_cell(game: Node2D, cell: Vector2i) -> void:
	_tap(game.get_canvas_transform() * Iso.to_point(cell))


## Sends a real tap to a point of the screen, given in pixels of the base resolution.
func _tap(point: Vector2) -> void:
	# Input arrives in window coordinates, that is before scaling to the base resolution.
	var spot := get_viewport().get_final_transform() * point
	for pressed: bool in [true, false]:
		if _by_mouse:
			var click := InputEventMouseButton.new()
			click.button_index = MOUSE_BUTTON_LEFT
			click.position = spot
			click.global_position = spot
			click.pressed = pressed
			Input.parse_input_event(click)
		else:
			var touch := InputEventScreenTouch.new()
			touch.position = spot
			touch.pressed = pressed
			Input.parse_input_event(touch)
