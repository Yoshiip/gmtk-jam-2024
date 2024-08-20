extends Node3D

@onready var root := get_tree().current_scene

@export var speed := 10.0
@export var inverted := false
@export var trigger_group := 0
@export var open_delay := 1.0

func _ready() -> void:
	if inverted:
		delay = 0.0


var delay := 0.0



func trigger(_from: Node3D) -> void:
	delay = open_delay


func trigger_once(_from: Node3D) -> void:
	delay = 99999


func untrigger(_from: Node3D) -> void:
	delay = open_delay

func _is_open() -> bool:
	return $Door.position.y <= 0 if inverted else $Door.position.y >= 4

func _is_close() -> bool:
	return $Door.position.y >= 4 if inverted else $Door.position.y <= 0

func _physics_process(delta: float) -> void:
	delay -= delta * root.speed_factor()
	if delay > 0.0 and not _is_open():
		var coll: KinematicCollision3D = $Door.move_and_collide((Vector3.DOWN if inverted else Vector3.UP) * delta * speed)
	if delay < 0.0 and not _is_close():
		var coll: KinematicCollision3D = $Door.move_and_collide((Vector3.UP if inverted else Vector3.DOWN) * delta * speed)
