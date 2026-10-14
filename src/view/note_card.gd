class_name NoteCard
extends Control
## One note in the notebook: a slip of paper in the player's own hand, lying a little askew. An
## insight is a slip of its own colour with the notes it came from tucked underneath. A note
## that no longer holds is crossed out. The notebook moves the slips about; they take no input
## themselves.

const SIZE := Vector2(326, 184)
## A slip opened for reading: wider, and with all its text.
const READ_SIZE := Vector2(600, 420)
const PADDING := Vector2(20, 12)
const TITLE_HEIGHT := 48.0
const PAPER := {
	"hint": Color(0.99, 0.96, 0.88),
	"memory": Color(0.96, 0.95, 0.9),
	"rift": Color(0.9, 0.92, 0.96),
	"insight": Color(1.0, 0.92, 0.72),
}
const EDGE := Color(0.45, 0.36, 0.28, 0.35)
const MARK := Color(0.72, 0.36, 0.24)
const GLOW := Color(1.0, 0.82, 0.45)
const CROSS := Color(0.2, 0.17, 0.15, 0.75)

var note := ""
var kind := ""
## Whether the note is crossed out, how many notes are tucked underneath, whether a slip being
## dragged hovers over it, and how strongly it glows as something new (0 to 1).
var crossed := false
var tucked := 0
var hover := false:
	set(value):
		hover = value
		queue_redraw()
var glow := 0.0:
	set(value):
		glow = value
		queue_redraw()

var _title := Label.new()
var _text := Label.new()


## Fills the slip with a note. reading opens it to its full size.
func setup(note_id: String, note_kind: String, is_crossed: bool, tucked_notes: int, reading := false) -> void:
	note = note_id
	kind = note_kind
	crossed = is_crossed
	tucked = tucked_notes
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = READ_SIZE if reading else SIZE
	pivot_offset = size * 0.5
	var rift := kind == "rift"
	_title.theme_type_variation = &"NoteInsightTitle" if kind == "insight" else (&"NoteRiftTitle" if rift else &"NoteTitle")
	_text.theme_type_variation = &"NoteRiftText" if rift else &"NoteText"
	for label: Label in [_title, _text]:
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.position.x = PADDING.x
		label.size.x = size.x - PADDING.x * 2.0
		if label.get_parent() == null:
			add_child(label)
	_title.position.y = PADDING.y
	_title.size.y = TITLE_HEIGHT
	_text.position.y = PADDING.y + TITLE_HEIGHT
	_text.size.y = size.y - _text.position.y - PADDING.y
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# The title stays on one line; the text of a slip shows as much as fits.
	_title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	if not reading:
		_text.max_lines_visible = 3
		_text.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	retranslate()


func retranslate() -> void:
	_title.text = Texts.text("note.%s.title" % note)
	_text.text = Texts.text("note.%s.text" % note)


## Lets the text appear as if it were being written, over the given seconds.
func write_out(seconds: float) -> void:
	_text.visible_ratio = 0.0
	_title.visible_ratio = 0.0
	var writing := create_tween()
	writing.tween_property(_title, "visible_ratio", 1.0, seconds * 0.3)
	writing.tween_property(_text, "visible_ratio", 1.0, seconds * 0.7)


## Whether a point given in the coordinates of the slip's parent lies on the slip.
func covers(point: Vector2) -> bool:
	var local := get_transform().affine_inverse() * point
	return Rect2(Vector2.ZERO, size).has_point(local)


func centre() -> Vector2:
	return get_transform() * (size * 0.5)


func _draw() -> void:
	var paper: Color = PAPER.get(kind, PAPER.hint)
	var whole := Rect2(Vector2.ZERO, size)
	# Notes tucked underneath peek out at the edges.
	for number in mini(tucked, 2):
		var turn := 0.07 if number == 0 else -0.06
		draw_set_transform(size * 0.5, turn, Vector2.ONE)
		draw_rect(Rect2(-size * 0.5 + Vector2(10, 8) * (number + 1), size), PAPER.hint.darkened(0.04))
		draw_rect(Rect2(-size * 0.5 + Vector2(10, 8) * (number + 1), size), EDGE, false, 1.5)
		draw_set_transform(Vector2.ZERO)
	if glow > 0.0:
		for ring in 4:
			draw_rect(whole.grow(6.0 + ring * 7.0), Color(GLOW, 0.12 * glow))
	draw_rect(Rect2(Vector2(4, 6), size), Color(0, 0, 0, 0.16))
	draw_rect(whole, paper)
	draw_rect(whole, MARK if hover else EDGE, false, 4.0 if hover else 1.5)
	if kind == "insight":
		# Underlined twice, as one does with something one has just understood.
		var y := PADDING.y + TITLE_HEIGHT - 4.0
		draw_line(Vector2(PADDING.x, y), Vector2(size.x * 0.62, y - 2.0), Color(MARK, 0.7), 2.5, true)
		draw_line(Vector2(PADDING.x + 6.0, y + 5.0), Vector2(size.x * 0.55, y + 4.0), Color(MARK, 0.5), 2.0, true)
	if crossed:
		draw_line(Vector2(PADDING.x - 4.0, 34.0), Vector2(size.x - PADDING.x, 30.0), CROSS, 3.0, true)
		draw_line(Vector2(PADDING.x, size.y - 30.0), Vector2(size.x - PADDING.x + 2.0, 64.0), CROSS, 2.5, true)
