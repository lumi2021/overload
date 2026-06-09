# grid.gd
extends Node2D

@export var grid_size := 32
@export var color := Color(0.5, 0.5, 0.5, 0.4)
@export var hide_grid_zoom = 0.01

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var camera := get_viewport().get_camera_2d()
	if camera == null: return
	if hide_grid_zoom != 0 && camera.zoom.x < hide_grid_zoom: return

	var viewport_size := get_viewport_rect().size
	var zoom := camera.zoom
	var visible_size := viewport_size / zoom  # ← divisão, não multiplicação

	var cam_pos := camera.global_position
	var left   := cam_pos.x - visible_size.x / 2
	var right  := cam_pos.x + visible_size.x / 2
	var top    := cam_pos.y - visible_size.y / 2
	var bottom := cam_pos.y + visible_size.y / 2

	var start_x: float = floor(left / grid_size) * grid_size
	var start_y: float = floor(top  / grid_size) * grid_size

	var x := start_x
	while x <= right:
		draw_line(
			to_local(Vector2(x, top)),
			to_local(Vector2(x, bottom)),
			color
		)
		x += grid_size

	var y := start_y
	while y <= bottom:
		draw_line(
			to_local(Vector2(left,  y)),
			to_local(Vector2(right, y)),
			color
		)
		y += grid_size
