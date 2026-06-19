@tool
class_name Face extends TextureRect

enum Value{ NONE, ONE, TWO, THREE, FOUR, FIVE, SIX, UNKNOWN }

@export var value: Value:
	set(new_value):
		value = new_value
		update()

@export var face_dir: Dictionary[Value, Texture2D]


# ENGINE
func _ready():
	update()


# PUBLIC


# PRIVATE
func update():
	if !face_dir.has(value):
		hide()
		return
	show()
	texture = face_dir[value]

# SIGNALS
