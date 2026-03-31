class_name WanderBehaviour
extends NPCBehaviour

@export var turn_interval_min: float = 0.6
@export var turn_interval_max: float = 2
@export var turn_bias: float = 0.65
@export var jitter: float = 0.12

var _timer: float = 0
var _direction: Vector2 = Vector2.RIGHT

func reset(rng: RandomNumberGenerator) -> void:
	_timer = rng.randf_range(turn_interval_min, turn_interval_max)
	_direction = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1))
	
	if _direction.is_zero_approx():
		_direction = Vector2.RIGHT
	
	_direction = _direction.normalized()

func sample(_context: Dictionary, delta: float, rng: RandomNumberGenerator) -> Vector2:
	_timer -= delta
	
	if _timer <= 0.0:
		_timer = rng.randf_range(turn_interval_min, turn_interval_max)
		
		var target := Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0))
		
		if not target.is_zero_approx():
			_direction = _direction.lerp(target.normalized(), 1.0 - turn_bias).normalized()

	var noise := Vector2(
		rng.randf_range(-jitter, jitter),
		rng.randf_range(-jitter, jitter)
	)
	
	var output = _direction + noise

	return output.normalized() if output.length_squared() > 1 else output
