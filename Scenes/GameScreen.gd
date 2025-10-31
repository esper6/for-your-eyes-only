extends Control

## Generic game screen with desktop, file explorer, dialogue, and phone UI
## Day-specific logic should be in Day scenes that instance this

@onready var file_explorer: CharacterBody2D = $WindowContainer/FileExplorer
@onready var file_explorer_button: Button = $Taskbar/TaskbarContent/FileExplorerButton
@onready var time_label: Label = $Taskbar/TaskbarContent/TimeLabel
@onready var window_container: Control = $WindowContainer
@onready var desktop_icons_container: VBoxContainer = $DesktopIcons

# Preload windows
const TextViewer = preload("res://UI/Apps/TextViewer.tscn")

# Desktop file contents
var desktop_files: Dictionary = {
	"employee_manifesto": {
		"display_name": "Employee Guide Manifesto.txt",
		"content": """EMPLOYEE GUIDE MANIFESTO
		
Welcome to the Company!

This is your official employee guide. Please read carefully.

RULE 1: Always be on time.
RULE 2: Never question management decisions.
RULE 3: Your desk is your responsibility.
RULE 4: Report any suspicious activity immediately.
RULE 5: Trust the process.

Remember: We're all family here.

For any questions, contact HR.
Do NOT contact HR after hours.

Have a productive day!
"""
	}
}

func _ready() -> void:
	# Generic setup only
	file_explorer.visible = true
	file_explorer_button.pressed.connect(_on_file_explorer_button_pressed)
	_update_time()
	
	# Connect desktop icons
	_setup_desktop_icons()
	
	# NO day-specific logic here!
	# That should be in Day0.gd, Day1.gd, etc.

func _setup_desktop_icons() -> void:
	# Connect any desktop icons that exist in the scene
	for child in desktop_icons_container.get_children():
		if child.has_signal("icon_double_clicked"):
			child.icon_double_clicked.connect(_on_desktop_icon_double_clicked)

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
	file_explorer.visible = !file_explorer.visible

func _on_desktop_icon_double_clicked(icon_id: String) -> void:
	print("[GameScreen] Desktop icon double-clicked: ", icon_id)
	
	# Check if this is a file we can open
	if desktop_files.has(icon_id):
		_open_text_file(icon_id)

func _open_text_file(file_id: String) -> void:
	if not desktop_files.has(file_id):
		push_error("[GameScreen] Unknown file ID: ", file_id)
		return
	
	var file_data: Dictionary = desktop_files[file_id]
	var viewer = TextViewer.instantiate()
	window_container.add_child(viewer)
	
	# Position it nicely (offset from top-left)
	viewer.position = Vector2(300, 200)
	
	# Load the file content
	viewer.open_file(file_data["display_name"], file_data["content"])
	
	# Emit event that file was opened
	EventBus.file_opened.emit(file_data["display_name"], "Desktop/" + file_data["display_name"])
	
	print("[GameScreen] Opened text file: ", file_data["display_name"])

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
