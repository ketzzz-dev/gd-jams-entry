class_name NPCBrain
extends Node

@export var archetype: NPCArchetype:
	set(value):
		archetype = value
		
		_behaviours.clear()
		
		for behaviour in value.behaviours:
			var instance = behaviour.duplicate()
			
			instance.reset(rng)
			_behaviours.append(instance)

var rng := RandomNumberGenerator.new()

var _time: float = 0.0
var _last_output: Vector2 = Vector2.ZERO
var _behaviours: Array[NPCBehaviour] = []

var crowd_average: Vector2 = Vector2.ZERO
var crowd_repulsion: Vector2 = Vector2.ZERO
var nearest_distance: float = INF

func _ready() -> void:
	rng.randomize()

func get_intent(delta: float) -> Vector2:
	_time += delta
	
	if not archetype:
		return Vector2.ZERO
	
	var context := {
		"time": _time,
		"last_output": _last_output,
		"crowd_average": crowd_average,
		"crowd_repulsion": crowd_repulsion,
		"nearest_distance": nearest_distance,
	}

	var sum := Vector2.ZERO
	var scale := 1.0
	var total_weight := 0.0

	for behaviour in _behaviours:
		if behaviour == null or not behaviour.enabled:
			continue
		
		sum += behaviour.sample(context, delta, rng) * behaviour.weight
		scale *= behaviour.modulate(context, delta, rng)
		total_weight += behaviour.weight

	var out := Vector2.ZERO
	
	if total_weight > 0:
		out = (sum / total_weight) * scale

	out += Vector2(
		rng.randf_range(-archetype.micro_jitter, archetype.micro_jitter),
		rng.randf_range(-archetype.micro_jitter, archetype.micro_jitter)
	)

	if out.length_squared() > 1:
		out = out.normalized()
	
	_last_output = _last_output.lerp(out, archetype.output_smoothing)
	
	return _last_output
