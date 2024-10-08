extends Node


const MAX_LEVEL := 11

var levels_completed: Array[int ]= []

func level_completed() -> void:
	var current_level: int = get_tree().current_scene.level_id
	if !levels_completed.has(current_level):
		levels_completed.append(current_level)
	if current_level == MAX_LEVEL:
		MusicManager.play(MusicManager.Musics.NONE)
		get_tree().change_scene_to_file("res://levels/end.tscn")
	else:
		get_tree().change_scene_to_file(str("res://levels/puzzles/", current_level + 1, ".tscn"))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		var current_mode := get_window().mode
		get_window().mode = Window.MODE_FULLSCREEN if current_mode == Window.MODE_WINDOWED else Window.MODE_WINDOWED
	

var total_shoots := 0
var total_deaths := 0
