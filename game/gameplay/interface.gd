extends Control

@onready var coordinates_label = $Coordinates/Label
@onready var fps_counter_label = $FPSCounter/Label


func _physics_process(delta: float) -> void:
	var player = get_parent().player
	if not player:
		return
	coordinates_label.text = "Position: %s" % player.position
	fps_counter_label.text = str(Engine.get_frames_per_second(), " FPS")
