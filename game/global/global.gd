extends Node

enum {
	TYPE_NORMAL = 0,
	TYPE_FLAT = 1
}
const WORLDS_DIR = "user://worlds"
const MULTIPLAYER_INFO_FILE = "user://multiplayer.json"
var worlds: Dictionary = {}
var multiplayer_info = {
	"server_configs": [],
	"servers": []
}


func _ready() -> void:
	if not DirAccess.dir_exists_absolute(WORLDS_DIR):
		DirAccess.make_dir_absolute(WORLDS_DIR)
	var world_files := PackedStringArray()
	var dir = DirAccess.open(WORLDS_DIR)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = "%s/%s/info.json" % [dir.get_current_dir(), file_name]
		if FileAccess.file_exists(file_path):
			world_files.append(file_path)
		file_name = dir.get_next()
	for i in world_files:
		if not FileAccess.file_exists(i):
			continue
		var world_file = FileAccess.open(i, FileAccess.READ)
		var json = JSON.parse_string(world_file.get_line())
		world_file.close()
		if not (json is Dictionary and json.has("name") and json.has("mode") and json.has("seed") and json.has("type") and json.has("sqlite_path")):
			continue
		worlds[i] = json
	# Mutliplayer info
	if not FileAccess.file_exists(MULTIPLAYER_INFO_FILE):
		return
	var file = FileAccess.open(MULTIPLAYER_INFO_FILE, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text(true))
	file.close()
	if json is Dictionary:
		multiplayer_info = json


func _exit_tree() -> void:
	var file = FileAccess.open(MULTIPLAYER_INFO_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(multiplayer_info))
	file.close()


func save_world_info(world: String) -> void:
	if not worlds.has(world):
		return
	var file = FileAccess.open(world, FileAccess.WRITE)
	file.store_string(JSON.stringify(worlds[world]))
	file.close()


func create_world(world_name: String, mode: int, world_seed: int, type: int) -> void:
	var world_folder = "%s/%s" % [WORLDS_DIR, world_name.to_snake_case()]
	DirAccess.make_dir_absolute(world_folder)
	var world = "%s/info.json" % world_folder
	worlds[world] = {
		"name": world_name,
		"mode": mode,
		"seed": world_seed,
		"type": type,
		"sqlite_path": "%s/chunks.sqlite" % world_folder
	}
	save_world_info(world)


func rename_world(world: String, new_name: String) -> void:
	if not worlds.has(world):
		return
	worlds[world]["name"] = new_name
	save_world_info(world)


func delete_world(world: String) -> void:
	OS.move_to_trash(world)


func create_backup(world: String) -> void:
	pass # TODO Make backup
