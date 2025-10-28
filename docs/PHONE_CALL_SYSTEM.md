# Phone Call System Documentation

## Overview

The Phone Call System allows you to create immersive incoming call notifications throughout the game. Calls appear as popups in the bottom-right corner with Accept/Deny buttons, and can automatically retry if denied.

## Architecture

### Components

1. **PhoneCallSystem** (Autoload: `PhoneCallSystem`)
   - Manages call queue, delays, and retry logic
   - Handles call lifecycle
   - Integrates with DialogueSystem

2. **PhoneCallUI** (`UI/PhoneCallUI.tscn`)
   - Bottom-right popup with caller name
   - Accept and Deny buttons
   - Fade-in/fade-out animations

3. **EventBus Integration**
   - Phone call events for system-wide communication
   - Tracks call state across game

---

## Quick Start

### Schedule a Call

```gdscript
# Schedule a call that plays dialogue when accepted
PhoneCallSystem.schedule_call(
    "intro_call",           # Unique call ID
    "Agent X",              # Caller name shown in UI
    "intro",                # Dialogue ID to play when accepted
    10.0,                   # Wait 10 seconds before calling
    10.0,                   # Retry after 10 seconds if denied
    -1                      # Infinite retries (-1)
)
```

### Using DialogueDatabase Helper

```gdscript
# Shorter version using DialogueDatabase
DialogueDatabase.schedule_dialogue_call(
    "intro_call",
    "Agent X",
    "intro",
    10.0,       # Delay
    10.0        # Retry delay
)
```

---

## PhoneCallSystem API

### Core Methods

#### `schedule_call()`

Schedule an incoming phone call.

```gdscript
PhoneCallSystem.schedule_call(
    call_id: String,        # Unique identifier
    caller_name: String,    # Display name
    dialogue_id: String,    # Dialogue to play when accepted
    delay_seconds: float = 0.0,      # Delay before showing call
    retry_delay: float = 10.0,       # Seconds between retries
    max_retries: int = -1            # -1 = infinite
)
```

**Parameters:**
- `call_id`: Unique string to identify this call (e.g., "intro_call", "boss_urgent_01")
- `caller_name`: What appears in the UI (e.g., "Agent X", "Unknown Number", "Mom")
- `dialogue_id`: Must exist in DialogueDatabase
- `delay_seconds`: Wait time before call appears (0 = immediate)
- `retry_delay`: Seconds to wait before re-calling if denied
- `max_retries`: Maximum retry attempts (-1 for infinite, 0 for no retries)

#### `accept_call()`

Accept the current incoming call (usually called by UI).

```gdscript
PhoneCallSystem.accept_call()
```

- Starts the associated dialogue
- Clears any retry timers
- Emits `call_accepted` signal

#### `deny_call()`

Deny the current incoming call.

```gdscript
PhoneCallSystem.deny_call()
```

- Schedules a retry if within retry limit
- Emits `call_denied` signal
- Shows next call in queue (if any)

#### `cancel_call()`

Cancel a scheduled, active, or retrying call.

```gdscript
PhoneCallSystem.cancel_call("intro_call")
```

Useful when:
- Player completes a task that makes a call irrelevant
- Story branch changes
- Need to prevent a retry

#### `is_call_active()`

Check if any call is currently showing or in progress.

```gdscript
if PhoneCallSystem.is_call_active():
    print("Call in progress, don't interrupt!")
```

#### `get_current_call_info()`

Get details about the active call.

```gdscript
var info = PhoneCallSystem.get_current_call_info()
print("Caller: ", info.get("caller"))
print("Retry count: ", info.get("retry_count"))
```

Returns dictionary with keys:
- `id`: Call ID
- `caller`: Caller name
- `dialogue`: Dialogue ID
- `retry_count`: How many times call has been retried

---

## Signals & Events

### PhoneCallSystem Signals

```gdscript
# Emitted when a call comes in
PhoneCallSystem.call_incoming.connect(func(caller_name, call_id):
    print("Incoming call from: ", caller_name)
)

# Emitted when player accepts
PhoneCallSystem.call_accepted.connect(func(caller_name, call_id):
    print("Accepted call from: ", caller_name)
)

# Emitted when player denies
PhoneCallSystem.call_denied.connect(func(caller_name, call_id):
    print("Denied call from: ", caller_name)
)

# Emitted when call ends (dialogue completes)
PhoneCallSystem.call_ended.connect(func(call_id):
    print("Call ended: ", call_id)
)
```

### EventBus Events

The same events are mirrored on EventBus for global access:

```gdscript
EventBus.phone_call_incoming.connect(_on_call_incoming)
EventBus.phone_call_accepted.connect(_on_call_accepted)
EventBus.phone_call_denied.connect(_on_call_denied)
EventBus.phone_call_ended.connect(_on_call_ended)
```

---

## Usage Examples

### Example 1: Intro Call (With Retry)

```gdscript
# Game starts, wait 10 seconds, then Agent X calls
func _ready():
    PhoneCallSystem.schedule_call(
        "intro_call",
        "Agent X",
        "intro",
        10.0,       # Wait 10 seconds
        10.0,       # Retry every 10 seconds if denied
        -1          # Keep trying forever
    )
```

### Example 2: Urgent Call (Limited Retries)

```gdscript
# Boss calls, only tries 3 times
PhoneCallSystem.schedule_call(
    "boss_urgent",
    "Director",
    "urgent_mission_brief",
    0.0,        # Immediate
    5.0,        # Retry every 5 seconds
    3           # Max 3 retries
)
```

### Example 3: Timed Call

```gdscript
# Mysterious call after 2 minutes of gameplay
PhoneCallSystem.schedule_call(
    "mystery_call",
    "Unknown Number",
    "mysterious_warning",
    120.0,      # 2 minutes
    20.0,       # Retry every 20 seconds
    5           # Max 5 retries
)
```

### Example 4: Conditional Call

```gdscript
# Call only if player found a clue
func _on_clue_discovered():
    if not GameStateManager.is_puzzle_solved("received_follow_up_call"):
        PhoneCallSystem.schedule_call(
            "follow_up",
            "Agent X",
            "clue_discovered_followup",
            5.0,    # 5 second delay
            15.0    # Retry every 15 seconds
        )
        GameStateManager.mark_puzzle_solved("received_follow_up_call")
```

### Example 5: Multiple Callers

```gdscript
# Schedule multiple calls at different times
func _setup_story_calls():
    # Intro from Agent X
    PhoneCallSystem.schedule_call("intro", "Agent X", "intro", 10.0)
    
    # 30 seconds later, informant calls
    PhoneCallSystem.schedule_call("informant1", "Informant", "tip_off", 40.0)
    
    # 1 minute later, boss checks in
    PhoneCallSystem.schedule_call("boss1", "Director", "status_check", 70.0)
```

### Example 6: Cancel Call on Completion

```gdscript
# If player completes objective before call comes in, cancel it
func _on_objective_complete():
    PhoneCallSystem.cancel_call("follow_up_nag")
    print("Objective done, no need for follow-up call")
```

### Example 7: React to Denial

```gdscript
func _ready():
    EventBus.phone_call_denied.connect(_on_call_denied)

func _on_call_denied(caller_name: String, call_id: String):
    if call_id == "boss_urgent":
        # Boss is not happy about being ignored
        print("Boss will remember this...")
        GameStateManager.set_setting("boss_annoyed", true)
```

---

## Advanced Usage

### Call Priority System

Calls are shown in the order they're queued, but you can access the internal priority system:

```gdscript
# In PhoneCallSystem.gd, modify the PhoneCall class:
var call = PhoneCall.new("urgent_call", "Director", "urgent_dialogue")
call.priority = 10  # Higher priority calls show first
```

### Custom Call Behavior

Listen to call events and add custom logic:

```gdscript
func _ready():
    EventBus.phone_call_incoming.connect(_on_incoming_call)

func _on_incoming_call(caller_name: String, call_id: String):
    # Pause game during important calls
    if caller_name == "Director":
        get_tree().paused = true
    
    # Play ringtone
    $RingtoneSFX.play()
    
    # Make screen flash
    $ScreenFlash.flash()
```

### Integrating with Game State

```gdscript
# Track call statistics
func _ready():
    EventBus.phone_call_accepted.connect(_track_accepted)
    EventBus.phone_call_denied.connect(_track_denied)

var calls_answered = 0
var calls_ignored = 0

func _track_accepted(caller, call_id):
    calls_answered += 1
    GameStateManager.set_setting("calls_answered", calls_answered)

func _track_denied(caller, call_id):
    calls_ignored += 1
    GameStateManager.set_setting("calls_ignored", calls_ignored)
    
    # Achievement for ignoring too many calls?
    if calls_ignored >= 10:
        EventBus.notify("Achievement", "Master of Ignorance")
```

---

## Customizing the UI

The PhoneCallUI is fully customizable. Edit `UI/PhoneCallUI.tscn`:

### Change Position

The call panel is anchored to bottom-right. To change:
1. Select `CallPanel` node
2. Modify anchors and offsets
3. Update margins

### Add Caller Photo

```gdscript
# In PhoneCallUI.gd
@onready var caller_photo: TextureRect = $CallPanel/.../CallerPhoto

func _on_call_incoming(caller_name: String, call_id: String):
    # Load photo based on caller
    var photo_path = "res://assets/callers/" + caller_name + ".png"
    if ResourceLoader.exists(photo_path):
        caller_photo.texture = load(photo_path)
```

### Add Ringtone

```gdscript
# In PhoneCallUI.gd
@onready var ringtone: AudioStreamPlayer = $RingtoneSFX

func _on_call_incoming(caller_name: String, call_id: String):
    ringtone.play()

func _hide_ui():
    ringtone.stop()
    # ... rest of hide logic
```

### Animation Variants

Change the fade-in animation in `PhoneCallUI.gd`:

```gdscript
# Slide in from right
var tween = create_tween()
tween.tween_property(call_panel, "position:x", 0, 0.3).from(300)

# Bounce in
tween.set_trans(Tween.TRANS_BOUNCE)
tween.tween_property(call_panel, "modulate:a", 1.0, 0.5).from(0.0)
```

---

## Best Practices

### 1. Use Descriptive Call IDs

❌ Bad:
```gdscript
schedule_call("call1", "Agent", "dialogue1", 10.0)
```

✅ Good:
```gdscript
schedule_call("intro_agent_briefing", "Agent X", "mission_intro", 10.0)
```

### 2. Don't Interrupt Dialogue

The system automatically prevents calls during dialogue, but you can add extra checks:

```gdscript
if not DialogueSystem.is_active and not PhoneCallSystem.is_call_active():
    schedule_important_call()
```

### 3. Track First-Time Calls

```gdscript
func schedule_informant_call():
    if not GameStateManager.is_puzzle_solved("talked_to_informant"):
        PhoneCallSystem.schedule_call("informant", "??", "informant_intro", 30.0)
        # Mark as scheduled, not as talked yet
```

### 4. Limit Retry Spam

For non-critical calls, limit retries:

```gdscript
# Optional side quest call - don't spam player
PhoneCallSystem.schedule_call(
    "side_quest_offer",
    "Old Friend",
    "side_quest_intro",
    60.0,
    30.0,
    2       # Only try twice
)
```

### 5. Cancel Obsolete Calls

```gdscript
func _on_mission_complete():
    # Cancel any follow-up calls since mission is done
    PhoneCallSystem.cancel_call("mission_reminder")
    PhoneCallSystem.cancel_call("time_sensitive_tip")
```

---

## Troubleshooting

### Call Not Showing Up

1. **Check dialogue exists**:
   ```gdscript
   print(DialogueDatabase.has_dialogue("your_dialogue_id"))
   ```

2. **Check call was scheduled**:
   ```gdscript
   print(PhoneCallSystem.get_current_call_info())
   ```

3. **Check for conflicts**: Is dialogue or another call already active?

### Call Shows But Doesn't Play Dialogue

- Verify `dialogue_id` matches DialogueDatabase key exactly (case-sensitive)
- Check console for errors about missing dialogue

### Retry Not Working

- Check `max_retries` isn't set to 0
- Check if call was cancelled elsewhere
- Verify retry_delay is reasonable (not too large)

### UI Not Appearing

- Check PhoneCallUI is added to Main scene
- Verify PhoneCallUI.gd script is attached
- Check if UI is being hidden by other elements (z-index)

---

## See Also

- [Dialogue System](DIALOGUE_SYSTEM.md) - Creating dialogue that plays during calls
- [Event System](EVENT_SYSTEM.md) - Using EventBus with phone calls
- [Game State](GAME_STATE.md) - Tracking call history and player choices

