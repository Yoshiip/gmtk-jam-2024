extends Prop

@onready var root := get_tree().current_scene

func _ready() -> void:
	$Floor.text = str(root.level_id + 1)
	$Deaths.text = str(GameManager.total_deaths, " deaths")

func _process(delta: float) -> void:
	$Shoots.text = str(GameManager.total_shoots, " shoots")
