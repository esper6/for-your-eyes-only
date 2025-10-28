extends Control

## Visual novel style dialogue box with typewriter effect and click-to-advance

@onready var character_name_label: Label = $Panel/MarginContainer/VBoxContainer/CharacterName
@onready var dialogue_label: Label = $Panel/MarginContainer/VBoxContainer/DialogueText
@onready var continue_indicator: Label = $Panel/ContinueIndicator
@onready var panel: Panel = $Panel

var current_text: String = ""
var displayed_text: String = ""
var text_index: int = 0
var typewriter_speed: float = 0.03  # Seconds per character
var is_typing: bool = false
var typewriter_timer: float = 0.0

func _ready() -> void:
	# Connect to DialogueSystem signals
	DialogueSystem.dialogue_updated.connect(_on_dialogue_updated)
	DialogueSystem.dialogue_started.connect(_on_dialogue_started)
	DialogueSystem.dialogue_ended.connect(_on_dialogue_ended)
	
	# Hide initially
	hide()
	continue_indicator.hide()

func _process(delta: float) -> void:
	if is_typing:
		typewriter_timer += delta
		if typewriter_timer >= typewriter_speed:
			typewriter_timer = 0.0
			_display_next_character()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_click()

func _on_click() -> void:
	if is_typing:
		# Skip typewriter effect, show full text immediately
		_finish_typing()
	else:
		# Advance to next dialogue line
		DialogueSystem.advance_dialogue()

func _on_dialogue_started() -> void:
	show()
	continue_indicator.hide()

func _on_dialogue_ended() -> void:
	hide()
	is_typing = false
	continue_indicator.hide()

func _on_dialogue_updated(character_name: String, text: String) -> void:
	# Set character name
	if character_name.is_empty():
		character_name_label.hide()
	else:
		character_name_label.text = character_name
		character_name_label.show()
	
	# Start typewriter effect
	current_text = text
	displayed_text = ""
	text_index = 0
	is_typing = true
	typewriter_timer = 0.0
	continue_indicator.hide()
	dialogue_label.text = ""

func _display_next_character() -> void:
	if text_index < current_text.length():
		displayed_text += current_text[text_index]
		dialogue_label.text = displayed_text
		text_index += 1
	else:
		_finish_typing()

func _finish_typing() -> void:
	is_typing = false
	displayed_text = current_text
	dialogue_label.text = displayed_text
	continue_indicator.show()
