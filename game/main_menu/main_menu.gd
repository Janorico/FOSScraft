extends MarginContainer


func _ready() -> void:
	$InfoContainer/VersionButton.text = "%s v%s-%s" % [ProjectSettings.get_setting("application/config/name"), ProjectSettings.get_setting("application/config/version"), ProjectSettings.get_setting("application/config/version_status")]


func _on_exit() -> void:
	get_tree().quit()
