extends Control

## Title screen with play, options, and quit buttons

@onready var play_button: Button = $CenterContainer/MenuContainer/PlayButton
@onready var options_button: Button = $CenterContainer/MenuContainer/OptionsButton
@onready var quit_button: Button = $CenterContainer/MenuContainer/QuitButton
@onready var title_label: Label = $CenterContainer/MenuContainer/TitleLabel

func _ready() -> void:
	# Connect buttons
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Focus the play button for keyboard navigation
	play_button.grab_focus()

func _on_play_pressed() -> void:
	# Load Day 0 (first day of the game)
	get_tree().change_scene_to_file("res://Scenes/Days/Day0.tscn")

func _on_options_pressed() -> void:
	# TODO: Open options menu
	print("Options menu not yet implemented")
	# When you create an options menu scene, use:
	# get_tree().change_scene_to_file("res://UI/OptionsMenu.tscn")

func _on_quit_pressed() -> void:
	# Quit the game
	get_tree().quit()
