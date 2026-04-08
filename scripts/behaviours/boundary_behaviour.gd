class_name BoundaryBehaviour
extends NPCBehaviour

@export var region_size: Vector2 = Vector2(15, 15)
@export var margin: float = 1.5
@export var strength: float = 1.8

func sample(context: Dictionary, _delta: float, _rng: RandomNumberGenerator) -> Vector2:
	var pos: Vector3 = context.get("position", Vector3.ZERO)
	var current: Vector2 = context.get("last_output", Vector2.ZERO)
	var half := region_size * 0.5
	var push := Vector2.ZERO

	var left_dist   := pos.x - (-half.x)
	var right_dist  := half.x - pos.x
	var top_dist    := pos.y - (-half.y)
	var bottom_dist := half.y - pos.y

	if left_dist < margin and current.x < 0:
		push.x += (1.0 - left_dist / margin) * strength
	if right_dist < margin and current.x > 0:
		push.x -= (1.0 - right_dist / margin) * strength
	if top_dist < margin and current.y < 0:
		push.y += (1.0 - top_dist / margin) * strength
	if bottom_dist < margin and current.y > 0:
		push.y -= (1.0 - bottom_dist / margin) * strength

	return push
