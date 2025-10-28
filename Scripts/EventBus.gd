extends Node

## Global event bus for game-wide events
## Use this to communicate between different parts of the game without tight coupling
## 
## Example usage:
##   EventBus.dialogue_requested.emit("intro")
##   EventBus.file_opened.connect(_on_any_file_opened)

# ============================================
# DIALOGUE EVENTS
# ============================================
## Request a dialogue to be played by ID
signal dialogue_requested(dialogue_id: String)

## Emitted when dialogue starts
signal dialogue_started(dialogue_id: String)

## Emitted when dialogue ends
signal dialogue_ended()

# ============================================
# PHONE CALL EVENTS
# ============================================
## Emitted when a phone call is incoming
signal phone_call_incoming(caller_name: String, call_id: String)

## Emitted when player accepts a call
signal phone_call_accepted(caller_name: String, call_id: String)

## Emitted when player denies a call
signal phone_call_denied(caller_name: String, call_id: String)

## Emitted when a call ends (after dialogue completes)
signal phone_call_ended(call_id: String)

# ============================================
# FILE SYSTEM EVENTS
# ============================================
## Emitted when a file is clicked/opened
signal file_opened(file_name: String, file_path: String)

## Emitted when a folder is clicked/opened
signal folder_opened(folder_name: String, folder_path: String)

## Emitted when navigating to a new directory
signal directory_changed(new_path: String)

# ============================================
# GAME STATE EVENTS
# ============================================
## Emitted when a puzzle is completed
signal puzzle_completed(puzzle_id: String)

## Emitted when an item/clue is found
signal item_found(item_id: String)

## Emitted when the player discovers something important
signal discovery_made(discovery_id: String)

## Emitted when player progress is saved
signal game_saved()

## Emitted when player progress is loaded
signal game_loaded()

# ============================================
# UI EVENTS
# ============================================
## Emitted when a window is opened
signal window_opened(window_name: String)

## Emitted when a window is closed
signal window_closed(window_name: String)

## Emitted when a notification should be shown
signal notification_requested(title: String, message: String)

# ============================================
# SYSTEM EVENTS
# ============================================
## Emitted when settings change
signal settings_updated(setting_name: String, new_value)

## Emitted when the game is paused
signal game_paused()

## Emitted when the game is unpaused
signal game_resumed()

func _ready() -> void:
	# Connect dialogue_requested to DialogueDatabase
	dialogue_requested.connect(_on_dialogue_requested)
	
	# Connect to existing systems
	if GameStateManager:
		GameStateManager.settings_changed.connect(_on_settings_changed)
	
	if DialogueSystem:
		DialogueSystem.dialogue_started.connect(_on_dialogue_system_started)
		DialogueSystem.dialogue_ended.connect(_on_dialogue_system_ended)
	
	print("[EventBus] Initialized and ready")

# ============================================
# INTERNAL HANDLERS
# ============================================

func _on_dialogue_requested(dialogue_id: String) -> void:
	if DialogueDatabase and DialogueDatabase.has_dialogue(dialogue_id):
		DialogueDatabase.play(dialogue_id)
		dialogue_started.emit(dialogue_id)
	else:
		push_error("[EventBus] Dialogue not found: " + dialogue_id)

func _on_settings_changed(setting_name: String, new_value) -> void:
	settings_updated.emit(setting_name, new_value)

func _on_dialogue_system_started() -> void:
	# DialogueSystem emits its own dialogue_started without ID
	# We re-emit it with context if needed
	pass

func _on_dialogue_system_ended() -> void:
	dialogue_ended.emit()

# ============================================
# CONVENIENCE METHODS
# ============================================

## Trigger a dialogue sequence
func play_dialogue(dialogue_id: String) -> void:
	dialogue_requested.emit(dialogue_id)

## Mark a puzzle as complete and trigger events
func complete_puzzle(puzzle_id: String) -> void:
	if GameStateManager:
		GameStateManager.mark_puzzle_solved(puzzle_id)
	puzzle_completed.emit(puzzle_id)

## Discover an item/clue
func discover_item(item_id: String) -> void:
	item_found.emit(item_id)
	
	# Check if this discovery triggers any dialogue
	var dialogue_id = "item_" + item_id
	if DialogueDatabase and DialogueDatabase.has_dialogue(dialogue_id):
		play_dialogue(dialogue_id)

## Show a notification to the player
func notify(title: String, message: String) -> void:
	notification_requested.emit(title, message)
	print("[Notification] ", title, ": ", message)

