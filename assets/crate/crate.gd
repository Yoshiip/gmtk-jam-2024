extends Prop

func on_scale(scaled_up := true) -> void:
	if scaled_up:
		var new_scale: float = min(current_scale + 1, scales.size() - 1)
		for contact in get_colliding_bodies():
			if is_instance_of(contact, RigidBody3D):
				print((contact.position - position).normalized() * 5.0)
				contact.apply_impulse((position - contact.position).normalized() * 5.0)
		if _can_change_scale(new_scale):
			current_scale = new_scale
		else:
			return
	else:
		current_scale = max(current_scale - 1, 0)
	holdable = current_scale == 0
	print(holdable)
	_transition_scale()

func kill() -> void:
	queue_free()
