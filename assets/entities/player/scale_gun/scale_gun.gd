class_name ScaleGun
extends Node3D

@onready var root: GameRoot = get_tree().current_scene


@onready var mode_label: Label3D = $ScaleGun/Mode

var modes := [
	"objects",
	"time",
	"self"
]

var mode := 0:
	set(value):
		mode = value
		mode_label.text = modes[mode].capitalize()



func _ready() -> void:
	if !root.can_scale_time:
		modes.erase("time")
	if !root.can_scale_self:
		modes.erase("self")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("prev_mode"):
		_prev_mode()
	if event.is_action_pressed("next_mode"):
		_next_mode()

func _process(delta: float) -> void:
	cooldown -= delta


func _next_mode() -> void:
	self.mode = (self.mode + 1) % modes.size()


func _prev_mode() -> void:
	self.mode = fmod(float(self.mode) - 1.0, float(modes.size()))


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
