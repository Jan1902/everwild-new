class_name RoundButton
extends Button
## A round button in a corner of the screen: a dark disc with a fine light rim. What it shows is
## drawn on top by whoever owns it, on the "draw" signal, with the helpers below.

const SIZE := 92.0
## Distance from the edges of the screen.
const MARGIN := 36.0
const DISC_COLOR := Color(0.09, 0.1, 0.14, 0.62)
const DISC_COLOR_PRESSED := Color(0.09, 0.1, 0.14, 0.82)
const RIM_OPACITY := 0.4
const RIM_WIDTH := 2.5

## Colour of the rim and of what is drawn on the disc: the paper of the pages.
var light: Color


## Puts the button in the upper left or the upper right corner of the screen.
func _init(on_the_right := false) -> void:
	theme_type_variation = &"IconButton"
	focus_mode = Control.FOCUS_NONE
	if on_the_right:
		anchor_left = 1.0
		anchor_right = 1.0
		offset_left = -MARGIN - SIZE
	else:
		offset_left = MARGIN
	offset_right = offset_left + SIZE
	offset_top = MARGIN
	offset_bottom = MARGIN + SIZE
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)


func _ready() -> void:
	light = (get_theme_stylebox(&"panel", &"Paper") as StyleBoxFlat).bg_color


func centre() -> Vector2:
	return Vector2.ONE * SIZE * 0.5


## The disc has to lie below what the owner draws. The "draw" signal comes before _draw() but
## after this notification.
func _notification(what: int) -> void:
	if what != NOTIFICATION_DRAW:
		return
	var radius := SIZE * 0.5
	draw_circle(centre(), radius, DISC_COLOR_PRESSED if is_pressed() else DISC_COLOR, true, -1.0, true)
	draw_arc(centre(), radius - RIM_WIDTH, 0.0, TAU, 64, Color(light, RIM_OPACITY), RIM_WIDTH, true)


## A stroke with round ends, between two points given relative to the centre.
func draw_stroke(from: Vector2, to: Vector2, color: Color, width: float) -> void:
	draw_line(centre() + from, centre() + to, color, width, true)
	for end: Vector2 in [from, to]:
		draw_circle(centre() + end, width * 0.5, color, true, -1.0, true)


## A filled area with smooth edges, its corners given relative to the centre.
func draw_area(corners: PackedVector2Array, color: Color) -> void:
	var points := PackedVector2Array()
	for corner in corners:
		points.append(centre() + corner)
	draw_colored_polygon(points, color)
	points.append(points[0])
	draw_polyline(points, color, 1.5, true)
