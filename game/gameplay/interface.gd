extends Control

@onready var coordinates_label = $Coordinates/Label
@onready var fps_counter_label = $FPSCounter/Label
@onready var player = get_node("../Player")


func _physics_process(delta: float) -> void:
	coordinates_label.text = "Position: %s" % player.position
	fps_counter_label.text = str(Engine.get_frames_per_second(), " FPS")
