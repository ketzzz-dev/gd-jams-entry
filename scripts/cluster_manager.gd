class_name ClusterManager
extends Node

@export var cluster_count: int = 6
@export var reassignment_interval: float = 5.0

var _timer := 0.0
var _members: Dictionary = {}          # cluster_id -> Array[Character]
var _centers: Dictionary = {}          # cluster_id -> Vector3

func register_characters(chars: Array) -> void:
	_members.clear()
	for i in cluster_count:
		_members[i] = []

	# initial random assignment
	for c in chars:
		var id = randi() % cluster_count
		c.cluster_id = id
		_members[id].append(c)

func _physics_process(delta: float) -> void:
	_timer -= delta

	if _timer <= 0.0:
		_timer = reassignment_interval
		_reassign_some()

	_recompute_centers()
	_push_to_characters()

func _recompute_centers() -> void:
	for id in _members.keys():
		var arr: Array = _members[id]
		if arr.is_empty():
			_centers[id] = Vector3.ZERO
			continue

		var sum := Vector3.ZERO
		for c in arr:
			sum += c.global_position

		_centers[id] = sum / arr.size()

func _push_to_characters() -> void:
	for id in _members.keys():
		var center: Vector3 = _centers[id]
		for c in _members[id]:
			c.cluster_center = center

func _reassign_some() -> void:
	# small % drift between clusters to avoid static blobs
	for id in _members.keys():
		var arr: Array = _members[id]
		for i in range(arr.size()):
			if randf() < 0.05:
				var c = arr[i]
				var new_id = randi() % cluster_count
				if new_id == id:
					continue

				arr.remove_at(i)
				c.cluster_id = new_id
				_members[new_id].append(c)
