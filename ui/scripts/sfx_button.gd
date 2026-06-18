class_name SfxButton extends Button


# ENGINE
func _enter_tree() -> void:
	pressed.connect(_on_pressed)

func _exit_tree() -> void:
	pressed.disconnect(_on_pressed)


# PUBLIC


# PRIVATE


# SIGNALS
func _on_pressed() -> void:
	SfxManager.play(SfxManager.Sfx.CLICK)
