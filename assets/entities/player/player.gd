class_name Player
extends CharacterBody3D


var scales := [0.5, 1.0, 1.5, 2.0]
var current_scale := 1

@export var mass := 20.0
var can_hold_looking := false
var can_scale_looking := false

var safe := false

const SPEED = 4.0
const JUMP_VELOCITY = 4.8
const LOOK_SENSITIVITY := 0.003

#bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.06
var t_bob = 0.0


const BASE_GUN_COOLDOWN := 0.25
var footstep_timer := 0.25

var holded: Prop

@onready var ceil_ray_cast: RayCast3D = $CeilRayCast
@onready var root: GameRoot = get_tree().current_scene
@onready var head: Marker3D = $Head
@onready var camera: Camera3D = $Head/Camera
@onready var main_ray: RayCast3D = camera.get_node("MainRay")

@onready var sub_viewport: SubViewport = camera.get_node("SubViewportContainer/SubViewport")
@onready var view_model_camera: Camera3D = sub_viewport.get_node("ViewModelCamera")

@onready var scale_gun: ScaleGun = view_model_camera.get_node("FPSRig/ScaleGun")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func get_total_mass() -> float:
	if is_instance_valid(holded):
		return mass + holded.mass
	return mass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * LOOK_SENSITIVITY)
		camera.rotate_x(-event.relative.y * LOOK_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		view_model_camera.sway(Vector2(event.relative.x, event.relative.y))

const SCALABLE_FLAG := 2
var trauma := 0.0

func _drop_holded() -> void:
	if is_instance_valid(holded):
		holded.on_hold(false, camera.rotation.x > -0.5)
		holded = null

func _handle_interact() -> void:
	can_hold_looking = false
	if holded:
		if Input.is_action_just_pressed("interact"):
			_drop_holded()
	elif main_ray.is_colliding():
		var collider := main_ray.get_collider()
		if is_instance_valid(collider) && collider.has_method("on_interact"):
			print(collider.global_position.distance_to(global_position))
			if Input.is_action_just_pressed("interact") && collider.global_position.distance_to(global_position) < 3.0:
				collider.on_interact()
		elif is_instance_valid(collider) && collider.get("holdable"):
			if collider.global_position.distance_to(self.position) < 3 and not current_scale == 0:
				can_hold_looking = true
				if Input.is_action_just_pressed("interact"):
					collider.on_hold(true)
					holded = collider
		
		
	can_scale_looking = false
	if main_ray.is_colliding():
		var collider := main_ray.get_collider()
		if is_instance_valid(collider) && collider.collision_layer ^ SCALABLE_FLAG == 1:
			can_scale_looking = true
			if Input.is_action_just_pressed("shoot") && scale_gun.can_shoot():
				if collider.on_scale(scale_gun.option == "+"):
					trauma = 0.075
					var prop_scale: float = collider.get("current_scale")
					scale_gun.scale_shooted(1 if prop_scale == null else prop_scale)
				else:
					scale_gun.shoot_invalid()
	#if mode == "time":
		#if Input.is_action_just_pressed("shoot") && scale_gun.can_shoot():
			#if scale_gun.option == "+":
				#root.speed_up_game()
			#else:
				#root.slow_down_game()
			#scale_gun.time_shooted()
	#elif mode == "self":
		#if (Input.is_action_just_pressed("shoot")
			#&& scale_gun.can_shoot()):
			#if ceil_ray_cast.is_colliding():
				#scale_gun.shoot_invalid()
			#else:
				#scale_gun.self_shooted()
				#_change_scale(scale_gun.option == "+")


func _change_scale(plus := true) -> void:
	if plus:
		var new_scale: float = min(current_scale + 1, scales.size() - 1)
		if current_scale != new_scale:
			$SizeUp.pitch_scale = 1.0 + new_scale / 12.0
			$SizeUp.play()
		current_scale = new_scale
	else:
		var new_scale: float = max(current_scale - 1, 0)
		if current_scale != new_scale:
			$SizeDown.pitch_scale = 1.0 + new_scale / 12.0
			$SizeDown.play()
		current_scale = new_scale
	_transition_scale()

func _transition_scale() -> void:
	var tween := create_tween()
	tween.set_parallel()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "scale", _get_scale(), 0.3)
	mass = 20.0 * scales[current_scale]
	_drop_holded()

func _get_scale(index = -1) -> Vector3:
	if index == -1:
		var s: float = scales[current_scale]
		return Vector3(s, s, s)
	else:
		return Vector3(scales[index], scales[index], scales[index]) 


func _process(delta: float) -> void:
	trauma *= 0.75
	$Head/Camera.h_offset = randf_range(-trauma, trauma)
	$Head/Camera.v_offset = randf_range(-trauma, trauma)
	view_model_camera.h_offset = randf_range(-trauma, trauma) * 0.1
	view_model_camera.v_offset = randf_range(-trauma, trauma) * 0.1

func _handle_footstep(delta: float) -> void:
	footstep_timer -= ((velocity * Vector3(1, 0, 1)).length() / SPEED) * delta
	if footstep_timer < 0.0:
		$Footstep.play()
		$Footstep.pitch_scale = randf_range(0.8, 1.2)
		footstep_timer = randf_range(0.65, 0.80)

var caught_by: Node3D

var was_on_floor := true

func _physics_process(delta: float) -> void:
	if is_instance_valid(caught_by):
		$Head/Camera.look_at(caught_by.get_node("Eyes").global_position)
		return
	if is_instance_valid(holded):
		var holded_middle := holded.get_node_or_null("Middle")
		var offset_y := 0.0
		if holded_middle != null:
			offset_y += holded_middle.position.y
		holded.global_position = global_position + Vector3.FORWARD.rotated(Vector3.UP, camera.global_rotation.y) + Vector3(0, 1.0 - offset_y, 0)
		view_model_camera.visible = false
	else:
		view_model_camera.visible = true
		view_model_camera.global_transform = camera.transform
	# Add the gravity.
	if is_on_floor():
		if not was_on_floor:
			was_on_floor = true
			trauma = 0.05
			$Impact.play()
	else:
		was_on_floor = false
		velocity += get_gravity() * delta
	
	_handle_interact()
	_handle_footstep(delta)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		$Jump.play()
		$Jump.pitch_scale = 1.5 if current_scale == 0 else 1.0
		velocity.y = JUMP_VELOCITY * max(sqrt(scales[current_scale]), 1.0)

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 3.0)
	


	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	move_and_slide()
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

var weak := false

func damage() -> void:
	if weak:
		root.player_died()
	else:
		weak = true
		trauma += 0.5
		velocity = Vector3.ZERO
