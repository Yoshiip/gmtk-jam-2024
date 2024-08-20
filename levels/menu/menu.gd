extends Node3D


var levels_count := 12
@onready var levels_container: VBoxContainer = $CanvasLayer/Control/HBox/Levels

@onready var credits_container: VBoxContainer = $CanvasLayer/Control/HBox/Credits/Container

const CREDITS := {
	"Yoshiip": ["Code", {
		"Website": "",
	}],
	"Troutking": ["2D Art, 3D Art, Textures"],
	"Barbedor": ["Music"],
	"moose": ["SFX"],
	"Vuski": ["Game Design"],
}

const CREDIT_LINE = preload("res://assets/ui/credit_line/credit_line.tscn")

func _ready() -> void:
	MusicManager.play(MusicManager.Musics.MENU)
	for key in CREDITS:
		var line := CREDIT_LINE.instantiate()
		line.get_node("Header/Name").text = key
		line.get_node("Description").text = CREDITS[key][0]
		credits_container.add_child(line)
	for level in range(levels_count):
		var button := Button.new()
		button.text = str("Level ", level + 1)
		button.pressed.connect(_button_pressed.bind(level))
		levels_container.add_child(button)
	

func _button_pressed(level: int) -> void:
	get_tree().change_scene_to_file(str("res://levels/puzzles/", level, ".tscn"))
