@tool
class_name SpawnMarker extends GridNode2D

enum Type{ NPC, PLAYER }

@onready var marker_sprite: Sprite2D = %MarkerSprite

@export var type: Type:
	set(value):
		type = value
		_update()
@export var sprite_dir: Dictionary[Type, Texture2D]


# ENGINE
func _ready():
	super()
	_update()


# PUBLIC


# PRIVATE
func _update():
	if sprite_dir.has(type) and marker_sprite:
		marker_sprite.texture = sprite_dir[type]


# SIGNALS
