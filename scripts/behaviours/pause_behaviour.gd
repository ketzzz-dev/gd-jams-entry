# PauseBehavior.gd
class_name PauseBehaviour
extends NPCBehaviour

@export var pause_chance: float = 0.02
@export var pause_duration_min: float = 0.25
@export var pause_duration_max: float = 0.9
@export var resume_bias: float = 0.65

var _pause_timer: float = 0.0

func sample(context: Dictionary, delta: float, rng: RandomNumberGenerator) -> Vector2:
	_pause_timer = maxf(0.0, _pause_timer - delta)

	if _pause_timer > 0.0:
		return Vector2.ZERO

	if rng.randf() < pause_chance:
		_pause_timer = rng.randf_range(pause_duration_min, pause_duration_max)
		return Vector2.ZERO

	var last_output: Vector2 = context.get("last_output", Vector2.ZERO)
	
	return last_output * resume_bias
