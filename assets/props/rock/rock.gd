extends Prop

func on_scale(scaled_up := true) -> bool:
	if scaled_up:
		var new_scale: float = min(current_scale + 1, scales.size() - 1)
		if _can_change_scale(new_scale):
			current_scale = new_scale
		else:
			return false
	else:
		current_scale = max(current_scale - 1, 0)
	_transition_scale()
	holdable = current_scale == 0
	return true



func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Clone") and linear_velocity.length() > 1.0:
		body.kill()
		queue_free()
