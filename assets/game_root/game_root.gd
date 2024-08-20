class_name GameRoot
extends Node3D

@export var can_scale_time := false
@export var can_scale_self := false

@export var is_infiltration := false
@export var level_id := 0

const LEVELS_COMMON = preload("res://assets/levels_common.tscn")
const CLONE_PATH_FOLLOW = preload("res://assets/entities/clone/path_follow/clone_path_follow.tscn")
const CROSSHAIR_DEFAULT = preload("res://assets/ui/crosshair001.png")
const CROSSHAIR_ACTION = preload("res://assets/ui/crosshair038.png")

const CANVAS_LAYER = preload("res://islands/canvas_layer.tscn")
const PLAYER = preload("res://assets/entities/player/player.tscn")

@onready var player: Player
@onready var vignette_material: ShaderMaterial
@onready var actions: HBoxContainer
@onready var crosshair: TextureRect

var detection := 0.0
var game_speed := 1.0
var moving_time := false
var canvas_layer: CanvasLayer
var dying := false
var vignette_color := Color.BLACK
var weight_label: Label


func _add_player() -> void:
	player = PLAYER.instantiate()
	if is_instance_valid($Spawnpoint):
		player.position = $Spawnpoint.position
	else:
		player.position = Vector3.UP
	add_child(player)


func _ready() -> void:
	if level_id == 0:
		GameManager.total_deaths = 0
		GameManager.total_shoots = 0
	if is_infiltration:
		MusicManager.play(MusicManager.Musics.INFILTRATION)
	else:
		MusicManager.play(MusicManager.Musics.PUZZLE)
	_add_player()
	
	canvas_layer = CANVAS_LAYER.instantiate()
	add_child(canvas_layer)
	_transition_enter()
	
	add_child(LEVELS_COMMON.instantiate())
	
	vignette_material = canvas_layer.get_node("Container/Vignette").material
	actions = canvas_layer.get_node("Container/Actions")
	crosshair = canvas_layer.get_node("Container/Crosshair")
	weight_label = canvas_layer.get_node("Container/Weight/Container/CurrentWeight")
	
	if is_infiltration:
		var clones : Array[Clone]
		clones.assign($Clones.get_children())
		for clone in clones:
			if clone.moving:
				var path := $Paths.get_node_or_null(NodePath(clone.path_id))
				var path_follow := CLONE_PATH_FOLLOW.instantiate()
				clone.path_follow = path_follow
				path.add_child(path_follow)
				clone.global_position = path_follow.global_position

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _process(delta: float) -> void:
	weight_label.text = str(floor(player.get_total_mass()))
	if game_speed != 1.0:
		vignette_color = vignette_color.lerp(Color.WHITE, delta)
	else:
		vignette_color = vignette_color.lerp(Color.BLACK, delta)
	vignette_material.set_shader_parameter("color", vignette_color)
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

func player_died() -> void:
	if dying:
		return
	
	GameManager.total_deaths += 1
	dying = true
	restart_level()


func speed_factor() -> float:
	return pow(game_speed, 2)


func player_detected(from: Node3D, delta: float) -> void:
	detection += delta
	if detection >= 1.0:
		player.caught_by = from
		show_dialogue("Clone", "Inmate, you have nothing to do out there! Return to your cell!")
		from.player_caught()


func show_dialogue(from: String, message: String) -> void:
	canvas_layer.get_node("Container/Dialogue").visible = true
	canvas_layer.get_node("Container/Dialogue/Author").text = from
	canvas_layer.get_node("Container/Dialogue/Message").text = message


func restart_level() -> void:
	var transition := canvas_layer.get_node("Container/Transition")
	var tween := get_tree().create_tween()
	transition.visible = true
	transition.modulate.a = 0.0
	tween.tween_property(transition, "modulate:a", 1.0, 0.25)
	tween.tween_interval(0.1)
	tween.tween_callback(get_tree().reload_current_scene)
