extends Node

# Signals
signal player_registered(id)
# Server config distribution
signal client_configured
var server_config
var is_client_configured := false
# Player info
var my_info = {}
var other_players = {}


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


@rpc("authority", "call_remote")
func configure_client(config: Dictionary) -> void:
	server_config = config
	is_client_configured = true
	client_configured.emit()


@rpc("any_peer", "call_remote")
func register_player(id: int, info: Dictionary) -> void:
	other_players[id] = info
	player_registered.emit(id)


func _on_peer_connected(id: int) -> void:
	if multiplayer.is_server():
		configure_client.rpc_id(id, server_config)
	if not multiplayer.is_server() or not server_config["dedicated"]:
		register_player.rpc_id(id, my_info)


func _on_peer_disconnected(id: int) -> void:
	other_players.erase(id)
