extends Node

# Signals
signal player_registered(id)
# Local config
var is_singleplayer := true
# Server config distribution
signal client_configured
var server_config := {}
var is_client_configured := false
# Player info
var my_info = {}
var other_players = {}


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func init_server(config: Dictionary) -> void:
	server_config = config
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(config["port"], config["max_players"])
	multiplayer.multiplayer_peer = peer


func init_client(server_idx) -> void:
	var peer = ENetMultiplayerPeer.new()
	var server = Global.multiplayer_info["servers"][server_idx]
	peer.create_client(server["address"], server["port"])
	multiplayer.multiplayer_peer = peer


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
		configure_client.rpc_id(id, {
			"name": server_config["name"],
			"world": server_config["world"]
		})
	if not multiplayer.is_server() or not server_config["dedicated"]:
		register_player.rpc_id(id, multiplayer.get_unique_id(), my_info)


func _on_peer_disconnected(id: int) -> void:
	other_players.erase(id)
