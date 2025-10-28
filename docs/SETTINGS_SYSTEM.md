# Settings System Guide

## Overview

The game now has a centralized settings system managed by `GameStateManager` (autoload). This makes it easy to add user-configurable options and persist them across game sessions.

## Current Settings

All settings are stored in `GameState.gd` with these defaults:

```gdscript
{
    "typewriter_speed": 0.03,     # Seconds per character (dialogue)
    "text_skip_enabled": true,    # Can skip typewriter effect
    "auto_advance": false,        # Auto-advance dialogue
    "master_volume": 1.0,         # Master volume (0.0 - 1.0)
    "sfx_volume": 1.0,           # Sound effects volume
    "music_volume": 1.0          # Music volume
}
```

## How to Use

### Getting a Setting

```gdscript
var speed = GameStateManager.get_setting("typewriter_speed", 0.03)
```

The second parameter is the default value if the setting doesn't exist.

### Changing a Setting

```gdscript
GameStateManager.set_setting("typewriter_speed", 0.05)
```

This will:
1. Update the setting value
2. Emit the `settings_changed` signal
3. Automatically save to disk

### Listening for Setting Changes

```gdscript
func _ready():
    GameStateManager.settings_changed.connect(_on_settings_changed)

func _on_settings_changed(setting_name: String, new_value):
    if setting_name == "typewriter_speed":
        # Update your code to use the new value
        pass
```

### Resetting to Defaults

```gdscript
GameStateManager.reset_settings_to_default()
```

## File Persistence

Settings are automatically saved to: `user://settings.json`

- **Windows**: `%APPDATA%\Godot\app_userdata\[ProjectName]\settings.json`
- **Linux**: `~/.local/share/godot/app_userdata/[ProjectName]/settings.json`
- **macOS**: `~/Library/Application Support/Godot/app_userdata/[ProjectName]/settings.json`

Settings are loaded automatically when the game starts.

## Creating an Options Menu

When you're ready to build an Options menu, follow this pattern:

### 1. Create UI Elements

Add sliders, dropdowns, or buttons for each setting.

### 2. Connect to Setting Functions

```gdscript
# For a slider (0-100 scale)
func _on_text_speed_slider_value_changed(value: float):
    # Convert 0-100 slider to 0.01-0.1 speed
    var speed = 0.01 + (value / 100.0) * 0.09
    GameStateManager.set_setting("typewriter_speed", speed)

# For a dropdown/option button
func _on_text_speed_option_selected(index: int):
    match index:
        0: GameStateManager.set_setting("typewriter_speed", 0.05)  # Slow
        1: GameStateManager.set_setting("typewriter_speed", 0.03)  # Normal
        2: GameStateManager.set_setting("typewriter_speed", 0.01)  # Fast
        3: GameStateManager.set_setting("typewriter_speed", 0.0)   # Instant
```

### 3. Update UI to Reflect Current Settings

```gdscript
func _ready():
    # Set slider to current value
    var current_speed = GameStateManager.get_setting("typewriter_speed", 0.03)
    text_speed_slider.value = (current_speed - 0.01) / 0.09 * 100.0
    
    # Listen for external changes
    GameStateManager.settings_changed.connect(_on_settings_changed)

func _on_settings_changed(setting_name: String, new_value):
    # Update UI if setting was changed elsewhere
    pass
```

## Adding New Settings

To add a new setting:

1. Add it to the default dictionary in `GameState.gd` (two places: initial and reset function)
2. Use `get_setting()` and `set_setting()` to access it
3. That's it! Persistence is automatic

## Test Buttons

The main scene has test buttons in the top-left:
- **Test Dialogue**: Starts example dialogue
- **Slow/Normal/Fast/Instant**: Changes typewriter speed in real-time

Try changing the speed, then clicking "Test Dialogue" again to see the difference!

## Example: Typewriter Speed

The dialogue system uses this pattern:

```gdscript
# VN/DialogueBox.gd
var typewriter_speed: float = 0.03

func _ready():
    # Load from settings
    _update_typewriter_speed()
    
    # Listen for changes
    GameStateManager.settings_changed.connect(_on_settings_changed)

func _update_typewriter_speed():
    typewriter_speed = GameStateManager.get_setting("typewriter_speed", 0.03)

func _on_settings_changed(setting_name: String, _new_value):
    if setting_name == "typewriter_speed":
        _update_typewriter_speed()
```

This ensures the dialogue box always uses the current user preference!

