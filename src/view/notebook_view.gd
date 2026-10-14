class_name NotebookView
extends CanvasLayer
## The notebook: a small button in the corner that opens the book. The button only shows once the
## player carries the notebook.
##
## The book lies open across the screen. On the left page is the map of the pieces of the world
## (MapView). On the right page lie the notes as slips of paper in the player's hand (NoteCard),
## a little untidy. A tap on a slip opens it to read it whole. A slip can be dragged: dropped on
## another one, the two are thought together, and if they belong together an insight is written
## down and the two go underneath it (Session.combine). If they do not, the slip springs back.
## Dropped anywhere else, it stays where it was put. A page holds PER_PAGE slips; more go on the
## next. The arrows at the foot of the page or a swipe across it turn it, and a slip held at the
## edge of the page turns it too, so slips from different pages can be drawn together. A tap
## beside the book or on the cross closes it.
##
## While the book is open it takes every touch, except while someone is speaking: the dialogue
## lies above it and takes them. Only the first finger counts.

## The notebook was opened.
signal opened
## Two notes were thought together into an insight; these are the effects to show.
signal thought(effects: Array)

## Item the player has to carry for the notebook to be there.
const ITEM := "notebook"
const PAPER_IMAGE := "res://assets/ui/notebook.png"
## Width of the open book on screen, and the two pages as fractions of the book.
const BOOK_WIDTH := 1660.0
const LEFT_PAGE := Rect2(0.075, 0.075, 0.395, 0.84)
const RIGHT_PAGE := Rect2(0.525, 0.06, 0.41, 0.87)
## Area of the cross that closes the book, for fingers.
const CLOSE_SIZE := 84.0
## Pixels a finger has to move before a slip is dragged instead of tapped.
const DRAG_START := 14.0
## Slips on one page, height of a row of them, how far slips lie askew at most, and how far they
## stray from their place.
const PER_PAGE := 8
const ROW := 196.0
const TILT := 0.12
const STRAY := Vector2(26, 16)
## Height of the foot of the page with the arrows, pixels a swipe has to go to turn the page, how
## near the edge a slip has to be held to turn it, and for how many seconds.
const PAGER := 76.0
const SWIPE := 90.0
const EDGE := 60.0
const EDGE_HOLD := 0.6
## Seconds the book has to be open without a thought before the ghostly finger shows again
## what belongs together, for a player who has been dragging slips before and is stuck.
const GHOST_AGAIN := 10.0
## Seconds an insight takes to be written, and a slip to spring back.
const WRITE := 1.6
const SPRING := 0.35
## The open book on the button: half its width, the height of a page at its outer edge, how
## much higher the pages lie at the spine, and how far the cover shows below them.
const BOOK_ICON_WIDTH := 25.0
const BOOK_ICON_HEIGHT := 31.0
const BOOK_ICON_RISE := 5.0
const BOOK_ICON_COVER := 4.0
const INK := Color(0.2, 0.17, 0.15)
const MARK := Color(0.72, 0.36, 0.24)
## The ink of the cross as it looks on the paper.
const CROSS_INK := Color(0.47, 0.42, 0.37)
## The pause button lies in this corner of the screen; touches there are left to it.
const PAUSE_CORNER := Vector2(170, 170)

var session: Session
var sounds: Sounds
## The dialogue: while it is open, touches are its own.
var dialogue: DialogueBox

var _open := false
var _unread := false
var _hinted := false
var _button := RoundButton.new(true)
## Dims the world behind the book.
var _page := ColorRect.new()
var _book := TextureRect.new()
var _map := MapView.new()
## The right page, which clips the slips, and the layer of slips on it.
var _desk := Control.new()
var _slips := Control.new()
var _ghost := Control.new()
var _close := Control.new()
var _pager := Control.new()
## The page of slips on show, from 0, and how many there are.
var _page_index := 0
var _pages := 1
## Notes new since the book was last open: their pages show it at the arrows.
var _fresh: Array[String] = []
## The slip opened for reading, or null.
var _reader: NoteCard
var _cards: Array[NoteCard] = []

## Notes the player had seen when the book was last open; the others are new.
var _seen: Array[String] = []
## The slip under the finger, where the finger came down, how far the slip is from it, whether
## it is being dragged, whether the finger swipes the page instead, where the slip lay and on
## which page, and how long it has been held at the edge of the page.
var _held: NoteCard
var _press := Vector2.ZERO
var _grab := Vector2.ZERO
var _dragging := false
var _swiping := false
var _home := Vector2.ZERO
var _home_page := 0
var _at_edge := 0.0
var _time := 0.0
## Whether the player has dragged a slip yet. Until then, a ghostly finger shows how.
var _has_dragged := false
## Seconds the book has been open since it was opened or the last thought.
var _open_time := 0.0


func _ready() -> void:
	layer = 15
	_button.draw.connect(_draw_button)
	_button.pressed.connect(open)
	add_child(_button)

	_page.color = Color(0, 0, 0, 0.6)
	_page.mouse_filter = Control.MOUSE_FILTER_STOP
	_page.visible = false
	add_child(_page)
	_book.texture = load(PAPER_IMAGE) if ResourceLoader.exists(PAPER_IMAGE) else null
	_book.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_book.stretch_mode = TextureRect.STRETCH_SCALE
	_book.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_page.add_child(_book)
	_book.add_child(_map)
	_desk.clip_contents = true
	_desk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_book.add_child(_desk)
	_slips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_desk.add_child(_slips)
	_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ghost.draw.connect(_draw_ghost)
	_desk.add_child(_ghost)
	_close.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_close.draw.connect(_draw_close)
	_book.add_child(_close)
	_pager.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pager.draw.connect(_draw_pager)
	_desk.add_child(_pager)
	get_viewport().size_changed.connect(_lay_out)
	_lay_out()


func is_open() -> bool:
	return _open


## Shows or hides the button, depending on whether the player carries the notebook.
func refresh() -> void:
	_button.visible = ITEM in session.state.items
	# Something is new only if a note has been written down since the book was last open; notes
	# that someone says again are already in it.
	if not _open and session.state.notes.size() > session.state.notes_seen:
		mark_unread()
	_map.session = session
	if _open:
		_map.refresh()


## Opens the book. With a note given, that note is opened for reading.
func open(note := "") -> void:
	_open = true
	_open_time = 0.0
	_unread = false
	_hinted = false
	_page.visible = true
	_map.session = session
	_map.refresh()
	_fresh.assign(session.state.notes.filter(func(found: String) -> bool: return found not in _seen and not _seen.is_empty()))
	# The newest notes lie on the last page.
	var list := _slip_notes()
	_page_index = maxi(0, list.size() - 1) / PER_PAGE
	if note in list:
		_page_index = list.find(note) / PER_PAGE
	_fill()
	if not note.is_empty():
		_read(note)
	_seen = session.state.notes.duplicate()
	session.state.notes_seen = session.state.notes.size()
	if sounds:
		sounds.play("page")
	_button.queue_redraw()
	opened.emit()


func close() -> void:
	# What was written down while the book was open, such as an insight, has been seen.
	if _open:
		session.state.notes_seen = session.state.notes.size()
	_open = false
	_page.visible = false
	_held = null
	_dragging = false
	_swiping = false
	if _reader:
		_reader.queue_free()
		_reader = null


## Brings the notebook back to how a new game starts: closed, tidy and with nothing unread.
func reset() -> void:
	close()
	_seen.clear()
	_fresh.clear()
	_page_index = 0
	_unread = false
	_has_dragged = false
	_button.queue_redraw()


## Shows the open book in the language that is in use now.
func retranslate() -> void:
	if _open:
		_fill()
		_map.queue_redraw()


## Marks the button, so the player sees that something new has been written down.
func mark_unread() -> void:
	_unread = not _open
	_button.queue_redraw()


## Lets the button call for attention, for the first time the notebook is worth a look.
func hint(on: bool) -> void:
	if on != _hinted:
		_hinted = on
		_button.queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	if _hinted:
		_button.queue_redraw()
	if _open:
		_open_time += delta
		_ghost.queue_redraw()
		_pager.queue_redraw()
		# A slip held at the edge of the page turns it.
		if _dragging and _held:
			var x := _held.centre().x
			var step := -1 if x < EDGE else (1 if x > _desk.size.x - EDGE else 0)
			_at_edge = _at_edge + delta if step != 0 else 0.0
			if _at_edge >= EDGE_HOLD and _turn(step):
				_at_edge = 0.0


func _lay_out() -> void:
	var screen := get_viewport().get_visible_rect().size
	_page.position = Vector2.ZERO
	_page.size = screen
	var ratio := 0.63
	if _book.texture:
		ratio = float(_book.texture.get_height()) / _book.texture.get_width()
	var width := minf(BOOK_WIDTH, screen.x - 40.0)
	width = minf(width, (screen.y - 30.0) / ratio)
	_book.size = Vector2(width, width * ratio)
	_book.position = (screen - _book.size) * 0.5
	_map.position = LEFT_PAGE.position * _book.size
	_map.size = LEFT_PAGE.size * _book.size
	_desk.position = RIGHT_PAGE.position * _book.size
	_desk.size = RIGHT_PAGE.size * _book.size
	_ghost.size = _desk.size
	_pager.size = _desk.size
	_close.size = Vector2.ONE * CLOSE_SIZE
	_close.position = Vector2(_book.size.x * 0.955 - CLOSE_SIZE, _book.size.y * 0.03)
	if _open:
		_fill()


## The notes that lie as slips on the page: every one found, except pieces of the world, which
## are on the map, and notes tucked under an insight.
func _slip_notes() -> Array[String]:
	var notes := session.notes()
	var tucked := {}
	for note in session.state.notes:
		for source: String in notes.get(note, {}).get("from", []):
			tucked[source] = true
	var list: Array[String] = []
	for note in session.state.notes:
		if notes.has(note) and notes[note].get("kind", "") != "piece" and not tucked.has(note):
			list.append(note)
	return list


## Lays the slips of the page on show out anew. A slip being dragged stays in the hand.
func _fill() -> void:
	for card in _cards:
		if card != _held:
			card.queue_free()
	_cards.clear()
	var notes := session.notes()
	var list := _slip_notes()
	_pages = maxi(1, ceili(list.size() / float(PER_PAGE)))
	_page_index = clampi(_page_index, 0, _pages - 1)
	for number in range(_page_index * PER_PAGE, mini(list.size(), (_page_index + 1) * PER_PAGE)):
		var note := list[number]
		if _held and _held.note == note:
			continue
		var card := NoteCard.new()
		var crossed := session.holds(notes[note].get("crossed_if", [{"fact": "-never-"}]), session.definition.get("start", ""))
		card.setup(note, notes[note].get("kind", ""), crossed, notes[note].get("from", []).size())
		card.position = _placed(note, _spot(number % PER_PAGE, note))
		card.rotation = _jitter(note, 1) * TILT
		if note in _fresh:
			card.glow = 1.0
			var fade := card.create_tween()
			fade.tween_property(card, "glow", 0.0, 2.5).set_delay(1.0)
		_slips.add_child(card)
		_cards.append(card)
	if _held:
		_cards.append(_held)
		_slips.move_child(_held, -1)


## Turns to the next (1) or the previous (-1) page. Returns false if there is none.
func _turn(step: int) -> bool:
	var page := _page_index + step
	if page < 0 or page >= _pages:
		return false
	_page_index = page
	if sounds:
		sounds.play("page")
	_fill()
	return true


## Where the player has put a note, or the given place if they have not.
func _placed(note: String, otherwise: Vector2) -> Vector2:
	var place: Variant = session.state.slips.get(note)
	return Vector2(place[0], place[1]) if place is Array else otherwise


## Remembers where a note lies, in the saved game.
func _place(note: String, at: Vector2) -> void:
	session.state.slips[note] = [at.x, at.y]


## The page of slips a note lies on.
func _page_of(note: String) -> int:
	return maxi(0, _slip_notes().find(note)) / PER_PAGE


## Where a slip lies until the player moves it: two columns, in the order the notes were found,
## each a little off its place.
func _spot(number: int, note: String) -> Vector2:
	var column := number % 2
	var row := number / 2
	var cell := _desk.size.x * 0.5
	var place := Vector2(column * cell + (cell - NoteCard.SIZE.x) * 0.5, row * ROW + 20.0)
	place += Vector2(_jitter(note, 2) * STRAY.x, _jitter(note, 3) * STRAY.y)
	# A slip askew reaches a little beyond its own width; it stays on the page.
	place.x = clampf(place.x, 14.0, _desk.size.x - NoteCard.SIZE.x - 14.0)
	return place


## A number from -1 to 1 that is always the same for a note.
static func _jitter(note: String, salt: int) -> float:
	return float(hash(note + str(salt)) % 2001) / 1000.0 - 1.0


func _input(event: InputEvent) -> void:
	if not _open or (dialogue and dialogue.is_open()):
		return
	var touch := event as InputEventScreenTouch
	var drag := event as InputEventScreenDrag
	if (touch and touch.index != 0) or (drag and drag.index != 0) or (not touch and not drag):
		return
	var point: Vector2 = touch.position if touch else drag.position
	if touch and touch.pressed and point.x < PAUSE_CORNER.x and point.y < PAUSE_CORNER.y:
		return
	get_viewport().set_input_as_handled()
	if touch and touch.pressed:
		_on_press(point)
	elif drag:
		_on_drag(point)
	elif touch:
		_on_release(point)


func _on_press(point: Vector2) -> void:
	_press = point
	_held = null
	_dragging = false
	_swiping = false
	if _reader:
		# A tap anywhere puts the slip that is being read back.
		_reader.queue_free()
		_reader = null
		return
	var on_book := Rect2(_book.position, _book.size).has_point(point)
	if not on_book or Rect2(_book.position + _close.position, _close.size).has_point(point):
		close.call_deferred()
		return
	var on_slips := _slips_point(point)
	# The arrows at the foot of the page.
	if _pages > 1 and on_slips.y > _desk.size.y - PAGER and on_slips.y < _desk.size.y:
		if on_slips.x < _desk.size.x * 0.3:
			_turn(-1)
			return
		if on_slips.x > _desk.size.x * 0.7:
			_turn(1)
			return
	for number in range(_cards.size() - 1, -1, -1):
		if _cards[number].covers(on_slips):
			_held = _cards[number]
			_grab = _held.position - on_slips
			_home = _held.position
			_home_page = _page_index
			_at_edge = 0.0
			return
	_swiping = Rect2(_book.position + _desk.position, _desk.size).has_point(point)


func _on_drag(point: Vector2) -> void:
	if _held == null:
		return
	if not _dragging and point.distance_to(_press) < DRAG_START:
		return
	if not _dragging:
		_dragging = true
		_has_dragged = true
		_slips.move_child(_held, -1)
		_held.scale = Vector2.ONE * 1.06
	_held.position = _slips_point(point) + _grab
	var target := _target()
	for card in _cards:
		card.hover = card == target


func _on_release(point: Vector2) -> void:
	var held := _held
	_held = null
	if _swiping:
		_swiping = false
		if absf(point.x - _press.x) > SWIPE:
			_turn(-1 if point.x > _press.x else 1)
		return
	if held == null:
		return
	if not _dragging:
		_read(held.note)
		return
	_dragging = false
	held.scale = Vector2.ONE
	var target := _target_for(held)
	for card in _cards:
		card.hover = false
	if target == null:
		# Put down somewhere else on its own page, it stays there. On another page it goes back
		# to its own.
		if _page_index == _home_page:
			_place(held.note, held.position)
		else:
			_fill()
		return
	var effects := session.combine(held.note, target.note)
	if effects.is_empty():
		if _page_index == _home_page:
			_spring_back(held)
		else:
			if sounds:
				sounds.play("miss")
			_fill()
		return
	var insight := ""
	for effect: Dictionary in effects:
		if effect.has("note") and session.notes().get(effect["note"], {}).has("from"):
			insight = effect["note"]
	_place(insight, target.position)
	if sounds:
		sounds.play("insight")
	_open_time = 0.0
	thought.emit(effects)
	held.queue_free()
	_page_index = _page_of(insight)
	_fill()
	_seen.append(insight)
	for card in _cards:
		if card.note == insight:
			card.write_out(WRITE)
			card.glow = 1.0
			card.create_tween().tween_property(card, "glow", 0.0, 3.0).set_delay(WRITE)
	_map.refresh()


## The slip under the one being dragged, if any.
func _target() -> NoteCard:
	return _target_for(_held)


func _target_for(held: NoteCard) -> NoteCard:
	if held == null:
		return null
	for number in range(_cards.size() - 1, -1, -1):
		var card := _cards[number]
		if card != held and card.covers(held.centre()):
			return card
	return null


## Two notes that do not belong together: the slip shakes its head and goes back.
func _spring_back(card: NoteCard) -> void:
	if sounds:
		sounds.play("miss")
	var spring := card.create_tween()
	var at := card.position
	for shake in [12.0, -10.0, 6.0]:
		spring.tween_property(card, "position", at + Vector2(shake, 0), 0.05)
	spring.tween_property(card, "position", _home, SPRING).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Opens a note for reading: a larger slip with all of its text, in the middle of the page.
func _read(note: String) -> void:
	var notes := session.notes()
	if not notes.has(note):
		return
	_reader = NoteCard.new()
	var crossed := session.holds(notes[note].get("crossed_if", [{"fact": "-never-"}]), session.definition.get("start", ""))
	_reader.setup(note, notes[note].get("kind", ""), crossed, 0, true)
	_reader.position = (_desk.size - NoteCard.READ_SIZE) * 0.5
	_reader.scale = Vector2.ONE * 0.85
	_reader.modulate.a = 0.0
	_desk.add_child(_reader)
	var rise := _reader.create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	rise.tween_property(_reader, "scale", Vector2.ONE, 0.2)
	rise.tween_property(_reader, "modulate:a", 1.0, 0.2)


## A point of the screen in the coordinates of the slips.
func _slips_point(point: Vector2) -> Vector2:
	return point - _book.position - _desk.position - _slips.position


## The foot of the page when there is more than one: arrows to either side, darker where there
## is a page to turn to and in red where that page has something new, and the page number.
func _draw_pager() -> void:
	if _pages <= 1:
		return
	var font := _pager.get_theme_font(&"font", &"MapName")
	var font_size := _pager.get_theme_font_size(&"font_size", &"MapName")
	var y := _desk.size.y - PAGER * 0.5
	var label := "%d / %d" % [_page_index + 1, _pages]
	var width := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	_pager.draw_string(font, Vector2((_desk.size.x - width) * 0.5, y + 12.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(INK, 0.6))
	for step: int in [-1, 1]:
		var page := _page_index + step
		if page < 0 or page >= _pages:
			continue
		var list := _slip_notes()
		var fresh := false
		for number in range(page * PER_PAGE, mini(list.size(), (page + 1) * PER_PAGE)):
			fresh = fresh or list[number] in _fresh
		# Opaque, like the cross: see-through strokes would be darker where they meet.
		var color := MARK if fresh else CROSS_INK
		var tip := Vector2(_desk.size.x * 0.5 + step * (_desk.size.x * 0.5 - 40.0), y)
		var back := Vector2(-step * 18.0, 0)
		for side: float in [-1.0, 1.0]:
			_pager.draw_line(tip, tip + back + Vector2(0, side * 18.0), color, 5.0, true)
			_pager.draw_circle(tip + back + Vector2(0, side * 18.0), 2.5, color, true, -1.0, true)
		_pager.draw_circle(tip, 2.5, color, true, -1.0, true)


## Until the player has dragged a slip, a ghostly finger shows how: it takes a slip that belongs
## with another and draws it there, over and over. Later it comes back when the book has been
## open a while without a thought although two slips belong together.
func _draw_ghost() -> void:
	if (_has_dragged and _open_time < GHOST_AGAIN) or _reader or _held:
		return
	var pair := []
	for open: Array in session.open_insights():
		var from := _card(open[0])
		var to := _card(open[1])
		if from and to:
			pair = [from, to]
			break
	if pair.is_empty():
		return
	var beat := fmod(_time / 2.6, 1.0)
	var travel := clampf((beat - 0.15) / 0.55, 0.0, 1.0)
	travel = travel * travel * (3.0 - 2.0 * travel)
	var from_point: Vector2 = pair[0].centre() + _slips.position
	var to_point: Vector2 = pair[1].centre() + _slips.position
	var at := from_point.lerp(to_point, travel)
	var alpha := sin(beat * PI) * 0.75
	_ghost.draw_circle(at + Vector2(0, 3), 22.0, Color(0, 0, 0, 0.15 * alpha), true, -1.0, true)
	_ghost.draw_circle(at, 20.0, Color(1, 1, 1, alpha), true, -1.0, true)
	_ghost.draw_arc(at, 20.0, 0.0, TAU, 24, Color(INK, 0.5 * alpha), 2.5, true)


func _card(note: String) -> NoteCard:
	for card in _cards:
		if card.note == note:
			return card
	return null


## A cross of two strokes with round ends. Its ink is opaque: see-through strokes would be
## darker where they cross.
func _draw_close() -> void:
	var centre := Vector2.ONE * CLOSE_SIZE * 0.5
	for arm: Vector2 in [Vector2(1, 1), Vector2(1, -1)]:
		var from := centre - arm * 15.0
		var to := centre + arm * 15.0
		_close.draw_line(from, to, CROSS_INK, 5.0, true)
		for end: Vector2 in [from, to]:
			_close.draw_circle(end, 2.5, CROSS_INK, true, -1.0, true)


## An open book: two pages that rise towards the spine, a few lines of writing on them and the
## cover showing below. A dot at the rim while there is something unread. A ring that breathes
## around it while it calls for attention.
func _draw_button() -> void:
	var top := -BOOK_ICON_HEIGHT * 0.5 - 1.0
	for side: float in [-1.0, 1.0]:
		var spine := Vector2(side * 1.5, top + BOOK_ICON_RISE)
		var edge := Vector2(side * BOOK_ICON_WIDTH, top)
		var down := Vector2(0, BOOK_ICON_HEIGHT)
		_button.draw_area([spine, edge, edge + down, spine + down], _button.light)
		var below := Vector2(0, BOOK_ICON_COVER)
		_button.draw_area([spine + down, edge + down, edge + down + below, spine + down + below], MARK)
		for line in 3:
			var from := Vector2(side * 6.0, top + 12.0 + line * 6.5)
			var to := Vector2(side * (BOOK_ICON_WIDTH - 5.0), top + 8.0 + line * 6.5)
			_button.draw_stroke(from, to, _button.light.lerp(MARK, 0.55), 2.0)
	if _hinted:
		var beat := fmod(_time / 1.4, 1.0)
		var centre := Vector2.ONE * RoundButton.SIZE * 0.5
		_button.draw_arc(centre, RoundButton.SIZE * (0.5 + 0.35 * beat), 0.0, TAU, 40, Color(1, 1, 1, 0.8 * (1.0 - beat)), 4.0, true)
	if _unread:
		var spot := Vector2(RoundButton.SIZE - 13.0, 13.0)
		_button.draw_circle(spot, 13.0, _button.light, true, -1.0, true)
		_button.draw_circle(spot, 9.5, MARK, true, -1.0, true)
