class_name Prop
extends RigidBody3D

@export var base_mass := 1.0
@export var scales: Array[float] = []
@export var current_scale := 0

@export var holdable := false
var throwed := false

var holded := false:
	set(value):
		holded = value
		$CollisionShape.disabled = holded

func _ready() -> void:
	_transition_scale()

func _get_scale(index = -1) -> Vector3:
	if index == -1:
		var s: float = scales[current_scale]
		return Vector3(s, s, s)
	else:
		return Vector3(scales[index], scales[index], scales[index]) 

func _can_change_scale(new_scale: float) -> bool:
	return true
	#var shape_rid := PhysicsServer3D.box_shape_create()
	#var prop_shape_size: Vector3 = $CollisionShape.shape.size * _get_scale()
	#PhysicsServer3D.shape_set_data(shape_rid, prop_shape_size / 2.0)
#
	#var params = PhysicsShapeQueryParameters3D.new()
	#params.shape_rid = shape_rid
	#
	#params.transform = global_transform.translated(Vector3.UP * new_scale * 2.0)
	#var space_query: Array[Dictionary] = get_world_3d().direct_space_state.intersect_shape(params)
	#for query in space_query:
		#if query.rid == get_rid():
			#space_query.erase(query)
	#PhysicsServer3D.free_rid(shape_rid)
	#return space_query.is_empty()

func _transition_scale() -> void:
	var tween := create_tween()
	tween.set_parallel()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property($Mesh, "scale", _get_scale(), 0.3)
	tween.set_parallel()
	tween.tween_property($CollisionShape, "scale", _get_scale(), 0.0)
	mass = base_mass * scales[current_scale]

func on_scale(plus := true) -> void:
	if plus:
		var new_scale: float = min(current_scale + 1, scales.size() - 1)
		if _can_change_scale(new_scale):
			current_scale = new_scale
		else:
			return
	else:
		current_scale = max(current_scale - 1, 0)
	_transition_scale()
	mass = base_mass * current_scale

func on_hold(picked_up := true, throw := false) -> void:
	holded = picked_up
	if picked_up:
		freeze = true
	else:
		freeze = false
		throwed = true
		if throw:
			var player := get_tree().get_nodes_in_group("Player")[0]
			apply_impulse(((global_position - player.global_position) * Vector3(1, 0, 1)).normalized() * 10.0 + Vector3(0, 2, 0))
