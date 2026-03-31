class_name PauseBehaviour
extends NPCBehaviour

@export var pause_chance: float = 0.02
@export var pause_duration_min: float = 0.25
@export var pause_duration_max: float = 0.9

var _pause_timer: float = 0.0

func modulate(_context: Dictionary, delta: float, rng: RandomNumberGenerator) -> float:
	_pause_timer = maxf(0.0, _pause_timer - delta)
	
	if _pause_timer > 0.0:
		return 0.0  # Fully suppress all movement while paused.
	
	if rng.randf() < pause_chance:
		_pause_timer = rng.randf_range(pause_duration_min, pause_duration_max)
		
		return 0.0
	
	return 1.0
