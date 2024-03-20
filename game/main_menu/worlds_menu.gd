extends Control

# Worlds list
@onready var worlds_list = $ScrollContainer/WorldsList
# No selection dialog
@onready var no_selection_dialog = $NoSelectionDialog
# New world dialog
@onready var new_world_name = $NewWorldDialog/Container/NameLineEdit
@onready var new_world_mode = $NewWorldDialog/Container/ModeOptionButton
@onready var new_world_seed = $NewWorldDialog/Container/SeedSpinBox
@onready var new_world_type = $NewWorldDialog/Container/TypeOptionButton
# Rename world dialog
@onready var rename_world_dialog = $RenameWorldDialog
@onready var old_name_line_edit = $RenameWorldDialog/GridContainer/OldNameLineEdit
@onready var new_name_line_edit = $RenameWorldDialog/GridContainer/NewNameLineEdit
# Delete world dialog
@onready var delete_world_dialog = $DeleteWorldDialog


func _ready() -> void:
	reload_worlds_list()


func reload_worlds_list() -> void:
	worlds_list.clear()
	for i in Global.worlds.values():
		worlds_list.add_item(i["name"])


func has_selection() -> bool:
	return worlds_list.get_selected_items().size() > 0


func get_selected_world() -> String:
	return Global.worlds.keys()[worlds_list.get_selected_items()[0]]


func _on_new_world_dialog_confirmed() -> void:
	Global.create_world(new_world_name.text, new_world_mode.selected, new_world_seed.value, new_world_type.selected)
	reload_worlds_list()


func _on_rename_button_pressed() -> void:
	if has_selection():
		old_name_line_edit.text = Global.worlds[get_selected_world()]["name"]
		new_name_line_edit.text = ""
		rename_world_dialog.popup_centered()
	else:
		no_selection_dialog.popup_centered()


func _on_rename_world_dialog_confirmed() -> void:
	Global.rename_world(get_selected_world(), new_name_line_edit.text)
	reload_worlds_list()


func _on_delete_button_pressed() -> void:
	if has_selection():
		delete_world_dialog.dialog_text = """Do you really want to delete "%s"?

IMPORTANT: This is intended to move
the world to the OS trash, if enabled,
IT MIGHT BE IMPOSSIBLE TO UNDO THIS!""" % Global.worlds[get_selected_world()]["name"]
		delete_world_dialog.popup_centered()
	else:
		no_selection_dialog.popup_centered()


func _on_delete_world_dialog_confirmed() -> void:
	Global.delete_world(get_selected_world())
	reload_worlds_list()
