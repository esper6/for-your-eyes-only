extends Control

func _ready():
	print("=== Day 1 Started ===")
	PhoneCallDatabase.schedule("day1_morning_call")
	GameStateManager.mark_puzzle_solved("day_1_started")
