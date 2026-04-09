class_name NPCBehaviour
extends Resource

enum BehaviourType {
	STEERING,
	GOAL
}

@export var behaviour_type: BehaviourType = BehaviourType.STEERING
@export var weight: float = 1.0
@export var enabled: bool = true

func reset(_rng: RandomNumberGenerator) -> void:
	pass

# For STEERING behaviours
func sample(_context: Dictionary, _delta: float, _rng: RandomNumberGenerator) -> Vector2:
	return Vector2.ZERO

# For GOAL behaviours
func get_target(_context: Dictionary, _delta: float, _rng: RandomNumberGenerator) -> Variant:
	return null

func modulate(_context: Dictionary, _delta: float, _rng: RandomNumberGenerator) -> float:
	return 1.0
