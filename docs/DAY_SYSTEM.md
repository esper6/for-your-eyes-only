# Day-Based Level System

## Overview

The game is now organized into a day-based level structure where each day is its own scene with specific objectives, calls, and story progression.

## Architecture

### File Structure

```
Scenes/
├── GameScreen.tscn          # Reusable base scene with all UI
├── GameScreen.gd            # Generic game logic (desktop, taskbar, etc.)
└── Days/
    ├── Day0.tscn           # Day 0 scene (instances GameScreen)
    ├── Day0.gd             # Day 0 specific logic
    ├── Day1.tscn           # Day 1 scene
    ├── Day1.gd             # Day 1 specific logic
    └── ...
```

### How It Works

**GameScreen** is a reusable template containing:
- Desktop background
- File Explorer
- Taskbar with time
- DialogueBox
- PhoneCallUI

**Day Scenes** instance GameScreen and add day-specific logic:
- Phone calls to schedule
- Objectives to complete
- Event triggers
- Progression to next day

---

## Creating a New Day

### Step 1: Create Day Scene

**File**: `Scenes/Days/Day1.tscn`

```godot
[gd_scene load_steps=3 format=3]

[ext_resource type="PackedScene" path="res://Scenes/GameScreen.tscn" id="1"]
[ext_resource type="Script" path="res://Scenes/Days/Day1.gd" id="2"]

[node name="Day1" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource("2")

[node name="GameScreen" parent="." instance=ExtResource("1")]
```

### Step 2: Create Day Script

**File**: `Scenes/Days/Day1.gd`

```gdscript
extends Control

## Day 1: [Brief description of day's story]

func _ready() -> void:
	print("=== Day 1 Started ===")
	_start_day_1()

func _start_day_1() -> void:
	# Schedule calls specific to Day 1
	PhoneCallDatabase.schedule("day1_morning_call")
	
	# Mark day started
	GameStateManager.mark_puzzle_solved("day_1_started")
	
	# Set up event listeners
	EventBus.puzzle_completed.connect(_on_puzzle_completed)
	EventBus.file_opened.connect(_on_file_opened)

func _on_puzzle_completed(puzzle_id: String) -> void:
	if puzzle_id == "day_1_objective":
		_end_day_1()

func _on_file_opened(file_name: String, path: String) -> void:
	# Day-specific file reactions
	if file_name == "important_document.txt":
		PhoneCallDatabase.trigger("urgent_call")

func _end_day_1() -> void:
	print("=== Day 1 Complete ===")
	GameStateManager.mark_puzzle_solved("day_1_complete")
	
	# Show completion dialogue/screen
	await get_tree().create_timer(2.0).timeout
	
	# Load next day
	get_tree().change_scene_to_file("res://Scenes/Days/Day2.tscn")
```

---

## Day Progression Flow

```
Title Screen
    ↓ (Play Button)
Day 0
    ↓ (Complete Objective)
Day 1
    ↓ (Complete Objective)
Day 2
    ↓ ...
End Game
```

### Triggering Day Completion

There are several ways to end a day:

#### Option 1: Puzzle Completion
```gdscript
# In Day script
func _on_puzzle_completed(puzzle_id: String) -> void:
	if puzzle_id == "day_objective":
		_end_day()
```

#### Option 2: Discovery Trigger
```gdscript
func _on_discovery_made(discovery_id: String) -> void:
	if discovery_id == "found_all_clues":
		_end_day()
```

#### Option 3: Timer-Based
```gdscript
func _start_day() -> void:
	# End day after 10 minutes
	await get_tree().create_timer(600.0).timeout
	_end_day()
```

#### Option 4: Phone Call Completion
```gdscript
func _ready() -> void:
	EventBus.phone_call_ended.connect(_on_call_ended)

func _on_call_ended(call_id: String) -> void:
	if call_id == "final_call_of_day":
		_end_day()
```

---

## Example: Day 0 (Current Implementation)

**Scenes/Days/Day0.gd**:
- Schedules "intro_call" from Kathy HR
- Listens for puzzle completion
- Transitions to Day 1 when objective is met

**Key Features**:
- Automatic phone call after 5 seconds
- Event-driven progression
- Clean separation from UI logic

---

## Best Practices

### 1. Keep GameScreen Generic

❌ Bad (in GameScreen.gd):
```gdscript
func _ready():
	PhoneCallDatabase.schedule("intro_call")  # Day-specific!
```

✅ Good (in GameScreen.gd):
```gdscript
func _ready():
	# Only generic setup
	file_explorer.visible = true
	_update_time()
```

### 2. Put Day Logic in Day Scripts

✅ Good (in Day0.gd):
```gdscript
func _ready():
	PhoneCallDatabase.schedule("intro_call")
	GameStateManager.mark_puzzle_solved("day_0_started")
```

### 3. Use Descriptive Names

```gdscript
# Good naming
"day_0_started"
"day_1_complete"
"day_2_objective"

# Bad naming
"puzzle_1"
"flag_a"
```

### 4. Always Mark Days as Complete

```gdscript
func _end_day_0() -> void:
	GameStateManager.mark_puzzle_solved("day_0_complete")
	# Transition...
```

This lets you check progress:
```gdscript
if GameStateManager.is_puzzle_solved("day_0_complete"):
	print("Player has completed Day 0")
```

### 5. Clean Up Event Listeners

```gdscript
func _exit_tree() -> void:
	# Disconnect when day ends
	EventBus.puzzle_completed.disconnect(_on_puzzle_completed)
```

---

## Customizing Individual Days

Each day can have unique:

### Different UI Elements

```gdscript
# In Day script
func _ready() -> void:
	# Add day-specific UI
	var notification = preload("res://UI/DayNotification.tscn").instantiate()
	add_child(notification)
```

### Different File System

```gdscript
# Modify FileExplorer's file_system for this day
func _ready() -> void:
	var file_explorer = $GameScreen/WindowContainer/FileExplorer
	file_explorer.file_system = load_day_specific_files()
```

### Different Available Apps

```gdscript
# Enable/disable apps based on day
func _ready() -> void:
	if current_day >= 2:
		enable_email_app()
	if current_day >= 5:
		enable_browser_app()
```

---

## Debugging Days

### Skip to Specific Day

Create debug functions:

```gdscript
# In a debug script or console
func skip_to_day(day_number: int) -> void:
	get_tree().change_scene_to_file("res://Scenes/Days/Day" + str(day_number) + ".tscn")
```

### Check Day Progress

```gdscript
func print_progress() -> void:
	for i in range(10):
		var day_key = "day_" + str(i) + "_complete"
		if GameStateManager.is_puzzle_solved(day_key):
			print("Day ", i, ": COMPLETE")
		else:
			print("Day ", i, ": Not complete")
```

---

## Common Patterns

### Day Intro Sequence

```gdscript
func _ready() -> void:
	_show_day_title()
	await get_tree().create_timer(2.0).timeout
	_start_day()
```

### Multiple Objectives Per Day

```gdscript
var objectives_completed: int = 0
var total_objectives: int = 3

func _on_puzzle_completed(puzzle_id: String) -> void:
	if puzzle_id.begins_with("day_1_"):
		objectives_completed += 1
		
		if objectives_completed >= total_objectives:
			_end_day()
```

### Branching Story

```gdscript
func _end_day_1() -> void:
	var next_day = "Day2A.tscn" if player_helped_npc else "Day2B.tscn"
	get_tree().change_scene_to_file("res://Scenes/Days/" + next_day)
```

---

## See Also

- [Phone Call System](PHONE_CALL_SYSTEM.md) - Scheduling calls per day
- [Dialogue System](DIALOGUE_SYSTEM.md) - Day-specific dialogues
- [Event System](EVENT_SYSTEM.md) - Triggering day progression

