extends Prop

var bodies_inside: Array[Node3D]

@export var strength := 2.0
@export var max_range := 10.0

var pitch := 1.0
func _physics_process(delta: float) -> void:
	$Mesh/Propellers.rotation.y += delta * strength * 10.0
	pitch = lerp(pitch, strength * _get_scale().x, delta * 0.5)
	print(pitch)
	$Fan.pitch_scale = pitch / 4.0
	for body in bodies_inside:
		var strength: float = max((max_range + (position.y - body.position.y)), 0.0) * strength * _get_scale().x
		if is_instance_of(body, RigidBody3D):
			body.apply_force(transform.basis.y * delta * strength * 500.0)
		elif is_instance_of(body, CharacterBody3D):
			body.velocity += transform.basis.y * delta * strength * Vector3(1.0, transform.basis.y.y, 1.0)


func _on_air_area_body_entered(body: Node3D) -> void:
	bodies_inside.append(body)


func _on_air_area_body_exited(body: Node3D) -> void:
	bodies_inside.erase(body)


func _transition_scale() -> void:
	var tween := create_tween()
	tween.set_parallel()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property($Mesh, "scale", _get_scale(), 0.3)
	tween.tween_property($AirArea, "scale", _get_scale(), 0.3)
	tween.tween_property($CollisionShape, "scale", _get_scale(), 0.0)
	mass = base_mass * scales[current_scale]
