class_name PauseBehaviour
extends NPCBehaviour

@export var pause_chance: float = 0.02
@export var pause_duration_min: float = 0.25
@export var pause_duration_max: float = 0.9
@export var check_interval: float = 1.0

var _pause_timer: float = 0.0
var _check_timer: float = 0.0

func sample(_context: Dictionary, delta: float, rng: RandomNumberGenerator) -> Vector2:
	_pause_timer = maxf(0.0, _pause_timer - delta)
	_check_timer = maxf(0.0, _check_timer - delta)
	
	if _pause_timer <= 0.0 and _check_timer <= 0.0:
		_check_timer = check_interval
		
		if rng.randf() < pause_chance:
			_pause_timer = rng.randf_range(pause_duration_min, pause_duration_max)
	
	return Vector2.ZERO

func modulate(_context: Dictionary, _delta: float, _rng: RandomNumberGenerator) -> float:
	return 0.0 if _pause_timer > 0.0 else 1.0
