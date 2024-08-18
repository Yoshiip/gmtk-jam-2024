extends RigidBody3D

const SCALES := [1.0, 5.0, 10.0]
var current_scale := 0
@onready var root := get_tree().current_scene

var throwed := false
var holded := false:
	set(value):
		holded = value
		$CollisionShape.disabled = holded

@export var holdable := false

func _transition_scale() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SPRING)
	var s : float = SCALES[current_scale]
	tween.tween_property($Mesh, "scale", Vector3(s, s, s), 0.3)
	tween.set_parallel()
	tween.tween_property($CollisionShape, "scale", Vector3(s, s, s), 0.0)


func _physics_process(delta: float) -> void:
	if !throwed:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO

func on_scale(plus : bool) -> void:
	if plus:
		current_scale = min(current_scale + 1, SCALES.size() - 1)
	else:
		current_scale = max(current_scale - 1, 0)
	_transition_scale()
	holdable = current_scale == 0

func on_hold(start: bool) -> void:
	if !start:
		throwed = true
		var player := get_tree().get_nodes_in_group("Player")[0]
		apply_impulse(((global_position - player.global_position) * Vector3(1, 0, 1)).normalized() * 10.0 + Vector3(0, 2, 0))
