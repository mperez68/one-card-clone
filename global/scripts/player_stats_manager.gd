extends Node

@export var default_hp: int = 6
@export var default_movement: int = 1
@export var default_attack: int = 1
@export var default_defense: int = 1
@export var default_range: int = 2

var hp: int
var movement: int
var attack: int
var defense: int
var a_range: int
var level: int


# ENGINE
func _ready() -> void:
	reset()

# PUBLIC
func reset():
	hp = default_hp
	movement = default_movement
	attack = default_attack
	defense = default_defense
	a_range = default_range
	level = 1

func inc_level():
	level += 1

func heal():
	hp = default_hp

func boost_stat(stat: StatTray.Stat):
	match stat:
		StatTray.Stat.MOVEMENT:
			movement += 1
		StatTray.Stat.ATTACK:
			attack += 1
		StatTray.Stat.DEFENSE:
			defense += 1
		StatTray.Stat.RANGE:
			a_range += 1


# PRIVATE


# SIGNALS
