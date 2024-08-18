extends StaticBody3D

const PROJECTILE = preload("res://assets/entities/turret/projectile/projectile.tscn")

var player: Player


const BASE_FIRE_SPEED := 0.125
@onready var root: GameRoot = get_tree().current_scene
@onready var fire_speed := BASE_FIRE_SPEED


func _get_player() -> void:
	player = root.player

@onready var cannon_point: Marker3D = $Turret/CannonPoint
@onready var mesh: Node3D = $Mesh

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
			mesh.rotation.y = atan2(direction.x, direction.z)
	else:
		_get_player()
