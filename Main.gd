extends Control

@onready var email_window = $WindowContainer/EmailWindow
@onready var image_window = $WindowContainer/ImageViewerWindow
@onready var email_button = $Taskbar/EmailButton
@onready var image_button = $Taskbar/ImageViewerButton

func _ready():
	# Hide windows initially
	email_window.visible = false
	image_window.visible = false

	# Connect buttons
	email_button.connect("pressed", _on_email_button_pressed)
	image_button.connect("pressed", _on_image_button_pressed)

	# Initialize dialogue
	DialogueSystem.load_dialogue([
		"Welcome to your desktop.",
		"You need to open that email...",
        "Drag the email window to the corner to solve the puzzle."
	])

func _on_email_button_pressed():
	email_window.visible = !email_window.visible

func _on_image_button_pressed():
	image_window.visible = !image_window.visible
