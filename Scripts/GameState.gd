extends Node
class_name GameState

## Game state and user settings manager

signal settings_changed(setting_name: String, new_value)

# Game progress
var current_scene: String = "Scene1"
var puzzles_solved: Dictionary = {}

# User settings with defaults
var settings: Dictionary = {
	"typewriter_speed": 0.03,  # Seconds per character
	"text_skip_enabled": true,
	"auto_advance": false,
	"master_volume": 1.0,
	"sfx_volume": 1.0,
	"music_volume": 1.0
}

const SETTINGS_FILE_PATH: String = "user://settings.json"

func _ready() -> void:
	load_settings()

# Puzzle management
func mark_puzzle_solved(puzzle_name: String) -> void:
	puzzles_solved[puzzle_name] = true

func is_puzzle_solved(puzzle_name: String) -> bool:
	return puzzles_solved.get(puzzle_name, false)

# Settings management
func get_setting(setting_name: String, default_value = null):
	return settings.get(setting_name, default_value)

func set_setting(setting_name: String, value) -> void:
	settings[setting_name] = value
	emit_signal("settings_changed", setting_name, value)
	save_settings()

func reset_settings_to_default() -> void:
	settings = {
		"typewriter_speed": 0.03,
		"text_skip_enabled": true,
		"auto_advance": false,
		"master_volume": 1.0,
		"sfx_volume": 1.0,
		"music_volume": 1.0
	}
	save_settings()

# Save/Load settings
func save_settings() -> void:
	var file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(settings, "\t")
		file.store_string(json_string)
		file.close()
		print("Settings saved to: ", SETTINGS_FILE_PATH)
	else:
		push_error("Failed to save settings to: " + SETTINGS_FILE_PATH)

func load_settings() -> void:
	if FileAccess.file_exists(SETTINGS_FILE_PATH):
		var file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				var loaded_settings = json.data
				# Merge loaded settings with defaults (in case new settings were added)
				for key in loaded_settings:
					settings[key] = loaded_settings[key]
				print("Settings loaded from: ", SETTINGS_FILE_PATH)
			else:
				push_error("Failed to parse settings JSON")
		else:
			push_error("Failed to open settings file")
	else:
		print("No settings file found, using defaults")
