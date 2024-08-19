extends Node


enum Musics {
	MENU,
	PUZZLE,
	ACTION
}

const PUZZLE_MUSIC = preload("res://assets/musics/puzzle.wav")

var current_music := Musics.MENU

func _ready() -> void:
	play(Musics.MENU)

var current_stream: AudioStreamPlayer

func play(music: Musics) -> void:
	if is_instance_valid(current_stream):
		current_stream.queue_free()
	current_stream = AudioStreamPlayer.new()
	current_stream.stream = PUZZLE_MUSIC
	add_child(current_stream)
	current_stream.play()
