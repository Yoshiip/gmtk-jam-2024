extends Control


@export var levels_count := 5
@onready var v_box_container: VBoxContainer = $CanvasLayer/VBoxContainer

func _ready() -> void:
	for level in range(levels_count):
		var button := Button.new()
		button.text = str("Level ", level)
		button.pressed.connect(_button_pressed.bind(level))
		v_box_container.add_child(button)
	

func _button_pressed(level: int) -> void:
	get_tree().change_scene_to_file(str("res://levels/puzzles/", level, ".tscn"))
