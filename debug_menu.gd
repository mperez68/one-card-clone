class_name DebugMenu extends Control

@onready var restart_button: SfxButton = %RestartButton
@onready var outro_button: SfxButton = %OutroButton


# ENGINE


# PUBLIC


# PRIVATE


# SIGNALS
func _on_song_button_pressed(song: String) -> void:
	MusicManager.play(song, restart_button.button_pressed, outro_button.button_pressed)

func _on_song_stop_button_pressed() -> void:
	MusicManager.stop(outro_button.button_pressed)

func _on_save_button_pressed() -> void:
	SaveStateManager.save_game_state()
	print(SaveStateManager.save_state.timestamp)

func _on_load_button_pressed() -> void:
	
	print(SaveStateManager.load_game_state().timestamp)
