extends Node3D

var pause_menu_open := false:
	set(value):
		pause_menu_open = value
		update_cursor()
var inventory_open := false:
	set(value):
		inventory_open = value
		update_cursor()


func _ready() -> void:
	update_cursor()


func update_cursor() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if not pause_menu_open and not inventory_open else Input.MOUSE_MODE_VISIBLE
