class_name ClassSelector extends HBoxContainer


# ENGINE


# PUBLIC


# PRIVATE


# SIGNALS
func _on_sfx_button_pressed(class_sel: int) -> void:
	PlayerStatsManager.player_class = class_sel as ClassInfo.PlayerClass
