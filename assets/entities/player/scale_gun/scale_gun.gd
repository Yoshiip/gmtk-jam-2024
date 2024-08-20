class_name ScaleGun
extends Node3D

@onready var root: GameRoot = get_tree().current_scene


@onready var option_label: Label3D = $ScaleGun/Option


var option := "+":
	set(value):
		option = value
		option_label.text = option
		option_label.modulate = Color.GREEN if "+" else Color.RED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_polarity"):
		self.option = "-" if self.option == "+" else "+"


func _process(delta: float) -> void:
	cooldown -= delta

func _animate_gun() -> void:
	rotation_degrees.x = 10
	var tween := get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "rotation:x", 0, 0.15)

func scale_shooted(new_prop_scale: float) -> void:
	GameManager.total_shoots += 1
	_animate_gun()
	cooldown = 0.25
	$Pitch.pitch_scale = 1.0 + new_prop_scale / 12.0
	$Pitch.play()

func shoot_invalid() -> void:
	$Error.play()

func time_shooted() -> void:
	GameManager.total_shoots += 1
	_animate_gun()
	cooldown = 1.0

func self_shooted() -> void:
	GameManager.total_shoots += 1
	_animate_gun()
	cooldown = 0.25

var cooldown := 0.0

func can_shoot() -> bool:
	return cooldown < 0.0
