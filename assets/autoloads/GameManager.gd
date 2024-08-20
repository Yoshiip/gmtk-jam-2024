extends Node


const MAX_LEVEL := 12

func play_next_level() -> void:
	var current_level: int = get_tree().current_scene.level_id
	if current_level == MAX_LEVEL:
		get_tree().change_scene_to_file("res://islands/exit.tscn")
	else:
		get_tree().change_scene_to_file(str("res://levels/puzzles/", current_level + 1, ".tscn"))
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		var current_mode := get_window().mode
		get_window().mode = Window.MODE_FULLSCREEN if current_mode == Window.MODE_WINDOWED else Window.MODE_WINDOWED
	

var total_shoots := 0
var total_deaths := 0
