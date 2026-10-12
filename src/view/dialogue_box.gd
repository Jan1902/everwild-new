class_name DialogueBox
extends CanvasLayer
## Shows what someone says, line by line, at the bottom of the screen. A tap shows the whole
## line at once, the next tap moves on. Once a line is complete, a small pulsing arrow shows that
## a tap continues. While the box is open it takes all taps, wherever they land.

## Characters per second the text appears with.
const SPEED := 45.0
## Seconds a line has to be on screen before a tap counts, so a tap meant for the world does
## not skip it.
const GRACE := 0.25

## Covers the whole screen while the box is open and catches every tap.
var _cover := Control.new()
var _name := Label.new()
var _text := Label.new()
var _arrow := Control.new()
## Lines still to come, each with "who" (name, may be empty) and "line".
var _queue: Array[Dictionary] = []
var _open := false
var _shown_for := 0.0
## Whether the whole line is on screen.
var _complete := false


func _ready() -> void:
	layer = 20
	_cover.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cover.mouse_filter = Control.MOUSE_FILTER_STOP
	_cover.gui_input.connect(_on_cover_input)
	_cover.visible = false
	add_child(_cover)

	var panel := PanelContainer.new()
	panel.theme_type_variation = &"DialoguePanel"
	panel.anchor_left = 0.14
	panel.anchor_right = 0.86
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_top = -300.0
	panel.offset_bottom = -50.0
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cover.add_child(panel)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(column)

	_name.theme_type_variation = &"DialogueName"
	column.add_child(_name)

	_text.theme_type_variation = &"DialogueText"
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_text)

	# The arrow sits in the lower right corner of the panel.
	_arrow.anchor_left = 0.86
	_arrow.anchor_right = 0.86
	_arrow.anchor_top = 1.0
	_arrow.anchor_bottom = 1.0
	_arrow.offset_left = -76.0
	_arrow.offset_top = -106.0
	_arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_arrow.draw.connect(_draw_arrow)
	_arrow.visible = false
	_cover.add_child(_arrow)


func is_open() -> bool:
	return _open


## Adds lines to show. who is the name of the speaker, empty for none.
func say(who: String, lines: Array[String]) -> void:
	for line in lines:
		_queue.append({"who": who, "line": line})
	if not is_open():
		_next()


func _process(delta: float) -> void:
	if not is_open():
		return
	_shown_for += delta
	if not _complete:
		var shown := int(_shown_for * SPEED)
		if shown >= _text.get_total_character_count():
			_reveal()
		else:
			_text.visible_characters = shown
	# The arrow bobs gently and breathes, so it reads as "go on" without nagging.
	_arrow.modulate.a = 0.65 + 0.35 * sin(_shown_for * 4.0)
	_arrow.queue_redraw()


func _on_cover_input(event: InputEvent) -> void:
	# A tap arrives as a touch and as a mouse click. Only the touch of the first finger counts.
	var touch := event as InputEventScreenTouch
	if touch == null or not touch.pressed or touch.index != 0 or not is_open() or _shown_for < GRACE:
		return
	if _complete:
		_next()
	else:
		_reveal()


## Shows the whole line and the arrow.
func _reveal() -> void:
	_complete = true
	_text.visible_characters = -1
	_arrow.visible = true


func _draw_arrow() -> void:
	var bob := Vector2(0, sin(_shown_for * 4.0) * 5.0)
	_arrow.draw_colored_polygon(
		PackedVector2Array([bob, bob + Vector2(32, 0), bob + Vector2(16, 20)]),
		_name.get_theme_color(&"font_color")
	)


func _hide_cover() -> void:
	# Something else may have been said in the meantime.
	_cover.visible = _open


func _next() -> void:
	_complete = false
	_arrow.visible = false
	if _queue.is_empty():
		_open = false
		# The cover stays until the tap that closed the box has passed, so that tap does not
		# reach the world as well.
		_hide_cover.call_deferred()
		return
	var entry: Dictionary = _queue.pop_front()
	_name.text = entry.who
	_name.visible = not entry.who.is_empty()
	_text.text = entry.line
	_text.visible_characters = 0
	_shown_for = 0.0
	_open = true
	_cover.visible = true
