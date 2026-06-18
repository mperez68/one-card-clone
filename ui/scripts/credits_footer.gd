@tool
class_name GodotVersionLabel extends Label

const PREFIX: String = "Made in Godot"


# ENGINE
func _ready():
	_update_text()


# PUBLIC


# PRIVATE
func _update_text():
	var major = Engine.get_version_info()["major"]
	var minor = Engine.get_version_info()["minor"]
	var patch = Engine.get_version_info()["patch"]
	var status = Engine.get_version_info()["status"]

	text = str("%s %s.%s.%s.%s" % [PREFIX, major, minor, patch, status])



# SIGNALS
