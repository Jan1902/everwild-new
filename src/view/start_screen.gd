class_name StartScreen
extends CanvasLayer
## The first thing the player sees: a calm screen that recommends headphones or a quiet place,
## because the mood is a large part of the game. A tap fades it out and the game begins.

signal dismissed

const BACKGROUND := Color(0.09, 0.1, 0.14)
const TEXT_COLOR := Color(0.93, 0.9, 0.84)
const FADE_IN := 1.5
const FADE_OUT := 1.4

var _cover: ColorRect
var _content: VBoxContainer
var _leaving := false


func _ready() -> void:
	layer = 40
	_cover = ColorRect.new()
	_cover.color = BACKGROUND
	_cover.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_cover)

	_content = VBoxContainer.new()
	_content.set_anchors_preset(Control.PRESET_FULL_RECT)
	_content.alignment = BoxContainer.ALIGNMENT_CENTER
	_content.add_theme_constant_override("separation", 48)
	_content.modulate.a = 0.0
	_cover.add_child(_content)

	var icon := Control.new()
	icon.custom_minimum_size = Vector2(0, 150)
	icon.draw.connect(_draw_headphones.bind(icon))
	_content.add_child(icon)
	_content.add_child(_label(Texts.text("start.advice"), 44, 1.0))
	_content.add_child(_label(Texts.text("start.begin"), 30, 0.55))

	create_tween().tween_property(_content, "modulate:a", 1.0, FADE_IN)


func _input(event: InputEvent) -> void:
	if not event is InputEventScreenTouch:
		return
	get_viewport().set_input_as_handled()
	if _leaving or not event.pressed:
		return
	_leaving = true
	dismissed.emit()
	var fade := create_tween()
	fade.tween_property(_cover, "modulate:a", 0.0, FADE_OUT)
	fade.tween_callback(queue_free)


func _label(text: String, font_size: int, opacity: float) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(TEXT_COLOR, opacity))
	return label


func _draw_headphones(icon: Control) -> void:
	var centre := Vector2(icon.size.x * 0.5, 90.0)
	icon.draw_arc(centre, 56.0, PI, TAU, 32, TEXT_COLOR, 7.0, true)
	for side: float in [-1.0, 1.0]:
		icon.draw_rect(Rect2(centre + Vector2(side * 56.0 - 13.0, -4.0), Vector2(26, 54)), TEXT_COLOR)