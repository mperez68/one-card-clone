class_name OptionsPanel extends PanelContainer

@onready var fullscreen_button: SfxButton = %FullscreenButton
@onready var borderless_button: SfxButton = %BorderlessButton


# ENGINE
func _ready():
	fullscreen_button.set_pressed_no_signal(SettingsManager.game_settings.fullscreen)
	borderless_button.set_pressed_no_signal(SettingsManager.game_settings.borderless)
	if OS.get_name() == "Web":
		fullscreen_button.hide()
		borderless_button.hide()


# PUBLIC


# PRIVATE


# SIGNALS
func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED)

func _on_borderless_button_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, toggled_on)
