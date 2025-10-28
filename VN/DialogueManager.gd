extends Node
class_name DialogueManager

## Manages dialogue flow for visual novel style conversations

signal dialogue_updated(character_name: String, text: String)
signal dialogue_started()
signal dialogue_ended()

var dialogue_queue: Array = []
var is_active: bool = false

## Load a new dialogue sequence
## dialogue_lines should be an array of dictionaries with keys: "character" and "text"
## Example: [{"character": "Alice", "text": "Hello!"}, {"character": "Bob", "text": "Hi there!"}]
func load_dialogue(dialogue_lines: Array) -> void:
	dialogue_queue = dialogue_lines.duplicate()
	is_active = true
	emit_signal("dialogue_started")
	_next_line()

## Advance to the next dialogue line (call this on click)
func advance_dialogue() -> void:
	if is_active:
		_next_line()

## Skip to a specific line in the dialogue
func skip_to_line(line_index: int) -> void:
	if line_index < dialogue_queue.size():
		dialogue_queue = dialogue_queue.slice(line_index)
		_next_line()

## Clear all dialogue and end
func clear_dialogue() -> void:
	dialogue_queue.clear()
	is_active = false
	emit_signal("dialogue_ended")

func _next_line() -> void:
	if dialogue_queue.size() > 0:
		var line: Dictionary = dialogue_queue.pop_front()
		var character_name: String = line.get("character", "")
		var text: String = line.get("text", "")
		emit_signal("dialogue_updated", character_name, text)
	else:
		is_active = false
		emit_signal("dialogue_ended")
