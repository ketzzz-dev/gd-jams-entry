@abstract
class_name NPCBehaviour
extends Resource

@export var weight: float = 1.0
@export var enabled: bool = true

func reset(_rng: RandomNumberGenerator) -> void:
	pass

func sample(_context: Dictionary, _delta: float, _rng: RandomNumberGenerator) -> Vector2:
	return Vector2.ZERO
