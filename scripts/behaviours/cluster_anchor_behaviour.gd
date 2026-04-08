class_name ClusterAnchorBehaviour
extends NPCBehaviour

@export var radius: float = 6.0
@export var interval_min := 1.5
@export var interval_max := 4.0

var _timer := 0.0
var _target := Vector3.ZERO

func _init():
	behaviour_type = BehaviourType.GOAL

func get_target(context: Dictionary, delta: float, rng: RandomNumberGenerator):
	_timer -= delta

	if _timer > 0.0:
		return _target

	_timer = rng.randf_range(interval_min, interval_max)

	var center: Variant = context.get("cluster_center", null)
	var agent: NavigationAgent3D = context["nav_agent"]

	if center == null:
		return null

	var nav_map: RID = agent.get_navigation_map()

	# sample locally around cluster center
	for i in 8:
		var offset = Vector3(
			rng.randf_range(-radius, radius),
			0,
			rng.randf_range(-radius, radius)
		)

		var candidate = center + offset
		var point = NavigationServer3D.map_get_closest_point(nav_map, candidate)

		if point.distance_to(center) <= radius:
			_target = point
			return _target

	# fallback
	_target = center
	return _target
