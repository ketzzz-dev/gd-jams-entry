class_name WanderBehaviour
extends NPCBehaviour

@export var interval_min := 2.0
@export var interval_max := 5.0
@export var navigation_layers: int = 1

var _timer := 0.0
var _target := Vector3.ZERO

func _init():
	behaviour_type = BehaviourType.GOAL

func get_target(context: Dictionary, delta: float, rng: RandomNumberGenerator):
	_timer -= delta

	if _timer <= 0.0:
		_timer = rng.randf_range(interval_min, interval_max)

		var agent: NavigationAgent3D = context["nav_agent"]
		var nav_map: RID = agent.get_navigation_map()

		if nav_map.is_valid():
			_target = _get_local_nav_point(agent, context["global_position"], 10.0, rng)

	return _target

func _get_local_nav_point(agent: NavigationAgent3D, origin: Vector3, radius: float, rng: RandomNumberGenerator) -> Vector3:
	var nav_map: RID = agent.get_navigation_map()

	for i in 8: # limited attempts
		var offset = Vector3(
			rng.randf_range(-radius, radius),
			0,
			rng.randf_range(-radius, radius)
		)

		var candidate = origin + offset
		var closest = NavigationServer3D.map_get_closest_point(nav_map, candidate)

		if closest.distance_to(origin) <= radius:
			return closest

	# fallback
	return origin
