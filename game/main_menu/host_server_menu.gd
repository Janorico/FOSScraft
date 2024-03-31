extends "res://game/main_menu/sub_menu.gd"


enum {
	CURRENT_ACTION_ADD = 0,
	CURRENT_ACTION_EDIT = 1
}
var current_action = CURRENT_ACTION_ADD
@onready var config_option_button = $VBoxContainer/ConfigContainer/ConfigOptionButton
# Config dialog
@onready var edit_server_config_dialog = $VBoxContainer/EditServerConfigDialog
@onready var name_line_edit = $VBoxContainer/EditServerConfigDialog/Container/NameLineEdit
@onready var port_spin_box = $VBoxContainer/EditServerConfigDialog/Container/PortSpinBox
@onready var max_players_spin_box = $VBoxContainer/EditServerConfigDialog/Container/MaxPlayersSpinBox
@onready var dedicated_check_button = $VBoxContainer/EditServerConfigDialog/Container/DedicatedCheckButton
@onready var upnp_check_button = $VBoxContainer/EditServerConfigDialog/Container/UPnPCheckButton
@onready var upnp_port_spin_box = $VBoxContainer/EditServerConfigDialog/Container/UPnPPortSpinBox


func _ready() -> void:
	update_config_list()


func update_config_list() -> void:
	config_option_button.clear()
	for i in Global.multiplayer_info["server_configs"]:
		config_option_button.add_item(i["name"])


func has_selected_cofig() -> bool:
	return config_option_button.selected != -1


func get_selected_config() -> Dictionary:
	return Global.multiplayer_info["server_configs"][config_option_button.selected]


func _on_add_button_pressed() -> void:
	current_action = CURRENT_ACTION_ADD
	name_line_edit.text = ""
	port_spin_box.value = 6767
	max_players_spin_box.value = 100
	dedicated_check_button.button_pressed = false
	upnp_check_button.button_pressed = true
	upnp_port_spin_box.value = 6767
	edit_server_config_dialog.popup_centered()


func _on_edit_button_pressed() -> void:
	current_action = CURRENT_ACTION_EDIT
	var server_configs = Global.multiplayer_info["server_configs"]
	name_line_edit.text = server_configs[config_option_button.selected]["name"]
	port_spin_box.value = server_configs[config_option_button.selected]["port"]
	max_players_spin_box.value = server_configs[config_option_button.selected]["max_players"]
	dedicated_check_button.button_pressed = server_configs[config_option_button.selected]["dedicated"]
	upnp_check_button.button_pressed = server_configs[config_option_button.selected]["upnp_enabled"]
	upnp_port_spin_box.value = server_configs[config_option_button.selected]["upnp_port"]
	edit_server_config_dialog.popup_centered()


func _on_edit_server_config_dialog_confirmed() -> void:
	var config = {
		"name": name_line_edit.text,
		"port": port_spin_box.value,
		"max_players": max_players_spin_box.value,
		"dedicated": dedicated_check_button.button_pressed,
		"upnp_enabled": upnp_check_button.button_pressed,
		"upnp_port": upnp_port_spin_box.value,
	}
	if current_action == CURRENT_ACTION_ADD:
		Global.multiplayer_info["server_configs"].append(config)
	elif current_action == CURRENT_ACTION_EDIT:
		Global.multiplayer_info["server_configs"][config_option_button.selected] = config
	update_config_list()


func _on_delete_config_dialog_confirmed() -> void:
	Global.multiplayer_info["server_configs"].remove_at(config_option_button.selected)
	update_config_list()
