extends StaticBody3D

@onready var root: GameRoot = $".."

@export var trigger_group := 0
@export var target_weight := 20.0
@onready var weight: Label3D = $Button/Weight


var current_weight := 0.0
var lerp_weight := 0.0

func _ready() -> void:
	weight.text = str(target_weight)

var bodies_inside: Array[CollisionObject3D]
@onready var mesh: CSGCylinder3D = $Button/Mesh


func _on_button_body_entered(body: Node3D) -> void:
	if body.get("mass"):
		bodies_inside.append(body)


func _on_button_body_exited(body: Node3D) -> void:
	if body.get("mass"):
		bodies_inside.erase(body)

func _process(delta: float) -> void:
	mesh.position.y = lerp(-0.120, 0.125, lerp_weight / target_weight)
	lerp_weight = max(move_toward(lerp_weight, target_weight - current_weight, delta * 50.0), 0)
	weight.text = str(floor(lerp_weight))

var was_valid := false

func _calculate_weight() -> void:
	current_weight = 0
	var rid_scanned: Array[RID] = []
	for body in bodies_inside:
		body.get_rid()
		current_weight += body.get("mass")
		if body.get("holded"):
			current_weight += body.holded.get("mass")
		if is_instance_of(body, RigidBody3D):
			var rigidbody: RigidBody3D = body
			if rigidbody.contact_monitor:
				current_weight += _deep_rigidbody_weight(rigidbody, rid_scanned)
	if not was_valid and current_weight >= target_weight:
		root.trigger_group_once(self, trigger_group)
		was_valid = true
		$Active.play()
	if was_valid and current_weight < target_weight:
		root.untrigger_group(self, trigger_group)
		was_valid = false

func _deep_rigidbody_weight(rigidbody: RigidBody3D, rids: Array[RID]) -> float:
	var sum := 0
	for body in rigidbody.get_colliding_bodies():
		if body.get("mass"):
			sum += body.mass
		rids.append(rigidbody.get_rid())
		if rigidbody.get("contact_monitor") and not rids.has(rigidbody.get_rid()):
			sum += _deep_rigidbody_weight(rigidbody, rids)
	return sum


func _physics_process(delta: float) -> void:
	_calculate_weight()
