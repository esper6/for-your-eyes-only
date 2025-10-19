extends Node
class_name DragManager

var dragging_window = null

func start_drag(window):
	dragging_window = window

func stop_drag():
	dragging_window = null
