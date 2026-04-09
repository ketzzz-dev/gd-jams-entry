class_name MimicBehaviour
extends NPCBehaviour

@export var reaction_delay: float = 0.18
@export var drift: float = 0.10
@export var invert_chance: float = 0.04
@export var memory_size: int = 90

var _history: Array[Vector2] = []
var _time_history: Array[float] = []
var _time: float = 0.0

func reset(_rng: RandomNumberGenerator) -> void:
	_history.clear()
	_time_history.clear()
	_time = 0.0

func sample(context: Dictionary, delta: float, rng: RandomNumberGenerator) -> Vector2:
	_time += delta
	
	var crowd_average: Vector2 = context.get("crowd_average", Vector2.ZERO)
	
	_history.append(crowd_average)
	_time_history.append(_time)
	
	while _history.size() > memory_size:
		_history.pop_front()
		_time_history.pop_front()
	
	var delayed := crowd_average
	
	for i in range(_time_history.size() - 1, -1, -1):
		if _time - _time_history[i] >= reaction_delay:
			delayed = _history[i]
			
			break

	if rng.randf() < invert_chance:
		delayed = -delayed

	delayed += Vector2(
		rng.randf_range(-drift, drift),
		rng.randf_range(-drift, drift)
	)

	return delayed.normalized() if delayed.length_squared() > 1 else delayed
