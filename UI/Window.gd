extends Panel

@onready var title_bar = $TitleBar
var dragging = false
var drag_offset = Vector2.ZERO

func _ready():
	title_bar.connect("gui_input", _on_title_bar_input)

func _on_title_bar_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = get_global_mouse_position() - global_position
				DragSystem.start_drag(self)
			else:
				dragging = false
				DragSystem.stop_drag()
	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - drag_offset
