class_name FlowBiasBehaviour
extends NPCBehaviour

@export var strength: float = 0.6
@export var min_flow: float = 0.05  # ignore noise

func _init():
	behaviour_type = BehaviourType.STEERING

func sample(context: Dictionary, _delta: float, _rng: RandomNumberGenerator) -> Vector2:
	var flow: Vector2 = context.get("crowd_average", Vector2.ZERO)

	if flow.length() < min_flow:
		return Vector2.ZERO

	# Optional: soften sharp turns vs last output
	var last: Vector2 = context.get("last_output", Vector2.ZERO)
	var blended = last.lerp(flow.normalized(), 0.5)

	return blended * strength
