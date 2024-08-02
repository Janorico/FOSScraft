class_name TerrainGeneratoFlat extends FOSScraftGenerator

func _generate_block(out_buffer: VoxelBuffer, origin_in_voxels: Vector3i, _lod: int) -> void:
	out_buffer.fill(0)
	if origin_in_voxels.y != 0:
		return
	for x in out_buffer.get_size().x:
		for z in out_buffer.get_size().z:
			out_buffer.set_voxel(7, x, 0, z)
			out_buffer.set_voxel(4, x, 1, z)
			out_buffer.set_voxel(1, x, 2, z)


func _get_used_channels_mask() -> int:
	return 1 << VoxelBuffer.CHANNEL_TYPE
