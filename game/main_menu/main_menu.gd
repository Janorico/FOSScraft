extends MarginContainer

const GAMEPLAY_SCENE = preload("res://game/gameplay/gameplay.tscn")
# Singleplayer Menu
@onready var singleplayer_menu = $SingleplayerMenu
@onready var singleplayer_worlds_menu = $SingleplayerMenu/VBoxContainer/WorldsMenu
@onready var singleplayer_no_selection = $SingleplayerMenu/VBoxContainer/WorldsMenu/NoSelectionDialog


func _ready() -> void:
	$InfoContainer/VersionButton.text = "%s v%s-%s" % [ProjectSettings.get_setting("application/config/name"), ProjectSettings.get_setting("application/config/version"), ProjectSettings.get_setting("application/config/version_status")]


func start_gameplay(world) -> void:
	var gameplay_instance = GAMEPLAY_SCENE.instantiate()
	gameplay_instance.world = world
	get_tree().get_root().add_child(gameplay_instance)
	get_tree().current_scene = gameplay_instance
	queue_free()


func _on_rich_text_meta_clicked(meta) -> void:
	OS.shell_open(meta)


func _on_singleplayer_menu_play_button_pressed() -> void:
	if singleplayer_worlds_menu.has_selection():
		singleplayer_menu.hide()
		start_gameplay(singleplayer_worlds_menu.get_selected_world())
	else:
		singleplayer_no_selection.popup_centered()


func _on_host_server_menu_play_button_pressed() -> void:
	pass # Replace with function body.


func _on_join_server_menu_play_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit() -> void:
	get_tree().quit()
