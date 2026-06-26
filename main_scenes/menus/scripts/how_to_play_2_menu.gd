class_name HowToPlay2Menu extends MenuControl

@onready var dice: Array[Dice] = [ %RollingDice, %RollingDice2, %RollingDice3, %RollingDice4, %RollingDice5, %RollingDice6, %RollingDice7, %RollingDice8]


# ENGINE
func _ready():
	super()
	for die in dice:
		die.roll(0.0)


# PUBLIC


# PRIVATE


# SIGNALS
