extends Node

const SAVE_PATH: String = "user://settings.tres"

var game_settings: GameSettings:
	get():
		if !game_settings:
			game_settings = GameSettings.new()
		return game_settings


# ENGINE
func _ready():
	load_game_settings()


# PUBLIC
func save_game_settings():
	for volume in game_settings.volumes.keys():
		game_settings.volumes[volume] = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index(volume))
	game_settings.fullscreen = DisplayServer.window_get_mode()
	game_settings.borderless = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)
	ResourceSaver.save(game_settings, SAVE_PATH)

func load_game_settings():
	if ResourceLoader.exists(SAVE_PATH):
		game_settings = ResourceLoader.load(SAVE_PATH)
		if !game_settings:
			return false
	for volume in game_settings.volumes:
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(volume), game_settings.volumes[volume])
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if game_settings.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, game_settings.borderless)


# PRIVATE


# SIGNALS
