class_name TerrainGeneratorNormal extends FOSScraftGenerator

@export var terrain_height := 20
# Noises
var noise := FastNoiseLite.new()
var ore_noise := ZN_FastNoiseLite.new()

var setup_done := false


func _generate_block(out_buffer: VoxelBuffer, origin_in_voxels: Vector3i, _lod: int) -> void:
	if not setup_done:
		# Apply seed
		noise.seed = terrain_seed
		ore_noise.seed = terrain_seed
		# Conigure noises
		ore_noise.period = 8
		# Don't run this again
		setup_done = true
	# Setup random number generator
	var rng = RandomNumberGenerator.new()
	rng.seed = origin_in_voxels.x * terrain_seed + origin_in_voxels.z
	for x in out_buffer.get_size().x:
		var global_x = x + origin_in_voxels.x
		for z in out_buffer.get_size().z:
			var global_z = z + origin_in_voxels.z
			# Get terrain height
			var surface_y = floor(((noise.get_noise_2d(global_x, global_z) + 1) / 2) * terrain_height)
			for y in out_buffer.get_size().y:
				var global_y = y + origin_in_voxels.y
				# Basic Terrain
				if global_y > surface_y:
					out_buffer.set_voxel(0, x, y, z)
				elif global_y == surface_y:
					out_buffer.set_voxel(1, x, y, z)
				elif global_y > surface_y - 20:
					out_buffer.set_voxel(4, x, y, z)
				else:
					out_buffer.set_voxel(5, x, y, z)
				# Ore generation
				if global_y < surface_y - 50:
					ore_generation(x, y, z, global_x, global_y, global_z, out_buffer)
				# Flowers and grass
				if global_y == surface_y + 1:
					var number = rng.randf()
					if number < 0.05:
						out_buffer.set_voxel(rng.randi_range(9, 12), x, y, z)
					elif number < 0.2:
						out_buffer.set_voxel(7, x, y, z)
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
