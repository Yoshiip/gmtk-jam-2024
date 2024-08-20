extends Prop

func _ready() -> void:
	super()
	holdable = current_scale == 0

func on_scale(scaled_up := true) -> bool:
	if scaled_up:
		var new_scale: float = min(current_scale + 1, scales.size() - 1)
		for contact in get_colliding_bodies():
			if is_instance_of(contact, CharacterBody3D):
				return false
			if is_instance_of(contact, RigidBody3D):
				contact.apply_impulse((position - contact.position).normalized() * 5.0)
		if _can_change_scale(new_scale):
			current_scale = new_scale
		else:
			return false
	else:
		current_scale = max(current_scale - 1, 0)
	holdable = current_scale == 0
	mass = base_mass * scales[current_scale]
	_transition_scale()
	return true

func kill() -> void:
	queue_free()
