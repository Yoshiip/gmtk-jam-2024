extends Node


enum Musics {
	MENU,
	PUZZLE,
	INFILTRATION
}

const PUZZLE_MUSIC = preload("res://assets/musics/puzzle.wav")
const INFILTRATION_MUSIC = preload("res://assets/musics/infiltration.wav")
var current_music := Musics.MENU

func _ready() -> void:
	play(Musics.MENU)

var current_stream: AudioStreamPlayer

func play(music: Musics) -> void:
	if music == current_music:
		return
	current_music = music
	if is_instance_valid(current_stream):
		current_stream.queue_free()
	current_stream = AudioStreamPlayer.new()
	match music:
		Musics.MENU:
			current_stream.stream = PUZZLE_MUSIC
		Musics.PUZZLE:
			current_stream.stream = PUZZLE_MUSIC
		Musics.INFILTRATION:
			current_stream.stream = INFILTRATION_MUSIC
			current_stream.volume_db = -16
	add_child(current_stream)
	current_stream.play()
