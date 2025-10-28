extends Panel

@export var window_title: String = "Window" : set = set_window_title
@export var show_close_button: bool = true : set = set_show_close_button
@export var content_scene: PackedScene

@onready var title_bar = $TitleBar
@onready var close_button = $TitleBar/NinePatchRect/TextureButton
@onready var title_label = $TitleBar/NinePatchRect/Label
@onready var content_area: Control = $ContentArea
var dragging = false
var drag_offset = Vector2.ZERO

func _ready():
	title_bar.gui_input.connect(_on_title_bar_gui_input)
	close_button.pressed.connect(_on_close_button_pressed)
	set_window_title(window_title)
	set_show_close_button(show_close_button)
	if content_scene:
		set_content_scene(content_scene)

func _on_title_bar_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				move_to_front()
				dragging = true
				drag_offset = get_global_mouse_position() - global_position
			else:
				dragging = false
	elif event is InputEventMouseMotion and dragging:
		move_to_front()
		var desired = get_global_mouse_position() - drag_offset
		var parent_ctrl := get_parent() as Control
		if parent_ctrl:
			var min_global = parent_ctrl.global_position
			var max_global = min_global + parent_ctrl.size - size
			desired.x = clamp(desired.x, min_global.x, max_global.x)
			desired.y = clamp(desired.y, min_global.y, max_global.y)
			global_position = desired
		else:
			global_position = desired

func _on_close_button_pressed():
	visible = false

func set_window_title(value: String) -> void:
	window_title = value
	if title_label:
		title_label.text = value

func set_show_close_button(value: bool) -> void:
	show_close_button = value
	if close_button:
		close_button.visible = value

func set_content_scene(scene: PackedScene) -> void:
	content_scene = scene
	if scene:
		var node = scene.instantiate()
		set_content(node)

func set_content(node: Node) -> void:
	for child in content_area.get_children():
		child.queue_free()
	content_area.add_child(node)
	if node is Control:
		var ctrl := node as Control
		ctrl.anchor_left = 0.0
		ctrl.anchor_top = 0.0
		ctrl.anchor_right = 1.0
		ctrl.anchor_bottom = 1.0
		ctrl.grow_horizontal = Control.GROW_DIRECTION_BOTH
		ctrl.grow_vertical = Control.GROW_DIRECTION_BOTH
