class_name TerrainGeneratorNormal extends VoxelGeneratorScript

@export var terrain_height := 20
@export var noise: Noise = FastNoiseLite.new()
@export var ore_noise = ZN_FastNoiseLite.new()


func _init() -> void:
	ore_noise.period = 8


func _generate_block(out_buffer: VoxelBuffer, origin_in_voxels: Vector3i, _lod: int) -> void:
	for x in out_buffer.get_size().x:
		var global_x = x + origin_in_voxels.x
		for z in out_buffer.get_size().z:
			var global_z = z + origin_in_voxels.z
			# Get terrain height
			var surface_y = floor(((noise.get_noise_2d(global_x, global_z) + 1) / 2) * terrain_height)
			for y in out_buffer.get_size().y:
				var global_y = y + origin_in_voxels.y
				if global_y > surface_y:
					out_buffer.set_voxel(0, x, y, z)
				elif global_y == surface_y:
					out_buffer.set_voxel(1, x, y, z)
				elif global_y > surface_y - 20:
					out_buffer.set_voxel(4, x, y, z)
				else:
					out_buffer.set_voxel(5, x, y, z)
				if global_y < surface_y - 50:
					ore_generation(x, y, z, global_x, global_y, global_z, out_buffer)
	out_buffer.compress_uniform_channels()


func _get_used_channels_mask() -> int:
	return 1 << VoxelBuffer.CHANNEL_TYPE


## ORE GENERATION
func ore_generation(x: int, y: int, z: int, vx: int, vy: int, vz: int, out_buffer: VoxelBuffer) -> void:
	var noise_result = (ore_noise.get_noise_3d(vx, vy, vz) + 1) / 2
	if noise_result < 0.15:
		out_buffer.set_voxel(13, x, y, z)
	if noise_result > 0.85:
		out_buffer.set_voxel(14, x, y, z)


class Biome extends Resource:
	@export var terrain_height := 20
