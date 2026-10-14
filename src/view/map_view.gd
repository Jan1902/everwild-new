class_name MapView
extends Control
## The map in the notebook: the pieces of the world the player knows as small pictures of their
## painted ground, and the arches between them as arrows drawn by hand. What is not known yet shows as a
## question: an arrow that ends in "?" where an arch leads somewhere unknown, or a dashed arrow
## with "?" on it where an arch skips something.
##
## Where the pieces lie and when an arrow shows is data in data/map.json: "pieces" (piece id ->
## position as a fraction of the page) and "ways" ("from", "to", "if" (conditions), and
## "unknown" or "skips" for the two kinds of question).

const PATH := "res://data/map.json"
## The ink as it looks on the paper. It is opaque: see-through strokes would be darker where they
## meet, as at the tip of an arrow.
const INK := Color(0.31, 0.28, 0.25)
const MARK := Color(0.72, 0.36, 0.24)
## Width of a piece on the map, and how far from its centre an arrow starts and ends.
const PIECE_WIDTH := 210.0
const GAP := 105.0
## Length of an arrow that leads somewhere unknown.
const UNKNOWN_LENGTH := 120.0
## Seconds a piece takes to appear on the map once it is known.
const APPEAR := 1.6
## Share of the page the map takes; below it the notebook lists what the player carries.
const MAP_SHARE := 0.8

var session: Session

var _data := {}
## Piece id -> how far it has appeared, from 0 to 1. Pieces already known when the map was first
## drawn are there at once.
var _shown := {}
var _first := true
## Piece id -> its ground picture, cut to where it is painted. Null for a piece without one.
var _pictures := {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	_data = data if data is Dictionary else {}


## Draws the map anew from the state of the game. Pieces that have become known since appear.
func refresh() -> void:
	for piece: String in _visible_pieces():
		if not _shown.has(piece):
			_shown[piece] = 1.0 if _first else 0.0
	_first = false
	queue_redraw()


## Whether a piece has just appeared and is still coming.
func is_appearing() -> bool:
	return _shown.values().any(func(amount: float) -> bool: return amount < 1.0)


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	var changed := false
	for piece: String in _shown:
		if _shown[piece] < 1.0:
			_shown[piece] = minf(1.0, _shown[piece] + delta / APPEAR)
			changed = true
	if changed:
		queue_redraw()


func _visible_pieces() -> Array[String]:
	var pieces: Array[String] = []
	if session == null:
		return pieces
	var notes := session.notes()
	for note: String in session.state.notes:
		if notes.get(note, {}).get("kind", "") == "piece" and _data.get("pieces", {}).has(note):
			pieces.append(note)
	# A piece the player has worked out where it lies is on the map before they have been there.
	for way: Dictionary in _ways():
		if not way.get("unknown", false) and not way.get("skips", false) and way.get("to", "") not in pieces:
			pieces.append(way.get("to", ""))
	return pieces


func _ways() -> Array[Dictionary]:
	var ways: Array[Dictionary] = []
	for way: Dictionary in _data.get("ways", []):
		if session.holds(way.get("if", []), session.definition.get("start", "")):
			ways.append(way)
	return ways


func _point(piece: String) -> Vector2:
	var place: Array = _data.get("pieces", {}).get(piece, [0.5, 0.5])
	return Vector2(place[0], place[1]) * Vector2(size.x, size.y * MAP_SHARE)


func _draw() -> void:
	if session == null:
		return
	var pieces := _visible_pieces()
	for way: Dictionary in _ways():
		var from := _point(way.get("from", ""))
		var to := _point(way.get("to", ""))
		if way.get("from", "") not in pieces:
			continue
		var along := (to - from).normalized()
		var start := from + along * GAP
		if way.get("unknown", false):
			var end := start + along * UNKNOWN_LENGTH
			_dashes(start, end, MARK)
			_question(end + along * 34.0)
		elif way.get("skips", false):
			# Bowed outwards, away from the middle of the map, so it does not cross the others.
			var middle := (from + to) * 0.5
			var outwards := (middle - size * 0.5).normalized() * 70.0
			var bend := middle + outwards
			var points := _curve(start, bend, to - (to - bend).normalized() * GAP)
			for number in range(0, points.size() - 1, 2):
				draw_line(points[number], points[number + 1], MARK, 3.0, true)
			_head(points[-1], (points[-1] - points[-2]).normalized(), MARK)
			_question(bend)
		elif way.get("to", "") in pieces:
			var end := to - along * GAP
			_hand_line(start, end, INK)
			_head(end, along, INK)
	for piece in pieces:
		_island(piece, _point(piece), _shown.get(piece, 1.0))
	_carried()


## What the player carries, in their hand at the foot of the page: everything they ever had,
## crossed out once it was given away. The notebook itself is not on it.
func _carried() -> void:
	var things := session.state.held.filter(func(item: String) -> bool: return item != "notebook")
	if things.is_empty():
		return
	var heading := get_theme_font(&"font", &"MapName")
	var heading_size := get_theme_font_size(&"font_size", &"MapName")
	var hand := get_theme_font(&"font", &"NoteText")
	var hand_size := get_theme_font_size(&"font_size", &"NoteText")
	var y := size.y * MAP_SHARE + 70.0
	var label := Texts.text("notebook.carrying") + ":"
	draw_string(heading, Vector2(0, y), label, HORIZONTAL_ALIGNMENT_LEFT, -1, heading_size, INK)
	var x := heading.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, heading_size).x + 24.0
	for item: String in things:
		var name := Texts.text("item." + item)
		var width := hand.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, hand_size).x
		if x + width > size.x:
			x = 0.0
			y += 44.0
		draw_string(hand, Vector2(x, y), name, HORIZONTAL_ALIGNMENT_LEFT, -1, hand_size, INK)
		if item not in session.state.items:
			draw_line(Vector2(x - 4, y - 10), Vector2(x + width + 4, y - 13), INK, 3.0, true)
		x += width + 30.0


## An island: a meadow on top and the earth underneath tapering off, its name above and a dot
## for each fault below, filled once it is fixed.
func _island(piece: String, at: Vector2, amount: float) -> void:
	var alpha := clampf(amount * 1.5, 0.0, 1.0)
	var picture := _picture(piece)
	var area := Vector2(PIECE_WIDTH, PIECE_WIDTH * 0.5)
	if picture:
		area.y = PIECE_WIDTH * picture.get_height() / picture.get_width()
	if amount < 1.0:
		# Something newly worked out glows as it appears.
		for ring in 5:
			draw_circle(at, PIECE_WIDTH * 0.6 * (1.0 - ring * 0.15) * (0.6 + amount), Color(1.0, 0.85, 0.5, 0.06 * (1.0 - amount)))
	if picture:
		draw_texture_rect(picture, Rect2(at - area * 0.5, area), false, Color(1, 1, 1, alpha))
	else:
		draw_set_transform(at, 0.0, Vector2(1.0, 0.45))
		draw_circle(Vector2.ZERO, PIECE_WIDTH * 0.4, Color(0.55, 0.66, 0.42, alpha))
		draw_set_transform(Vector2.ZERO)
	var font := get_theme_font(&"font", &"MapName")
	var font_size := get_theme_font_size(&"font_size", &"MapName")
	var name := Texts.text("world." + piece)
	var width := font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(font, at + Vector2(-width * 0.5, -area.y * 0.5 - 6.0), name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(INK, alpha))
	var faults := session.world(piece).faults.size()
	var fixed := faults - session.open_faults(piece).size()
	for number in faults:
		var dot := at + Vector2((number - (faults - 1) * 0.5) * 22.0, area.y * 0.5 + 14.0)
		if number < fixed:
			draw_circle(dot, 7.0, Color(MARK, alpha), true, -1.0, true)
		else:
			draw_arc(dot, 6.0, 0.0, TAU, 16, Color(MARK, alpha), 2.0, true)


## The painted ground of a piece, cut to where it is painted.
func _picture(piece: String) -> Texture2D:
	if not _pictures.has(piece):
		var path: String = session.world(piece).ground_image.get("path", "")
		var picture: AtlasTexture = null
		if ResourceLoader.exists(path):
			var texture: Texture2D = load(path)
			picture = AtlasTexture.new()
			picture.atlas = texture
			picture.region = Rect2(texture.get_image().get_used_rect())
		_pictures[piece] = picture
	return _pictures[piece]


func _question(at: Vector2) -> void:
	var font := get_theme_font(&"font", &"MapUnknown")
	var font_size := get_theme_font_size(&"font_size", &"MapUnknown")
	draw_string(font, at + Vector2(-10, 16), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, MARK)


## A line drawn by hand: it wavers a little.
func _hand_line(from: Vector2, to: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	var steps := 12
	var across := (to - from).orthogonal().normalized()
	for number in steps + 1:
		var t := float(number) / steps
		points.append(from.lerp(to, t) + across * sin(t * 9.0 + from.x * 0.01) * 2.5)
	draw_polyline(points, color, 3.0, true)


func _dashes(from: Vector2, to: Vector2, color: Color) -> void:
	var length := from.distance_to(to)
	var dash := 16.0
	var count := int(length / (dash * 1.8))
	for number in count:
		var a := from.lerp(to, number * dash * 1.8 / length)
		var b := from.lerp(to, minf(1.0, (number * dash * 1.8 + dash) / length))
		draw_line(a, b, color, 3.0, true)


func _curve(from: Vector2, bend: Vector2, to: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	for number in 25:
		var t := number / 24.0
		points.append(from.lerp(bend, t).lerp(bend.lerp(to, t), t))
	return points


func _head(at: Vector2, along: Vector2, color: Color) -> void:
	var back := -along * 18.0
	var side := along.orthogonal() * 10.0
	for end: Vector2 in [at + back + side, at + back - side]:
		draw_line(at, end, color, 3.0, true)
		draw_circle(end, 1.5, color, true, -1.0, true)
	draw_circle(at, 1.5, color, true, -1.0, true)
