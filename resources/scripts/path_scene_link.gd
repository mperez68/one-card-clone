class_name PathSceneLink extends SceneLink

@export var location_override: String

func _get_scene() -> PackedScene:
	return load(location_override)
