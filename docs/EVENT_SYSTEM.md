# Event System Documentation

## Overview

The **EventBus** is a global autoload singleton that provides a centralized event system for the entire game. It allows different parts of your game to communicate without being directly connected, following the Observer pattern.

## Why Use EventBus?

### Without EventBus (Tight Coupling):
```gdscript
# FileExplorer needs direct reference to DialogueSystem
func _on_file_opened():
    get_node("/root/Main/DialogueBox").show_dialogue("secret_found")
    get_node("/root/GameManager").mark_discovery("file_01")
    get_node("/root/SoundManager").play_sfx("discovery")
```

❌ Problems:
- Hard to maintain
- Breaks if node structure changes
- Components are tightly coupled
- Hard to test

### With EventBus (Loose Coupling):
```gdscript
# FileExplorer just emits an event
func _on_file_opened():
    EventBus.file_opened.emit("secret.txt", "C:/Documents/secret.txt")
```

✅ Benefits:
- Clean and simple
- Any system can listen for this event
- Easy to add/remove listeners
- Components are independent
- Easy to test and debug

---

## Available Events

### Dialogue Events

| Signal | Parameters | Description |
|--------|-----------|-------------|
| `dialogue_requested` | `dialogue_id: String` | Request a dialogue to play |
| `dialogue_started` | `dialogue_id: String` | Dialogue has started |
| `dialogue_ended` | - | Dialogue has finished |

**Example:**
```gdscript
# Trigger dialogue
EventBus.dialogue_requested.emit("intro")

# Listen for dialogue ending
EventBus.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_ended():
    print("Player finished reading dialogue")
```

### File System Events

| Signal | Parameters | Description |
|--------|-----------|-------------|
| `file_opened` | `file_name: String, file_path: String` | File was opened/clicked |
| `folder_opened` | `folder_name: String, folder_path: String` | Folder was opened |
| `directory_changed` | `new_path: String` | Current directory changed |

**Example:**
```gdscript
# Listen for file opens
EventBus.file_opened.connect(_on_any_file_opened)

func _on_any_file_opened(file_name: String, file_path: String):
    print("Opened: ", file_name, " at ", file_path)
    
    if file_name == "evidence.txt":
        EventBus.play_dialogue("found_evidence")
```

### Game State Events

| Signal | Parameters | Description |
|--------|-----------|-------------|
| `puzzle_completed` | `puzzle_id: String` | Puzzle was solved |
| `item_found` | `item_id: String` | Item/clue was discovered |
| `discovery_made` | `discovery_id: String` | Important discovery made |
| `game_saved` | - | Game was saved |
| `game_loaded` | - | Game was loaded |

**Example:**
```gdscript
# Complete a puzzle
EventBus.complete_puzzle("cipher_01")

# Listen for puzzle completion
EventBus.puzzle_completed.connect(_on_puzzle_done)

func _on_puzzle_done(puzzle_id: String):
    print("Puzzle completed: ", puzzle_id)
    unlock_next_area()
```

### UI Events

| Signal | Parameters | Description |
|--------|-----------|-------------|
| `window_opened` | `window_name: String` | Window/panel opened |
| `window_closed` | `window_name: String` | Window/panel closed |
| `notification_requested` | `title: String, message: String` | Show notification |

**Example:**
```gdscript
# Show notification
EventBus.notify("Achievement Unlocked", "You found the secret room!")

# Listen for notifications
EventBus.notification_requested.connect(_show_notification)

func _show_notification(title: String, message: String):
    notification_panel.show_message(title, message)
```

### System Events

| Signal | Parameters | Description |
|--------|-----------|-------------|
| `settings_updated` | `setting_name: String, new_value` | Setting changed |
| `game_paused` | - | Game paused |
| `game_resumed` | - | Game resumed |

---

## How to Use

### 1. Emitting Events

```gdscript
# Simple emit
EventBus.dialogue_requested.emit("intro")

# With parameters
EventBus.file_opened.emit("document.txt", "C:/Documents/document.txt")

# Multiple parameters
EventBus.notification_requested.emit("Alert", "New message received")
```

### 2. Listening to Events

```gdscript
func _ready():
    # Connect to an event
    EventBus.puzzle_completed.connect(_on_puzzle_completed)
    
    # One-shot connection (disconnects after first call)
    EventBus.dialogue_ended.connect(_on_dialogue_ended, CONNECT_ONE_SHOT)

func _on_puzzle_completed(puzzle_id: String):
    print("Puzzle solved: ", puzzle_id)

func _on_dialogue_ended():
    print("Dialogue finished")
```

### 3. Disconnecting from Events

```gdscript
func _exit_tree():
    # Clean up connections when node is removed
    if EventBus.puzzle_completed.is_connected(_on_puzzle_completed):
        EventBus.puzzle_completed.disconnect(_on_puzzle_completed)
```

**Note:** Godot automatically disconnects signals when nodes are freed, but manual disconnection is good practice for autoloads or persistent objects.

---

## Convenience Methods

EventBus provides helper methods for common operations:

### `play_dialogue(dialogue_id: String)`

Trigger a dialogue sequence.

```gdscript
EventBus.play_dialogue("intro")
```

Equivalent to:
```gdscript
EventBus.dialogue_requested.emit("intro")
```

### `complete_puzzle(puzzle_id: String)`

Mark a puzzle as complete and emit event.

```gdscript
EventBus.complete_puzzle("puzzle_01")
```

This:
1. Marks puzzle as solved in GameStateManager
2. Emits `puzzle_completed` signal

### `discover_item(item_id: String)`

Register an item discovery.

```gdscript
EventBus.discover_item("secret_key")
```

This:
1. Emits `item_found` signal
2. Checks for dialogue named `"item_secret_key"`
3. Plays that dialogue if it exists

### `notify(title: String, message: String)`

Show a notification to the player.

```gdscript
EventBus.notify("New Email", "You have 1 unread message")
```

---

## Practical Examples

### Example 1: File Opens Trigger Dialogue

```gdscript
# In FileExplorer.gd
func _on_file_clicked(file_name: String):
    EventBus.file_opened.emit(file_name, current_path + file_name)

# In DialogueTriggers.gd (or any other script)
func _ready():
    EventBus.file_opened.connect(_check_file_triggers)

func _check_file_triggers(file_name: String, file_path: String):
    match file_name:
        "secret.txt":
            if not GameStateManager.is_puzzle_solved("found_secret"):
                EventBus.play_dialogue("secret_discovered")
                GameStateManager.mark_puzzle_solved("found_secret")
        
        "diary.txt":
            EventBus.play_dialogue("reading_diary")
```

### Example 2: Puzzle Chain

```gdscript
# Puzzle 1 completion triggers Puzzle 2
func _ready():
    EventBus.puzzle_completed.connect(_on_puzzle_completed)

func _on_puzzle_completed(puzzle_id: String):
    match puzzle_id:
        "puzzle_01":
            EventBus.play_dialogue("puzzle_01_complete")
            unlock_puzzle_02()
        
        "puzzle_02":
            EventBus.play_dialogue("puzzle_02_complete")
            EventBus.notify("Success", "All puzzles completed!")
            trigger_ending()
```

### Example 3: Achievement System

```gdscript
# Achievement listener
extends Node

var achievements = {
    "first_file": false,
    "all_folders_visited": false,
    "speed_runner": false
}

func _ready():
    EventBus.file_opened.connect(_check_first_file)
    EventBus.folder_opened.connect(_check_all_folders)
    EventBus.puzzle_completed.connect(_check_speed_run)

func _check_first_file(file_name: String, path: String):
    if not achievements["first_file"]:
        achievements["first_file"] = true
        EventBus.notify("Achievement", "Opened your first file!")

func _check_all_folders(folder_name: String, path: String):
    # Logic to check if all folders visited
    if all_folders_visited() and not achievements["all_folders_visited"]:
        achievements["all_folders_visited"] = true
        EventBus.notify("Achievement", "Explorer - Visited all folders!")
```

### Example 4: Auto-Save System

```gdscript
# Auto-save on important events
extends Node

var save_timer: Timer

func _ready():
    # Save when important things happen
    EventBus.puzzle_completed.connect(_trigger_autosave)
    EventBus.item_found.connect(_trigger_autosave)
    EventBus.discovery_made.connect(_trigger_autosave)
    
    # Debounce rapid saves
    save_timer = Timer.new()
    save_timer.wait_time = 5.0
    save_timer.one_shot = true
    save_timer.timeout.connect(_perform_save)
    add_child(save_timer)

func _trigger_autosave(_param = null):
    if save_timer.is_stopped():
        save_timer.start()

func _perform_save():
    GameStateManager.save_game()
    EventBus.game_saved.emit()
    print("Auto-saved!")
```

---

## Creating Custom Events

Need an event that doesn't exist? You can add it to EventBus!

### Step 1: Add Signal to EventBus.gd

```gdscript
# In Scripts/EventBus.gd
signal email_received(sender: String, subject: String)
signal phone_call_incoming(caller_id: String)
signal time_changed(hour: int, minute: int)
```

### Step 2: Use It Anywhere

```gdscript
# Emit
EventBus.email_received.emit("boss@company.com", "Urgent: New Assignment")

# Listen
EventBus.email_received.connect(_on_email_received)

func _on_email_received(sender: String, subject: String):
    notification_system.show_email_popup(sender, subject)
```

---

## Best Practices

### 1. ✅ DO: Use EventBus for Cross-System Communication

```gdscript
# Good: Systems don't need to know about each other
EventBus.puzzle_completed.emit("puzzle_01")
```

### 2. ❌ DON'T: Use EventBus for Parent-Child Communication

```gdscript
# Bad: Direct connection is clearer for parent-child
EventBus.button_clicked.emit()

# Good: Use direct signals for UI elements
button.pressed.connect(_on_button_pressed)
```

### 3. ✅ DO: Use Specific Event Names

```gdscript
# Good
EventBus.puzzle_completed.emit("cipher_puzzle")

# Bad
EventBus.thing_happened.emit("puzzle")
```

### 4. ✅ DO: Document Custom Events

Add comments when adding new signals:

```gdscript
## Emitted when player completes a phone call
## Parameters: caller_name, call_duration_seconds
signal phone_call_completed(caller_name: String, duration: float)
```

### 5. ✅ DO: Use ONE_SHOT for Temporary Listeners

```gdscript
# Automatically disconnect after first call
EventBus.dialogue_ended.connect(_continue_story, CONNECT_ONE_SHOT)
```

### 6. ❌ DON'T: Abuse for Everything

EventBus is great for decoupling, but don't use it for everything:

```gdscript
# Bad: Overkill for simple UI
button.pressed.connect(func(): EventBus.button_pressed.emit())

# Good: Direct connection
button.pressed.connect(_on_button_pressed)
```

---

## Debugging Events

### Print All Event Emissions

Add this to EventBus._ready():

```gdscript
# Debug: Print all signals
for sig in get_signal_list():
    var callable = func(args): print("[EventBus] ", sig.name, " emitted with: ", args)
    get(sig.name).connect(callable)
```

### Check Connection Status

```gdscript
if EventBus.puzzle_completed.is_connected(_on_puzzle_done):
    print("Already connected!")
```

### List All Connections

```gdscript
var connections = EventBus.puzzle_completed.get_connections()
print("puzzle_completed has ", connections.size(), " listeners")
```

---

## Performance Considerations

- ✅ Signals are **very fast** in Godot
- ✅ EventBus adds minimal overhead
- ✅ Safe to use in _process() if needed
- ⚠️ Avoid emitting hundreds of events per frame
- ⚠️ Don't create circular event dependencies

---

## Common Patterns

### State Machine with Events

```gdscript
enum GameState { EXPLORING, IN_DIALOGUE, IN_PUZZLE, PAUSED }
var current_state = GameState.EXPLORING

func _ready():
    EventBus.dialogue_started.connect(func(_id): change_state(GameState.IN_DIALOGUE))
    EventBus.dialogue_ended.connect(func(): change_state(GameState.EXPLORING))

func change_state(new_state):
    current_state = new_state
    match current_state:
        GameState.IN_DIALOGUE:
            disable_controls()
        GameState.EXPLORING:
            enable_controls()
```

### Event Filtering

```gdscript
func _ready():
    EventBus.file_opened.connect(_on_file_opened)

func _on_file_opened(file_name: String, path: String):
    # Only respond to .txt files
    if file_name.ends_with(".txt"):
        process_text_file(file_name)
```

### Event Accumulation

```gdscript
var files_opened: Array[String] = []

func _ready():
    EventBus.file_opened.connect(_track_file)

func _track_file(file_name: String, path: String):
    if not files_opened.has(file_name):
        files_opened.append(file_name)
        
    if files_opened.size() >= 10:
        EventBus.notify("Achievement", "Opened 10 different files!")
```

---

## See Also

- [Dialogue System](DIALOGUE_SYSTEM.md) - Using EventBus to trigger dialogue
- [Game State](GAME_STATE.md) - State management with events
- [Settings System](SETTINGS_SYSTEM.md) - Settings events

