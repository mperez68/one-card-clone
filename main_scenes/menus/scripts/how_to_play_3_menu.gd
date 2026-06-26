class_name HowToPlay3Menu extends MenuControl

@onready var rolled_trays: Array[StatTray] = [ %StatTray, %StatTray2, %StatTray3 ]

const ENEMY_STAT: int = 4


# ENGINE
func _ready():
	super()
	for tray in rolled_trays:
		tray.enemy_value = ENEMY_STAT
		tray.modifier_dice.type = Dice.Type.ROLLING
		tray.modifier_dice.roll_no_signal()
		tray.start_action()
		tray.show_remaining = true
		%StatTray4.enemy_value = ENEMY_STAT


# PUBLIC


# PRIVATE


# SIGNALS
