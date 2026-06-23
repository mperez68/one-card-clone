class_name Level extends Node2D

signal stage_changed(last_stage: Stage, new_stage: Stage)

enum Stage{ PRE_GAME, ROLLING, ALLOCATION, ACTION, COMPUTER_MOVE, COMPUTER_ATTACK, POST_GAME }

@onready var map: Map = %Map

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
	await get_tree().create_timer(0.5).timeout	# TODO start when prompted
	pass_turn()


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
			await get_tree().create_timer(0.5).timeout	# TODO approach
			pass_turn()
		Stage.COMPUTER_ATTACK:
			await get_tree().create_timer(0.5).timeout	# TODO calc damage
			pass_turn()
		_:
			pass
