@tool
class_name DiceGridNode2d extends GridNode2D

const MOVE_SPRITE: PackedScene = preload("res://elements/move_sprite_grid_node_2d.tscn")

const DELAY_INCREMENT: float = 0.1

signal died

@onready var dice: Dice = %Dice
@onready var damage_particles: GPUParticles2D = %DamageParticles
@onready var damage_sfx: AudioStreamPlayer2D = %DamageSfx
@onready var move_sfx: AudioStreamPlayer2D = %MoveSfx

@export_range(0.0, 6.0, 1.0) var hp: int = 3:
	set(value):
		hp = clamp(value, 0, 6)
		if dice:
			dice.face_value = hp as Face.Value
		if hp == 0 and !Engine.is_editor_hint():
			died.emit()
			blocking = false
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
	damage_particles.emitting = true
	damage_sfx.play()

func heal():
	hp = 6

func is_dead() -> bool:
	return hp == 0

func move_to(target_position: Vector3i):
	var route = TacGrid.get_map().get_route(grid_position, target_position, true, true)
	for i in route.size() - 1:
		var pos: Vector3i = route[i]
		var next_pos: Vector3i = route[i + 1]
		var node: MoveSpriteGridNode2d = MOVE_SPRITE.instantiate()
		node.grid_position = pos
		node.set_facing(pos, next_pos)
		add_sibling(node)
		node.play(i * DELAY_INCREMENT)
	super(target_position)
	move_sfx.play()

# PRIVATE


# SIGNALS
func _on_damage_particles_finished() -> void:
	if is_dead():
		queue_free()
