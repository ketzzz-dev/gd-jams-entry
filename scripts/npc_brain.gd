class_name NPCBrain
extends Node

@export var behaviours: Array[NPCBehaviour] = []

@export var micro_jitter: float = 0.05
@export var output_smoothing: float = 0.25

var rng := RandomNumberGenerator.new()
var _time: float = 0.0
var _last_output: Vector2 = Vector2.ZERO

var crowd_average: Vector2 = Vector2.ZERO
var crowd_repulsion: Vector2 = Vector2.ZERO
var nearest_dist: float = 1000
var goal_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	rng.randomize()
	
	for b in behaviours:
		if b:
			b.reset(rng)

func get_intent(delta: float) -> Vector2:
	_time += delta

	var ctx := {
		"time": _time,
		"last_output": _last_output,
		"crowd_average": crowd_average,
		"crowd_repulsion": crowd_repulsion,
		"nearest_dist": nearest_dist,
		"goal_direction": goal_direction,
	}

	var sum := Vector2.ZERO
	var total_weight := 0.0

	for b in behaviours:
		if b == null or not b.enabled:
			continue
		
		var v := b.sample(ctx, delta, rng)
		
		sum += v * b.weight
		total_weight += b.weight

	var out := Vector2.ZERO
	if total_weight > 0.0:
		out = sum / total_weight

	out += Vector2(
		rng.randf_range(-micro_jitter, micro_jitter),
		rng.randf_range(-micro_jitter, micro_jitter)
	)

	out = out.normalized()
	_last_output = _last_output.lerp(out, output_smoothing)
	
	return _last_output
