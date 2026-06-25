class_name HowToPlay2Menu extends MenuControl

@onready var dice: Array[Dice] = [ %Dice, %Dice2, %Dice3 ]


# ENGINE
func _ready():
	super()
	for die in dice:
		die.roll(0.0)


# PUBLIC


# PRIVATE


# SIGNALS
