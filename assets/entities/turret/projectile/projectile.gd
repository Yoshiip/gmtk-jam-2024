extends Area3D

var speed := 100.0
var lifetime := 5.0

@onready var root := get_tree().current_scene

func _process(delta: float) -> void:
	position += -transform.basis.z * delta * speed * root.speed_factor()
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		body.damage()
	if body.is_in_group("Destroyable"):
		body.kill()
	queue_free()
