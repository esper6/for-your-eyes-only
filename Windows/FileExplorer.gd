extends CharacterBody2D

## A file explorer window with physics-based dragging and collision

@onready var folder_tree: Tree = $ContentContainer/Sidebar/FolderTree
@onready var file_list: ItemList = $ContentContainer/MainArea/FileListContainer/FileList
@onready var address_bar: LineEdit = $ContentContainer/MainArea/TopBar/AddressBar
@onready var back_button: Button = $ContentContainer/MainArea/TopBar/BackButton
@onready var forward_button: Button = $ContentContainer/MainArea/TopBar/ForwardButton
@onready var title_bar: Panel = $TitleBar

var current_path: String = "C:/"
var history: Array[String] = []
var history_position: int = -1

# Dragging variables
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var drag_manager: Node = null

# In-game file system structure
var file_system: Dictionary = {
	"C:/": {
		"type": "folder",
		"children": {
			"Documents": {
				"type": "folder",
				"children": {
					"work_notes.txt": {"type": "file", "size": "2 KB"},
					"secrets.txt": {"type": "file", "size": "1 KB"},
					"personal": {
						"type": "folder",
						"children": {
							"diary.txt": {"type": "file", "size": "5 KB"}
						}
					}
				}
			},
			"Pictures": {
				"type": "folder",
				"children": {
					"vacation.jpg": {"type": "file", "size": "1.2 MB"},
					"family.png": {"type": "file", "size": "800 KB"}
				}
			},
			"Desktop": {
				"type": "folder",
				"children": {
					"readme.txt": {"type": "file", "size": "512 B"}
				}
			},
			"Downloads": {
				"type": "folder",
				"children": {}
			}
		}
	}
}

func _ready() -> void:
	# Get DragManager from autoload
	drag_manager = get_node_or_null("/root/DragSystem")
	
	_setup_folder_tree()
	_populate_file_list()
	_update_address_bar()
	_update_navigation_buttons()
	
	# Connect signals
	folder_tree.item_activated.connect(_on_folder_tree_item_activated)
	file_list.item_activated.connect(_on_file_list_item_activated)
	address_bar.text_submitted.connect(_on_address_submitted)
	back_button.pressed.connect(_on_back_pressed)
	forward_button.pressed.connect(_on_forward_pressed)
	
	# Connect title bar dragging
	title_bar.gui_input.connect(_on_title_bar_gui_input)

func _physics_process(_delta: float) -> void:
	if is_dragging:
		var mouse_pos = get_global_mouse_position()
		var target_pos = mouse_pos - drag_offset
		
		# Move with physics (you can add collision response here)
		global_position = target_pos
		
		# Optional: use move_and_collide for collision detection
		# var collision = move_and_collide((target_pos - global_position) * delta * 60)

func _on_title_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging
				is_dragging = true
				drag_offset = get_global_mouse_position() - global_position
				if drag_manager:
					drag_manager.start_drag(self)
				# Bring to front by moving to end of parent's children
				if get_parent():
					get_parent().move_child(self, -1)
			else:
				# Stop dragging
				is_dragging = false
				if drag_manager:
					drag_manager.stop_drag()

func _setup_folder_tree() -> void:
	folder_tree.clear()
	folder_tree.hide_root = true
	var root: TreeItem = folder_tree.create_item()
	_build_tree_recursive(root, file_system, "")

func _build_tree_recursive(parent_item: TreeItem, data: Dictionary, path: String) -> void:
	for key in data.keys():
		var item_data: Dictionary = data[key]
		if item_data.get("type") == "folder":
			var item: TreeItem = folder_tree.create_item(parent_item)
			item.set_text(0, key)
			var item_path: String = path + key + "/"
			item.set_metadata(0, item_path)
			
			if item_data.has("children"):
				_build_tree_recursive(item, item_data["children"], item_path)

func _populate_file_list() -> void:
	file_list.clear()
	
	var current_folder: Dictionary = _get_folder_at_path(current_path)
	if current_folder.is_empty():
		return
	
	var children: Dictionary = current_folder.get("children", {})
	
	# Add folders first
	for item_name in children.keys():
		var item: Dictionary = children[item_name]
		if item.get("type") == "folder":
			var index: int = file_list.add_item("📁 " + item_name)
			file_list.set_item_metadata(index, {"name": item_name, "type": "folder"})
	
	# Then add files
	for item_name in children.keys():
		var item: Dictionary = children[item_name]
		if item.get("type") == "file":
			var file_size: String = item.get("size", "0 B")
			var index: int = file_list.add_item("📄 " + item_name + " (" + file_size + ")")
			file_list.set_item_metadata(index, {"name": item_name, "type": "file"})

func _get_folder_at_path(path: String) -> Dictionary:
	# Start at the root
	var current: Dictionary = file_system.get("C:/", {})
	
	# If asking for root, return it directly
	if path == "C:/":
		return current
	
	# Navigate through the path
	var parts: PackedStringArray = path.split("/", false)
	# Skip the first part if it's "C:"
	var start_index = 1 if parts.size() > 0 and parts[0] == "C:" else 0
	
	for i in range(start_index, parts.size()):
		var part = parts[i]
		if current.has("children"):
			var children = current["children"]
			if children.has(part):
				current = children[part]
			else:
				return {}
		else:
			return {}
	
	return current
func _navigate_to(path: String) -> void:
	# Validate path exists
	var folder: Dictionary = _get_folder_at_path(path)
	if folder.is_empty():
		return
	
	# Add to history if navigating to new location
	if path != current_path:
		# Remove any forward history
		if history_position < history.size() - 1:
			history = history.slice(0, history_position + 1)
		
		history.append(path)
		history_position = history.size() - 1
	
	current_path = path
	_populate_file_list()
	_update_address_bar()
	_update_navigation_buttons()

func _update_address_bar() -> void:
	address_bar.text = current_path

func _update_navigation_buttons() -> void:
	back_button.disabled = history_position <= 0
	forward_button.disabled = history_position >= history.size() - 1

func _on_folder_tree_item_activated() -> void:
	var selected: TreeItem = folder_tree.get_selected()
	if selected:
		var path: String = selected.get_metadata(0)
		_navigate_to(path)

func _on_file_list_item_activated(index: int) -> void:
	var metadata: Dictionary = file_list.get_item_metadata(index)
	if metadata.get("type") == "folder":
		var new_path: String = current_path
		if not new_path.ends_with("/"):
			new_path += "/"
		new_path += metadata["name"] + "/"
		_navigate_to(new_path)
	elif metadata.get("type") == "file":
		# File opened - you can emit a signal or handle file opening here
		print("Opened file: ", metadata["name"])

func _on_address_submitted(new_path: String) -> void:
	if not new_path.ends_with("/"):
		new_path += "/"
	_navigate_to(new_path)

func _on_back_pressed() -> void:
	if history_position > 0:
		history_position -= 1
		current_path = history[history_position]
		_populate_file_list()
		_update_address_bar()
		_update_navigation_buttons()

func _on_forward_pressed() -> void:
	if history_position < history.size() - 1:
		history_position += 1
		current_path = history[history_position]
		_populate_file_list()
		_update_address_bar()
		_update_navigation_buttons()
