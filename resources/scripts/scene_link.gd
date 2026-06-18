@abstract
class_name SceneLink extends Resource

@export var button_text: String
var scene: PackedScene:
	get():
		if !scene:
			scene = _get_scene()
		return scene

@abstract
func _get_scene() -> PackedScene
