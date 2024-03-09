extends VoxelTerrain


func _exit_tree() -> void:
	save_modified_blocks()
