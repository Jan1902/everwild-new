extends SceneTree
## Writes the theme of the game's interface, assets/ui/theme.tres. The project uses it for every
## control (gui/theme/custom in project.godot); the views only name the variation a control is.
##
##   godot --headless --path . --script tools/build_theme.gd

const PATH := "res://assets/ui/theme.tres"
const PAPER := Color(0.93, 0.89, 0.8)
const INK := Color(0.2, 0.17, 0.15)
const FAINT := Color(0.2, 0.17, 0.15, 0.55)
const MARK := Color(0.72, 0.36, 0.24)
const NIGHT := Color(0.09, 0.1, 0.14)
const WARM := Color(0.95, 0.8, 0.55)
const PALE := Color(0.96, 0.95, 0.92)
const CREAM := Color(0.93, 0.9, 0.84)


func _init() -> void:
	var theme := Theme.new()
	theme.default_font_size = 34

	_label(theme, &"DialogueName", 30, WARM)
	_label(theme, &"DialogueText", 40, PALE)
	_label(theme, &"DialogueMark", 28, Color(WARM, 0.7))
	_panel(theme, &"DialoguePanel", Color(NIGHT, 0.84), 18, 36)

	_label(theme, &"PaperHeading", 44, INK)
	_label(theme, &"PaperText", 34, INK)
	_label(theme, &"PaperSmall", 28, FAINT)
	_label(theme, &"PaperFaint", 34, FAINT)
	_label(theme, &"PaperMissing", 32, FAINT)
	_panel(theme, &"Paper", PAPER, 14, 56)
	_text_button(theme, &"PaperEntry", 34, INK)
	_text_button(theme, &"PaperEntrySelected", 34, MARK)
	_text_button(theme, &"PaperLink", 32, MARK)
	# Buttons that draw their own picture.
	_text_button(theme, &"IconButton", 34, INK)
	_slider(theme)
	_scroll_bar(theme)

	_label(theme, &"StartAdvice", 44, CREAM)
	_label(theme, &"StartHint", 30, Color(CREAM, 0.55))

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(PATH.get_base_dir()))
	var result := ResourceSaver.save(theme, PATH)
	print("theme written" if result == OK else "theme not written: %d" % result)
	quit(0 if result == OK else 1)


func _label(theme: Theme, variation: StringName, font_size: int, color: Color) -> void:
	theme.set_type_variation(variation, &"Label")
	theme.set_font_size(&"font_size", variation, font_size)
	theme.set_color(&"font_color", variation, color)


func _panel(theme: Theme, variation: StringName, color: Color, corner: int, margin: int) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(corner)
	style.set_content_margin_all(margin)
	theme.set_type_variation(variation, &"PanelContainer")
	theme.set_stylebox(&"panel", variation, style)


## A slider with a bar thick enough to see and a knob large enough for a finger.
func _slider(theme: Theme) -> void:
	var bar := StyleBoxFlat.new()
	bar.bg_color = Color(INK, 0.2)
	bar.set_corner_radius_all(5)
	bar.content_margin_top = 5
	bar.content_margin_bottom = 5
	var filled: StyleBoxFlat = bar.duplicate()
	filled.bg_color = MARK
	theme.set_stylebox(&"slider", &"HSlider", bar)
	theme.set_stylebox(&"grabber_area", &"HSlider", filled)
	theme.set_stylebox(&"grabber_area_highlight", &"HSlider", filled)

	var size := 48
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var centre := Vector2.ONE * (size - 1) * 0.5
	for y in size:
		for x in size:
			# One pixel of soft edge.
			var opacity := clampf(size * 0.5 - 1.0 - Vector2(x, y).distance_to(centre), 0.0, 1.0)
			image.set_pixel(x, y, Color(MARK, opacity))
	var knob := ImageTexture.create_from_image(image)
	for state: StringName in [&"grabber", &"grabber_highlight", &"grabber_disabled"]:
		theme.set_icon(state, &"HSlider", knob)


## A thin, faint bar at the edge of a column that scrolls. It only shows how far the column goes;
## scrolling is done by swiping.
func _scroll_bar(theme: Theme) -> void:
	var track := StyleBoxEmpty.new()
	track.content_margin_left = 4
	track.content_margin_right = 4
	theme.set_stylebox(&"scroll", &"VScrollBar", track)
	var bar := StyleBoxFlat.new()
	bar.bg_color = Color(INK, 0.25)
	bar.set_corner_radius_all(4)
	for state: StringName in [&"grabber", &"grabber_highlight", &"grabber_pressed"]:
		theme.set_stylebox(state, &"VScrollBar", bar)


## A button that is nothing but its text, in the same colour whatever is done to it.
func _text_button(theme: Theme, variation: StringName, font_size: int, color: Color) -> void:
	theme.set_type_variation(variation, &"Button")
	theme.set_font_size(&"font_size", variation, font_size)
	for state: StringName in [&"font_color", &"font_hover_color", &"font_pressed_color", &"font_hover_pressed_color", &"font_focus_color"]:
		theme.set_color(state, variation, color)
	var empty := StyleBoxEmpty.new()
	for state: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed", &"focus", &"disabled"]:
		theme.set_stylebox(state, variation, empty)
