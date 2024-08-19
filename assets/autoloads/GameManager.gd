extends Node



func play_next_level() -> void:
	var current_level: int = get_tree().current_scene.level_id
	get_tree().change_scene_to_file(str("res://levels/puzzles/", current_level + 1, ".tscn"))
