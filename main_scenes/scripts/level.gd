class_name Level extends Node2D

signal stage_changed(last_stage: Stage, new_stage: Stage)

enum Stage{ PRE_GAME, ROLLING, ALLOCATION, ACTION, COMPUTER_MOVE, COMPUTER_ATTACK, POST_GAME }

@onready var map: Map = %Map
@onready var npc_timer: Timer = %NpcTimer
@onready var player_controller: PlayerController = %PlayerController

@export var next_level: PackedScene = preload("res://main_scenes/menus/credits_menu.tscn")
@export_group("Npc Stats")
@export var npc_movement: int = 4
@export var npc_attack: int = 4
@export var npc_defence: int = 4
@export var npc_range: int = 4

var queued_npcs: Array[DiceGridNode2d]
var living_npcs: int = 0

var stage: Stage:
	set(value):
		if value == stage:
			return
		var old: Stage = stage
		stage = value
		SfxManager.play(SfxManager.Sfx.CLICK)
		stage_changed.emit(old, stage)


# ENGINE
func _ready() -> void:
	player_controller.set_enemy_stats(npc_movement, npc_attack, npc_defence, npc_range)
	await get_tree().create_timer(0.5).timeout	# TODO start when prompted
	pass_turn()
	for npc in get_tree().get_nodes_in_group("npc"):
		living_npcs += 1
		npc.died.connect(_on_npc_died)

func _on_npc_died():
	living_npcs -= 1
	if living_npcs == 0:
		player_controller.end_game(true)


# PUBLIC
func update(target: Vector3i):
	print(target)

func pass_turn():
	stage = clamp((stage + 1) % Stage.POST_GAME, 1, Stage.COMPUTER_ATTACK) as Stage


# PRIVATE


# SIGNALS
func _on_stage_changed(last_stage: Stage, new_stage: Stage) -> void:
	match last_stage:
		_:
			pass
	match new_stage:
		Stage.COMPUTER_MOVE:
			for npc in get_tree().get_nodes_in_group("npc"):
				queued_npcs.push_back(npc as DiceGridNode2d)
			npc_timer.start()
		Stage.COMPUTER_ATTACK:
			for npc in get_tree().get_nodes_in_group("npc"):
				queued_npcs.push_back(npc as DiceGridNode2d)
			npc_timer.start()
		_:
			pass


func _on_npc_timer_timeout() -> void:
	var player = get_tree().get_nodes_in_group("player").front()
	match stage:
		Stage.COMPUTER_MOVE:
			if queued_npcs.is_empty():
				npc_timer.stop()
				pass_turn()
			else:
				var npc = queued_npcs.pop_front()
				npc.blocking = false
				npc.move_to(map.get_valid_approach(npc.grid_position, player.grid_position, npc_range, npc_movement))
				npc.blocking = true
		Stage.COMPUTER_ATTACK:
			if queued_npcs.is_empty():
				npc_timer.stop()
				pass_turn()
			else:
				var total_attack: int = 0
				for npc in queued_npcs:
					if map.is_in_hard_range(npc.grid_position, player.grid_position, npc_range):
						total_attack += npc_attack
				queued_npcs.clear()
				var player_def: int = player_controller.get_stat(StatTray.Stat.DEFENSE)
				while total_attack >= player_def:
					player.damage(1)
					total_attack -= player_def


func _on_progression_button_pressed(selection: int) -> void:
	match selection:
		0:
			print("heal")
		1:
			print("+1 movement")
		2:
			print("+1 attack")
		3:
			print("+1 defence")
		4:
			print("+1 range")
	SceneManager.new_scene(next_level)
