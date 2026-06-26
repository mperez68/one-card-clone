@tool
class_name Dice extends TextureRect

signal value_changed
signal dropped
signal rolled

enum Type{ DISABLED, STAT, ROLLING, PLAYER, NPC, EMPTY, EMPTY_DISABLED }

@onready var face: Face = %Face
@onready var roll_timer: Timer = %RollTimer
@onready var rolling_timer: Timer = %RollingTimer
@onready var spin_particles: CPUParticles2D = %SpinParticles
@onready var set_particles: CPUParticles2D = %SetParticles

@export var type: Type:
	set(value):
		type = value
		_update()
@export var face_value: Face.Value:
	set(value):
		face_value = value
		_update()
		value_changed.emit()
@export var draggable: bool = true
@export var type_dir: Dictionary[Type, Texture2D]


# ENGINE
func _ready():
	_update()

# Control that can be dragged from
func _get_drag_data(_at_position:Vector2) -> Variant:
	if draggable and type != Type.EMPTY and type != Type.EMPTY_DISABLED:
		set_drag_preview(self.duplicate(true))
		return self
	return null

# Control that can be dragged to
func _can_drop_data(_at_position:Vector2, data:Variant) -> bool:
	if data is not Dice:
		return false
	return true

func _drop_data(_at_position:Vector2, data:Variant) -> void:
	if data is Dice and type == Type.EMPTY and type != Type.EMPTY_DISABLED:
		type = data.type
		face_value = data.face_value
		data.type = Type.EMPTY
		data.face_value = Face.Value.NONE
		dropped.emit()


# PUBLIC
func set_to_six():
	set_particles.emitting = true
	face_value = Face.Value.SIX

func roll(delay: float = 0.0):
	spin_particles.emitting = true
	type = Dice.Type.ROLLING
	face_value = Face.Value.UNKNOWN
	if delay > 0.0:
		rolling_timer.start()
		roll_timer.start(delay)
	else:
		_on_roll_timer_timeout()

func roll_no_signal():
	set_particles.emitting = true
	face_value = randi_range(1, 6) as Face.Value
	

func reset(settable: bool = true):
	type = Type.EMPTY if settable else Type.EMPTY_DISABLED
	face_value = Face.Value.NONE


# PRIVATE
func _update():
	if !type_dir.has(type):
		return
	if face:
		face.value = face_value
	texture = type_dir[type]


# SIGNALS
func _on_roll_timer_timeout() -> void:
	set_particles.emitting = true
	rolling_timer.stop()
	face_value = randi_range(1, 6) as Face.Value
	rolled.emit()

func _on_rolling_timer_timeout() -> void:
	face_value = randi_range(1, 6) as Face.Value
