extends Control

@onready var position_out = $Coordinates/Container/PositionOut
@onready var block_out = $Coordinates/Container/BlockOut
@onready var fps_counter_label = $FPSCounter/Label


func _physics_process(_delta: float) -> void:
	var player = get_parent().player
	if not player:
		return
	position_out.text = str(player.position)
	block_out.text = str(player.facing_block) if player.facing_block != null else "(-, -, -)"
	fps_counter_label.text = str(Engine.get_frames_per_second(), " FPS")
