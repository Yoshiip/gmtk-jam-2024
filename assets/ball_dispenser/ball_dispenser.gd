extends CSGCylinder3D
@onready var spawnpoint: Marker3D = $Spawnpoint

@export var trigger_group := 0
const BALL = preload("res://assets/props/ball.tscn")

var current_ball: Prop

func trigger(_f) -> void:
	if is_instance_valid(current_ball):
		current_ball.queue_free()
	var ball := BALL.instantiate()
	current_ball = ball
	ball.position = spawnpoint.global_position
	add_sibling(ball)
