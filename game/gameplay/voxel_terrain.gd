extends VoxelTerrain


func _exit_tree() -> void:
	if stream:
		save_modified_blocks()
