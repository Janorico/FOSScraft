extends ColorRect

signal save_world
signal export_buffer(path: String, copyright: String)


func _ready() -> void:
	if not multiplayer.is_server():
		$CenterContainer/VBoxContainer/HBoxContainer.hide()


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		visible = not visible
		get_parent().pause_menu_open = visible


func _on_resume_button_pressed() -> void:
	visible = false
	get_parent().pause_menu_open = false


func _on_save_button_pressed() -> void:
	save_world.emit()


func _on_backup_button_pressed() -> void:
	Global.create_backup(get_parent().world)


func _on_confirmation_dialog_confirmed() -> void:
	export_buffer.emit($CenterContainer/VBoxContainer/ExportBufferButton/ConfirmationDialog/GridContainer/DestinationButton/FileDialog.current_path, $CenterContainer/VBoxContainer/ExportBufferButton/ConfirmationDialog/GridContainer/CopyrightLineEdit.text)


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game/main_menu/main_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func export_buffer_to_gltf(buffer: VoxelBuffer, mesher: VoxelMesher, path: String, copyright: String) -> void:
	var gltf = GLTFState.new()
	# Metadata
	gltf.copyright = copyright
	# Generate mesh
	var mesh: Mesh = mesher.build_mesh(buffer, [])
	var i_mesh = ImporterMesh.new()
	for i in mesh.get_surface_count():
		i_mesh.add_surface(Mesh.PRIMITIVE_TRIANGLES, mesh.surface_get_arrays(i), [], {}, mesh.surface_get_material(i))
	var gltf_mesh = GLTFMesh.new()
	gltf_mesh.mesh = i_mesh
	gltf.meshes = [gltf_mesh]
	# Add mesh node
	var mesh_node = GLTFNode.new()
	mesh_node.mesh = 0
	gltf.nodes = [mesh_node]
	gltf.root_nodes = PackedInt32Array([0])
	# Save file
	GLTFDocument.new().write_to_filesystem(gltf, path)
