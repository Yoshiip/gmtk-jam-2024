class_name Player
extends CharacterBody3D


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

@onready var root: GameRoot = get_tree().current_scene
@onready var head: Marker3D = $Head
@onready var camera: Camera3D = $Head/Camera
@onready var main_ray: RayCast3D = camera.get_node("MainRay")

@onready var sub_viewport: SubViewport = camera.get_node("SubViewportContainer/SubViewport")
@onready var view_model_camera: Camera3D = sub_viewport.get_node("ViewModelCamera")

@onready var scale_gun: ScaleGun = view_model_camera.get_node("FPSRig/ScaleGun")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	sub_viewport.size = DisplayServer.window_get_size()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * LOOK_SENSITIVITY)
		camera.rotate_x(-event.relative.y * LOOK_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

const SCALABLE_FLAG := 2
var trauma := 0.0

func _handle_interact() -> void:
	can_hold_looking = false
	if holded:
		if Input.is_action_just_pressed("interact"):
			holded.on_hold(false, camera.rotation.x > -0.5)
			holded = null
	elif main_ray.is_colliding():
		var collider := main_ray.get_collider()
		
		if is_instance_valid(collider) && collider.has_method("on_interact"):
			if Input.is_action_just_pressed("interact"):
				collider.on_interact()
		elif is_instance_valid(collider) && collider.get("holdable"):
			if collider.global_position.distance_to(self.position) < 3:
				can_hold_looking = true
				if Input.is_action_just_pressed("interact"):
					collider.on_hold(true)
					holded = collider
		
		
	if scale_gun.mode == GUN_MODE_SCALE:
		can_scale_looking = false
		if main_ray.is_colliding():
			var collider := main_ray.get_collider()
			if is_instance_valid(collider) && collider.collision_layer ^ SCALABLE_FLAG == 1:
				can_scale_looking = true
				if Input.is_action_pressed("shoot") && scale_gun.can_shoot():
					collider.on_scale(scale_gun.option == "+")
					trauma = 0.125
					scale_gun.shooted()
	elif scale_gun.mode == GUN_MODE_TIME:
		if Input.is_action_pressed("shoot") && scale_gun.can_shoot():
			if scale_gun.option == "+":
				root.speed_up_game()
			else:
				root.slow_down_game()
			scale_gun.shooted()
	else:
		pass
const GUN_MODE_SCALE := 0
const GUN_MODE_TIME := 1
const GUN_MODE_SELF := 2

func _process(delta: float) -> void:
	trauma *= 0.75
	$Head/Camera.h_offset = randf_range(-trauma, trauma)
	$Head/Camera.v_offset = randf_range(-trauma, trauma)
	view_model_camera.h_offset = randf_range(-trauma, trauma)
	view_model_camera.v_offset = randf_range(-trauma, trauma)

func _handle_footstep(delta: float) -> void:
	footstep_timer -= ((velocity * Vector3(1, 0, 1)).length() / SPEED) * delta
	if footstep_timer < 0.0:
		$Footstep.play()
		footstep_timer = randf_range(0.25, 3)

func _physics_process(delta: float) -> void:
	if is_instance_valid(holded):
		holded.global_position = global_position + Vector3.FORWARD.rotated(Vector3.UP, camera.global_rotation.y)
		view_model_camera.visible = false
	else:
		view_model_camera.visible = true
		view_model_camera.global_transform = camera.transform
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	_handle_interact()

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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
	
	_handle_footstep(delta)


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
