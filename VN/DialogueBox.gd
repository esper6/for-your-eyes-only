extends Control

@onready var label = $Label

func _ready():
	DialogueSystem.connect("dialogue_updated", _on_dialogue_updated)

func _on_dialogue_updated(text):
	label.text = text
