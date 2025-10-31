extends Control

## Day 0: First day of the game
## Handles day-specific events, calls, and progression

func _ready() -> void:
	print("=== Day 0 Started ===")
	_start_day_0()

func _start_day_0() -> void:
	# Schedule intro call for Day 0
	PhoneCallDatabase.schedule("intro_call")
	
	# Mark that Day 0 has started
	GameStateManager.mark_puzzle_solved("day_0_started")
	
	# Set up day-specific event listeners
	EventBus.puzzle_completed.connect(_on_puzzle_completed)
	EventBus.discovery_made.connect(_on_discovery_made)
	
	print("[Day 0] Waiting for Kathy HR to call...")

func _on_puzzle_completed(puzzle_id: String) -> void:
	print("[Day 0] Puzzle completed: ", puzzle_id)
	
	# Example: Complete Day 0 when a specific objective is met
	if puzzle_id == "day_0_objective":
		_end_day_0()

func _on_discovery_made(discovery_id: String) -> void:
	print("[Day 0] Discovery made: ", discovery_id)
	
	# Example: Respond to discoveries during Day 0
	if discovery_id == "found_all_clues":
		EventBus.complete_puzzle("day_0_objective")

func _end_day_0() -> void:
	print("=== Day 0 Complete ===")
	GameStateManager.mark_puzzle_solved("day_0_complete")
	
	# TODO: Show day complete screen or transition
	await get_tree().create_timer(2.0).timeout
	
	# Transition to Day 1
	get_tree().change_scene_to_file("res://Scenes/Days/Day1.tscn")
