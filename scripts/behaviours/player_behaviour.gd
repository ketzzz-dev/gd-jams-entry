class_name PlayerBehaviour
extends NPCBehaviour

func sample(_context: Dictionary, _delta: float, _rng: RandomNumberGenerator) -> Vector2:
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	return input.normalized() if input.length_squared() > 1 else input
