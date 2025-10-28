extends Node

## Examples of how to use the PhoneCallDatabase system
## This file demonstrates both time-based and event-based calls

func _ready():
	print("=== Phone Call System Examples ===")
	print("See PhoneCallExamples.gd for code samples")

# ============================================
# TIME-BASED CALLS
# ============================================

## Example 1: Simple scheduled call
func example_simple_call():
	# Just schedule by ID - all details are in PhoneCallDatabase
	PhoneCallDatabase.schedule("intro_call")

## Example 2: Multiple timed calls
func example_story_sequence():
	# Schedule a sequence of calls at different times
	PhoneCallDatabase.schedule("intro_call")          # 10 seconds
	PhoneCallDatabase.schedule("two_minute_reminder") # 2 minutes

## Example 3: Conditional call
func example_conditional_call():
	# Only call if player hasn't seen intro yet
	if not GameStateManager.is_puzzle_solved("saw_intro"):
		PhoneCallDatabase.schedule("intro_call")

# ============================================
# EVENT-BASED CALLS (AUTOMATIC)
# ============================================

## Example 4: File-triggered calls
## These are AUTOMATIC - no code needed!
## When player opens "secrets.txt", PhoneCallDatabase automatically
## triggers the "secret_file_callback" call

## Example 5: Puzzle-triggered calls
## When EventBus.puzzle_completed.emit("puzzle_01") is called,
## PhoneCallDatabase automatically triggers "first_checkin" call

## Example 6: Manual event trigger
func example_manual_trigger():
	# You can also manually trigger event-based calls
	# (useful for custom events not in the standard list)
	PhoneCallDatabase.trigger("secret_file_callback")

# ============================================
# CUSTOM CALLS
# ============================================

## Example 7: Add a new call at runtime
func example_dynamic_call():
	# Add a new call definition
	PhoneCallDatabase.add_call(
		"emergency_call",      # Call ID
		"Unknown Number",      # Caller name
		"urgent_warning",      # Dialogue ID
		0.0,                   # Immediate
		5.0,                   # Retry every 5 seconds
		3                      # Max 3 retries
	)
	
	# Then schedule it
	PhoneCallDatabase.schedule("emergency_call")

## Example 8: Add a new event trigger at runtime
func example_dynamic_trigger():
	# Map a new event to a call
	PhoneCallDatabase.add_event_trigger(
		"file_opened",         # Event type
		"mystery_file.txt",    # Event value (file name)
		"informant_tip"        # Call to trigger
	)
	
	# Now when player opens "mystery_file.txt", it will trigger the call!

# ============================================
# ADVANCED USAGE
# ============================================

## Example 9: Cancel obsolete calls
func example_cancel_call():
	# If story changes, cancel a scheduled call
	PhoneCallSystem.cancel_call("two_minute_reminder")

## Example 10: Check if call was triggered
func example_check_triggered():
	if PhoneCallDatabase.has_been_triggered("intro_call"):
		print("Player has received the intro call")
	else:
		print("Intro call hasn't been triggered yet")

## Example 11: Reset for new game
func example_reset_for_new_game():
	# Clear all triggered call history
	PhoneCallDatabase.reset_all_triggered()
	
	# Now calls can be triggered again

## Example 12: Listen to call events
func example_listen_to_events():
	# React when calls are accepted/denied
	EventBus.phone_call_accepted.connect(_on_call_accepted)
	EventBus.phone_call_denied.connect(_on_call_denied)

func _on_call_accepted(caller_name: String, call_id: String):
	print("Player accepted call from: ", caller_name)
	
	# Do something special based on who called
	if caller_name == "Director":
		GameStateManager.set_setting("in_good_standing", true)

func _on_call_denied(caller_name: String, call_id: String):
	print("Player denied call from: ", caller_name)
	
	# Track reputation
	if caller_name == "Director":
		GameStateManager.set_setting("director_annoyed", true)

# ============================================
# REAL GAME EXAMPLES
# ============================================

## Example: Boss calls when player takes too long
func example_timeout_call():
	# Start a timer when puzzle begins
	var timer = get_tree().create_timer(300.0)  # 5 minutes
	await timer.timeout
	
	# If puzzle still not solved, boss calls
	if not GameStateManager.is_puzzle_solved("puzzle_01"):
		PhoneCallDatabase.schedule("urgent_warning")

## Example: Multiple callers at once
func example_multi_caller():
	# Schedule several calls - they'll queue automatically
	PhoneCallDatabase.schedule("first_checkin")
	PhoneCallDatabase.schedule("informant_tip")
	PhoneCallDatabase.schedule("urgent_warning")
	
	# PhoneCallSystem will show them one at a time

## Example: Call based on player choice
func _on_player_chose_option(option: String):
	match option:
		"investigate":
			PhoneCallDatabase.schedule("informant_tip")
		"ignore":
			PhoneCallDatabase.schedule("urgent_warning")
		"report":
			PhoneCallDatabase.schedule("first_checkin")

