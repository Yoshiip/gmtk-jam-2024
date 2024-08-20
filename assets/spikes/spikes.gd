extends Area3D

@onready var root: GameRoot = get_tree().current_scene


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		root.player_died()
	elif body.is_in_group("Destroyable"):
		body.destroy()
