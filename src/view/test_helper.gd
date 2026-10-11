class_name TestHelper
extends Node
## Drives the running game through command line arguments so it can be checked automatically.
##
##   godot --path . -- --tap=16,9 --wait=6 --screenshot=C:/path/image.png
##
## --tap=x,y          taps the cell (may be given several times, one after another with --wait
##                    seconds in between)
## --wait=s           waiting time after each tap, default 1
## --screenshot=path  saves a screenshot at the end
## --intact           starts in the intact version of the world
## --save=path        loads the game from this file and saves it there (without it, runs with
##                    arguments neither load nor save)
## Afterwards the character's cell, the open faults and the music position are printed and the
## game quits.


func _ready() -> void:
	var taps: Array[Vector2i] = []
	var wait := 1.0
	var screenshot := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--tap="):
			var parts := argument.trim_prefix("--tap=").split(",")
			taps.append(Vector2i(int(parts[0]), int(parts[1])))
		elif argument.begins_with("--wait="):
			wait = float(argument.trim_prefix("--wait="))
		elif argument.begins_with("--screenshot="):
			screenshot = argument.trim_prefix("--screenshot=")

	var game := get_parent()
	if "--intact" in OS.get_cmdline_user_args():
		game.set_broken(false, true)
	await get_tree().create_timer(0.5).timeout
	for cell in taps:
		_tap(game, cell)
		await get_tree().create_timer(wait).timeout
	if taps.is_empty():
		await get_tree().create_timer(wait).timeout

	if not screenshot.is_empty():
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(screenshot)
	print("player=%d,%d open_faults=%s music=%.1f" % [
		game.player.cell.x, game.player.cell.y, ",".join(game.session.open_faults()), game.music_position(),
	])
	# The music has to have died away before Godot closes, otherwise it reports a leak.
	game.stop_music()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


## Sends a real touch to the screen position of the cell, so the conversion is checked as well.
func _tap(game: Node2D, cell: Vector2i) -> void:
	# Input arrives in window coordinates, that is before scaling to the base resolution.
	var spot := get_viewport().get_final_transform() * game.get_canvas_transform() * Iso.to_point(cell)
	for pressed: bool in [true, false]:
		var touch := InputEventScreenTouch.new()
		touch.position = spot
		touch.pressed = pressed
		Input.parse_input_event(touch)
