extends PanelContainer

signal play_button_pressed


func _on_play_button_pressed() -> void:
	play_button_pressed.emit()
