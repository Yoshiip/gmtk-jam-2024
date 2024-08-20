extends Prop

@export var min_angle := -75
@export var max_angle := 75
@export var speed := 15.0

@onready var root : GameRoot = get_tree().current_scene
@onready var target_angle := min_angle
@onready var detection_ray_cast: RayCast3D = $DetectionRayCast

var player: Player
var player_inside := false
var was_inside := false

func _ready() -> void:
	min_angle += rotation_degrees.y
	max_angle += rotation_degrees.y
	rotation_degrees.y = 0

func _process(delta: float) -> void:
	var area_rotation : float = $Area.rotation_degrees.y
	if player_inside:
		if !was_inside:
			was_inside = true
			$Alerted.play()
		var direction := (player.global_position - global_position).normalized()
		var angle := atan2(direction.x, direction.z) + PI
		rotation.y = angle - PI / 2
		detection_ray_cast.look_at(player.global_position)
		if detection_ray_cast.is_colliding():
			if detection_ray_cast.get_collider().name == "Player":
				root.player_detected(self, delta)
	else:
		was_inside = false
		rotation_degrees.y = move_toward(area_rotation, target_angle, delta * speed * root.speed_factor())
		if area_rotation == target_angle:
			target_angle = min_angle if target_angle == max_angle else max_angle

func player_caught() -> void:
	pass

func _on_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		player = body
		player_inside = true


func _on_area_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		player_inside = false
