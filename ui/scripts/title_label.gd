@tool
class_name TitleLabel extends Label


# ENGINE
func _ready():
	text = ProjectSettings.get_setting("application/config/name").replace(" ", "\n")


# PUBLIC


# PRIVATE


# SIGNALS
