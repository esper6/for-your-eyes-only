extends Node
class_name DialogueManager

signal dialogue_updated(text)

var dialogue_queue = []

func load_dialogue(dialogue_lines):
	dialogue_queue = dialogue_lines
	_next_line()

func _next_line():
	if dialogue_queue.size() > 0:
		var line = dialogue_queue.pop_front()
		emit_signal("dialogue_updated", line)
	else:
		emit_signal("dialogue_updated", "[End of dialogue]")
