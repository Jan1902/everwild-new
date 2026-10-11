class_name DialogueBox
extends CanvasLayer
## Shows what someone says, line by line, at the bottom of the screen. A tap shows the whole
## line at once, the next tap moves on. Once a line is complete, a small pulsing arrow shows that
## a tap continues. While the box is open it takes all taps.

signal finished

## Characters per second the text appears with.
const SPEED := 45.0
## Seconds a line has to be on screen before a tap counts, so a tap meant for the world does
## not skip it.
const GRACE := 0.25
const PANEL_COLOR := Color(0.09, 0.1, 0.14, 0.84)
const NAME_COLOR := Color(0.95, 0.8, 0.55)
const TEXT_COLOR := Color(0.96, 0.95, 0.92)

var _panel: PanelContainer
var _name: Label
var _text: Label
## Lines still to come, each with "who" (name, may be empty) and "line".
var _queue: Array[Dictionary] = []
var _shown_for := 0.0
## Whether the whole line is on screen.
var _complete := false
var _arrow: Control


func _ready() -> void:
	layer = 20
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.set_corner_radius_all(18)
	style.set_content_margin_all(36)

	_panel = PanelContainer.new()
	_panel.add_theme_stylebox_override("panel", style)
	_panel.anchor_left = 0.14
	_panel.anchor_right = 0.86
	_panel.anchor_top = 1.0
	_panel.anchor_bottom = 1.0
	_panel.offset_top = -300.0
	_panel.offset_bottom = -50.0
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.visible = false
	add_child(_panel)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	_panel.add_child(column)

	_name = Label.new()
	_name.add_theme_font_size_override("font_size", 30)
	_name.add_theme_color_override("font_color", NAME_COLOR)
	column.add_child(_name)

	_text = Label.new()
	_text.add_theme_font_size_override("font_size", 40)
	_text.add_theme_color_override("font_color", TEXT_COLOR)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_text)

	# The arrow sits in the lower right corner of the panel.
	_arrow = Control.new()
	_arrow.anchor_left = 0.86
	_arrow.anchor_right = 0.86
	_arrow.anchor_top = 1.0
	_arrow.anchor_bottom = 1.0
	_arrow.offset_left = -76.0
	_arrow.offset_top = -106.0
	_arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_arrow.draw.connect(_draw_arrow)
	_arrow.visible = false
	add_child(_arrow)


func is_open() -> bool:
	return _panel.visible


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


func _input(event: InputEvent) -> void:
	if not is_open() or not event is InputEventScreenTouch:
		return
	get_viewport().set_input_as_handled()
	if not event.pressed or _shown_for < GRACE:
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
		PackedVector2Array([bob, bob + Vector2(32, 0), bob + Vector2(16, 20)]), NAME_COLOR
	)


func _next() -> void:
	_complete = false
	_arrow.visible = false
	if _queue.is_empty():
		_panel.visible = false
		finished.emit()
		return
	var entry: Dictionary = _queue.pop_front()
	_name.text = entry.who
	_name.visible = not entry.who.is_empty()
	_text.text = entry.line
	_text.visible_characters = 0
	_shown_for = 0.0
	_panel.visible = true