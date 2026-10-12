class_name Banner
extends CanvasLayer
## A line of text that appears near the top of the screen for a while and fades again, for the
## rare moments the game marks, such as a world becoming whole. It takes no taps.

const FADE_IN := 0.9
const STAY := 3.2
const FADE_OUT := 1.6

var _label := Label.new()
var _fade: Tween


func _ready() -> void:
	# Above the colour grading, so the text keeps its colour, and below everything that opens.
	layer = 12
	_label.theme_type_variation = &"Banner"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.anchor_right = 1.0
	_label.offset_top = 150.0
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.modulate.a = 0.0
	add_child(_label)


func show_text(text: String) -> void:
	if _fade:
		_fade.kill()
	_label.text = text
	_fade = create_tween()
	_fade.tween_property(_label, "modulate:a", 1.0, FADE_IN)
	_fade.tween_interval(STAY)
	_fade.tween_property(_label, "modulate:a", 0.0, FADE_OUT)
