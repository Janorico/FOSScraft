extends Node3D

var world = null
var pause_menu_open := false:
	set(value):
		pause_menu_open = value
		update_cursor()
var inventory_open := false:
	set(value):
		inventory_open = value
		update_cursor()


func _ready() -> void:
	# Setup Terrain
	var terrain = $VoxelTerrain
	var world_info = Net.server_config if world == null else Global.worlds[world]
	var generator = TerrainGeneratorNormal.new() if world_info["type"] == Global.TYPE_NORMAL else TerrainGeneratoFlat.new()
	generator.terrain_seed = floori(world_info["seed"])
	terrain.generator = generator
	if world:
		var stream = VoxelStreamSQLite.new()
		stream.database_path = ProjectSettings.globalize_path(world_info["sqlite_path"])
		terrain.stream = stream
	# Lock cursor
	update_cursor()


func update_cursor() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if not pause_menu_open and not inventory_open else Input.MOUSE_MODE_VISIBLE
