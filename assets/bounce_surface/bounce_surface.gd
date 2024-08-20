extends StaticBody3D


@export var scales: Array[float] = []
@export var current_scale := 0

func _ready() -> void:
	_transition_scale()

func _get_scale(index = -1) -> Vector3:
	if index == -1:
		var s: float = scales[current_scale]
		return Vector3(s, s, s)
	else:
		return Vector3(scales[index], scales[index], scales[index]) 

func _transition_scale() -> void:
	var tween := create_tween()
	tween.set_parallel()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property($Mesh, "scale", _get_scale(), 0.3)
	tween.set_parallel()
	tween.tween_property($CollisionShape, "scale", _get_scale(), 0.0)

func on_scale(scaled_up := true) -> bool:
	if scaled_up:
		current_scale = min(current_scale + 1, scales.size() - 1)
	else:
		current_scale = max(current_scale - 1, 0)
	_transition_scale()
	return true

func destroy() -> void:
	queue_free()
