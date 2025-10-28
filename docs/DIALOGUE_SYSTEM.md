# Dialogue System Documentation

## Overview

The game uses a modular, event-driven dialogue system that separates dialogue content from game logic. This makes it easy to add, modify, and trigger dialogue throughout the game.

## Architecture

The system consists of three main components:

### 1. **DialogueManager** (Autoload: `DialogueSystem`)
- **Location**: `VN/DialogueManager.gd`
- **Purpose**: Core dialogue engine that handles displaying text with typewriter effects
- **Key Features**:
  - Manages dialogue queue
  - Handles text advancement
  - Emits signals for dialogue lifecycle

### 2. **DialogueDatabase** (Autoload: `DialogueDatabase`)
- **Location**: `VN/DialogueDatabase.gd`
- **Purpose**: Central repository for all dialogue content
- **Key Features**:
  - Stores all dialogue sequences by ID
  - Provides easy access to dialogue
  - Supports runtime dialogue addition

### 3. **EventBus** (Autoload: `EventBus`)
- **Location**: `Scripts/EventBus.gd`
- **Purpose**: Global event system for triggering dialogue and other game events
- **Key Features**:
  - Decouples systems from each other
  - Provides convenient methods for common operations
  - Handles cross-system communication

---

## Quick Start Guide

### Playing Dialogue

The simplest way to play dialogue:

```gdscript
# Anywhere in your code
EventBus.play_dialogue("intro")
```

Or directly through DialogueDatabase:

```gdscript
DialogueDatabase.play("intro")
```

### Adding New Dialogue

1. Open `VN/DialogueDatabase.gd`
2. Add your dialogue to the `dialogues` dictionary:

```gdscript
var dialogues: Dictionary = {
    "my_new_dialogue": [
        {"character": "Agent", "text": "This is the first line."},
        {"character": "You", "text": "This is your response."},
        {"character": "", "text": "Narration has no character name."}
    ]
}
```

3. Trigger it from anywhere:

```gdscript
EventBus.play_dialogue("my_new_dialogue")
```

---

## Dialogue Format

Each dialogue entry is an array of dictionaries with this structure:

```gdscript
{
    "character": "Character Name",  # String - who's speaking (empty for narration)
    "text": "What they say"          # String - the dialogue text
}
```

### Example

```gdscript
"example_conversation": [
    {"character": "Agent", "text": "We have a new assignment for you."},
    {"character": "You", "text": "What kind of assignment?"},
    {"character": "Agent", "text": "Top secret. I'll brief you on location."},
    {"character": "", "text": "The agent hands you a folder marked 'CLASSIFIED'."}
]
```

---

## Triggering Dialogue from Events

### Method 1: Direct Trigger

Trigger dialogue immediately when something happens:

```gdscript
func _on_button_pressed():
    EventBus.play_dialogue("button_pressed_dialogue")
```

### Method 2: Event Listening

Listen for events and respond with dialogue:

```gdscript
func _ready():
    EventBus.file_opened.connect(_on_file_opened)

func _on_file_opened(file_name: String, file_path: String):
    if file_name == "secret_document.txt":
        EventBus.play_dialogue("secret_found")
```

### Method 3: Conditional Triggers

Only trigger dialogue the first time or under certain conditions:

```gdscript
func _on_folder_opened(folder_name: String, path: String):
    # Only show dialogue the first time
    if folder_name == "Documents" and not GameStateManager.is_puzzle_solved("visited_documents"):
        EventBus.play_dialogue("first_documents_visit")
        GameStateManager.mark_puzzle_solved("visited_documents")
```

---

## EventBus Reference

### Dialogue Events

```gdscript
# Request dialogue by ID
EventBus.play_dialogue("dialogue_id")

# Listen for when dialogue starts
EventBus.dialogue_started.connect(_on_dialogue_started)

# Listen for when dialogue ends
EventBus.dialogue_ended.connect(_on_dialogue_ended)
```

### File System Events

```gdscript
# Emitted when a file is opened
EventBus.file_opened.emit(file_name, file_path)
EventBus.file_opened.connect(_on_file_opened)

# Emitted when a folder is opened
EventBus.folder_opened.emit(folder_name, folder_path)
EventBus.folder_opened.connect(_on_folder_opened)

# Emitted when directory changes
EventBus.directory_changed.emit(new_path)
EventBus.directory_changed.connect(_on_directory_changed)
```

### Game State Events

```gdscript
# Complete a puzzle and trigger events
EventBus.complete_puzzle("puzzle_01")
EventBus.puzzle_completed.connect(_on_puzzle_completed)

# Discover an item
EventBus.discover_item("secret_key")
EventBus.item_found.connect(_on_item_found)

# Generic discovery
EventBus.discovery_made.emit("found_hidden_room")
```

### UI Events

```gdscript
# Show a notification
EventBus.notify("Achievement", "You found the secret!")
EventBus.notification_requested.connect(_on_notification)

# Window events
EventBus.window_opened.emit("settings_menu")
EventBus.window_closed.emit("settings_menu")
```

---

## DialogueDatabase API

### Core Methods

```gdscript
# Play dialogue (returns true if found, false if not)
var success: bool = DialogueDatabase.play("dialogue_id")

# Check if dialogue exists
if DialogueDatabase.has_dialogue("dialogue_id"):
    print("Dialogue exists!")

# Get raw dialogue data
var dialogue_lines: Array = DialogueDatabase.get_dialogue("dialogue_id")

# Get all dialogue IDs (useful for debugging)
var all_ids: Array = DialogueDatabase.get_all_dialogue_ids()
```

### Runtime Manipulation

```gdscript
# Add dialogue at runtime (for dynamic content)
DialogueDatabase.add_dialogue("dynamic_id", [
    {"character": "NPC", "text": "This was generated at runtime!"}
])

# Remove dialogue
DialogueDatabase.remove_dialogue("dialogue_id")
```

---

## Best Practices

### 1. **Use Descriptive IDs**

❌ Bad:
```gdscript
"dialogue1"
"d2"
"conv_03"
```

✅ Good:
```gdscript
"intro_agent_briefing"
"first_documents_visit"
"secret_file_discovered"
```

### 2. **Organize by Category**

Group related dialogues in DialogueDatabase.gd:

```gdscript
var dialogues: Dictionary = {
    # ============================================
    # INTRO & TUTORIAL
    # ============================================
    "intro": [...],
    "tutorial_file_explorer": [...],
    
    # ============================================
    # CHAPTER 1
    # ============================================
    "chapter1_start": [...],
    "chapter1_end": [...],
}
```

### 3. **Use GameState for Tracking**

Track whether dialogue has been seen using GameStateManager:

```gdscript
if not GameStateManager.is_puzzle_solved("seen_intro"):
    EventBus.play_dialogue("intro")
    GameStateManager.mark_puzzle_solved("seen_intro")
```

### 4. **Respond to Events, Don't Poll**

❌ Bad (polling in _process):
```gdscript
func _process(_delta):
    if some_condition:
        play_dialogue()
```

✅ Good (event-driven):
```gdscript
func _ready():
    EventBus.file_opened.connect(_handle_file_opened)
```

### 5. **Keep Logic Out of Dialogue**

❌ Bad:
```gdscript
# Don't put game logic in DialogueDatabase
"dialogue_with_logic": [
    {"character": "NPC", "text": "Here's some money!"},
    # How do you give the player money here?
]
```

✅ Good:
```gdscript
# Handle logic in the event handler
func _on_quest_complete():
    EventBus.play_dialogue("quest_complete")
    player.add_money(100)  # Logic stays in code
```

---

## Example: Complete Flow

Here's a complete example of adding a new dialogue-triggered event:

### Step 1: Add Dialogue to Database

```gdscript
# In VN/DialogueDatabase.gd
"found_usb_drive": [
    {"character": "You", "text": "What's this? A USB drive hidden in the desk drawer?"},
    {"character": "Agent", "text": "Excellent work! Get that to me immediately."},
    {"character": "", "text": "The USB drive might contain critical evidence."}
]
```

### Step 2: Create Trigger Function

```gdscript
# In your game script
func _on_desk_searched():
    if not GameStateManager.is_puzzle_solved("found_usb"):
        EventBus.play_dialogue("found_usb_drive")
        GameStateManager.mark_puzzle_solved("found_usb")
        
        # Add USB to inventory
        player_inventory.add_item("usb_drive")
        
        # Emit discovery event
        EventBus.discover_item("usb_drive")
```

### Step 3: Connect to UI/Interaction

```gdscript
# In your interaction script
func _on_desk_clicked():
    _on_desk_searched()
```

Done! The dialogue will play automatically when the player clicks the desk for the first time.

---

## Advanced: Dialogue Chains

To create longer conversations that wait for player input between sections:

```gdscript
func start_investigation():
    EventBus.play_dialogue("investigation_start")
    EventBus.dialogue_ended.connect(_on_intro_finished, CONNECT_ONE_SHOT)

func _on_intro_finished():
    # Wait a moment, then continue
    await get_tree().create_timer(1.0).timeout
    EventBus.play_dialogue("investigation_instructions")
```

---

## Troubleshooting

### Dialogue Not Playing

1. **Check the ID exists**:
   ```gdscript
   print(DialogueDatabase.has_dialogue("your_id"))
   ```

2. **Check the console for errors**:
   - DialogueDatabase prints errors when IDs aren't found

3. **Verify autoloads are loaded**:
   ```gdscript
   print(EventBus != null)
   print(DialogueDatabase != null)
   ```

### Dialogue Playing Multiple Times

Use GameStateManager to track if it's been seen:

```gdscript
if not GameStateManager.is_puzzle_solved("unique_flag"):
    EventBus.play_dialogue("dialogue_id")
    GameStateManager.mark_puzzle_solved("unique_flag")
```

### Dialogue IDs Are Hard to Remember

Keep a reference list! You can print all IDs:

```gdscript
print(DialogueDatabase.get_all_dialogue_ids())
```

Or create constants:

```gdscript
# In a constants file
const DIALOGUE = {
    INTRO = "intro",
    SECRET_FOUND = "secret_file_found",
    ENDING_GOOD = "ending_good"
}

# Use like:
EventBus.play_dialogue(DIALOGUE.INTRO)
```

---

## See Also

- [Settings System](SETTINGS_SYSTEM.md) - How to configure dialogue speed and other settings
- [Event System](EVENT_SYSTEM.md) - Complete EventBus documentation
- [Game State](GAME_STATE.md) - Managing persistent data and progress

