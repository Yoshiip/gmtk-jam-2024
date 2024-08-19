class_name ScaleGun
extends Node3D

const MODES := [
	"objects",
	"time",
	"self"
]


@onready var current_mode: Label3D = $CurrentMode
@onready var option_label: Label3D = $Option

var mode := 0:
	set(value):
		mode = value
		current_mode.text = MODES[mode]

var option := "+":
	set(value):
		option = value
		option_label.text = option

func _next_mode() -> void:
	self.mode = (self.mode + 1) % MODES.size()

func _prev_mode() -> void:
	self.mode = fmod(float(self.mode) - 1.0, float(MODES.size()))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_polarity"):
		self.option = "-" if self.option == "+" else "+"
	if event.is_action_pressed("prev_mode"):
		_prev_mode()
	if event.is_action_pressed("next_mode"):
		_next_mode()

var i := 0.0

func _process(delta: float) -> void:
	position.y = sin(i) * 0.02
	i += delta


func shoot_animation() -> void:
	get_parent().rotation_degrees.x = 10
	var tween := get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(get_parent(), "rotation:x", 0, 0.15)
