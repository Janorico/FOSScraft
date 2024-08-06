extends Node3D

@onready var players = $Players
var player: Player
var world = null
var server = null
var pause_menu_open := false:
	set(value):
		pause_menu_open = value
		update_cursor()
var inventory_open := false:
	set(value):
		inventory_open = value
		update_cursor()


func _ready() -> void:
	# Multiplayer
	Net.player_registered.connect(instance_player)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	if Net.is_singleplayer:
		$VoxelTerrain/VoxelTerrainMultiplayerSynchronizer.queue_free()
	# Load player
	if Net.is_singleplayer or not multiplayer.is_server() or not Net.server_config["dedicated"]:
		@warning_ignore("incompatible_ternary")
		player = instance_player(null if Net.is_singleplayer else multiplayer.get_unique_id())
		player.get_node("ReflectionCenter").remote_path = "../../../ReflectionProbe"
	$PauseMenu.export_buffer.connect(_on_export_buffer)
	# Lock cursor
	update_cursor()
	# Wait for config
	if not Net.is_singleplayer and not multiplayer.is_server() and not Net.is_client_configured:
		await Net.client_configured
	# Setup Terrain
	var voxel_terrain: VoxelTerrain = $VoxelTerrain
	# Generator
	var world_info = Global.worlds[world] if world else Net.server_config["world"]
	@warning_ignore("incompatible_ternary")
	var generator
	match world_info["type"] as int:
		Global.TYPE_FLAT:
			generator = TerrainGeneratoFlat.new()
		Global.TYPE_EMPTY:
			generator = TerrainGeneratorEmpty.new()
		_:
			generator = TerrainGeneratorNormal.new()
	generator.terrain_seed = floori(world_info["seed"])
	voxel_terrain.generator = generator
	if world: # Alternate: Net.is_singleplayer or multiplayer.is_server()
		# Stream
		var stream = VoxelStreamSQLite.new()
		stream.database_path = ProjectSettings.globalize_path(world_info["sqlite_path"])
		voxel_terrain.stream = stream
	# Update server name
	if not Net.is_singleplayer and not multiplayer.is_server():
		Global.multiplayer_info["servers"][server]["name"] = Net.server_config["name"]


func update_cursor() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if not pause_menu_open and not inventory_open else Input.MOUSE_MODE_VISIBLE


func instance_player(id) -> Player:
	var player_instance = preload("res://game/gameplay/player/player.tscn").instantiate()
	player_instance.terrain_node = $VoxelTerrain
	players.add_child(player_instance)
	player_instance.position.y = 20
	player_instance.initialize(id)
	return player_instance

func _on_export_buffer(path: String, copyright: String) -> void:
	if player == null or not player.copy_ready:
		return
	$PauseMenu.export_buffer_to_gltf(player.export_buffer, player.terrain_node.mesher, path, copyright)


func _on_player_disconnected(id: int) -> void:
	var p = players.get_node_or_null("Player%d" % id)
	if p:
		p.queue_free()


func _on_server_disconnected() -> void:
	# Load main scene
	var main_menu = load("res://game/main_menu/main_menu.tscn").instantiate()
	get_tree().get_root().add_child(main_menu)
	get_tree().current_scene = main_menu
	# Show dialog
	main_menu.get_node("ServerDisconnectedDialog").popup_centered()
	# Unlock mouse, remove gameplay scene
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	queue_free()
