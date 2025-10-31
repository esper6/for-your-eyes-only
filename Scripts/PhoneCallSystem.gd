extends Node

## Manages incoming phone calls throughout the game
## Handles call queuing, delays, and retry logic

signal call_incoming(caller_name: String, call_id: String)
signal call_accepted(caller_name: String, call_id: String)
signal call_denied(caller_name: String, call_id: String)
signal call_ended(call_id: String)

# Call data structure
class PhoneCall:
	var id: String
	var caller_name: String
	var dialogue_id: String  # Dialogue to play when accepted
	var retry_delay: float = 10.0  # Seconds to wait before retry after denial
	var max_retries: int = -1  # -1 = infinite retries
	var retry_count: int = 0
	var priority: int = 0  # Higher = more urgent
	var is_active: bool = false
	
	func _init(p_id: String, p_caller: String, p_dialogue: String):
		id = p_id
		caller_name = p_caller
		dialogue_id = p_dialogue

# Active calls
var pending_calls: Array[PhoneCall] = []
var current_call: PhoneCall = null
var is_call_ui_visible: bool = false

# Retry timers
var retry_timers: Dictionary = {}  # call_id -> Timer

func _ready() -> void:
	# Connect to dialogue system to know when call dialogue ends
	if DialogueSystem:
		DialogueSystem.dialogue_ended.connect(_on_dialogue_ended)
	
	print("[PhoneCallSystem] Initialized")

## Schedule a phone call
## Parameters:
##   call_id: Unique identifier for this call
##   caller_name: Display name (e.g., "Agent X", "Unknown Number")
##   dialogue_id: ID of dialogue to play when accepted
##   delay_seconds: Wait this long before showing call (0 = immediate)
##   retry_delay: Seconds to wait before retry if denied (default 10)
##   max_retries: Maximum retry attempts, -1 for infinite (default -1)
func schedule_call(
	call_id: String,
	caller_name: String,
	dialogue_id: String,
	delay_seconds: float = 0.0,
	retry_delay: float = 10.0,
	max_retries: int = -1
) -> void:
	var call = PhoneCall.new(call_id, caller_name, dialogue_id)
	call.retry_delay = retry_delay
	call.max_retries = max_retries
	
	if delay_seconds > 0:
		# Schedule for later
		await get_tree().create_timer(delay_seconds).timeout
	
	_queue_call(call)
	print("[PhoneCallSystem] Scheduled call from ", caller_name, " (", call_id, ")")

## Queue a call to be shown
func _queue_call(call: PhoneCall) -> void:
	# Check if already queued or active
	for pending_call in pending_calls:
		if pending_call.id == call.id:
			print("[PhoneCallSystem] Call already queued: ", call.id)
			return
	
	if current_call and current_call.id == call.id:
		print("[PhoneCallSystem] Call already active: ", call.id)
		return
	
	pending_calls.append(call)
	_process_next_call()

## Show the next call in queue if possible
func _process_next_call() -> void:
	# Don't show if already showing a call
	if is_call_ui_visible or current_call != null:
		return
	
	# Don't interrupt dialogue
	if DialogueSystem and DialogueSystem.is_active:
		return
	
	# Get highest priority call
	if pending_calls.size() > 0:
		pending_calls.sort_custom(func(a, b): return a.priority > b.priority)
		current_call = pending_calls.pop_front()
		_show_call(current_call)

## Display the incoming call UI
func _show_call(call: PhoneCall) -> void:
	is_call_ui_visible = true
	call.is_active = true
	
	# Emit signal for UI to show
	call_incoming.emit(call.caller_name, call.id)
	EventBus.emit_signal("phone_call_incoming", call.caller_name, call.id)
	
	print("[PhoneCallSystem] Incoming call from ", call.caller_name)

## Called when player accepts the call
func accept_call() -> void:
	if current_call == null:
		push_error("[PhoneCallSystem] No active call to accept")
		return
	
	print("[PhoneCallSystem] Call accepted: ", current_call.caller_name)
	
	call_accepted.emit(current_call.caller_name, current_call.id)
	EventBus.emit_signal("phone_call_accepted", current_call.caller_name, current_call.id)
	
	# Play the dialogue
	if DialogueDatabase.has_dialogue(current_call.dialogue_id):
		DialogueDatabase.play(current_call.dialogue_id)
	else:
		push_error("[PhoneCallSystem] Dialogue not found: ", current_call.dialogue_id)
	
	# Clear retry timer if exists
	if retry_timers.has(current_call.id):
		retry_timers[current_call.id].queue_free()
		retry_timers.erase(current_call.id)
	
	is_call_ui_visible = false
	# current_call stays until dialogue ends

## Called when player denies the call
func deny_call() -> void:
	if current_call == null:
		push_error("[PhoneCallSystem] No active call to deny")
		return
	
	print("[PhoneCallSystem] Call denied: ", current_call.caller_name)
	
	call_denied.emit(current_call.caller_name, current_call.id)
	EventBus.emit_signal("phone_call_denied", current_call.caller_name, current_call.id)
	
	# Check if we should retry
	current_call.retry_count += 1
	
	if current_call.max_retries == -1 or current_call.retry_count <= current_call.max_retries:
		# Schedule retry
		_schedule_retry(current_call)
	else:
		print("[PhoneCallSystem] Max retries reached for ", current_call.id)
		call_ended.emit(current_call.id)
	
	is_call_ui_visible = false
	current_call = null
	
	# Process next call
	_process_next_call()

## Schedule a call retry after delay
func _schedule_retry(call: PhoneCall) -> void:
	print("[PhoneCallSystem] Scheduling retry for ", call.caller_name, " in ", call.retry_delay, "s")
	
	var timer = Timer.new()
	timer.wait_time = call.retry_delay
	timer.one_shot = true
	add_child(timer)
	
	timer.timeout.connect(func():
		print("[PhoneCallSystem] Retrying call from ", call.caller_name)
		_queue_call(call)
		timer.queue_free()
		retry_timers.erase(call.id)
	)
	
	retry_timers[call.id] = timer
	timer.start()

## Called when dialogue ends
func _on_dialogue_ended() -> void:
	if current_call != null:
		print("[PhoneCallSystem] Call ended: ", current_call.id)
		call_ended.emit(current_call.id)
		current_call = null
		
		# Process next call in queue
		_process_next_call()

## Cancel a scheduled or active call
func cancel_call(call_id: String) -> void:
	# Check pending
	for i in range(pending_calls.size() - 1, -1, -1):
		if pending_calls[i].id == call_id:
			pending_calls.remove_at(i)
			print("[PhoneCallSystem] Cancelled pending call: ", call_id)
			return
	
	# Check active
	if current_call and current_call.id == call_id:
		is_call_ui_visible = false
		current_call = null
		print("[PhoneCallSystem] Cancelled active call: ", call_id)
	
	# Check retry timers
	if retry_timers.has(call_id):
		retry_timers[call_id].queue_free()
		retry_timers.erase(call_id)
		print("[PhoneCallSystem] Cancelled retry for: ", call_id)

## Check if a call is currently active
func is_call_active() -> bool:
	return is_call_ui_visible or (current_call != null)

## Get current call info
func get_current_call_info() -> Dictionary:
	if current_call:
		return {
			"id": current_call.id,
			"caller": current_call.caller_name,
			"dialogue": current_call.dialogue_id,
			"retry_count": current_call.retry_count
		}
	return {}
