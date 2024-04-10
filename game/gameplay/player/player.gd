class_name Player extends CharacterBody3D


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
@onready var block_label = $SelectedBlock/BlockLabel
@onready var blocks = terrain_node.mesher.library.models
var selected_block := 18
@onready var head = $Head
@onready var camera = $Head/FPPerspective
@onready var collision_shape = $CollisionShape3D
@onready var vt = terrain_node.get_voxel_tool()
var flying := false
var grounded := true
var prev_veloctiy = Vector3.ZERO
var last_jump_time := 0.0
var crouching := false
var fill_pos = null
var erase_pos = null


func _ready() -> void:
	vt.mode = VoxelTool.MODE_SET


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
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
		# Interaction
		block_interaction()
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


func initialize(id) -> void:
	if id:
		name = "Player%d" % id
		set_multiplayer_authority(id)
		# Setup viewer
		if multiplayer.is_server():
			var viewer: VoxelViewer = $VoxelViewer
			viewer.set_network_peer_id(id)
			if not is_multiplayer_authority():
				viewer.requires_visuals = false
			viewer.requires_data_block_notifications = true
		elif not is_multiplayer_authority():
			$VoxelViewer.queue_free()
	else:
		$MultiplayerSynchronizer.queue_free()
	if id and not is_multiplayer_authority():
		$SelectedBlock.queue_free()
		camera.queue_free()
		$Head/Authorithy.queue_free()
	if not id or is_multiplayer_authority():
		update_block_label()
		# Set up mover
		mover.set_collision_mask(collision_mask)
		mover.set_step_climbing_enabled(true)
		mover.set_max_step_height(0.5)


@rpc("any_peer", "call_local")
func take_damage(damage: float) -> void:
	print("Received ", damage, " damage.")


func block_interaction() -> void:
	var faced_block = vt.raycast(camera.global_position, -camera.global_basis.z, 5.0)
	faced_block_visual.visible = faced_block != null
	if faced_block:
		var fill = Input.is_action_pressed("fill")
		faced_block_visual.position = Vector3(faced_block.position) + Vector3(0.5, 0.5, 0.5)
		if Input.is_action_just_pressed("destroy_block"):
			if multiplayer.is_server():
				break_block(faced_block.position, fill)
			else:
				break_block.rpc_id(1, faced_block.position, fill)
		elif Input.is_action_just_pressed("place_block"):
			if vt.get_voxel(faced_block.position) == 20:
				if multiplayer.is_server():
					explode_sphere(faced_block.position, 5)
				else:
					explode_sphere.rpc_id(1, faced_block.position, 5)
			else:
				if multiplayer.is_server():
					place_block(faced_block.previous_position, selected_block, fill)
				else:
					place_block.rpc_id(1, faced_block.previous_position, selected_block, fill)
		elif Input.is_action_pressed("pick_block"):
			selected_block = vt.get_voxel(faced_block.position)
			update_block_label()


func update_block_label() -> void:
	block_label.text = blocks[selected_block].resource_name


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.15
		head.rotation_degrees.x = clamp(head.rotation_degrees.x - event.relative.y * 0.15, -90, 90)
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			selected_block -= 1
			if selected_block == 0:
				selected_block = blocks.size() - 1
			update_block_label()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			selected_block += 1
			if selected_block == blocks.size():
				selected_block = 1
			update_block_label()


@rpc("call_remote", "any_peer")
func break_block(pos: Vector3i, fill: bool) -> void:
	if fill:
		erase_pos = pos
	elif erase_pos != null:
		vt.value = 0
		vt.do_box(erase_pos, pos)
		erase_pos = null
	else:
		vt.set_voxel(pos, 0)


@rpc("call_remote", "any_peer")
func place_block(pos: Vector3i, block: int, fill: bool) -> void:
	if fill:
		fill_pos = pos
	elif fill_pos != null:
		vt.value = selected_block
		vt.do_box(fill_pos, pos)
		fill_pos = null
	else:
		vt.set_voxel(pos, block)


@rpc("call_remote", "any_peer")
func explode_sphere(pos: Vector3i, radius: int) -> void:
	vt.mode = VoxelTool.MODE_SET
	vt.value = 0
	vt.do_sphere(pos, radius)
