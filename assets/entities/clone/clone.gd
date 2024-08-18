class_name Clone
extends CharacterBody3D

const CLONE_DEAD_PARTICLES = preload("res://assets/entities/clone/dead_particles/clone_dead_particles.tscn")

@export var moving := false
@export var path_id : StringName = ""

@onready var root := get_tree().current_scene
const SPEED = 1.0
const JUMP_VELOCITY = 4.5
const SCALES := [0.4, 0.75, 1.0, 1.5, 2.0, 3.0]
var current_scale_index := 2
var current_scale := Vector3.ONE

var path_follow: ClonePathFollow

func _process(delta: float) -> void:
	if player_inside_area && !player.safe:
		$DetectionRayCast.look_at(player.global_position + Vector3.UP)
		if $DetectionRayCast.is_colliding():
			if $DetectionRayCast.get_collider().name == "Player":
				root.player_detected(delta)

func _get_scale() -> Vector3:
	var s : float = SCALES[current_scale_index]
	return Vector3(s, s, s)


func _physics_process(delta: float) -> void:
	if moving:
		path_follow.progress += SPEED * delta * root.game_speed
		global_transform = path_follow.global_transform.scaled_local(current_scale)

func _transition_scale() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "current_scale", _get_scale(), 0.175)

func on_scale(scaled : bool) -> void:
	if scaled:
		current_scale_index = min(current_scale_index + 1, SCALES.size() - 1)
	else:
		current_scale_index = max(current_scale_index - 1, 0)
	_transition_scale()


var player_inside_area := false

var player: Player

func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		player = body
		player_inside_area = true

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		player_inside_area = false
	

func kill() -> void:
	var particles := CLONE_DEAD_PARTICLES.instantiate()
	particles.position = position
	add_sibling(particles)
	queue_free()
