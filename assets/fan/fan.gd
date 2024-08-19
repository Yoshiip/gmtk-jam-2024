extends Prop

var bodies_inside: Array[Node3D]

@export var strength := 2.0
@export var max_range := 10.0

func _physics_process(delta: float) -> void:
	for body in bodies_inside:
		var strength: float = max((max_range + (position.y - body.position.y)), 0.0) * strength * _get_scale().x
		if is_instance_of(body, RigidBody3D):
			body.apply_force(Vector3.UP * delta * strength * 500.0)
		elif is_instance_of(body, CharacterBody3D):
			body.velocity.y += delta * strength


func _on_air_area_body_entered(body: Node3D) -> void:
	bodies_inside.append(body)


func _on_air_area_body_exited(body: Node3D) -> void:
	bodies_inside.erase(body)

func on_scale(plus := true) -> void:
	if plus:
		var new_scale: float = min(current_scale + 1, scales.size() - 1)
		current_scale = new_scale
	else:
		current_scale = max(current_scale - 1, 0)
	_transition_scale()
	

func _transition_scale() -> void:
	var tween := create_tween()
	tween.set_parallel()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property($Mesh, "scale", _get_scale(), 0.3)
	tween.tween_property($AirArea, "scale", _get_scale(), 0.3)
	tween.tween_property($CollisionShape, "scale", _get_scale(), 0.0)
	mass = base_mass * scales[current_scale]
