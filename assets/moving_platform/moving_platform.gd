extends CSGBox3D


@export var trigger_group := 0
@export var open_delay := 5.0
@export var trigger_position := Vector3.ZERO

@onready var root := get_tree().current_scene
@onready var base_position := position

var delay := 0.0

func trigger(_from: Node3D) -> void:
	_open()
	delay = open_delay

func trigger_once(_from: Node3D) -> void:
	_open()
	delay = 99999

func untrigger(_from: Node3D) -> void:
	_close()

func _open() -> void:
	set_process(true)
	var tween := get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "position", base_position + trigger_position, trigger_position.length() * 0.2)

func _close() -> void:
	set_process(false)
	var tween := get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "position", base_position, trigger_position.length() * 0.2)


func _process(delta: float) -> void:
	delay -= delta * root.speed_factor()
	if delay < 0.0:
		_close()
