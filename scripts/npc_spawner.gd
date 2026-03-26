extends Node

@export var region_size: Vector2 = Vector2(100, 100)
@export var min_distance: float = 5
@export var max_npcs: int = 32
@export var num_samples_before_rejection: int = 30
@export var custom_seed: int
@export var npc_scene: PackedScene

var points: Array[Vector2] = []

var cols: int
var rows: int
var cell_size: float

func _ready() -> void:
	for point in _generate():
		var npc := npc_scene.instantiate() as CharacterBody3D
		
		add_child(npc)
		
		npc.global_position = Vector3(point.x - region_size.x / 2, 0, point.y - region_size.y / 2)

func _generate() -> Array[Vector2]:
	if custom_seed:
		seed(custom_seed)
	
	cell_size = min_distance / sqrt(2.0)
	cols = ceili(region_size.x / cell_size)
	rows = ceili(region_size.y / cell_size)
	
	var grid: Array[int] = []
	
	grid.resize(cols * rows)
	grid.fill(0)
	points.clear()
	
	var active: Array[Vector2] = []

	var first := Vector2(randf_range(0, region_size.x), randf_range(0, region_size.y))
	var first_cell := Vector2i(int(first.x / cell_size), int(first.y / cell_size))
	
	grid[first_cell.y * cols + first_cell.x] = points.size() + 1
	
	points.append(first)
	active.append(first)
	
	while active.size() > 0:
		var rand_idx := randi_range(0, active.size() - 1)
		var spawn_center := active[rand_idx]
		var accepted := false
		
		for i in num_samples_before_rejection:
			var angle := randf() * TAU
			var radius := randf_range(min_distance, 2.0 * min_distance)
			var candidate := spawn_center + Vector2(cos(angle), sin(angle)) * radius
			
			if _is_valid(candidate, grid):
				var c_cell := Vector2i(int(candidate.x / cell_size), int(candidate.y / cell_size))
				
				grid[c_cell.y * cols + c_cell.x] = points.size() + 1
				
				points.append(candidate)
				active.append(candidate)
				
				accepted = true
				
				break
		
		if not accepted:
			active.remove_at(rand_idx)
	
	points.shuffle()
	
	return points.slice(0, max_npcs)

func _is_valid(candidate: Vector2, grid: Array[int]) -> bool:
	if candidate.x < 0 or candidate.x >= region_size.x \
	or candidate.y < 0 or candidate.y >= region_size.y:
		return false
		
	var cell := Vector2i(int(candidate.x / cell_size), int(candidate.y / cell_size))
	
	for dx in range(-2, 3): for dy in range(-2, 3):
		var nx := cell.x + dx
		var ny := cell.y + dy
		
		if nx < 0 or nx >= cols or ny < 0 or ny >= rows:
			continue
		
		var idx: int = grid[ny * cols + nx]
		
		if idx > 0:
			var other := points[idx - 1]
			
			if candidate.distance_squared_to(other) < min_distance * min_distance:
				return false
	
	return true
