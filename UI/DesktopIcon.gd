extends VBoxContainer

## A clickable desktop icon that can trigger actions

signal icon_clicked(icon_id: String)
signal icon_double_clicked(icon_id: String)

@export var icon_id: String = "unknown"
@export var icon_label: String = "Icon"
@export var icon_color: Color = Color(0.3, 0.3, 0.3, 1)

@onready var icon_rect: ColorRect = $Icon
@onready var label: Label = $Label

var click_timer: Timer = null
var click_count: int = 0

func _ready() -> void:
	label.text = icon_label
	icon_rect.color = icon_color
	
	# Setup click timer for double-click detection
	click_timer = Timer.new()
	click_timer.wait_time = 0.3
	click_timer.one_shot = true
	add_child(click_timer)
	click_timer.timeout.connect(_on_click_timer_timeout)
	
	# Connect input event
	icon_rect.gui_input.connect(_on_icon_gui_input)

func _on_icon_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			click_count += 1
			
			if click_count == 1:
				# Start timer for double-click detection
				click_timer.start()
			elif click_count == 2:
				# Double-click detected
				click_timer.stop()
				click_count = 0
				emit_signal("icon_double_clicked", icon_id)

func _on_click_timer_timeout() -> void:
	# Single click
	if click_count == 1:
		emit_signal("icon_clicked", icon_id)
	click_count = 0

func set_icon_data(id: String, display_label: String, color: Color = Color(0.3, 0.3, 0.3, 1)) -> void:
	icon_id = id
	icon_label = display_label
	icon_color = color
	
	if label:
		label.text = icon_label
	if icon_rect:
		icon_rect.color = icon_color

