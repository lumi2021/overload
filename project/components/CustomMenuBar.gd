class_name CustomMenuBar
extends Button

@onready var submenu = get_node_or_null("Submenu")

func _ready() -> void:
	theme_type_variation = "CustomMenuBar"
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	if submenu == null:
		push_error("CustomMenuBar: Submenu node does not exists")
		return

	submenu.hide()
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	if submenu == null: return
	
	if (submenu.visible == false):
		submenu.show()
	else:
		submenu.hide()

func _input(event):
	if submenu == null: return
	
	if submenu.visible and event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_viewport().get_mouse_position()
		if not submenu.get_global_rect().has_point(mouse_pos):
			if get_global_rect().has_point(mouse_pos): return
			submenu.hide()
