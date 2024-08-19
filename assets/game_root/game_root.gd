class_name GameRoot
extends Node3D


@export var level_id := 0

const CANVAS_LAYER = preload("res://islands/canvas_layer.tscn")
const PLAYER = preload("res://assets/entities/player/player.tscn")
var game_speed := 1.0
@onready var player: Player
var moving_time := false

var canvas_layer: CanvasLayer

@onready var vignette_material: ShaderMaterial
@onready var actions: HBoxContainer
@onready var crosshair: TextureRect

func _add_player() -> void:
	player = PLAYER.instantiate()
	if is_instance_valid($Spawnpoint):
		player.position = $Spawnpoint.position
	else:
		player.position = Vector3.UP
	add_child(player)

const LEVELS_COMMON = preload("res://assets/levels_common.tscn")

func _ready() -> void:
	
	_add_player()
	
	canvas_layer = CANVAS_LAYER.instantiate()
	add_child(canvas_layer)
	_transition_enter()
	
	add_child(LEVELS_COMMON.instantiate())
	
	vignette_material = canvas_layer.get_node("Container/Vignette").material
	actions = canvas_layer.get_node("Container/Actions")
	crosshair = canvas_layer.get_node("Container/Crosshair")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	if event.is_action_pressed("fullscreen"):
		var current_mode := get_window().mode
		get_window().mode = Window.MODE_FULLSCREEN if current_mode == Window.MODE_WINDOWED else Window.MODE_FULLSCREEN




const CROSSHAIR_DEFAULT = preload("res://assets/ui/crosshair001.png")
const CROSSHAIR_ACTION = preload("res://assets/ui/crosshair038.png")


func _process(delta: float) -> void:
	if is_instance_valid(player):
		crosshair.texture = CROSSHAIR_ACTION if player.can_scale_looking or player.can_scale_looking else CROSSHAIR_DEFAULT
		actions.get_node("Scale").visible = player.can_scale_looking
		actions.get_node("Hold").visible = player.can_hold_looking
		if player.position.y < -4:
			player_died()


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



func trigger_group(from: Node3D, group_id: int) -> void:
	for object in get_tree().get_nodes_in_group("GroupTrigger"):
		if object.trigger_group == group_id:
			object.trigger(from)

func trigger_group_once(from: Node3D, group_id: int) -> void:
	for object in get_tree().get_nodes_in_group("GroupTrigger"):
		if object.trigger_group == group_id:
			object.trigger_once(from)

func untrigger_group(from: Node3D, group_id: int) -> void:
	for object in get_tree().get_nodes_in_group("GroupTrigger"):
		if object.trigger_group == group_id:
			object.untrigger(from)

func _transition_enter() -> void:
	var transition := canvas_layer.get_node("Container/Transition")
	var tween := get_tree().create_tween()
	transition.visible = true
	transition.modulate.a = 1.0
	tween.tween_property(transition, "modulate:a", 0.0, 0.25)
	tween.tween_property(transition, "visible", false, 0.0)

var dying := false
func player_died() -> void:
	if dying:
		return
	
	dying = true
	var transition := canvas_layer.get_node("Container/Transition")
	var tween := get_tree().create_tween()
	transition.visible = true
	transition.modulate.a = 0.0
	tween.tween_property(transition, "modulate:a", 1.0, 0.25)
	tween.tween_interval(0.1)
	tween.tween_callback(get_tree().reload_current_scene)


func speed_factor() -> float:
	return pow(game_speed, 2)
