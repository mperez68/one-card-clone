@tool
class_name DiceGridNode2d extends GridNode2D

signal died

@onready var dice: Dice = %Dice

@export_range(0.0, 6.0, 1.0) var hp: int = 3:
	set(value):
		hp = clamp(value, 0, 6)
		if dice:
			dice.face_value = hp as Face.Value
		blocking = hp == 0
		if hp == 0:
			died.emit()
			if dice:
				dice.type = Dice.Type.DISABLED
		elif dice:
			dice.type = default_type
@export var default_type: Dice.Type = Dice.Type.NPC


# ENGINE
func _ready():
	super()
	hp = hp


# PUBLIC
func damage(value: int):
	hp -= value

func heal():
	hp = 6

func is_dead() -> bool:
	return hp == 0


# PRIVATE


# SIGNALS
