class_name FadingLabelHolder extends Control

@onready var label: Label = %Label
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var text: String

# ENGINE
func _ready():
	label.text = text
	animation_player.play("fade")


# PUBLIC
func set_text(string: String):
	text = string


# PRIVATE


# SIGNALS
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
