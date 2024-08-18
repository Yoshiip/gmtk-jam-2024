extends Node3D

@export var floor := "0"
@export var section := ""

func _ready() -> void:
	$CurrentFloor.text = floor
	$Section.text = section
