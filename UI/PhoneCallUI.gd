extends Control

## UI for incoming phone calls

@onready var call_panel: Panel = $CallPanel
@onready var caller_label: Label = $CallPanel/MarginContainer/VBoxContainer/CallerLabel
@onready var status_label: Label = $CallPanel/MarginContainer/VBoxContainer/StatusLabel
@onready var accept_button: Button = $CallPanel/MarginContainer/VBoxContainer/ButtonContainer/AcceptButton
@onready var deny_button: Button = $CallPanel/MarginContainer/VBoxContainer/ButtonContainer/DenyButton

var current_call_id: String = ""

func _ready() -> void:
	# Connect to PhoneCallSystem
	if PhoneCallSystem:
		PhoneCallSystem.call_incoming.connect(_on_call_incoming)
		PhoneCallSystem.call_accepted.connect(_on_call_accepted)
		PhoneCallSystem.call_denied.connect(_on_call_denied)
	
	# Connect buttons
	accept_button.pressed.connect(_on_accept_pressed)
	deny_button.pressed.connect(_on_deny_pressed)
	
	# Hide initially
	hide()
	
	print("[PhoneCallUI] Initialized")

func _on_call_incoming(caller_name: String, call_id: String) -> void:
	current_call_id = call_id
	caller_label.text = caller_name
	status_label.text = "Incoming Call..."
	
	# Show with animation
	show()
	call_panel.modulate = Color(1, 1, 1, 0)
	
	var tween = create_tween()
	tween.tween_property(call_panel, "modulate", Color(1, 1, 1, 1), 0.3)
	
	# Play ring sound (if you have one)
	# $RingSound.play()
	
	print("[PhoneCallUI] Showing call from: ", caller_name)

func _on_accept_pressed() -> void:
	if PhoneCallSystem:
		PhoneCallSystem.accept_call()
	_hide_ui()

func _on_deny_pressed() -> void:
	if PhoneCallSystem:
		PhoneCallSystem.deny_call()
	_hide_ui()

func _on_call_accepted(caller_name: String, call_id: String) -> void:
	if call_id == current_call_id:
		_hide_ui()

func _on_call_denied(caller_name: String, call_id: String) -> void:
	if call_id == current_call_id:
		_hide_ui()

func _hide_ui() -> void:
	var tween = create_tween()
	tween.tween_property(call_panel, "modulate", Color(1, 1, 1, 0), 0.2)
	tween.tween_callback(hide)
	current_call_id = ""

