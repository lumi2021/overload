@tool
extends BaseButton
class_name MenuBarOption

var text_label: Label
var tip_label: Label

var _style_disabled: StyleBox
var _style_pressed: StyleBox
var _style_hover: StyleBox
var _Style_normal: StyleBox

@export var text := "":
	set(value):
		text = value
		if text_label:
			text_label.text = value

@export var tip := "":
	set(value):
		tip = value
		if tip_label:
			tip_label.text = value

func _ready() -> void:
	theme_type_variation = "MenuBarOption"
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	text_label = Label.new()
	tip_label = Label.new()

	add_child(text_label)
	add_child(tip_label)

	text_label.text = text
	tip_label.text = tip

	# Setup left label
	text_label.anchor_left = 0.0
	text_label.anchor_right = 0.5
	text_label.offset_left = 4
	text_label.mouse_filter = Control.MOUSE_FILTER_PASS

	# Setup right label
	tip_label.anchor_left = 0.5
	tip_label.anchor_right = 1.0
	tip_label.offset_right = -4
	text_label.mouse_filter = Control.MOUSE_FILTER_PASS
	tip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	theme_changed.connect(_on_theme_changed)

func _apply_theme():
	if not text_label or not tip_label:
		return

	text_label.add_theme_color_override(
		"font_color",
		get_theme_color("text_font_color", "MenuBarOption")
	)

	tip_label.add_theme_color_override(
		"font_color",
		get_theme_color("tip_font_color", "MenuBarOption")
	)
	
	_style_disabled = get_theme_stylebox("disabled")
	_style_pressed = get_theme_stylebox("pressed")
	_style_hover = get_theme_stylebox("hover")
	_Style_normal = get_theme_stylebox("normal")

func _draw():
	var style: StyleBox

	if disabled:
		style = _style_disabled
	elif button_pressed:
		style = _style_pressed
	elif is_hovered():
		style = _style_hover
	else:
		style = _Style_normal

	style.draw(get_canvas_item(), Rect2(Vector2.ZERO, size))

func _get_minimum_size() -> Vector2:
	var left := text_label.get_combined_minimum_size() if text_label else Vector2.ZERO
	var right := tip_label.get_combined_minimum_size() if tip_label else Vector2.ZERO
	return Vector2(left.x + right.x + 32, max(left.y, right.y))
func _on_theme_changed() -> void:
	_apply_theme()
