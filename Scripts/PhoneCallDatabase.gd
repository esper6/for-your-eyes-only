extends Node

## Central database for all phone call configurations
## Access from anywhere with: PhoneCallDatabase.schedule("intro_call")

# Phone call definitions
# Each call has:
#   - caller_name: Display name
#   - dialogue_id: Dialogue to play when accepted
#   - delay: Seconds before call appears (for time-based calls)
#   - retry_delay: Seconds between retries if denied
#   - max_retries: Maximum retry attempts (-1 = infinite)
var calls: Dictionary = {
	# ============================================
	# STORY CALLS
	# ============================================
	"intro_call": {
		"caller_name": "Agent X",
		"dialogue_id": "intro",
		"delay": 10.0,
		"retry_delay": 10.0,
		"max_retries": -1
	},
	
	"first_checkin": {
		"caller_name": "Agent X",
		"dialogue_id": "puzzle_01_complete",
		"delay": 0.0,  # Immediate when triggered
		"retry_delay": 15.0,
		"max_retries": 3
	},
	
	"urgent_warning": {
		"caller_name": "Director",
		"dialogue_id": "access_denied",
		"delay": 0.0,
		"retry_delay": 5.0,
		"max_retries": 5
	},
	
	# ============================================
	# DISCOVERY CALLS
	# ============================================
	"secret_file_callback": {
		"caller_name": "Agent X",
		"dialogue_id": "secret_file_found",
		"delay": 3.0,  # Give player 3 seconds to read
		"retry_delay": 20.0,
		"max_retries": 2
	},
	
	"informant_tip": {
		"caller_name": "Unknown Number",
		"dialogue_id": "work_notes_opened",
		"delay": 5.0,
		"retry_delay": 30.0,
		"max_retries": 1
	},
	
	# ============================================
	# TIMED CALLS
	# ============================================
	"two_minute_reminder": {
		"caller_name": "Agent X",
		"dialogue_id": "puzzle_01_complete",
		"delay": 120.0,  # 2 minutes
		"retry_delay": 30.0,
		"max_retries": -1
	}
}

# Event-based call triggers
# Maps game events to call IDs
# When the event happens, the call is automatically scheduled
var event_triggers: Dictionary = {
	# ============================================
	# FILE SYSTEM TRIGGERS
	# ============================================
	"file_opened": {
		"secrets.txt": "secret_file_callback",
		"work_notes.txt": "informant_tip"
	},
	
	"folder_opened": {
		"Documents": "first_checkin"  # Calls after first time opening Documents
	},
	
	# ============================================
	# PUZZLE TRIGGERS
	# ============================================
	"puzzle_completed": {
		"puzzle_01": "first_checkin",
		"puzzle_02": "urgent_warning"
	},
	
	# ============================================
	# DISCOVERY TRIGGERS
	# ============================================
	"item_found": {
		"secret_key": "urgent_warning",
		"usb_drive": "secret_file_callback"
	}
}

# Track which calls have already been triggered to prevent duplicates
var triggered_calls: Dictionary = {}

func _ready() -> void:
	# Connect to EventBus to listen for trigger events
	_setup_event_listeners()
	print("[PhoneCallDatabase] Initialized with ", calls.size(), " call definitions")

## Setup event listeners for automatic call triggering
func _setup_event_listeners() -> void:
	if not EventBus:
		push_error("[PhoneCallDatabase] EventBus not available")
		return
	
	# Listen to file system events
	EventBus.file_opened.connect(_on_file_opened)
	EventBus.folder_opened.connect(_on_folder_opened)
	
	# Listen to game state events
	EventBus.puzzle_completed.connect(_on_puzzle_completed)
	EventBus.item_found.connect(_on_item_found)
	EventBus.discovery_made.connect(_on_discovery_made)

## Schedule a call by ID (time-based)
func schedule(call_id: String) -> bool:
	if not calls.has(call_id):
		push_error("[PhoneCallDatabase] Call ID not found: " + call_id)
		return false
	
	var call_data: Dictionary = calls[call_id]
	
	if PhoneCallSystem:
		PhoneCallSystem.schedule_call(
			call_id,
			call_data.get("caller_name", "Unknown"),
			call_data.get("dialogue_id", ""),
			call_data.get("delay", 0.0),
			call_data.get("retry_delay", 10.0),
			call_data.get("max_retries", -1)
		)
		print("[PhoneCallDatabase] Scheduled call: ", call_id)
		return true
	else:
		push_error("[PhoneCallDatabase] PhoneCallSystem not available")
		return false

## Trigger a call based on an event (can only trigger once by default)
func trigger(call_id: String, allow_duplicate: bool = false) -> bool:
	# Check if already triggered
	if not allow_duplicate and triggered_calls.has(call_id):
		print("[PhoneCallDatabase] Call already triggered: ", call_id)
		return false
	
	# Schedule the call
	if schedule(call_id):
		triggered_calls[call_id] = true
		return true
	
	return false

## Check if a call has been triggered
func has_been_triggered(call_id: String) -> bool:
	return triggered_calls.has(call_id)

## Reset triggered status (useful for testing or new game+)
func reset_triggered(call_id: String) -> void:
	triggered_calls.erase(call_id)

## Reset all triggered calls
func reset_all_triggered() -> void:
	triggered_calls.clear()

## Get call data
func get_call_data(call_id: String) -> Dictionary:
	return calls.get(call_id, {})

## Check if call exists
func has_call(call_id: String) -> bool:
	return calls.has(call_id)

# ============================================
# EVENT HANDLERS
# ============================================

func _on_file_opened(file_name: String, file_path: String) -> void:
	if event_triggers.has("file_opened"):
		var file_triggers: Dictionary = event_triggers["file_opened"]
		if file_triggers.has(file_name):
			var call_id: String = file_triggers[file_name]
			print("[PhoneCallDatabase] File trigger: ", file_name, " -> ", call_id)
			trigger(call_id)

func _on_folder_opened(folder_name: String, folder_path: String) -> void:
	if event_triggers.has("folder_opened"):
		var folder_triggers: Dictionary = event_triggers["folder_opened"]
		if folder_triggers.has(folder_name):
			var call_id: String = folder_triggers[folder_name]
			print("[PhoneCallDatabase] Folder trigger: ", folder_name, " -> ", call_id)
			trigger(call_id)

func _on_puzzle_completed(puzzle_id: String) -> void:
	if event_triggers.has("puzzle_completed"):
		var puzzle_triggers: Dictionary = event_triggers["puzzle_completed"]
		if puzzle_triggers.has(puzzle_id):
			var call_id: String = puzzle_triggers[puzzle_id]
			print("[PhoneCallDatabase] Puzzle trigger: ", puzzle_id, " -> ", call_id)
			trigger(call_id)

func _on_item_found(item_id: String) -> void:
	if event_triggers.has("item_found"):
		var item_triggers: Dictionary = event_triggers["item_found"]
		if item_triggers.has(item_id):
			var call_id: String = item_triggers[item_id]
			print("[PhoneCallDatabase] Item trigger: ", item_id, " -> ", call_id)
			trigger(call_id)

func _on_discovery_made(discovery_id: String) -> void:
	# Generic discovery handler
	# You can map discoveries to calls here
	pass

# ============================================
# RUNTIME MANAGEMENT
# ============================================

## Add a new call at runtime
func add_call(call_id: String, caller_name: String, dialogue_id: String, delay: float = 0.0, retry_delay: float = 10.0, max_retries: int = -1) -> void:
	calls[call_id] = {
		"caller_name": caller_name,
		"dialogue_id": dialogue_id,
		"delay": delay,
		"retry_delay": retry_delay,
		"max_retries": max_retries
	}
	print("[PhoneCallDatabase] Added call: ", call_id)

## Add an event trigger at runtime
func add_event_trigger(event_type: String, event_value: String, call_id: String) -> void:
	if not event_triggers.has(event_type):
		event_triggers[event_type] = {}
	
	event_triggers[event_type][event_value] = call_id
	print("[PhoneCallDatabase] Added trigger: ", event_type, "/", event_value, " -> ", call_id)

## Get all call IDs
func get_all_call_ids() -> Array:
	return calls.keys()

