class_name PlayerBehaviour
extends NPCBehaviour

func sample(context: Dictionary, _delta: float, _rng: RandomNumberGenerator) -> Vector2:
	var input := Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
	
	var cam: Camera3D = context["cam"]

	var forward = -cam.global_transform.basis.z
	var right = cam.global_transform.basis.x

	# Flatten to XZ plane
	forward = Vector2(forward.x, forward.z)
	right = Vector2(right.x, right.z)

	forward = forward.normalized()
	right = right.normalized()
	
	var x = input.dot(right)
	var y = input.dot(forward)
	
	var movement = Vector2(x, y)
	
	return Vector2.ZERO if movement.is_zero_approx() else movement.normalized()
