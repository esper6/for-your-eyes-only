extends CharacterBody2D

## A simple text viewer window (like Notepad)

@onready var title_label: Label = $TitleBar/TitleLabel
@onready var close_button: Button = $TitleBar/CloseButton
@onready var text_display: TextEdit = $ContentArea/TextDisplay
@onready var title_bar: Panel = $TitleBar

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var drag_manager: Node = null

var file_name: String = "Untitled"
var file_content: String = ""

func _ready() -> void:
	# Get DragManager from autoload
	drag_manager = get_node_or_null("/root/DragSystem")
	
	# Setup UI
	text_display.editable = false
	text_display.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	
	# Connect signals
	close_button.pressed.connect(_on_close_pressed)
	title_bar.gui_input.connect(_on_title_bar_gui_input)

func _physics_process(_delta: float) -> void:
	if is_dragging:
		var mouse_pos = get_global_mouse_position()
		var target_pos = mouse_pos - drag_offset
		global_position = target_pos

func open_file(file_name_param: String, content: String) -> void:
	file_name = file_name_param
	file_content = content
	title_label.text = file_name
	text_display.text = content

func _on_close_pressed() -> void:
	queue_free()

func _on_title_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging
				is_dragging = true
				drag_offset = get_global_mouse_position() - global_position
				if drag_manager:
					drag_manager.start_drag(self)
				# Bring to front
				if get_parent():
					get_parent().move_child(self, -1)
			else:
				# Stop dragging
				is_dragging = false
				if drag_manager:
					drag_manager.stop_drag()

