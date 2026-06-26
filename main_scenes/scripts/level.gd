class_name Level extends Node2D

const PLAYER: PackedScene = preload("res://elements/player_dice_grid_node_2d.tscn")
const NPC: PackedScene = preload("res://elements/npc_dice_grid_node_2d.tscn")
const TEXT: PackedScene = preload("res://ui/fading_label_holder.tscn")

signal stage_changed(last_stage: Stage, new_stage: Stage)

enum Stage{ PRE_GAME, ROLLING, ALLOCATION, ACTION, COMPUTER_MOVE, COMPUTER_ATTACK, POST_GAME }

@onready var map: Map = %Map
@onready var npc_timer: Timer = %NpcTimer
@onready var player_controller: PlayerController = %PlayerController
@onready var spawn_marker: SpawnMarker = %SpawnMarker
@onready var success_buttons: Array[SfxButton] = [
	%SuccessButton, %SuccessButton1, %SuccessButton2, %SuccessButton3, %SuccessButton4
]

@export var next_level: PackedScene = preload("res://main_scenes/menus/credits_menu.tscn")
@export_group("Npc Stats")
@export var npc_hp: int = 2
@export var npc_movement: int = 5
@export var npc_attack: int = 4
@export var npc_defence: int = 4
@export var npc_range: int = 3

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
	# Player
	var player: DiceGridNode2d = PLAYER.instantiate()
	player.hp = PlayerStatsManager.hp
	player.grid_position = spawn_marker.grid_position
	add_child(player)
	player_controller.add_player(player)
	player_controller.set_enemy_stats(npc_movement, npc_attack, npc_defence, npc_range)
	# NPCs
	for child in get_children(true):
		if child is SpawnMarker and child.type == SpawnMarker.Type.NPC:
			var npc: DiceGridNode2d = NPC.instantiate()
			npc.hp = npc_hp
			npc.grid_position = child.grid_position
			add_child(npc)
	for npc in get_tree().get_nodes_in_group("npc"):
		living_npcs += 1
		npc.died.connect(_on_npc_died)
	
	await get_tree().create_timer(0.5).timeout	# TODO start when prompted
	pass_turn()

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
				var target_pos: Vector3i = map.get_valid_approach(npc.grid_position, player.grid_position, npc_range, npc_movement)
				npc.blocking = true
				if map.can_stand(target_pos, false) and target_pos != Vector3i.ZERO:
					npc.move_to(target_pos)
		Stage.COMPUTER_ATTACK:
			if queued_npcs.is_empty():
				npc_timer.stop()
				pass_turn()
			else:
				var total_attack: int = 0
				for npc in queued_npcs:
					if map.is_in_hard_range(npc.grid_position, player.grid_position, npc_range):
						var text1: FadingLabelHolder = TEXT.instantiate()
						text1.set_text("%s" % npc_attack)
						text1.position = npc.position
						add_child(text1)
						total_attack += npc_attack
				queued_npcs.clear()
				var player_def: int = player_controller.get_stat(StatTray.Stat.DEFENSE)
				var text: FadingLabelHolder = TEXT.instantiate()
				if total_attack >= player_def:
					text.set_text("%s%s" % [str(total_attack), "" if total_attack < player_def else "!"])
				else:
					text.set_text("" if total_attack > 0 else "...")
				text.position = player.position
				add_child(text)
				while total_attack >= player_def:
					player.damage(1)
					total_attack -= player_def


func _on_progression_button_pressed(selection: int) -> void:
	for button in success_buttons:
		button.disabled = true
	PlayerStatsManager.hp = player_controller.player.hp
	match selection:
		0:
			PlayerStatsManager.heal()
		1:
			PlayerStatsManager.boost_stat(StatTray.Stat.MOVEMENT)
		2:
			PlayerStatsManager.boost_stat(StatTray.Stat.ATTACK)
		3:
			PlayerStatsManager.boost_stat(StatTray.Stat.DEFENSE)
		4:
			PlayerStatsManager.boost_stat(StatTray.Stat.RANGE)
	SceneManager.new_scene(next_level)
