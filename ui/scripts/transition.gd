class_name Transition extends Control

signal transition_finished(fade: String)

@onready var animation_player: AnimationPlayer = %AnimationPlayer

@export_enum("in", "out") var fade: String = "in"


# ENGINE
func _ready():
	animation_player.play("fade_%s" % fade)


# PUBLIC


# PRIVATE


# SIGNALS
func _on_animation_finished(anim_name: StringName) -> void:
	transition_finished.emit(fade)
	if anim_name == "fade_in":
		queue_free()
