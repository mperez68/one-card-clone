class_name PlayerController extends Control

signal pass_turn

const Stage := Level.Stage

@onready var stat_tray_container: HBoxContainer = %StatTrayContainer
@onready var rolling_container: PanelContainer = %RollingContainer
@onready var rolling_dice_tray: HBoxContainer = %RollingDiceTray
@onready var allocation_button: SfxButton = %AllocationButton
@onready var end_turn_button: SfxButton = %EndTurnButton

var rolling_dice: int


# ENGINE
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pass_turn.emit()

# PUBLIC


# PRIVATE
func _set_draggable(draggable: bool):
	for child in rolling_dice_tray.get_children():
		if child is Dice:
			child.draggable = draggable
	for child in stat_tray_container.get_children():
		if child is StatTray:
			child.draggable = draggable

func _show_remaining(showing: bool, reset: bool = false):
	for child in stat_tray_container.get_children():
		if child is StatTray:
			child.show_remaining = showing
			if reset:
				child.reset()

func _start_action():
	for child in stat_tray_container.get_children():
		if child is StatTray:
			child.start_action()

func _roll_tray():
	rolling_dice = rolling_dice_tray.get_children().size()
	for child in rolling_dice_tray.get_children():
		if child is Dice:
			child.roll(randf_range(1.0, 2.0))


# SIGNALS
func _on_stage_changed(last_stage: Stage, new_stage: Stage):
	match last_stage:
		Stage.ALLOCATION:
			allocation_button.hide()
			allocation_button.disabled = true
			rolling_container.hide()
			_set_draggable(false)
		Stage.ACTION:
			_show_remaining(false)
			end_turn_button.hide()
		Stage.COMPUTER:
			_show_remaining(false, true)
		_:
			pass
	match new_stage:
		Stage.ROLLING:
			_roll_tray()
			rolling_container.show()
		Stage.ALLOCATION:
			allocation_button.show()
			_set_draggable(true)
		Stage.ACTION:
			_start_action()
			_show_remaining(true)
			end_turn_button.show()
		_:
			pass

func _on_dice_rolled() -> void:
	rolling_dice -= 1
	if rolling_dice <= 0:
		pass_turn.emit()

func _on_stat_tray_dice_dropped() -> void:
	allocation_button.disabled = true
	for child in rolling_dice_tray.get_children():
		if child is Dice:
			if ![Dice.Type.EMPTY, Dice.Type.EMPTY_DISABLED].has(child.type):
				return
	allocation_button.disabled = false

func _on_allocation_button_pressed() -> void:
	pass_turn.emit()

func _on_end_turn_button_pressed() -> void:
	pass_turn.emit()
