class_name SongManager extends Node

enum State{ STOPPED, INTRO, LOOP, OUTRO }

@export var song_name: String
@export var intro_rhythm: AudioStream
@export var intro_lead: AudioStream
@export var loop_rhythm: AudioStream
@export var loop_lead: AudioStream
@export var outro_rhythm: AudioStream
@export var outro_lead: AudioStream

@onready var intro: Array[AudioStreamPlayer] = [%IntroRhythm, %IntroLead]
@onready var loop: Array[AudioStreamPlayer] = [%LoopRhythm, %LoopLead]
@onready var outro: Array[AudioStreamPlayer] = [%OutroRhythm, %OutroLead]
@onready var all_tracks: Array[AudioStreamPlayer] = intro + loop + outro

var state: State = State.STOPPED


# ENGINE
func _ready() -> void:
	intro[0].stream = intro_rhythm
	intro[1].stream = intro_lead
	loop[0].stream = loop_rhythm
	loop[1].stream = loop_lead
	outro[0].stream = outro_rhythm
	outro[1].stream = outro_lead


# PUBLIC
func play(force_restart: bool = false):
	if (![State.STOPPED, State.OUTRO].has(state) and !force_restart) or !loop[0].stream:
		return
	if force_restart:
		stop(false)
	if intro[0].stream or intro[1].stream:
		for track in intro:
			if track.stream:
				track.play()
		for track in outro:
			track.stop()
		state = State.INTRO
	else:
		_on_intro_finished()

func stop(play_outro: bool = true):
	var is_playing: bool = [State.INTRO, State.LOOP].has(state)
	for track in intro + loop:
		track.stop()
	state = State.STOPPED
	for track in outro:
		if play_outro and track.stream and is_playing:
			track.play()
			state = State.OUTRO
		else:
			track.stop()


# PRIVATE


# SIGNALS
func _on_intro_finished() -> void:
	state = State.LOOP
	for track in loop:
		if track.stream:
			track.play()

func _on_outro_finished() -> void:
	state = State.STOPPED
