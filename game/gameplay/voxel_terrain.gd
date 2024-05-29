extends VoxelTerrain

const STAIR_MESH = preload("res://assets/3d/blocks/stairs.obj")
const SLAB_MESH = preload("res://assets/3d/blocks/slab.obj")
const SLAB_TOP_MESH = preload("res://assets/3d/blocks/slab_top.obj")
const CROSS_MESH = preload("res://assets/3d/blocks/cross.obj")
@export var fosscraft_block_library: FOSScraftBlockLibrary
@export var block_atlas_size := Vector2i.ONE
#@export var compile := false:
#	set(value):
#		compile = false
#		if value:
#			compile_library()


func _ready() -> void:
	compile_library()


func compile_library() -> void:
	print("Compiling library...")
	var library = VoxelBlockyLibrary.new()
	for block in fosscraft_block_library.blocks:
		if block.is_cross: # Stuff like flowers and grass (NOT the block)
			block.base_model = VoxelBlockyModelMesh.new()
			block.base_model.mesh = offset_mesh_uv(CROSS_MESH, block.cross_position)
			block.base_model.set_material_override(0, block.cross_material)
			block.base_model.collision_aabbs = block.cross_aabb
			block.base_model.collision_mask = block.cross_collision_mask
		print("Adding base model...")
		block.base_model.resource_name = block.resource_name # Stop blocks being called "BLOCKModel" (Comes from automatic conversion, to lazy to remove + is less confusing in Inspector)
		library.add_model(block.base_model) # Add original block
		print("Creating rotated variants...")
		for b in hardcode_rotation_types(block.rotation_type, block.base_model): # Create and add all the rotated versions
			print("Added rotated variant...")
			library.add_model(b)
		if not block.base_model is VoxelBlockyModelCube: # Don't try to create stairs/slabs from a mesh.
			continue
		print("Add stairs/slabs...")
		if block.has_stairs:
			var stair_model = VoxelBlockyModelMesh.new()
			stair_model.mesh = offset_mesh_uv(STAIR_MESH, block.base_model.get_tile(VoxelBlockyModel.SIDE_NEGATIVE_Z))
			stair_model.set_material_override(0, block.base_model.get_material_override(0))
			stair_model.collision_aabbs = [AABB(Vector3.ZERO, Vector3(1, 0.5, 1)), AABB(Vector3(0, 0.5, 0), Vector3(1, 0.5, 0.5))]
			stair_model.resource_name = block.resource_name + " Stairs"
			library.add_model(stair_model)
			for b in hardcode_rotation_types(Block.ROTATION_TYPE_VERTICAL, stair_model):
				library.add_model(b)
			var upside_down_stair_model = create_rotated_model(stair_model, "down", Vector3i.AXIS_Z, false, 2)
			library.add_model(upside_down_stair_model)
			for b in hardcode_rotation_types(Block.ROTATION_TYPE_VERTICAL, upside_down_stair_model):
				library.add_model(b)
		if block.has_slabs:
			var slab_model = VoxelBlockyModelMesh.new()
			slab_model.mesh = offset_mesh_uv(SLAB_MESH, block.base_model.get_tile(VoxelBlockyModel.SIDE_NEGATIVE_Z))
			slab_model.set_material_override(0, block.base_model.get_material_override(0))
			slab_model.collision_aabbs = [AABB(Vector3.ZERO, Vector3(1, 0.5, 1))]
			slab_model.resource_name = block.resource_name + " Slab"
			library.add_model(slab_model)
			var slab_top = slab_model.duplicate()
			slab_top.mesh = offset_mesh_uv(SLAB_TOP_MESH, block.base_model.get_tile(VoxelBlockyModel.SIDE_NEGATIVE_Z))
			slab_top.resource_name += "_top"
			library.add_model(slab_top)
	print("Baking library...")
	library.bake()
	print("Setting library...")
	mesher.library = library
	print("Done!")


func hardcode_rotation_types(rotation_type: int, base_model: VoxelBlockyModel) -> Array:
	# Create array
	var blocks: Array = []
	# AXES rotation type
	if rotation_type == Block.ROTATION_TYPE_AXES_HALF or rotation_type == Block.ROTATION_TYPE_AXES:
		blocks.append(create_rotated_model(base_model, "z", Vector3i.AXIS_X)) # Original is y, so no need for that.
		blocks.append(create_rotated_model(base_model, "x", Vector3i.AXIS_Z))
	if rotation_type == Block.ROTATION_TYPE_AXES:
		blocks.append(create_rotated_model(base_model, "oz", Vector3i.AXIS_X, false))
		blocks.append(create_rotated_model(base_model, "ox", Vector3i.AXIS_Z, false))
		blocks.append(create_rotated_model(base_model, "oy", Vector3i.AXIS_Z, false, 2))
	# VERTICAL rotation type
	if rotation_type == Block.ROTATION_TYPE_VERTICAL_HALF or rotation_type == Block.ROTATION_TYPE_VERTICAL:
		blocks.append(create_rotated_model(base_model, "x", Vector3i.AXIS_Y)) # Original is z, so no need for that.
	# Retun array
	if rotation_type == Block.ROTATION_TYPE_VERTICAL:
		blocks.append(create_rotated_model(base_model, "ox", Vector3i.AXIS_Y, false))
		blocks.append(create_rotated_model(base_model, "oz", Vector3i.AXIS_Y, true, 2))
	# Retun array
	return blocks


func  create_rotated_model(model: VoxelBlockyModel, suffix: String, axis: int, clockwise := true, times = 1) -> VoxelBlockyModel:
	var rmodel = model.duplicate()
	rmodel.resource_name += "_" + suffix
	for i in times:
		rmodel.rotate_90(axis, clockwise)
	return rmodel


func offset_mesh_uv(mesh: ArrayMesh, offset: Vector2) -> ArrayMesh:
	# Input
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	# Processing
	for i in mdt.get_vertex_count():
		var vertex_uv = mdt.get_vertex_uv(i)
		vertex_uv += (Vector2.ONE / Vector2(block_atlas_size)) * offset
		mdt.set_vertex_uv(i, vertex_uv)
	# Output
	var out_mesh = ArrayMesh.new()
	mdt.commit_to_surface(out_mesh)
	return out_mesh


func _exit_tree() -> void:
	if stream:
		save_modified_blocks()
