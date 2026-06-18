extends Node

enum Sfx{ CLICK }

@onready var _sfx_map: Array[AudioStreamPlayer] = [
	%Click
]

# ENGINE


# PUBLIC
func play(sfx: Sfx):
	_sfx_map[sfx].play()


# PRIVATE


# SIGNALS
