extends CSGBox3D

const FLOOR = preload("res://assets/materials/stylized/floor.tres")
const WALLS = preload("res://assets/materials/stylized/walls.tres")

func _ready() -> void:
	material = WALLS
	use_collision = true
	position.y -= 0.1
	size.y -= 0.2
	
	var top := CSGBox3D.new()
	top.material = FLOOR
	top.size = Vector3(size.x, 0.2, size.z)
	top.use_collision = true
	top.position.y = (size.y / 2) + 0.1
	add_child(top)
