# camera.gd
extends Camera2D

@export var zoom_start := 0.5
@export var zoom_min := 0.2
@export var zoom_max := 5.0
@export var zoom_speed := 0.1
@export var drag_button := MOUSE_BUTTON_LEFT

@export_node_path("ProgressBar") var zoom_meter
var _zoom_meter: ProgressBar

var _dragging := false
var _drag_origin := Vector2.ZERO

func _ready() -> void:
	_zoom_meter = get_node(zoom_meter)
	zoom = Vector2(zoom_start, zoom_start)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
	
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_apply_zoom(-zoom_speed, event.position)
			get_viewport().set_input_as_handled()
		
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_apply_zoom(zoom_speed, event.position)
			get_viewport().set_input_as_handled()

		elif event.button_index == drag_button:
			_dragging = event.pressed
			if _dragging:
				_drag_origin = event.position
			get_viewport().set_input_as_handled()

	# Drag move
	if event is InputEventMouseMotion and _dragging:
		global_position -= event.relative / zoom
		get_viewport().set_input_as_handled()

func _apply_zoom(delta: float, mouse_pos: Vector2) -> void:
	var old_zoom := zoom
	var new_zoom_val = clamp(zoom.x - delta, zoom_min, zoom_max)
	zoom = Vector2.ONE * new_zoom_val

	var zoom_factor := 1.0 / old_zoom.x - 1.0 / zoom.x
	global_position += (mouse_pos - get_viewport_rect().size / 2) * zoom_factor
	
	var zoom_percent := (zoom.x - zoom_min) / (zoom_max - zoom_min)
	if (_zoom_meter != null): _zoom_meter.value = zoom_percent
