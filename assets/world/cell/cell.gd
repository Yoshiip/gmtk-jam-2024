
extends Area3D

@export var checkpoint := true
@export var cell_id := 0

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		body.safe = true

func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		body.safe = false
