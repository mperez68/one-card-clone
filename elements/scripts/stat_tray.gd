@tool
class_name StatTray extends VBoxContainer

signal dice_dropped

enum Stat{ MOVEMENT, ATTACK, DEFENSE, RANGE }

@onready var stat_texture: TextureRect = %StatTexture
@onready var stat_dice: Dice = %StatDice
@onready var modifier_dice: Dice = %ModifierDice
@onready var enemy_stat_label: Label = %EnemyStatLabel
@onready var remaining_value_label: Label = %RemainingValueLabel
@onready var slash_label: Label = %SlashLabel
@onready var total_value_label: Label = %TotalValueLabel

@export var stat: Stat:
	set(value):
		stat = value
		_update()
@export var stat_dir: Dictionary[Stat, Texture2D]
@export var draggable: bool = false:
	set(value):
		draggable = value
		if modifier_dice:
			modifier_dice.draggable = draggable
@export var settable: bool = true:
	set(value):
		settable = value
		if modifier_dice:
			modifier_dice.reset(settable)
		
var total_value: int:
	set(value):
		total_value = value
		_update()
var remaining_value: int:
	set(value):
		remaining_value = max(0, value)
		_update()
var enemy_value: int:
	set(value):
		enemy_value = value
		_update()
var show_remaining: bool = false:
	set(value):
		show_remaining = value
		_update()

# ENGINE
func _ready():
	reset(true)
	_update()


# PUBLIC
func start_action():
	remaining_value = total_value

func reset(game_reset: bool = false):
	if game_reset:
		stat_dice.face_value = Face.Value.TWO if stat == Stat.RANGE else Face.Value.ONE
	settable = stat != Stat.RANGE
	modifier_dice.reset(settable)

func set_base_dice(value: int):
	stat_dice.face_value = value as Face.Value


# PRIVATE
func _update():
	draggable = draggable
	if !stat_dir.has(stat) or !stat_texture:
		return
	stat_texture.texture = stat_dir[stat]
	
	enemy_stat_label.text = str(enemy_value)
	enemy_stat_label.visible = enemy_value != 0
	
	remaining_value_label.text = str(remaining_value)
	remaining_value_label.visible = show_remaining and ![Stat.DEFENSE, Stat.RANGE].has(stat)
	slash_label.visible = show_remaining and ![Stat.DEFENSE, Stat.RANGE].has(stat)
	
	total_value_label.text = str(total_value)


# SIGNALS
func _on_dice_value_changed():
	total_value = int(stat_dice.face_value) + int(modifier_dice.face_value)

func _on_modifier_dice_dropped() -> void:
	dice_dropped.emit()
