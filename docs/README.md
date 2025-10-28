# For Your Eyes Only - Documentation

Welcome to the documentation for **For Your Eyes Only**, a narrative investigation game built with Godot 4.

## 📚 Documentation Index

### Core Systems

- **[Dialogue System](DIALOGUE_SYSTEM.md)** - Complete guide to creating and triggering dialogue
  - DialogueDatabase - Central repository for all dialogue
  - DialogueManager - Typewriter effects and display
  - How to add new dialogue
  - Event-triggered dialogue
  - Best practices and examples

- **[Event System](EVENT_SYSTEM.md)** - Global event bus for game communication
  - Available events (dialogue, files, puzzles, UI, etc.)
  - How to emit and listen to events
  - Convenience methods
  - Custom events
  - Best practices

- **[Settings System](SETTINGS_SYSTEM.md)** - User preferences and configuration
  - Typewriter speed
  - Volume controls
  - Saving/loading settings
  - Creating an Options menu

- **[Phone Call System](PHONE_CALL_SYSTEM.md)** - Incoming call notifications
  - Schedule calls with delays
  - Accept/Deny functionality
  - Automatic retry on denial
  - Integration with dialogue system

## 🎯 Quick Start

### Playing Dialogue

```gdscript
# Request dialogue by ID
EventBus.play_dialogue("intro")
```

### Scheduling Phone Calls

```gdscript
# Schedule an incoming call with dialogue
PhoneCallSystem.schedule_call(
    "intro_call",      # Call ID
    "Agent X",         # Caller name
    "intro",           # Dialogue to play when accepted
    10.0,              # Wait 10 seconds
    10.0,              # Retry after 10 seconds if denied
    -1                 # Infinite retries
)
```

### Triggering on Game Events

```gdscript
# Listen for file opens
EventBus.file_opened.connect(_on_file_opened)

func _on_file_opened(file_name: String, path: String):
    if file_name == "secret.txt":
        EventBus.play_dialogue("secret_found")
```

### Adding New Dialogue

1. Open `VN/DialogueDatabase.gd`
2. Add your dialogue:
   ```gdscript
   "my_dialogue": [
       {"character": "Agent", "text": "Hello, agent."},
       {"character": "You", "text": "What's the mission?"}
   ]
   ```
3. Trigger it: `EventBus.play_dialogue("my_dialogue")`

## 🏗️ Architecture Overview

### Autoload Singletons

The game uses several autoload singletons that are globally accessible:

| Name | Path | Purpose |
|------|------|---------|
| `GameStateManager` | `Scripts/GameState.gd` | Game progress, settings, save/load |
| `DialogueSystem` | `VN/DialogueManager.gd` | Core dialogue engine |
| `EventBus` | `Scripts/EventBus.gd` | Global event system |
| `DialogueDatabase` | `VN/DialogueDatabase.gd` | Dialogue content repository |
| `PhoneCallSystem` | `Scripts/PhoneCallSystem.gd` | Phone call management |
| `DragSystem` | `UI/DragManager.gd` | Window dragging system |

### Key Principles

1. **Event-Driven**: Systems communicate through EventBus, not direct references
2. **Data-Driven**: Dialogue is stored in DialogueDatabase, separate from game logic
3. **Persistent**: Settings and progress are automatically saved
4. **Modular**: Each system is independent and can be modified without breaking others

## 🎮 Common Workflows

### Adding a New Investigation Scene

1. **Create your scene** with interactable elements
2. **Add dialogue** to `VN/DialogueDatabase.gd`
3. **Emit events** when player interacts:
   ```gdscript
   func _on_evidence_clicked():
       EventBus.discovery_made.emit("evidence_01")
       EventBus.play_dialogue("evidence_found")
   ```
4. **Track progress** with GameStateManager:
   ```gdscript
   GameStateManager.mark_puzzle_solved("found_evidence_01")
   ```

### Creating a Puzzle

1. **Add puzzle dialogue** to DialogueDatabase
2. **Create puzzle logic** in your script
3. **Emit completion event**:
   ```gdscript
   func _on_puzzle_solved():
       EventBus.complete_puzzle("puzzle_cipher_01")
   ```
4. **Listen for completion** to trigger next steps:
   ```gdscript
   EventBus.puzzle_completed.connect(_on_any_puzzle_completed)
   
   func _on_any_puzzle_completed(puzzle_id: String):
       if puzzle_id == "puzzle_cipher_01":
           unlock_next_area()
   ```

### Adding a New File to File Explorer

1. **Add to file_system** in `Windows/FileExplorer.gd`:
   ```gdscript
   "new_file.txt": {"type": "file", "size": "3 KB"}
   ```
2. **Add dialogue** for when it's opened (optional)
3. **Add trigger** in `_check_file_triggers()`:
   ```gdscript
   "new_file.txt":
       EventBus.play_dialogue("new_file_opened")
   ```

## 🔧 Development Tips

### Debugging

- **Enable console prints**: Most systems print debug info to console
- **Check EventBus**: See what events are firing
- **Dialogue IDs**: Use `DialogueDatabase.get_all_dialogue_ids()` to list all

### Testing Dialogue

Create a test button that cycles through dialogue:

```gdscript
var test_dialogues = ["intro", "puzzle_01_complete", "ending_good"]
var current_index = 0

func _on_test_button_pressed():
    EventBus.play_dialogue(test_dialogues[current_index])
    current_index = (current_index + 1) % test_dialogues.size()
```

### Performance

- EventBus is very fast, don't worry about signal overhead
- Dialogue is loaded into memory at startup (minimal footprint)
- Settings auto-save is debounced to avoid excessive writes

## 📝 Code Style Guidelines

### Naming Conventions

- **Events**: Use past tense - `file_opened`, `puzzle_completed`
- **Dialogue IDs**: Use snake_case - `intro_agent_briefing`, `secret_file_found`
- **Functions**: Descriptive names - `_check_file_triggers()`, not `_check()`

### Comments

```gdscript
## Doc comments use double-hash for public functions
func play_dialogue(id: String) -> void:
    pass

# Regular comments use single-hash for internal notes
# This is implementation detail
```

### Signals

```gdscript
## Always document signal parameters
## Emitted when player opens a file
## Parameters: file_name (String), full_path (String)
signal file_opened(file_name: String, file_path: String)
```

## 🚀 Extending the System

### Want to Add JSON Dialogue Loading?

See the advanced section in [Dialogue System](DIALOGUE_SYSTEM.md#option-2-json-files)

### Want to Add Branching Dialogue?

Extend DialogueDatabase with choice support:

```gdscript
"dialogue_with_choices": [
    {"character": "Agent", "text": "What do you want to do?"},
    {
        "choices": [
            {"text": "Investigate further", "goto": "investigate_path"},
            {"text": "Report findings", "goto": "report_path"}
        ]
    }
]
```

### Want to Add Voice Acting?

Add audio to dialogue format:

```gdscript
{"character": "Agent", "text": "Hello", "audio": "res://audio/agent_hello.ogg"}
```

Then extend DialogueBox to play audio when showing text.

## 📚 Additional Resources

- [Godot Signals Documentation](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)
- [Godot Autoload Documentation](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html)

## 🆘 Getting Help

If you're stuck:

1. Check the relevant documentation file
2. Look at examples in the existing code
3. Enable debug prints in the autoload scripts
4. Check the Godot console for error messages

## 📄 License

[Add your license information here]

---

**Last Updated**: October 2025  
**Godot Version**: 4.5  
**Project Version**: 0.1.0

