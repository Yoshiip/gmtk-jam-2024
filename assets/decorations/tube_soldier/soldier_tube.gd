extends Prop

var i := 0.0

func _ready() -> void:
	i = randf() * 10.0

func _process(delta: float) -> void:
	$Mesh/Clone.position.y = 2.6 + cos(i) * 0.3
	i += delta * 0.4
