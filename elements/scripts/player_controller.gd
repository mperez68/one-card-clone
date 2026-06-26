class_name PlayerController extends Control

signal pass_turn

const Stage := Level.Stage

const MAX_MOVE: int = 6

@onready var stat_tray_container: HBoxContainer = %StatTrayContainer
@onready var rolling_container: PanelContainer = %RollingContainer
@onready var rolling_dice_tray: Control = %RollingDiceTray
@onready var allocation_button: SfxButton = %AllocationButton
@onready var end_turn_button: SfxButton = %EndTurnButton
@onready var spin_button: SfxButton = %SpinButton

@onready var end_game_container: Control = %EndGameContainer
@onready var success_container: VBoxContainer = %SuccessContainer
@onready var failure_container: VBoxContainer = %FailureContainer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var rotate_animated_sprite: AnimatedSprite2D = %RotateAnimatedSprite

@onready var ordered_dice_wheel: Array[Dice] = [
	%RollingDice, %RollingDice2, %RollingDice3, %RollingDice5, %RollingDice8, %RollingDice7, %RollingDice6, %RollingDice4
]

var rolling_dice: int
var is_action: bool = false:
	set(value):
		is_action = value
		_update_highlights(true)
var player: Node
var map: Map

# ENGINE
func _ready() -> void:
	if OS.get_name() == "Web":
		var children: Array[Node] = rolling_dice_tray.get_children()
		for i in 3:
			ordered_dice_wheel[i] = children[i]
	for tray in stat_tray_container.get_children():
		match tray.stat:
			StatTray.Stat.MOVEMENT:
				tray.set_base_dice(PlayerStatsManager.movement)
			StatTray.Stat.ATTACK:
				tray.set_base_dice(PlayerStatsManager.attack)
			StatTray.Stat.DEFENSE:
				tray.set_base_dice(PlayerStatsManager.defense)
			StatTray.Stat.RANGE:
				tray.set_base_dice(PlayerStatsManager.a_range)

func _unhandled_input(event: InputEvent) -> void:
	if !is_action:
		return
	var grid_pos: Vector3i = map.local_to_grid3d(get_global_mouse_position(), true)
	var npc_at_grid_pos: DiceGridNode2d = TacGrid.get_mob_at_grid_3d(grid_pos)
	if event.is_action_pressed("click_on"):
		if !_cache():
			return
		var player_move: int = get_stat(StatTray.Stat.MOVEMENT)
		if npc_at_grid_pos and can_attack(grid_pos):
			if spend_stat(get_npc_stat(StatTray.Stat.DEFENSE), StatTray.Stat.ATTACK):
				npc_at_grid_pos.damage(1)
			_update_highlights(true)
			return
		player.blocking = false
		if player_move > 0 and map.is_navigable(player.grid_position, grid_pos, player_move):
			if spend_stat(ceili(map.get_route_weight(player.grid_position, grid_pos)), StatTray.Stat.MOVEMENT):
				player.move_to(grid_pos)
			_update_highlights()
		player.blocking = true
	if event is InputEventMouseMotion and npc_at_grid_pos and can_attack(grid_pos):
		map.draw_highlight(Map.Highlight.TARGET_HOVER, [Vector2i(grid_pos.x, grid_pos.y)])

func can_attack(grid_pos: Vector3i) -> bool:
	return map.is_in_hard_range(player.grid_position, grid_pos, get_stat(StatTray.Stat.RANGE)) and get_stat(StatTray.Stat.ATTACK) >= get_npc_stat(StatTray.Stat.DEFENSE)


# PUBLIC
func get_stat(stat: StatTray.Stat) -> int:
	for tray in stat_tray_container.get_children():
		if tray is StatTray and tray.stat == stat:
			return tray.remaining_value
	return 0

func set_stat(die: Dice, stat: StatTray.Stat):
	for tray in stat_tray_container.get_children():
		if tray is StatTray and tray.stat == stat:
			tray.modifier_dice.type = die.type
			tray.modifier_dice.face_value = die.face_value
			return

func get_npc_stat(stat: StatTray.Stat) -> int:
	for tray in stat_tray_container.get_children():
		if tray is StatTray and tray.stat == stat:
			return tray.enemy_value
	return 0

func spend_stat(value: int, stat: StatTray.Stat) -> bool:
	for tray in stat_tray_container.get_children():
		if tray is StatTray and tray.stat == stat:
			if tray.remaining_value >= value:
				tray.remaining_value -= value
				return true
	return false

func set_enemy_stats(mve: int, atk: int, def: int, rng: int):
	for tray: StatTray in stat_tray_container.get_children():
		var new_value: int = 0
		match tray.stat:
			StatTray.Stat.MOVEMENT:
				new_value = mve
			StatTray.Stat.ATTACK:
				new_value = atk
			StatTray.Stat.DEFENSE:
				new_value = def
			StatTray.Stat.RANGE:
				new_value = rng
		tray.enemy_value = new_value

func add_player(new_player: DiceGridNode2d):
	player = new_player
	new_player.died.connect(end_game.bind(false))

func end_game(success: bool):
	animation_player.play("show")
	end_game_container.show()
	(success_container if success else failure_container).show()


# PRIVATE
func _cache() -> bool:
	if !player:
		player = get_tree().get_nodes_in_group("player").front()
	if !map:
		map = TacGrid.get_map()
	return player != null and map != null

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
	rolling_dice = ordered_dice_wheel.size()
	for child in rolling_dice_tray.get_children():
		if child is Dice:
			child.roll(randf_range(1.0, 2.0))

func _update_highlights(hide_player: bool = false):
	_cache()
	if hide_player:
		player.blocking = false
	var tiles: Array[Vector2i]
	var move: int = get_stat(StatTray.Stat.MOVEMENT)
	if move > 0 and is_action:
		for x in range(max(0, player.grid_position.x - ceili(float(move) / 2)) - 1, player.grid_position.x + ceili(float(move) / 2) + 2):
			for y in range(max(0, player.grid_position.y - ceili(float(move) / 2)) - 1, player.grid_position.y + ceili(float(move) / 2) + 2):
				if map.get_route_weight(player.grid_position, Vector3i(x, y, player.grid_position.z)) <= move and Vector3i(x, y, player.grid_position.z) != player.grid_position:
					tiles.push_back(Vector2i(x, y))
	map.draw_highlight(Map.Highlight.MOVE_HIGHLIGHT, tiles)
	if hide_player:
		player.blocking = true


# SIGNALS
func _on_stage_changed(last_stage: Stage, new_stage: Stage):
	match last_stage:
		Stage.ALLOCATION:
			allocation_button.hide()
			spin_button.disabled = true
			rolling_container.hide()
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
			spin_button.disabled = false
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

func _on_allocation_button_pressed() -> void:
	set_stat(ordered_dice_wheel[0], StatTray.Stat.MOVEMENT)
	set_stat(ordered_dice_wheel[1], StatTray.Stat.ATTACK)
	set_stat(ordered_dice_wheel[2], StatTray.Stat.DEFENSE)
	pass_turn.emit()

func _on_end_turn_button_pressed() -> void:
	pass_turn.emit()

func _on_scene_change_button_pressed() -> void:
	PlayerStatsManager.reset()

func _on_spin_button_pressed() -> void:
	rotate_animated_sprite.play("default")
	var last_value: Face.Value = ordered_dice_wheel.back().face_value
	for die in ordered_dice_wheel:
		var temp_value: Face.Value = die.face_value
		die.face_value = last_value
		last_value = temp_value
