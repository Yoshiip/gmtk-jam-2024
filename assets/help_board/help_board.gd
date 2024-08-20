extends Prop

@export var title := ""
@export_multiline var text := ""

func _ready() -> void:
	$Title.text = title.to_upper()
	$Text.text = text.capitalize()
