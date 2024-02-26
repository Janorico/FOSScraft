extends CharacterBody3D


@export_category("Entity chracteristics")
@export var base_speed = 4.0
@export var base_jump_power = 5.0
@export_category("Visual")
@export var fov := 75
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export_category("External Nodes")
@export var terrain_node: VoxelTerrain
@export var faced_block_visual: Node3D
@export_category("Collision")
@export var collision_aabb: AABB
var mover = VoxelBoxMover.new()
@onready var head = $Head
@onready var camera = $Head/FPPerspective
@onready var vt = terrain_node.get_voxel_tool()
var flying := false
var grounded := true
var prev_veloctiy = Vector3.ZERO


func _ready() -> void:
	# Set up mover
	mover.set_collision_mask(collision_mask)
	mover.set_step_climbing_enabled(true)
	mover.set_max_step_height(0.5)


func _physics_process(delta: float) -> void:
	# Grounded
	var limit = -gravity * delta
	if prev_veloctiy.y < limit and velocity.y >= limit:
		print("Hit ground with ", prev_veloctiy.y, "m/s!")
		if abs(prev_veloctiy.y) > 3.5:
			print("Ouch, damage!")
		grounded = true
	# Don't launch from stairs.
	if mover.has_stepped_up():
		velocity.y = 0.0
	# Y axis movement
	if flying:
		velocity.y = lerp(velocity.y, Input.get_axis("crouch", "jump") * base_jump_power, delta)
	elif not is_on_floor() or not grounded:
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("jump") and (is_on_floor() or grounded):
		velocity.y = base_jump_power
		grounded = false
	
	# Y plane movement
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var speed = base_speed + (base_speed * (Input.get_action_strength("sprint") * 1.2))
	# Sprint effect
	camera.fov = move_toward(camera.fov, fov + Input.get_action_strength("sprint") * 5, delta * 50)
	# Calculate veloctiy
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	# Save velocity
	prev_veloctiy = velocity
	# Voxel collision
	velocity = mover.get_motion(position, velocity * delta, collision_aabb, terrain_node) / delta
	# Godot collision/Apply velocity
	move_and_slide()
	# Interaction
	block_interaction()


@rpc("any_peer", "call_local")
func take_damage(damage: float) -> void:
	print("Received ", damage, " damage.")


func block_interaction() -> void:
	var faced_block = vt.raycast(camera.global_position, -camera.global_basis.z, 5.0)
	faced_block_visual.visible = faced_block != null
	if faced_block:
		faced_block_visual.position = Vector3(faced_block.position) + Vector3(0.5, 0.5, 0.5)
		if Input.is_action_just_pressed("destroy_block"):
			vt.set_voxel(faced_block.position, 0)
		elif Input.is_action_just_pressed("place_block"):
			vt.set_voxel(faced_block.previous_position, 21)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.15
		head.rotation_degrees.x = clamp(head.rotation_degrees.x - event.relative.y * 0.15, -90, 90)
