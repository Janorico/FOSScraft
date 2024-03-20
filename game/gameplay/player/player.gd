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
@onready var collision_shape = $CollisionShape3D
@onready var vt = terrain_node.get_voxel_tool()
var flying := false
var grounded := true
var prev_veloctiy = Vector3.ZERO
var last_jump_time := 0.0
var crouching := false


func _ready() -> void:
	# Set up mover
	mover.set_collision_mask(collision_mask)
	mover.set_step_climbing_enabled(true)
	mover.set_max_step_height(0.5)


func _physics_process(delta: float) -> void:
	var jump_input := false
	var fly_input := 0.0
	var input_dir := Vector2.ZERO
	var prev_crouching = crouching
	var sprint_input := 0.0
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		jump_input = Input.is_action_just_pressed("jump")
		fly_input = Input.get_axis("crouch", "jump")
		input_dir = Input.get_vector("left", "right", "forward", "backward")
		crouching = Input.is_action_pressed("crouch")
		sprint_input = Input.get_action_strength("sprint")
	# Fly toggle
	if jump_input:
		if last_jump_time < 0.2:
			flying = not flying
		last_jump_time = 0
	else:
		last_jump_time += delta
	# Grounded
	var limit = -gravity * delta
	if prev_veloctiy.y < limit and velocity.y >= limit:
		# TODO Calculate and take damage
		grounded = true
	# Don't launch from stairs.
	if mover.has_stepped_up():
		velocity.y = 0.0
	# Y axis movement
	if flying:
		velocity.y = lerp(velocity.y, fly_input * base_jump_power, delta * 5)
	elif not is_on_floor() or not grounded:
		velocity.y -= gravity * delta
	if jump_input and (is_on_floor() or grounded):
		velocity.y = base_jump_power
		grounded = false
	
	# Y plane movement
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if prev_crouching != crouching:
		if crouching:
			head.position.y = 0.35
			collision_aabb.size.y = 1.5
			collision_shape.position.y = -0.15
			collision_shape.shape.size.y = 1.5
		else:
			head.position.y = 0.65
			collision_aabb.size.y = 1.8
			collision_shape.position.y = 0
			collision_shape.shape.size.y = 1.8
	var speed = base_speed + ((base_speed * -0.7) if crouching else (base_speed * (sprint_input * 0.3)))
	# Sprint effect
	camera.fov = move_toward(camera.fov, fov + sprint_input * 2.5, delta * 25)
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
			vt.set_voxel(faced_block.previous_position, 18)


func _input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.15
		head.rotation_degrees.x = clamp(head.rotation_degrees.x - event.relative.y * 0.15, -90, 90)
