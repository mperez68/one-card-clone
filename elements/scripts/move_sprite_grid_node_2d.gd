@tool
class_name MoveSpriteGridNode2D extends GridNode2D

@onready var delay_timer: Timer = %DelayTimer
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

var is_corner: bool = false

# ENGINE


# PUBLIC
func play(delay: float):
	if delay == 0.0:
		_on_delay_timer_timeout()
	else:
		delay_timer.start(delay)

func set_facing(start :Vector3i, end: Vector3i):
	var diff: Vector3i = end - start
	match diff:
		Vector3i.RIGHT:
			facing = Facing.RIGHT
		Vector3i(1, 1, 0):
			facing = Facing.DOWN
			is_corner = true
		Vector3i.DOWN:
			facing = Facing.UP
		Vector3i(-1, 1, 0):
			facing = Facing.LEFT
			is_corner = true
		Vector3i.LEFT:
			facing = Facing.LEFT
		Vector3i(-1, -1, 0):
			facing = Facing.UP
			is_corner = true
		Vector3i.UP:
			facing = Facing.DOWN
		Vector3i(1, -1, 0):
			facing = Facing.RIGHT
			is_corner = true


# PRIVATE


# SIGNALS
func _on_animated_sprite_2d_animation_finished() -> void:
	if !Engine.is_editor_hint():
		queue_free()

func _on_delay_timer_timeout() -> void:
	animated_sprite_2d.play("diagonal" if is_corner else "adjacent")
