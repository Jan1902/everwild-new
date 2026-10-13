class_name NotebookView
extends CanvasLayer
## The notebook: a small button in the corner that opens a page with everything the player has
## found. The button only shows once the player carries the notebook. While the page is open it
## takes all taps. It closes with the cross in its corner or a tap beside the page. Both columns
## scroll by swiping up and down when they are longer than the page.

## Size of the area that reacts to a tap on the cross. Larger than the cross itself, for fingers.
const CLOSE_SIZE := 76.0
## The cross itself: how far its strokes reach from the centre, and how thick they are.
const CLOSE_REACH := 15.0
const CLOSE_STROKE := 5.0
## Item the player has to carry for the notebook to be there.
const ITEM := "notebook"
## The open book on the button: half its width, the height of a page at its outer edge, how
## much higher the pages lie at the spine, and how far the cover shows below them.
const BOOK_WIDTH := 25.0
const BOOK_HEIGHT := 31.0
const BOOK_RISE := 5.0
const BOOK_COVER := 4.0
## Dots that show the condition of a piece of the world.
const DOT_RADIUS := 11.0
const DOT_SPACING := 36.0

var session: Session

var _notes := {}
var _entries: Array[Dictionary] = []
var _selected := ""
var _unread := false
var _open := false
var _button := RoundButton.new(true)
## Dims the world behind the page and catches every tap beside it.
var _page := ColorRect.new()
var _close := Button.new()
var _list := VBoxContainer.new()
var _detail := VBoxContainer.new()
var _list_scroll := ScrollContainer.new()
var _detail_scroll := ScrollContainer.new()


func _ready() -> void:
	layer = 15
	_notes = Notebook.read()

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
	_list_scroll.custom_minimum_size.x = 460.0
	_list.add_theme_constant_override("separation", 18)
	_detail_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail.add_theme_constant_override("separation", 20)
	# A column longer than the page scrolls by swiping up and down.
	for column: Array in [[_list_scroll, _list], [_detail_scroll, _detail]]:
		column[0].horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		column[1].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column[0].add_child(column[1])
		columns.add_child(column[0])


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
	_detail_scroll.scroll_vertical = 0
	_show_selected.call_deferred()
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
	_detail_scroll.scroll_vertical = 0
	# The button that was pressed is one of those the page is built from anew.
	_fill.call_deferred()


## Scrolls the list so far that the selected entry is on the page.
func _show_selected() -> void:
	for entry: Control in _list.get_children():
		if entry.theme_type_variation == &"PaperEntrySelected":
			_list_scroll.ensure_control_visible(entry)


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
		if entry.kind == "piece":
			_add_condition(entry.world)
		_detail.add_child(_label(Texts.text("note.%s.text" % entry.id), &"PaperText"))
		if entry.links.is_empty():
			continue
		_detail.add_child(_label(Texts.text("notebook.links"), &"PaperSmall"))
		for link: Dictionary in entry.links:
			if link.known:
				_detail.add_child(_note_button("–  " + Texts.text("note.%s.title" % link.id), &"PaperLink", link.id))
			else:
				_detail.add_child(_label("–  " + Texts.text("notebook.unknown"), &"PaperMissing"))


## Shows how a piece of the world is doing: one dot per fault, filled once it is fixed, and
## whether the piece is whole. The dots tell how much is wrong without telling what.
func _add_condition(world_id: String) -> void:
	var faults := session.world(world_id).faults.size()
	if faults == 0:
		return
	var fixed := faults - session.open_faults(world_id).size()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	var dots := Control.new()
	dots.custom_minimum_size = Vector2(faults * DOT_SPACING, DOT_SPACING)
	dots.draw.connect(_draw_dots.bind(dots, faults, fixed))
	row.add_child(dots)
	var condition := _label(Texts.text("notebook.whole" if fixed == faults else "notebook.broken"), &"PaperSmall")
	condition.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(condition)
	_detail.add_child(row)


func _draw_dots(dots: Control, faults: int, fixed: int) -> void:
	var color := _theme_color(&"PaperLink")
	for number in faults:
		var centre := Vector2((number + 0.5) * DOT_SPACING, dots.size.y * 0.5)
		if number < fixed:
			dots.draw_circle(centre, DOT_RADIUS, color)
		else:
			dots.draw_arc(centre, DOT_RADIUS - 1.5, 0.0, TAU, 24, color, 3.0, true)


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
	# A swipe that starts on the button still reaches the column and scrolls it.
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	button.pressed.connect(_select.bind(note))
	return button


## A cross of two strokes with round ends. Its colour is the ink as it looks on the paper, mixed
## beforehand: drawn with see-through ink, the strokes would be darker where they cross.
func _draw_close() -> void:
	var ink := _theme_color(&"PaperSmall")
	var paper: StyleBoxFlat = _page.get_theme_stylebox(&"panel", &"Paper")
	var color := paper.bg_color.lerp(Color(ink, 1.0), ink.a)
	var centre := Vector2.ONE * CLOSE_SIZE * 0.5
	for arm: Vector2 in [Vector2(1, 1), Vector2(1, -1)]:
		var from := centre - arm * CLOSE_REACH
		var to := centre + arm * CLOSE_REACH
		_close.draw_line(from, to, color, CLOSE_STROKE, true)
		for end: Vector2 in [from, to]:
			_close.draw_circle(end, CLOSE_STROKE * 0.5, color, true, -1.0, true)


## An open book: two pages that rise towards the spine, a few lines of writing on them and the
## cover showing below. A dot at the rim while there is something unread.
func _draw_button() -> void:
	var mark := _theme_color(&"PaperLink")
	var top := -BOOK_HEIGHT * 0.5 - 1.0
	for side: float in [-1.0, 1.0]:
		var spine := Vector2(side * 1.5, top + BOOK_RISE)
		var edge := Vector2(side * BOOK_WIDTH, top)
		var down := Vector2(0, BOOK_HEIGHT)
		_button.draw_area([spine, edge, edge + down, spine + down], _button.light)
		# The cover is a band along the lower edge of the page.
		var below := Vector2(0, BOOK_COVER)
		_button.draw_area([spine + down, edge + down, edge + down + below, spine + down + below], mark)
		for line in 3:
			var from := Vector2(side * 6.0, top + 12.0 + line * 6.5)
			var to := Vector2(side * (BOOK_WIDTH - 5.0), top + 8.0 + line * 6.5)
			_button.draw_stroke(from, to, _button.light.lerp(mark, 0.55), 2.0)
	if _unread:
		var spot := Vector2(RoundButton.SIZE - 13.0, 13.0)
		_button.draw_circle(spot, 13.0, _button.light, true, -1.0, true)
		_button.draw_circle(spot, 9.5, mark, true, -1.0, true)


## Font colour of a variation in the theme.
func _theme_color(variation: StringName) -> Color:
	return _page.get_theme_color(&"font_color", variation)
