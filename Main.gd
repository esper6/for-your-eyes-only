extends Control

@onready var file_explorer_window: Panel = $WindowContainer/FileExplorerWindow
@onready var file_explorer_button: Button = $Taskbar/TaskbarContent/FileExplorerButton
@onready var time_label: Label = $Taskbar/TaskbarContent/TimeLabel

func _ready() -> void:
	# Show file explorer on startup
	file_explorer_window.visible = true
	
	# Connect buttons
	file_explorer_button.pressed.connect(_on_file_explorer_button_pressed)
	
	# Update time
	_update_time()
	
	# Start with intro dialogue
	_start_intro_dialogue()

func _update_time() -> void:
	var time_dict: Dictionary = Time.get_time_dict_from_system()
	var hour: int = time_dict["hour"]
	var minute: int = time_dict["minute"]
	var am_pm: String = "AM"
	
	if hour >= 12:
		am_pm = "PM"
		if hour > 12:
			hour -= 12
	elif hour == 0:
		hour = 12
	
	time_label.text = "%d:%02d %s" % [hour, minute, am_pm]

func _on_file_explorer_button_pressed() -> void:
	file_explorer_window.visible = !file_explorer_window.visible

func _start_intro_dialogue() -> void:
	# Intro dialogue when game starts
	var intro_dialogue: Array = [
		{"character": "Agent", "text": "Welcome to your new assignment. This system contains sensitive information."},
		{"character": "Agent", "text": "Your job is to find evidence hidden in the files. Be thorough."},
		{"character": "You", "text": "Understood. Where should I start looking?"},
		{"character": "Agent", "text": "Check the Documents folder. There might be something interesting in the personal files."},
		{"character": "Agent", "text": "Good luck. And remember... trust no one."}
	]
	
	# Start the dialogue
	DialogueSystem.load_dialogue(intro_dialogue)

# Example functions for changing settings (to be called from Options menu later)
func set_text_speed_slow() -> void:
	GameStateManager.set_setting("typewriter_speed", 0.05)
	print("Text speed set to SLOW")

func set_text_speed_normal() -> void:
	GameStateManager.set_setting("typewriter_speed", 0.03)
	print("Text speed set to NORMAL")

func set_text_speed_fast() -> void:
	GameStateManager.set_setting("typewriter_speed", 0.01)
	print("Text speed set to FAST")

func set_text_speed_instant() -> void:
	GameStateManager.set_setting("typewriter_speed", 0.0)
	print("Text speed set to INSTANT")
