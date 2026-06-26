class_name LevelCountLabel extends Label


# ENGINE
func _ready():
	text = str("%s level%s cleared." % [PlayerStatsManager.level, "s" if PlayerStatsManager.level > 1 else ""])


# PUBLIC


# PRIVATE


# SIGNALS
