class_name AvoidBehaviour
extends NPCBehaviour

@export var avoid_strength: float = 1.2
@export var soft_radius: float = 2.5
@export var panic_radius: float = 0.9

func sample(context: Dictionary, _delta: float, _rng: RandomNumberGenerator) -> Vector2:
	var repulsion: Vector2 = context.get("crowd_repulsion", Vector2.ZERO)
	var nearest_dist: float = context.get("nearest_distance", 1000)
	
	var factor := 0.0
	
	if nearest_dist < panic_radius:
		factor = 1.0
	elif nearest_dist < soft_radius:
		factor = inverse_lerp(soft_radius, panic_radius, nearest_dist)

	return repulsion.normalized() * avoid_strength * factor
