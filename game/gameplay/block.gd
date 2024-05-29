class_name Block extends Resource


enum {
	ROTATION_TYPE_NONE,
	ROTATION_TYPE_AXES,
	ROTATION_TYPE_AXES_HALF,
	ROTATION_TYPE_VERTICAL,
	ROTATION_TYPE_VERTICAL_HALF
}
@export var base_model: VoxelBlockyModel
@export_enum("None", "Axes", "Axes Half", "Vertical", "Vertical Half") var rotation_type: int
@export var is_cross := false
@export var cross_position := Vector2i.ZERO
@export var cross_material: Material
@export var cross_aabb: Array[AABB] = [AABB(Vector3(0.15, 0, 0.15), Vector3(0.7, 0.69, 0.7))]
@export_flags_3d_physics var cross_collision_mask := 4
@export var has_stairs := false
@export var has_slabs := false
