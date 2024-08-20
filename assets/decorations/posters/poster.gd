extends Prop

const POSTER_IMAGES := [
	preload("res://assets/decorations/posters/1.png"),
	preload("res://assets/decorations/posters/2.png"),
	preload("res://assets/decorations/posters/3.png"),
	preload("res://assets/decorations/posters/4.png"),
]

@onready var mesh: MeshInstance3D = $Mesh/Poster

func _ready() -> void:
	mesh.set("surface_material_override/1", mesh.get("surface_material_override/1"))
	mesh.get("surface_material_override/1").albedo_texture = POSTER_IMAGES.pick_random()
