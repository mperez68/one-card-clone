extends Node

const SAVE_PATH: String = "user://game_state.tres"

var save_state: SaveState:
	get():
		if !save_state:
			save_state = SaveState.new()
		return save_state


# ENGINE
func _ready():
	load_game_state()


# PUBLIC
func save_game_state():
	save_state.update_timestamp()
	ResourceSaver.save(save_state, SAVE_PATH)

func load_game_state() -> SaveState:
	if ResourceLoader.exists(SAVE_PATH):
		save_state = ResourceLoader.load(SAVE_PATH)
	return save_state


# PRIVATE


# SIGNALS
