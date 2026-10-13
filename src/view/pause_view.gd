class_name PauseView
extends CanvasLayer
## The pause page: a small button in the corner that halts the game and opens a page with the
## few things to set (music volume, language) and the way to start over. It lies above the
## notebook and the dialogue, so the game can be paused at any time. It closes with "continue"
## or a tap beside the page.

signal volume_changed(volume: float)
signal language_changed(language: String)
signal new_game_requested
signal closed

## Height of everything that is tapped, for fingers.
const ROW_HEIGHT := 76.0
## Languages by their own names.
const LANGUAGE_NAMES := {"en": "English", "de": "Deutsch"}

var _volume := 1.0
var _open := false
## Whether the page asks if the player really wants to start over.
var _asking := false
var _button := RoundButton.new()
## Dims everything behind the page and catches every tap beside it.
var _page := ColorRect.new()
var _column := VBoxContainer.new()


func _ready() -> void:
	layer = 25
	# Everything else stands still while the page is open.
	process_mode = Node.PROCESS_MODE_ALWAYS

	_button.draw.connect(_draw_button)
	_button.pressed.connect(open)
	add_child(_button)

	_page.color = Color(0, 0, 0, 0.55)
	_page.set_anchors_preset(Control.PRESET_FULL_RECT)
	_page.mouse_filter = Control.MOUSE_FILTER_STOP
	_page.gui_input.connect(_on_page_input)
	_page.visible = false
	add_child(_page)

	# The paper takes the taps that land on it, so they do not count as beside the page.
	var paper := PanelContainer.new()
	paper.theme_type_variation = &"Paper"
	paper.anchor_left = 0.3
	paper.anchor_right = 0.7
	paper.anchor_top = 0.1
	paper.anchor_bottom = 0.9
	paper.mouse_filter = Control.MOUSE_FILTER_STOP
	_page.add_child(paper)
	_column.add_theme_constant_override("separation", 14)
	paper.add_child(_column)


func is_open() -> bool:
	return _open


## Sets what the page shows as the music volume, from 0 to 1.
func set_volume(volume: float) -> void:
	_volume = volume


func open() -> void:
	_open = true
	_asking = false
	_page.visible = true
	get_tree().paused = true
	_fill()


func close() -> void:
	if not _open:
		return
	_open = false
	_page.visible = false
	get_tree().paused = false
	closed.emit()


func _on_page_input(event: InputEvent) -> void:
	# A tap arrives as a touch and as a mouse click. Only the touch of the first finger counts.
	var touch := event as InputEventScreenTouch
	if touch and touch.pressed and touch.index == 0 and _open:
		# The page stays until the tap has passed, so it does not reach the world as well.
		close.call_deferred()


func _fill() -> void:
	for child in _column.get_children():
		_column.remove_child(child)
		child.queue_free()

	if _asking:
		_column.add_child(_label(Texts.text("pause.confirm"), &"PaperText"))
		_column.add_child(_spacer())
		# "No" sits where "start over" was, so tapping twice by accident does not start over.
		_column.add_child(_text_button(Texts.text("pause.confirm_no"), &"PaperEntry", _ask.bind(false)))
		_column.add_child(_text_button(Texts.text("pause.confirm_yes"), &"PaperLink", _start_over))
		return

	_column.add_child(_label(Texts.text("pause.title"), &"PaperHeading"))
	_column.add_child(_label(Texts.text("pause.volume"), &"PaperSmall"))
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = _volume
	slider.focus_mode = Control.FOCUS_NONE
	slider.custom_minimum_size.y = ROW_HEIGHT
	slider.value_changed.connect(_on_volume_changed)
	_column.add_child(slider)

	_column.add_child(_label(Texts.text("pause.language"), &"PaperSmall"))
	var languages := HBoxContainer.new()
	languages.add_theme_constant_override("separation", 56)
	for language: String in Texts.LANGUAGES:
		var variation := &"PaperEntrySelected" if language == Texts.language else &"PaperEntry"
		languages.add_child(_text_button(LANGUAGE_NAMES.get(language, language), variation, _choose_language.bind(language)))
	_column.add_child(languages)

	_column.add_child(_spacer())
	_column.add_child(_text_button(Texts.text("pause.new_game"), &"PaperEntry", _ask.bind(true)))
	_column.add_child(_text_button(Texts.text("pause.continue"), &"PaperLink", close))


func _on_volume_changed(volume: float) -> void:
	_volume = volume
	volume_changed.emit(volume)


func _choose_language(language: String) -> void:
	if language != Texts.language:
		language_changed.emit(language)
	# The button that was pressed is one of those the page is built from anew.
	_fill.call_deferred()


func _ask(asking: bool) -> void:
	_asking = asking
	_fill.call_deferred()


func _start_over() -> void:
	close()
	new_game_requested.emit()


func _label(text: String, variation: StringName) -> Label:
	var label := Label.new()
	label.text = text
	label.theme_type_variation = variation
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _text_button(text: String, variation: StringName, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.theme_type_variation = variation
	button.focus_mode = Control.FOCUS_NONE
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size.y = ROW_HEIGHT
	button.pressed.connect(action)
	return button


## Pushes what follows to the bottom of the page.
func _spacer() -> Control:
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return spacer


## Two upright bars with round ends.
func _draw_button() -> void:
	for side: float in [-1.0, 1.0]:
		_button.draw_stroke(Vector2(side * 10.0, -14.0), Vector2(side * 10.0, 14.0), _button.light, 10.0)
