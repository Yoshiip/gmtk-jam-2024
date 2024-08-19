extends Node3D




func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		GameManager.play_next_level()
