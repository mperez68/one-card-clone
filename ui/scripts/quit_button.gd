@tool
class_name QuitButton extends SfxButton

@export var back: bool = false:
	set(value):
		back = value
		_set_text()
@export var save: bool = false:
	set(value):
		save = value
		_set_text()


# ENGINE


# PUBLIC


# PRIVATE
func _set_text():
	var all_text: String = "Back" if back else "Quit"
	all_text = ("Save & " if save else "") + all_text
	text = all_text


# SIGNALS
func _on_pressed() -> void:
	super()
	if save:
		SaveStateManager.save_game_state()
	if back:
		SceneManager.back()
	else:
		SceneManager.quit()
