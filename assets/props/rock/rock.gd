extends Prop



func _physics_process(delta: float) -> void:
	if !throwed:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO

func on_scale(scaled_up := true) -> void:
	if scaled_up:
		current_scale = min(current_scale + 1, scales.size() - 1)
	else:
		current_scale = max(current_scale - 1, 0)
	_transition_scale()
	holdable = current_scale == 0

func on_hold(picked_up := true) -> void:
	if picked_up:
		sleeping = true
	else:
		throwed = true
		var player := get_tree().get_nodes_in_group("Player")[0]
		apply_impulse(((global_position - player.global_position) * Vector3(1, 0, 1)).normalized() * 10.0 + Vector3(0, 2, 0))


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Clone") and linear_velocity.length() > 2.0:
		body.kill()
		queue_free()
