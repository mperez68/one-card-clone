class_name PlayerController extends Control

signal pass_turn

const Stage := Level.Stage

@onready var stat_tray_container: HBoxContainer = %StatTrayContainer
@onready var rolling_container: PanelContainer = %RollingContainer
@onready var rolling_dice_tray: HBoxContainer = %RollingDiceTray
@onready var allocation_button: SfxButton = %AllocationButton
@onready var end_turn_button: SfxButton = %EndTurnButton

var rolling_dice: int
var is_action: bool = false
var player: Node
var map: Map

# ENGINE
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click_on") and is_action:
		if !_cache():
			return
		var grid_pos: Vector3i = map.local_to_grid3d(get_global_mouse_position(), true)
		for npc in get_tree().get_nodes_in_group("npc"):
			if npc is GridNode2D and npc.grid_position == grid_pos and !npc.is_dead() and map.is_in_range(player.grid_position, grid_pos, get_stat(StatTray.Stat.RANGE)):
				npc.damage(1)
				spend_stat(1, StatTray.Stat.ATTACK)
				return
		var remaining_move: int = get_stat(StatTray.Stat.MOVEMENT)
		if remaining_move > 0 and map.is_navigable(player.grid_position, grid_pos, remaining_move):
			spend_stat(map.get_route(player.grid_position, grid_pos).size(), StatTray.Stat.MOVEMENT)
			player.move_to(grid_pos)


# PUBLIC
func get_stat(stat: StatTray.Stat) -> int:
	for tray in stat_tray_container.get_children():
		if tray is StatTray and tray.stat == stat:
			return tray.remaining_value
	return 0

func spend_stat(value: int, stat: StatTray.Stat):
	for tray in stat_tray_container.get_children():
		if tray is StatTray and tray.stat == stat:
			tray.remaining_value -= value


# PRIVATE
func _cache() -> bool:
	if !player:
		player = get_tree().get_nodes_in_group("player").front()
	if !map:
		map = TacGrid.get_map()
	return player != null and map != null

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
			is_action = false
		_:
			pass
	match new_stage:
		Stage.ROLLING:
			_show_remaining(false, true)
			_roll_tray()
			rolling_container.show()
		Stage.ALLOCATION:
			allocation_button.show()
			_set_draggable(true)
		Stage.ACTION:
			_start_action()
			_show_remaining(true)
			end_turn_button.show()
			is_action = true
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
