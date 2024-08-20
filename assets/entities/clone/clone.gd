class_name Clone
extends CharacterBody3D

const CLONE_DEAD_PARTICLES = preload("res://assets/entities/clone/dead_particles/clone_dead_particles.tscn")

@export var moving := false
@export var path_id : StringName = ""
var scales := [0.4, 0.75, 1.0, 1.5, 2.0, 3.0]
var i := 0.0

var game_over := false
var player_inside_area := false
var player: Player

@onready var root := get_tree().current_scene
const SPEED = 1.0
const JUMP_VELOCITY = 4.5
var current_scale := 2

var path_follow: ClonePathFollow

@onready var base_position := position
var was_detected := false

func _process(delta: float) -> void:
	var detected := player_inside_area && !player.safe
	$Detected.visible = detected
	if detected:

		$DetectionRayCast.look_at(player.global_position + Vector3.UP)
		if $DetectionRayCast.is_colliding():
			
			if $DetectionRayCast.get_collider().name == "Player":
				if !was_detected:
					$Saw.play()
					was_detected = true
				root.player_detected(self, delta)
	elif was_detected:
		was_detected = false


func _get_scale() -> Vector3:
	var s : float = scales[current_scale]
	return Vector3(s, s, s)



func _physics_process(delta: float) -> void:
	i += delta
	$SpotLight.light_energy = 8.0 + sin(i) * 3.0

	if player_inside_area && !player.safe:
		velocity = (player.position - position).normalized() * SPEED * 2.0
	elif moving:
		path_follow.progress += SPEED * delta * root.game_speed
		transform = path_follow.transform.scaled_local(_get_scale())
	elif !position.is_equal_approx(base_position):
		velocity = (base_position - position).normalized() * SPEED * 2.0
	else:
		velocity = velocity.lerp(Vector3.ZERO, delta * 20.0)
	if velocity != Vector3.ZERO:
		var velocity_n := velocity.normalized()
		rotation.y = lerp(rotation.y, atan2(velocity_n.x, velocity_n.z), delta * 0.5)
	
	move_and_slide()

func _transition_scale() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", _get_scale(), 0.25)

func on_scale(scaled : bool) -> void:
	if scaled:
		current_scale = min(current_scale + 1, scales.size() - 1)
	else:
		current_scale = max(current_scale - 1, 0)
	_transition_scale()




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


func player_caught() -> void:
	$Speaking.play()
	set_process(false)
	set_physics_process(false)
	game_over = true
