@tool
extends Area3D

const BAR = preload("res://assets/world/cell/prison_bars/bar.tscn")

const SPACING := 0.65

@export var bar_count := 9

const SCALES := [1.0, 1.5, 1.75, 2.0]
var current_scale := 0

@onready var max_length := bar_count * SPACING

func _ready() -> void:
	$CollisionShape3D.shape.size.x = max_length
	for i in bar_count:
		var bar := BAR.instantiate()
		bar.position.x = i * SPACING - (bar_count / 2) * SPACING
		$Bars.add_child(bar)

func _hide_outside_bar() -> void:
	for bar in $Bars.get_children():
		bar.visible = abs(bar.position.x * SCALES[current_scale]) < max_length / 2.0

func _transition_scale() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	var s : float = SCALES[current_scale]
	tween.tween_property(self, "scale", Vector3(s, 1, s), 0.3)
	_hide_outside_bar()

func on_scale(plus : bool) -> void:
	if plus:
		current_scale = min(current_scale + 1, SCALES.size() - 1)
	else:
		current_scale = max(current_scale - 1, 0)
	_transition_scale()
