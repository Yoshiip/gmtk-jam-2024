extends Area3D

@onready var root: Node3D = $".."

@export var trigger_group := -1


func _on_body_entered(body: Node3D) -> void:
	root.trigger_group(trigger_group)
