extends Node

## Central database for all game dialogue
## Access from anywhere with: DialogueDatabase.play("dialogue_id")

var dialogues: Dictionary = {
	# ============================================
	# INTRO & TUTORIAL
	# ============================================
	"intro": [
		{"character": "Agent", "text": "Welcome to your new assignment. This system contains sensitive information."},
		{"character": "Agent", "text": "Your job is to find evidence hidden in the files. Be thorough."},
		{"character": "You", "text": "Understood. Where should I start looking?"},
		{"character": "Agent", "text": "Check the Documents folder. There might be something interesting in the personal files."},
		{"character": "Agent", "text": "Good luck. And remember... trust no one."}
	],
	
	# ============================================
	# FILE EXPLORER EVENTS
	# ============================================
	"first_documents_open": [
		{"character": "", "text": "The Documents folder contains several files..."},
		{"character": "", "text": "Something about these personal files seems suspicious."}
	],
	
	"first_pictures_open": [
		{"character": "", "text": "A collection of photos. Nothing unusual at first glance."}
	],
	
	"first_downloads_open": [
		{"character": "", "text": "The Downloads folder is empty. Or is it?"}
	],
	
	# ============================================
	# FILE DISCOVERY
	# ============================================
	"secret_file_found": [
		{"character": "You", "text": "Wait... this file shouldn't be here."},
		{"character": "Agent", "text": "What did you find? Send me the details immediately."}
	],
	
	"work_notes_opened": [
		{"character": "", "text": "Standard work notes. Meeting schedules, project updates..."},
		{"character": "", "text": "Wait, there's something odd about the formatting here."}
	],
	
	"diary_opened": [
		{"character": "", "text": "This is someone's personal diary. Should you really be reading this?"},
		{"character": "You", "text": "I have to. It might contain evidence."}
	],
	
	# ============================================
	# PUZZLE COMPLETION
	# ============================================
	"puzzle_01_complete": [
		{"character": "Agent", "text": "Good work. That's exactly what we needed."},
		{"character": "Agent", "text": "Keep digging. There's more to uncover."}
	],
	
	"puzzle_02_complete": [
		{"character": "You", "text": "I found the connection. These files are all related."},
		{"character": "Agent", "text": "Excellent. Now we're getting somewhere."}
	],
	
	# ============================================
	# ERRORS & WARNINGS
	# ============================================
	"access_denied": [
		{"character": "", "text": "ACCESS DENIED. You don't have permission to view this file."},
		{"character": "You", "text": "There must be a way to gain access..."}
	],
	
	"file_corrupted": [
		{"character": "", "text": "ERROR: File appears to be corrupted."},
		{"character": "You", "text": "That's... convenient. Too convenient."}
	],
	
	# ============================================
	# END GAME
	# ============================================
	"ending_good": [
		{"character": "Agent", "text": "You've done exceptional work. The evidence you gathered will bring them to justice."},
		{"character": "You", "text": "Just doing my job."},
		{"character": "Agent", "text": "This job isn't over yet. We have more assignments for you."}
	],
	
	"ending_bad": [
		{"character": "Agent", "text": "You missed critical evidence. The case is compromised."},
		{"character": "You", "text": "I... I'm sorry. I thought I had everything."},
		{"character": "Agent", "text": "Sorry doesn't cut it in this line of work."}
	]
}

func _ready() -> void:
	print("DialogueDatabase initialized with ", dialogues.size(), " dialogue sequences")

## Play dialogue by ID
## Returns true if dialogue exists and was played, false otherwise
func play(dialogue_id: String) -> bool:
	if dialogues.has(dialogue_id):
		DialogueSystem.load_dialogue(dialogues[dialogue_id])
		print("[DialogueDatabase] Playing: ", dialogue_id)
		return true
	else:
		push_error("[DialogueDatabase] Dialogue ID not found: " + dialogue_id)
		return false

## Check if dialogue exists
func has_dialogue(dialogue_id: String) -> bool:
	return dialogues.has(dialogue_id)

## Add dialogue at runtime (for dynamic content or modding)
func add_dialogue(dialogue_id: String, dialogue_lines: Array) -> void:
	dialogues[dialogue_id] = dialogue_lines
	print("[DialogueDatabase] Added dialogue: ", dialogue_id)

## Remove dialogue from database
func remove_dialogue(dialogue_id: String) -> void:
	if dialogues.has(dialogue_id):
		dialogues.erase(dialogue_id)
		print("[DialogueDatabase] Removed dialogue: ", dialogue_id)

## Get all dialogue IDs (useful for debugging)
func get_all_dialogue_ids() -> Array:
	return dialogues.keys()

## Get raw dialogue data (useful for editing/debugging)
func get_dialogue(dialogue_id: String) -> Array:
	return dialogues.get(dialogue_id, [])

# ============================================
# PHONE CALL INTEGRATION
# ============================================

## Schedule a phone call that plays dialogue when accepted
## This is a convenience wrapper around PhoneCallSystem.schedule_call()
func schedule_dialogue_call(
	call_id: String,
	caller_name: String,
	dialogue_id: String,
	delay_seconds: float = 0.0,
	retry_delay: float = 10.0
) -> void:
	if not has_dialogue(dialogue_id):
		push_error("[DialogueDatabase] Cannot schedule call - dialogue not found: " + dialogue_id)
		return
	
	if PhoneCallSystem:
		PhoneCallSystem.schedule_call(
			call_id,
			caller_name,
			dialogue_id,
			delay_seconds,
			retry_delay,
			-1  # Infinite retries by default
		)
	else:
		push_error("[DialogueDatabase] PhoneCallSystem not available")

