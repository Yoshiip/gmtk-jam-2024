extends Node


enum Musics {
	NONE,
	MENU,
	PUZZLE,
	PUZZLE_2,
	INFILTRATION
}
const MENU_MUSIC := preload("res://assets/musics/menu.mp3")
const PUZZLE_MUSIC = preload("res://assets/musics/puzzle.mp3")
const PUZZLE_2_MUSIC = preload("res://assets/musics/puzzle_2.mp3")
var current_music := Musics.NONE

var current_stream: AudioStreamPlayer

func play(music: Musics) -> void:
	if music == current_music:
		return
	current_music = music
	if is_instance_valid(current_stream):
		current_stream.queue_free()
	if music == Musics.NONE:
		return
	current_stream = AudioStreamPlayer.new()
	match music:
		Musics.MENU:
			current_stream.volume_db = -20
			current_stream.stream = MENU_MUSIC
		Musics.PUZZLE:
			current_stream.volume_db = -18
			current_stream.stream = PUZZLE_MUSIC
		Musics.PUZZLE_2:
			current_stream.volume_db = -18
			current_stream.stream = PUZZLE_2_MUSIC
	add_child(current_stream)
	current_stream.play()
