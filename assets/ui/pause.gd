extends Panel

@onready var root: GameRoot = get_tree().current_scene

func show_pause() -> void:
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func hide_pause_menu() -> void:
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
		if get_tree().paused:
			show_pause()
		else:
			hide_pause_menu()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://levels/menu.tscn")

func _on_restart_floor_pressed() -> void:
	get_tree().paused = false
	root.restart_level()


func _on_resume_pressed() -> void:
	hide_pause_menu()
