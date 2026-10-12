class_name StartScreen
extends CanvasLayer
## The first thing the player sees: a calm screen that recommends headphones or a quiet place,
## because the mood is a large part of the game. A tap fades it out and the game begins.

signal dismissed

const BACKGROUND := Color(0.09, 0.1, 0.14)
const FADE_IN := 1.5
const FADE_OUT := 1.4

## Covers the whole screen and catches every tap until it is gone.
var _cover := ColorRect.new()
var _advice := Label.new()
var _leaving := false


func _ready() -> void:
	layer = 40
	_cover.color = BACKGROUND
	_cover.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cover.mouse_filter = Control.MOUSE_FILTER_STOP
	_cover.gui_input.connect(_on_cover_input)
	add_child(_cover)

	var content := VBoxContainer.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 48)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.modulate.a = 0.0
	_cover.add_child(content)

	var icon := Control.new()
	icon.custom_minimum_size = Vector2(0, 150)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.draw.connect(_draw_headphones.bind(icon))
	content.add_child(icon)
	_advice.text = Texts.text("start.advice")
	_advice.theme_type_variation = &"StartAdvice"
	_advice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_advice)
	var hint := Label.new()
	hint.text = Texts.text("start.begin")
	hint.theme_type_variation = &"StartHint"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(hint)

	create_tween().tween_property(content, "modulate:a", 1.0, FADE_IN)


func _on_cover_input(event: InputEvent) -> void:
	# A tap arrives as a touch and as a mouse click. Only the touch of the first finger counts.
	var touch := event as InputEventScreenTouch
	if touch == null or not touch.pressed or touch.index != 0 or _leaving:
		return
	_leaving = true
	dismissed.emit()
	var fade := create_tween()
	fade.tween_property(_cover, "modulate:a", 0.0, FADE_OUT)
	fade.tween_callback(queue_free)


func _draw_headphones(icon: Control) -> void:
	var color := _advice.get_theme_color(&"font_color")
	var centre := Vector2(icon.size.x * 0.5, 90.0)
	icon.draw_arc(centre, 56.0, PI, TAU, 32, color, 7.0, true)
	for side: float in [-1.0, 1.0]:
		icon.draw_rect(Rect2(centre + Vector2(side * 56.0 - 13.0, -4.0), Vector2(26, 54)), color)
