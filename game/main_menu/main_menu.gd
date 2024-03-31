extends MarginContainer

const GAMEPLAY_SCENE = preload("res://game/gameplay/gameplay.tscn")
# Singleplayer menu
@onready var singleplayer_menu = $SingleplayerMenu
@onready var singleplayer_worlds_menu = $SingleplayerMenu/VBoxContainer/WorldsMenu
@onready var singleplayer_no_selection = $SingleplayerMenu/VBoxContainer/WorldsMenu/NoSelectionDialog
# Host server menu
@onready var host_server_menu = $HostServerMenu
@onready var host_server_no_config_selected = $HostServerMenu/VBoxContainer/NoConfigSelectedDialog
@onready var host_server_worlds_menu = $HostServerMenu/VBoxContainer/WorldsMenu
@onready var host_server_no_selection = $HostServerMenu/VBoxContainer/WorldsMenu/NoSelectionDialog
# Join server menu
@onready var join_server_menu = $JoinServerMenu


func _ready() -> void:
	$InfoContainer/VersionButton.text = "%s v%s-%s" % [ProjectSettings.get_setting("application/config/name"), ProjectSettings.get_setting("application/config/version"), ProjectSettings.get_setting("application/config/version_status")]
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)


func start_gameplay(world, server = null) -> void:
	var gameplay_instance = GAMEPLAY_SCENE.instantiate()
	gameplay_instance.world = world
	gameplay_instance.server = server
	get_tree().get_root().add_child(gameplay_instance)
	get_tree().current_scene = gameplay_instance
	queue_free()


func _on_rich_text_meta_clicked(meta) -> void:
	OS.shell_open(meta)


func _on_singleplayer_menu_play_button_pressed() -> void:
	if singleplayer_worlds_menu.has_selection():
		singleplayer_menu.hide()
		Net.is_singleplayer = true
		start_gameplay(singleplayer_worlds_menu.get_selected_world())
	else:
		singleplayer_no_selection.popup_centered()


func _on_host_server_menu_play_button_pressed() -> void:
	if not host_server_menu.has_selected_cofig():
		host_server_no_config_selected.popup_centered()
	elif host_server_worlds_menu.has_selection():
		host_server_menu.hide()
		Net.is_singleplayer = false
		var world = host_server_worlds_menu.get_selected_world()
		var config = host_server_menu.get_selected_config()
		var cworld = Global.worlds[world].duplicate()
		cworld.erase("sqlite_path")
		config["world"] = cworld
		Net.init_server(config)
		start_gameplay(world)
	else:
		host_server_no_selection.popup_centered()


func _on_join_server_menu_play_button_pressed() -> void:
	if not join_server_menu.server_list.is_anything_selected():
		join_server_menu.no_selection_dialog.popup_centered()
	else:
		join_server_menu.hide()
		$ConnectingMessage.show()
		Net.init_client(join_server_menu.get_selected_server())


func _connected_to_server() -> void:
	Net.is_singleplayer = false
	start_gameplay(null, join_server_menu.get_selected_server())


func _connection_failed() -> void:
	$ConnectingMessage.hide()
	$ConnectionFailedDialog.popup_centered()


func _on_exit() -> void:
	get_tree().quit()
