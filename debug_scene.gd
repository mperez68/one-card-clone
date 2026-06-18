class_name DebugScene extends Node2D

@onready var bound_camera: BoundCamera = %BoundCamera
@onready var sprite_2d: Sprite2D = %Sprite2D

# ENGINE
func _ready():
	MusicManager.stop()
	bound_camera.set_limits(Rect2(-1024, -768, 1024, 768))


# PUBLIC


# PRIVATE


# SIGNALS
func _on_center_button_toggled(toggled_on: bool) -> void:
	bound_camera.focus_target = sprite_2d if toggled_on else null

func _on_lock_button_toggled(toggled_on: bool) -> void:
	bound_camera.locked = toggled_on
