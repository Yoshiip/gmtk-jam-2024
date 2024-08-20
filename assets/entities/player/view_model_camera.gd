extends Camera3D


@onready var fps_rig := $FPSRig

var i := 0.0
func _process(delta: float) -> void:
	fps_rig.position.x = lerp(fps_rig.position.x, 0.0, delta * 5.0)
	fps_rig.position.y = lerp(fps_rig.position.y, 0.0, delta * 5.0) + cos(i) * 0.0005
	i += delta

func sway(amount: Vector2) -> void:
	fps_rig.position.x += amount.x*0.0002
	fps_rig.position.y += amount.y*0.0003
