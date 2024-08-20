extends Prop

@onready var root: GameRoot = get_tree().current_scene

func _physics_process(delta: float) -> void:
	if root.speed_factor() < 1.0:
		linear_velocity *= 0.99
	elif  root.speed_factor() > 1.0:
		linear_velocity *= 1.02
