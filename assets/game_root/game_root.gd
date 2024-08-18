class_name GameRoot
extends Node3D

@export var floor_id := 0

const CLONE_PATH_FOLLOW = preload("res://assets/clone/path_follow/clone_path_follow.tscn")

var game_speed := 1.0
var detection := 0.0
var last_detected := Time.get_ticks_msec()
var player : Player
var moving_time := false

@onready var detection_progress_bar: ProgressBar = $CanvasLayer/Container/Detection/ProgressBar
const PLAYER = preload("res://assets/player/player.tscn")

func add_player() -> void:
	player = PLAYER.instantiate()
	for cell in $Cells.get_children():
		if cell.cell_id == GameManager.checkpoints[floor_id]:
			player.position = cell.global_position
	add_child(player)

func _ready() -> void:
	show_dialogue("You", "It's too heavy, i can't hold it!")
	add_player()
	var clones : Array[Clone]
	clones.assign($Clones.get_children())
	for clone in clones:
		if clone.moving:
			var path := $Paths.get_node_or_null(NodePath(clone.path_id))
			var path_follow := CLONE_PATH_FOLLOW.instantiate()
			clone.path_follow = path_follow
			path.add_child(path_follow)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	if event.is_action_pressed("fullscreen"):
		var current_mode := get_window().mode

@onready var actions: HBoxContainer = $CanvasLayer/Container/Actions

func speed_factor() -> float:
	return pow(game_speed, 2)


@onready var crosshair: TextureRect = $CanvasLayer/Container/Crosshair

const CROSSHAIR_DEFAULT = preload("res://assets/ui/crosshair001.png")
const CROSSHAIR_ACTION = preload("res://assets/ui/crosshair038.png")

func _process(delta: float) -> void:
	crosshair.texture = CROSSHAIR_ACTION if player.can_scale_looking or player.can_scale_looking else CROSSHAIR_DEFAULT
	actions.get_node("Scale").visible = player.can_scale_looking
	actions.get_node("Hold").visible = player.can_hold_looking
	detection_progress_bar.value = detection

func player_detected(delta: float) -> void:
	detection += 0.5 * delta
	last_detected = Time.get_ticks_msec()
	if detection >= 1.0:
		player_busted()


func player_busted() -> void:
	var tween := create_tween()
	$CanvasLayer/Container/Transition.visible = true
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()


func speed_up_game() -> void:
	if moving_time:
		return
	moving_time = true
	var tween := get_tree().create_tween()
	tween.tween_property(self, "game_speed", 2.0, 2.5)
	tween.tween_interval(5.0)
	tween.tween_property(self, "game_speed", 1.0, 2.5)
	tween.tween_property(self, "moving_time", false, 0.0)

func slow_down_game() -> void:
	if moving_time:
		return
	moving_time = true
	var tween := get_tree().create_tween()
	tween.tween_property(self, "game_speed", 0.5, 2.5)
	tween.tween_interval(5.0)
	tween.tween_property(self, "game_speed", 1.0, 2.5)
	tween.tween_property(self, "moving_time", false, 0.0)



func trigger_group() -> void:
	pass

@onready var dialogue_box: Panel = $CanvasLayer/Container/Dialogue
@onready var dialogue_author: RichTextLabel = $CanvasLayer/Container/Dialogue/Author
@onready var dialogue_message: Label = $CanvasLayer/Container/Dialogue/Message

func show_dialogue(from: String, message: String) -> void:
	dialogue_author.text = "[center][wave]" + from + "[/wave][/center]"
	dialogue_message.text = message
	dialogue_box.modulate.a = 0.0
	var tween := get_tree().create_tween()
	tween.tween_property(dialogue_box, "modulate:a", 1.0, 0.5)
	tween.tween_property(dialogue_message, "visible_ratio", 1.0, 2.5)


func player_died() -> void:
	var tween := create_tween()
	$CanvasLayer/Container/Transition.visible = true
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()
