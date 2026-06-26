@tool
class_name ClassInfo extends HBoxContainer

enum PlayerClass{ NONE, BARBARIAN, MAGE, PALADIN, RANGER }

@export var player_class: PlayerClass:
	set(value):
		player_class = value
		_update()
@export var texture_dir: Dictionary[PlayerClass, Texture2D]

@onready var sfx_button: SfxButton = %SfxButton
@onready var label: Label = %Label
@onready var texture_rect: TextureRect = %TextureRect

var level: Level
var is_disabled: bool = false:
	set(value):
		is_disabled = value
		if is_disabled:
			sfx_button.disabled = true

# ENGINE
func _ready() -> void:
	if !Engine.is_editor_hint():
		player_class = PlayerStatsManager.player_class
	if get_tree().current_scene is Level:
		level = get_tree().current_scene
	elif !Engine.is_editor_hint():
		printerr("%s can't initialize!" % name)
		queue_free()
	_update()


# PUBLIC


# PRIVATE
func _barbarian_action():
	sfx_button.disabled = true
	var temp: Array[Node] = get_tree().get_nodes_in_group("player")
	var player: DiceGridNode2d = temp.front() if !temp.is_empty() else null
	if !player:
		return
	var rerolls: Array[Dice]
	var cap: int = PlayerStatsManager.default_hp - player.hp
	while rerolls.size() < cap:
		var die: Dice = level.player_controller.ordered_dice_wheel.pick_random()
		if !rerolls.has(die):
			rerolls.push_back(die)
	for die in rerolls:
		die.roll_no_signal()

func _mage_action():
	is_disabled = true
	level.stage = Level.Stage.ROLLING

func _paladin_action():
	is_disabled = true
	level.player_controller.ordered_dice_wheel.pick_random().set_to_six()

func _ranger_action():
	level.player_controller.ranger_swap = !level.player_controller.ranger_swap

func _update():
	if !label:
		return
	if texture_dir.has(player_class):
		texture_rect.texture = texture_dir[player_class]
	show()
	match player_class:
		PlayerClass.NONE:
			hide()
		PlayerClass.BARBARIAN:
			label.text = "Reroll a random dice for each damage taken."
		PlayerClass.MAGE:
			label.text = "Reroll all dice. One use per level."
		PlayerClass.PALADIN:
			label.text = "Turn a random die into a 6. One use per level."
		PlayerClass.RANGER:
			label.text = "toggle dice assignment to range or movement."


# SIGNALS
func _on_sfx_button_pressed() -> void:
	if Engine.is_editor_hint():
		return
	match player_class:
		PlayerClass.BARBARIAN:
			_barbarian_action()
		PlayerClass.MAGE:
			_mage_action()
		PlayerClass.PALADIN:
			_paladin_action()
		PlayerClass.RANGER:
			_ranger_action()

func _on_stage_changed(_last_stage: Level.Stage, new_stage: Level.Stage) -> void:
	if new_stage == Level.Stage.ALLOCATION:
		sfx_button.disabled = is_disabled
	else:
		sfx_button.disabled = true
