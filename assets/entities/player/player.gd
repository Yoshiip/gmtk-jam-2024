class_name Player
extends CharacterBody3D

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

var scale_mode_up := true

const BASE_GUN_COOLDOWN := 0.25
var gun_cooldown := 0.0

var holded: Node3D

@onready var root: GameRoot = get_tree().current_scene
@onready var head: Marker3D = $Head
@onready var camera: Camera3D = $Head/Camera
@onready var sub_viewport: SubViewport = $Head/Camera/SubViewportContainer/SubViewport
@onready var view_model_camera: Camera3D = $Head/Camera/SubViewportContainer/SubViewport/ViewModelCamera
@onready var main_ray: RayCast3D = $Head/Camera/MainRay
@onready var scale_mode: Label3D = view_model_camera.get_node("FPSRig/ScaleDevice/Mesh/ScaleMode")

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

func _handle_scale_device() -> void:
	if Input.is_action_just_pressed("switch_mode"):
		scale_mode_up = !scale_mode_up
		scale_mode.text = "+" if scale_mode_up else "-"


func _handle_interact() -> void:
	can_hold_looking = false
	if holded:
		if Input.is_action_just_pressed("pickup"):
			holded.on_hold(false)
			holded = null
	elif main_ray.is_colliding():
		var collider := main_ray.get_collider()
		if collider.get("holdable"):
			can_hold_looking = true
			if Input.is_action_just_pressed("pickup"):
				collider.on_hold(true)
				holded = collider
	can_scale_looking = false
	
	if main_ray.is_colliding():
		var collider := main_ray.get_collider()
		if collider.collision_layer ^ SCALABLE_FLAG == 1:
			can_scale_looking = true
			if Input.is_action_pressed("interact") && gun_cooldown <= 0.0:
				collider.on_scale(scale_mode_up)
				trauma = 0.2
				gun_cooldown = BASE_GUN_COOLDOWN


func _process(delta: float) -> void:
	gun_cooldown -= delta
	trauma *= 0.8
	$Head/Camera.h_offset = randf_range(-trauma, trauma)
	$Head/Camera.v_offset = randf_range(-trauma, trauma)
	view_model_camera.h_offset = randf_range(-trauma, trauma)
	view_model_camera.v_offset = randf_range(-trauma, trauma)

func _physics_process(delta: float) -> void:
	if is_instance_valid(holded):
		holded.position = global_position + Vector3(0, 0.75, 0) + Vector3.FORWARD.rotated(Vector3.UP, camera.global_rotation.y)
		view_model_camera.visible = false
	else:
		view_model_camera.visible = true
		view_model_camera.global_transform = camera.transform
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	_handle_scale_device()
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
