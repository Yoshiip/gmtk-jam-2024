extends StaticBody3D

var player: Player

@onready var root: GameRoot = get_tree().current_scene

const BASE_FIRE_SPEED := 0.125
@onready var fire_speed := BASE_FIRE_SPEED

const PROJECTILE = preload("res://assets/turret/projectile/projectile.tscn")

func _get_player() -> void:
	player = root.player

@onready var cannon_point: Marker3D = $Cannon/CSGBox3D2/CannonPoint

func shoot() -> void:
	var projectile := PROJECTILE.instantiate()
	add_sibling(projectile)
	projectile.global_position = cannon_point.global_position
	projectile.look_at(player.global_position + Vector3.UP + Vector3(randf() - 0.5,randf() - 0.5,randf() - 0.5).normalized()*0.1)
	fire_speed = BASE_FIRE_SPEED

func _process(delta: float) -> void:
	if is_instance_valid(player):
		if player.global_position.distance_to(global_position) < 10:
			fire_speed -= delta * root.speed_factor()
			if fire_speed < 0.0:
				shoot()
			var direction := (player.global_position - global_position).normalized()
			var angle_y := atan2(direction.x, direction.z)
			$Cannon.rotation.y = angle_y
	else:
		_get_player()
