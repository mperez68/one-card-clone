class_name Splash extends MenuControl

const MAIN_MENU: PackedScene = preload("res://main_scenes/menus/main_menu.tscn")

@onready var pause_timer: Timer = %PauseTimer


# ENGINE
func _ready():
	SaveStateManager.load_game_state()

func _input(event: InputEvent) -> void:
	if pause_timer.is_stopped():
		return
	if event is InputEventKey or event is InputEventMouseButton:
		pause_timer.stop()
		_on_pause_timer_timeout()


# PUBLIC


# PRIVATE


# SIGNALS
func _on_pause_timer_timeout() -> void:
	SceneManager.new_scene(MAIN_MENU)
