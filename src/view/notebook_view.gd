class_name NotebookView
extends CanvasLayer
## The notebook: a small button in the corner that opens a page with everything the player has
## found. The button only shows once the player carries the notebook. While the page is open it
## takes all taps. It closes with the cross in its corner or a tap beside the page.

const BUTTON_SIZE := 92.0
## Size of the area that reacts to a tap on the cross. Larger than the cross itself, for fingers.
const CLOSE_SIZE := 76.0
## Item the player has to carry for the notebook to be there.
const ITEM := "notebook"
const BUTTON_COLOR := Color(0.09, 0.1, 0.14, 0.6)

var session: Session

var _notes := {}
var _entries: Array[Dictionary] = []
var _selected := ""
var _unread := false
var _open := false
var _button := Button.new()
## Dims the world behind the page and catches every tap beside it.
var _page := ColorRect.new()
var _close := Button.new()
var _list := VBoxContainer.new()
var _detail := VBoxContainer.new()


func _ready() -> void:
	layer = 15
	_notes = Notebook.read()

	_button.theme_type_variation = &"IconButton"
	_button.focus_mode = Control.FOCUS_NONE
	_button.anchor_left = 1.0
	_button.anchor_right = 1.0
	_button.offset_left = -BUTTON_SIZE - 36.0
	_button.offset_right = -36.0
	_button.offset_top = 36.0
	_button.offset_bottom = 36.0 + BUTTON_SIZE
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
	paper.anchor_left = 0.12
	paper.anchor_right = 0.88
	paper.anchor_top = 0.1
	paper.anchor_bottom = 0.9
	paper.mouse_filter = Control.MOUSE_FILTER_STOP
	_page.add_child(paper)

	# The cross in the upper right corner of the paper.
	_close.theme_type_variation = &"IconButton"
	_close.focus_mode = Control.FOCUS_NONE
	_close.anchor_left = paper.anchor_right
	_close.anchor_right = paper.anchor_right
	_close.anchor_top = paper.anchor_top
	_close.anchor_bottom = paper.anchor_top
	_close.offset_left = -CLOSE_SIZE - 16.0
	_close.offset_right = -16.0
	_close.offset_top = 16.0
	_close.offset_bottom = 16.0 + CLOSE_SIZE
	_close.draw.connect(_draw_close)
	_close.pressed.connect(close)
	_page.add_child(_close)

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 64)
	paper.add_child(columns)
	_list.custom_minimum_size.x = 460.0
	_list.add_theme_constant_override("separation", 18)
	columns.add_child(_list)
	_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail.add_theme_constant_override("separation", 20)
	columns.add_child(_detail)


func is_open() -> bool:
	return _open


## Shows or hides the button, depending on whether the player carries the notebook.
func refresh() -> void:
	_button.visible = ITEM in session.state.items


func open(note := "") -> void:
	_entries = Notebook.entries(_notes, session.state.notes)
	var known := _entries.map(func(entry: Dictionary) -> String: return entry.id)
	if note in known:
		_selected = note
	elif _selected not in known:
		_selected = "" if known.is_empty() else known[-1]
	_unread = false
	_open = true
	_page.visible = true
	_fill()
	_button.queue_redraw()


func close() -> void:
	_open = false
	_page.visible = false


## Brings the notebook back to how a new game starts: closed and with nothing unread.
func reset() -> void:
	close()
	_selected = ""
	_unread = false
	_button.queue_redraw()


## Shows the open page in the language that is in use now.
func retranslate() -> void:
	if _open:
		_fill()


## Marks the button, so the player sees that something new has been written down.
func mark_unread() -> void:
	_unread = true
	_button.queue_redraw()


func _on_page_input(event: InputEvent) -> void:
	# A tap arrives as a touch and as a mouse click. Only the touch of the first finger counts.
	var touch := event as InputEventScreenTouch
	if touch and touch.pressed and touch.index == 0 and _open:
		_open = false
		# The page stays until the tap has passed, so it does not reach the world as well.
		_hide_page.call_deferred()


func _hide_page() -> void:
	_page.visible = _open


func _select(note: String) -> void:
	_selected = note
	# The button that was pressed is one of those the page is built from anew.
	_fill.call_deferred()


func _fill() -> void:
	for column: Node in [_list, _detail]:
		for child in column.get_children():
			column.remove_child(child)
			child.queue_free()

	_list.add_child(_label(Texts.text("notebook.title"), &"PaperHeading"))
	if _entries.is_empty():
		_detail.add_child(_label(Texts.text("notebook.empty"), &"PaperFaint"))
		return
	for entry in _entries:
		var variation := &"PaperEntrySelected" if entry.id == _selected else &"PaperEntry"
		_list.add_child(_note_button(Texts.text("note.%s.title" % entry.id), variation, entry.id))

	for entry in _entries:
		if entry.id != _selected:
			continue
		_detail.add_child(_label(Texts.text("note.%s.title" % entry.id), &"PaperHeading"))
		_detail.add_child(_label("%s · %s" % [Texts.text("kind." + entry.kind), Texts.text("world." + entry.world)], &"PaperSmall"))
		_detail.add_child(_label(Texts.text("note.%s.text" % entry.id), &"PaperText"))
		if entry.links.is_empty():
			continue
		_detail.add_child(_label(Texts.text("notebook.links"), &"PaperSmall"))
		for link: Dictionary in entry.links:
			if link.known:
				_detail.add_child(_note_button("–  " + Texts.text("note.%s.title" % link.id), &"PaperLink", link.id))
			else:
				_detail.add_child(_label("–  " + Texts.text("notebook.unknown"), &"PaperMissing"))


func _label(text: String, variation: StringName) -> Label:
	var label := Label.new()
	label.text = text
	label.theme_type_variation = variation
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


## A line of text that opens a note when tapped.
func _note_button(text: String, variation: StringName, note: String) -> Button:
	var button := Button.new()
	button.text = text
	button.theme_type_variation = variation
	button.focus_mode = Control.FOCUS_NONE
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.pressed.connect(_select.bind(note))
	return button


func _draw_close() -> void:
	var color := _theme_color(&"PaperSmall")
	var inset := CLOSE_SIZE * 0.3
	var far := CLOSE_SIZE - inset
	_close.draw_line(Vector2(inset, inset), Vector2(far, far), color, 5.0, true)
	_close.draw_line(Vector2(far, inset), Vector2(inset, far), color, 5.0, true)


## A little book on a dark disc, with a dot while there is something unread.
func _draw_button() -> void:
	var centre := Vector2.ONE * BUTTON_SIZE * 0.5
	_button.draw_circle(centre, BUTTON_SIZE * 0.5, BUTTON_COLOR)
	var paper: StyleBoxFlat = _page.get_theme_stylebox(&"panel", &"Paper")
	for side: float in [-1.0, 1.0]:
		_button.draw_colored_polygon(
			PackedVector2Array([
				centre + Vector2(side * 3, -17), centre + Vector2(side * 27, -22),
				centre + Vector2(side * 27, 16), centre + Vector2(side * 3, 21),
			]),
			paper.bg_color
		)
	if _unread:
		_button.draw_circle(Vector2(BUTTON_SIZE - 14, 14), 11.0, _theme_color(&"PaperLink"))


## Font colour of a variation in the theme.
func _theme_color(variation: StringName) -> Color:
	return _page.get_theme_color(&"font_color", variation)
