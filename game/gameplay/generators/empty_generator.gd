class_name  TerrainGeneratorEmpty extends FOSScraftGenerator


func _generate_block(out_buffer: VoxelBuffer, origin_in_voxels: Vector3i, _lod: int) -> void:
	out_buffer.fill(0)
	if origin_in_voxels == Vector3i.ZERO:
		out_buffer.set_voxel(1, 0, 0, 0)
