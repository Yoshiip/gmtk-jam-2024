extends Node3D


@onready var root := get_tree().current_scene

func _process(delta: float) -> void:
	$Arrow.rotation.z -= delta * root.speed_factor() * PI / 2
	$SmallArrow.rotation.z -= delta * root.speed_factor() * PI / 12

func on_scale(up: bool) -> void:
	if up:
		root.speed_up_game()
	else:
		root.slow_down_game()
