extends "res://game/main_menu/sub_menu.gd"

# Server list
@onready var server_list = $VBoxContainer/ServersMenu/ScrollContainer/ServerList
# Add server dialog
@onready var add_server_dialog = $VBoxContainer/AddServerDialog
@onready var add_server_address = $VBoxContainer/AddServerDialog/ServerOptions/AddressLineEdit
@onready var add_server_port = $VBoxContainer/AddServerDialog/ServerOptions/PortSpinBox
# Remove server dialog
@onready var remove_server_dialog = $VBoxContainer/RemoveServerDialog
# No selection dialog
@onready var no_selection_dialog = $VBoxContainer/NoSelectionDialog


func _ready() -> void:
	update_server_list()


func update_server_list() -> void:
	server_list.clear()
	for i in Global.multiplayer_info["servers"]:
		server_list.add_item(i.get("name", i["address"]), preload("res://assets/textures/server.png"))


func get_selected_server() -> int:
	return server_list.get_selected_items()[0]


func _on_add_button_pressed() -> void:
	add_server_address.text = ""
	add_server_port.value = 6767
	add_server_dialog.popup_centered()


func _on_add_server_dialog_confirmed() -> void:
	Global.multiplayer_info["servers"].append({
		"address": add_server_address.text,
		"port": add_server_port.value
	})
	update_server_list()


func _on_remove_button_pressed() -> void:
	if server_list.is_anything_selected():
		remove_server_dialog.popup_centered()
	else:
		no_selection_dialog.popup_centered()


func _on_remove_server_dialog_confirmed() -> void:
	Global.multiplayer_info["servers"].remove_at(get_selected_server())
	update_server_list()
