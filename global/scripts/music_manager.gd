extends Node

var songs: Dictionary[String, SongManager]


# ENGINE
func _ready() -> void:
	for child in get_children():
		if child is SongManager:
			songs[child.name if child.song_name.is_empty() else child.song_name] = child


# PUBLIC
func play(song_name: String, force_restart: bool = false, play_outro: bool = false):
	if !songs.keys().has(song_name):
		printerr("song %s does not exist!" % song_name)
	for song in songs.keys():
		if song == song_name:
			songs[song].play(force_restart)
		else:
			songs[song].stop(play_outro)

func stop(play_outro: bool = false):
	for song in songs.values():
		song.stop(play_outro)


# PRIVATE


# SIGNALS
