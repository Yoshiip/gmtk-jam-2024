extends Area3D

@onready var root: GameRoot = get_tree().current_scene

func _process(delta: float) -> void:
	$ceiling_fan.rotation.y += delta * 10.0 * root.speed_factor()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Clone"):
		body.kill()
