class_name CohesionBehaviour
extends NPCBehaviour

@export var strength: float = 0.4
@export var dead_zone: float = 1.5  # don't pull if already close

func _init():
	behaviour_type = BehaviourType.STEERING

func sample(context: Dictionary, _delta: float, _rng: RandomNumberGenerator) -> Vector2:
	var center: Variant = context.get("cluster_center", null)
	if center == null:
		return Vector2.ZERO

	var pos: Vector3 = context["global_position"]
	var to_center: Vector3 = center - pos

	if to_center.length() < dead_zone:
		return Vector2.ZERO

	var dir2 = Vector2(to_center.x, to_center.z).normalized()
	return dir2 * strength
