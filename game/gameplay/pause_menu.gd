extends ColorRect


signal save_world


func _ready() -> void:
	if not multiplayer.is_server():
		$CenterContainer/VBoxContainer/HBoxContainer.hide()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		visible = not visible
		get_parent().pause_menu_open = visible


func _on_resume_button_pressed() -> void:
	visible = false
	get_parent().pause_menu_open = false


func _on_save_button_pressed() -> void:
	save_world.emit()


func _on_backup_button_pressed() -> void:
	Global.create_backup(get_parent().world)


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game/main_menu/main_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
