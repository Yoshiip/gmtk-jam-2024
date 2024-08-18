extends Marker3D

@onready var root := get_tree().current_scene

@export var trigger_group := 0
@export var open_delay := 5.0

var delay := 0.0
func trigger(_from: Node3D) -> void:
	_open()
	delay = open_delay

func _open() -> void:
	set_process(true)
	var tween := get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property($Mesh, "position:y", 5, 0.5)

func _close() -> void:
	set_process(false)
	var tween := get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property($Mesh, "position:y", 2, 0.5)

func _process(delta: float) -> void:
	delay -= delta * root.speed_factor()
	if delay < 0.0:
		_close()
