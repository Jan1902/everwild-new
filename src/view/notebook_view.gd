class_name NotebookView
extends CanvasLayer
## The notebook: a small button in the corner that opens a page with everything the player has
## found. The button only shows once the player carries the notebook. While the page is open it
## takes all taps.

const PAPER := Color(0.93, 0.89, 0.8)
const INK := Color(0.2, 0.17, 0.15)
const FAINT := Color(0.2, 0.17, 0.15, 0.55)
const MARK := Color(0.72, 0.36, 0.24)
const BUTTON_SIZE := 92.0
## Item the player has to carry for the notebook to be there.
const ITEM := "notebook"

var session: Session

var _notes := {}
var _entries: Array[Dictionary] = []
var _selected := ""
var _unread := false
var _button: Control
var _page: Control
var _list: VBoxContainer
var _detail: VBoxContainer
## Controls that react to a tap, each with the id of the note they show.
var _targets: Array[Dictionary] = []


func _ready() -> void:
	layer = 15
	_notes = Notebook.read()

	_button = Control.new()
	_button.anchor_left = 1.0
	_button.anchor_right = 1.0
	_button.offset_left = -BUTTON_SIZE - 36.0
	_button.offset_right = -36.0
	_button.offset_top = 36.0
	_button.offset_bottom = 36.0 + BUTTON_SIZE
	_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_button.draw.connect(_draw_button)
	add_child(_button)

	_page = ColorRect.new()
	_page.color = Color(0, 0, 0, 0.55)
	_page.set_anchors_preset(Control.PRESET_FULL_RECT)
	_page.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_page.visible = false
	add_child(_page)

	var style := StyleBoxFlat.new()
	style.bg_color = PAPER
	style.set_corner_radius_all(14)
	style.set_content_margin_all(56)
	var paper := PanelContainer.new()
	paper.name = "Paper"
	paper.add_theme_stylebox_override("panel", style)
	paper.anchor_left = 0.12
	paper.anchor_right = 0.88
	paper.anchor_top = 0.1
	paper.anchor_bottom = 0.9
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_page.add_child(paper)

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 64)
	paper.add_child(columns)
	_list = VBoxContainer.new()
	_list.custom_minimum_size.x = 460.0
	_list.add_theme_constant_override("separation", 18)
	columns.add_child(_list)
	_detail = VBoxContainer.new()
	_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail.add_theme_constant_override("separation", 20)
	columns.add_child(_detail)


func is_open() -> bool:
	return _page.visible


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
	_page.visible = true
	_fill()
	_button.queue_redraw()


func close() -> void:
	_page.visible = false


## Marks the button, so the player sees that something new has been written down.
func mark_unread() -> void:
	_unread = true
	_button.queue_redraw()


func _input(event: InputEvent) -> void:
	var touch := event as InputEventScreenTouch
	if touch == null:
		return
	var on_button := _button.visible and _button.get_global_rect().has_point(touch.position)
	if not is_open():
		if on_button:
			get_viewport().set_input_as_handled()
			if touch.pressed:
				open()
		return
	get_viewport().set_input_as_handled()
	if not touch.pressed:
		return
	for target in _targets:
		if target.control.get_global_rect().has_point(touch.position):
			_selected = target.id
			_fill()
			return
	if on_button or not _page.get_node("Paper").get_global_rect().has_point(touch.position):
		close()


func _fill() -> void:
	_targets.clear()
	for column: Node in [_list, _detail]:
		for child in column.get_children():
			column.remove_child(child)
			child.queue_free()

	_list.add_child(_label(Texts.text("notebook.title"), 44, INK))
	if _entries.is_empty():
		_detail.add_child(_label(Texts.text("notebook.empty"), 34, FAINT))
		return
	for entry in _entries:
		var title := _label(Texts.text("note.%s.title" % entry.id), 34, MARK if entry.id == _selected else INK)
		_list.add_child(title)
		_targets.append({"control": title, "id": entry.id})

	for entry in _entries:
		if entry.id != _selected:
			continue
		_detail.add_child(_label(Texts.text("note.%s.title" % entry.id), 44, INK))
		_detail.add_child(_label("%s · %s" % [Texts.text("kind." + entry.kind), Texts.text("world." + entry.world)], 28, FAINT))
		_detail.add_child(_label(Texts.text("note.%s.text" % entry.id), 34, INK))
		if entry.links.is_empty():
			continue
		_detail.add_child(_label(Texts.text("notebook.links"), 28, FAINT))
		for link: Dictionary in entry.links:
			if link.known:
				var related := _label("–  " + Texts.text("note.%s.title" % link.id), 32, MARK)
				_detail.add_child(related)
				_targets.append({"control": related, "id": link.id})
			else:
				_detail.add_child(_label("–  " + Texts.text("notebook.unknown"), 32, FAINT))


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


## A little book on a dark disc, with a dot while there is something unread.
func _draw_button() -> void:
	var centre := Vector2.ONE * BUTTON_SIZE * 0.5
	_button.draw_circle(centre, BUTTON_SIZE * 0.5, Color(0.09, 0.1, 0.14, 0.6))
	for side: float in [-1.0, 1.0]:
		_button.draw_colored_polygon(
			PackedVector2Array([
				centre + Vector2(side * 3, -17), centre + Vector2(side * 27, -22),
				centre + Vector2(side * 27, 16), centre + Vector2(side * 3, 21),
			]),
			PAPER
		)
	if _unread:
		_button.draw_circle(Vector2(BUTTON_SIZE - 14, 14), 11.0, MARK)