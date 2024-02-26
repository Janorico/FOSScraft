extends RichTextLabel


func _ready() -> void:
	text = """[b]FOSScraft v{version}-{status}[/b]
Godot {godot_version}
Architecture: {architecture}""".format({
		"version": ProjectSettings.get_setting("application/config/version"),
		"status": ProjectSettings.get_setting("application/config/version_status"),
		"godot_version": Engine.get_version_info()["string"],
		"architecture": Engine.get_architecture_name()
	})
