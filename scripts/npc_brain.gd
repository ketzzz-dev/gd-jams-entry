class_name NPCBrain
extends Node

@export var archetype: NPCArchetype:
	set(value):
		_set_archetype(value)
	get:
		return _archetype

var _archetype: NPCArchetype

var rng := RandomNumberGenerator.new()

var _time: float = 0.0
var _last_output: Vector2 = Vector2.ZERO

var _steering_behaviours: Array[NPCBehaviour] = []
var _goal_behaviours: Array[NPCBehaviour] = []

var _current_target: Vector3 = Vector3.ZERO
var _has_target: bool = false

# Crowd context
var crowd_average: Vector2 = Vector2.ZERO
var crowd_repulsion: Vector2 = Vector2.ZERO
var nearest_distance: float = INF

func _ready() -> void:
	rng.randomize()

func _set_archetype(value: NPCArchetype) -> void:
	_archetype = value
	
	_steering_behaviours.clear()
	_goal_behaviours.clear()

	if _archetype == null:
		return

	for behaviour in _archetype.behaviours:
		var instance: NPCBehaviour = behaviour.duplicate()
		instance.reset(rng)

		if instance.behaviour_type == NPCBehaviour.BehaviourType.GOAL:
			_goal_behaviours.append(instance)
		else:
			_steering_behaviours.append(instance)

func get_intent(delta: float) -> Vector2:
	_time += delta

	if not _archetype:
		return Vector2.ZERO

	var context := {
		"time": _time,
		"last_output": _last_output,
		"crowd_average": crowd_average,
		"crowd_repulsion": crowd_repulsion,
		"nearest_distance": nearest_distance,
		"global_position": owner.global_position,
		"nav_agent": owner.nav_agent,
		"cluster_center": owner.cluster_center,
		"cluster_id": owner.cluster_id,
		"cam": get_viewport().get_camera_3d()
	}

	# --- GOAL LAYER ---
	_process_goals(context, delta)

	# --- NAVIGATION VECTOR ---
	var nav_vector := _get_navigation_vector(context)

	# --- STEERING LAYER ---
	var steering := _process_steering(context, delta)

	var out := nav_vector + steering

	# --- Noise ---
	out += Vector2(
		rng.randf_range(-_archetype.micro_jitter, _archetype.micro_jitter),
		rng.randf_range(-_archetype.micro_jitter, _archetype.micro_jitter)
	)

	if out.length_squared() > 1:
		out = out.normalized()

	_last_output = _last_output.lerp(out, _archetype.output_smoothing)

	return _last_output

func _process_goals(context: Dictionary, delta: float) -> void:
	_has_target = false

	for behaviour in _goal_behaviours:
		if behaviour == null or not behaviour.enabled:
			continue

		var target = behaviour.get_target(context, delta, rng)

		if target != null:
			_current_target = target
			_has_target = true
			
			context["nav_agent"].set_target_position(_current_target)
			return

func _get_navigation_vector(context: Dictionary) -> Vector2:
	if not _has_target:
		return Vector2.ZERO

	var agent: NavigationAgent3D = context["nav_agent"]

	if agent.is_navigation_finished():
		return Vector2.ZERO

	var next_point: Vector3 = agent.get_next_path_position()
	var current: Vector3 = context["global_position"]

	var dir3 := next_point - current
	var dir2 := Vector2(dir3.x, dir3.z)

	return dir2.normalized() if dir2.length_squared() > 1 else dir2

func _process_steering(context: Dictionary, delta: float) -> Vector2:
	var sum := Vector2.ZERO
	var scale := 1.0
	var total_weight := 0.0

	for behaviour in _steering_behaviours:
		if behaviour == null or not behaviour.enabled:
			continue

		sum += behaviour.sample(context, delta, rng) * behaviour.weight
		scale *= behaviour.modulate(context, delta, rng)
		total_weight += behaviour.weight

	if total_weight == 0:
		return Vector2.ZERO

	return (sum / total_weight) * scale
