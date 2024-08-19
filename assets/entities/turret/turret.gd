extends Prop

const BASE_FIRE_SPEED := 0.175

const PROJECTILE = preload("res://assets/entities/turret/projectile/projectile.tscn")

var player: Player
var trauma := 0.0


@onready var root: GameRoot = get_tree().current_scene
@onready var fire_speed := BASE_FIRE_SPEED

@onready var shoot_slow: AudioStreamPlayer3D = $ShootSlow
@onready var arm: Node3D = $Mesh/Arm
@onready var cannon_point: Marker3D = $Mesh/Arm/CannonPoint

func _get_player() -> void:
	player = root.player


func shoot() -> void:
	shoot_slow.play()
	var projectile := PROJECTILE.instantiate()
	add_sibling(projectile)
	projectile.global_position = cannon_point.global_position
	projectile.look_at(player.global_position + Vector3.UP + Vector3(randf() - 0.5,randf() - 0.5,randf() - 0.5).normalized()*0.1 + player.velocity * 0.1)
	fire_speed = BASE_FIRE_SPEED
	player.trauma += 0.01
	trauma = 0.3


func _process(delta: float) -> void:
	trauma *= 0.9
	arm.position.z = -trauma
@onready var shoot_raycast: RayCast3D = $ShootRaycast

var loading := -1.0
var inside := false

func _physics_process(delta: float) -> void:
	if is_instance_valid(player):
		shoot_raycast.look_at(player.position)
		if shoot_raycast.is_colliding() && player.global_position.distance_to(global_position) < 50:
			var collider := shoot_raycast.get_collider()
			if is_instance_valid(collider) && (collider.is_in_group("Destroyable") || collider.name == "Player"):
				if !inside:
					inside = true
					loading = 1.0
					$TurretOn.play()
				if loading > 0.0:
					loading -= delta
				else:
					fire_speed -= delta * root.speed_factor()
					var direction := (player.global_position - global_position).normalized()
					var angle := atan2(direction.x, direction.z) + PI
					arm.rotation.y = move_toward(arm.rotation.y, angle, delta * 3.0)
					if fire_speed < 0.0 && abs(angle_difference(angle, arm.rotation.y)) < 0.1:
						shoot()
				return
		if inside:
			inside = false
			$TurretOff.play()
	else:
		_get_player()
