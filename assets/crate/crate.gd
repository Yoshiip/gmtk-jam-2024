extends Prop

func on_scale(scaled_up := true) -> void:
	if scaled_up:
		var new_scale: float = min(current_scale + 1, scales.size() - 1)
		if _can_change_scale(new_scale):
			current_scale = new_scale
		else:
			return
	else:
		current_scale = max(current_scale - 1, 0)
	holdable = current_scale == 0
	_transition_scale()
