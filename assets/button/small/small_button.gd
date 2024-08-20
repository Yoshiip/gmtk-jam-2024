extends StaticBody3D

@export var button_group := 0

@onready var root: GameRoot = get_tree().current_scene

func on_interact() -> void:
	root.trigger_group(self, button_group)
