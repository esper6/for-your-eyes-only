# Desktop Icons System

## Overview

The desktop icon system allows you to create clickable icons on the desktop that can open windows, trigger events, or perform actions when clicked or double-clicked.

## Components

### 1. DesktopIcon Component
**Location**: `UI/DesktopIcon.tscn` and `UI/DesktopIcon.gd`

A reusable component for creating desktop icons with double-click support.

**Properties**:
- `icon_id`: String - Unique identifier for the icon
- `icon_label`: String - Display name shown under the icon
- `icon_color`: Color - Color of the icon rectangle

**Signals**:
- `icon_clicked(icon_id: String)` - Emitted on single click
- `icon_double_clicked(icon_id: String)` - Emitted on double click

### 2. TextViewer Window
**Location**: `UI/Apps/TextViewer.tscn` and `UI/Apps/TextViewer.gd`

A simple text viewer window for displaying text files (like Notepad).

**Features**:
- Draggable window
- Read-only text display with word wrapping
- Close button
- Physics-based movement

**Methods**:
- `open_file(file_name: String, content: String)` - Opens and displays a text file

## Usage

### Adding a New Desktop Icon with Text File

1. **Define the file content in GameScreen.gd**:

```gdscript
var desktop_files: Dictionary = {
    "my_file": {
        "display_name": "My Document.txt",
        "content": """Your text content here
        
Can be multiple lines
With formatting as needed"""
    }
}
```

2. **Add the icon to the scene** (in `GameScreen.tscn` under `DesktopIcons`):

```gdscript
[node name="MyFile" parent="DesktopIcons" instance=ExtResource("5_desktopicon")]
layout_mode = 2
icon_id = "my_file"
icon_label = "My Document.txt"
icon_color = Color(0.8, 0.9, 0.7, 1)
```

3. **Double-click to open** - The system automatically handles opening text files!

### Adding Icons That Do Other Things

If you want an icon to do something other than open a text file:

```gdscript
# In GameScreen.gd, modify _on_desktop_icon_double_clicked():

func _on_desktop_icon_double_clicked(icon_id: String) -> void:
    match icon_id:
        "employee_manifesto":
            _open_text_file("employee_manifesto")
        
        "my_computer":
            # Open file explorer or do something else
            file_explorer.visible = true
            file_explorer.position = Vector2(100, 100)
        
        "documents":
            # Navigate to Documents folder
            if file_explorer.has_method("_navigate_to"):
                file_explorer._navigate_to("C:/Documents/")
                file_explorer.visible = true
```

### Custom Window Types

You can create other window types (like web browsers, email clients, etc.):

1. Create a new scene in `UI/Apps/` (see `EmailClient.tscn` as example)
2. Make it a `CharacterBody2D` with dragging support
3. Preload it in `GameScreen.gd`
4. Handle it in `_on_desktop_icon_double_clicked()`

## Events Integration

The system automatically emits events when files are opened:

```gdscript
# In your game code, listen for file opens:
EventBus.file_opened.connect(_on_file_opened)

func _on_file_opened(file_name: String, file_path: String):
    if file_name == "Employee Guide Manifesto.txt":
        # Player opened the manifesto!
        GameState.mark_puzzle_solved("read_manifesto")
```

## Example: The Employee Guide Manifesto

The Employee Guide Manifesto is set up as follows:

1. **Icon**: Yellowish color (`Color(0.9, 0.9, 0.7, 1)`), positioned at the top of the desktop icons
2. **Content**: Defined in `GameScreen.gd` under `desktop_files["employee_manifesto"]`
3. **Action**: Double-click opens it in a TextViewer window
4. **Event**: Emits `file_opened` signal with file name and path

## Tips

- **Icon Colors**: Use different colors to distinguish file types
  - Documents: Yellow/cream tones
  - Folders: Brown/tan tones
  - Executables: Gray/dark tones
  - Images: Colorful tones

- **Icon Positioning**: Icons are in a VBoxContainer on the left side of the screen. Adjust the container's position in `GameScreen.tscn` to move all icons at once.

- **Window Positioning**: When opening windows, vary the spawn position to avoid overlapping:
  ```gdscript
  viewer.position = Vector2(300 + randf() * 100, 200 + randf() * 100)
  ```

- **Multiple Opens**: The current system allows opening the same file multiple times. To prevent this, track open windows in GameScreen.

## Extending the System

### Adding Image Files

You could create an `ImageViewer` similar to `TextViewer`:

```gdscript
func _open_image_file(file_id: String) -> void:
    var viewer = ImageViewer.instantiate()
    window_container.add_child(viewer)
    viewer.position = Vector2(300, 200)
    viewer.open_image(image_path)
```

### Adding Executable Files

Icons that launch apps instead of viewing content:

```gdscript
"calculator": {
    "type": "executable",
    "app_scene": "res://UI/Apps/Calculator.tscn"
}
```

### Desktop Icon Drag-and-Drop

Currently icons are static. You could add dragging to icons themselves to let users rearrange them.

## See Also

- [File Explorer System](../Windows/FileExplorer.gd) - Navigate the virtual file system
- [Event System](EVENT_SYSTEM.md) - Connect events and triggers
- [Dialogue System](DIALOGUE_SYSTEM.md) - Trigger dialogue from file opens

