extends Node

const NUM_SAMPLES_BEFORE_REJECTION := 30

@export var region_size: Vector2 = Vector2(100, 100)
@export var min_distance: float = 5

@export var npc_scene: PackedScene
@export var npc_sprites: Array[Texture2D]

var _cols: int
var _rows: int
var _cell_size: float

func _ready() -> void:
	var available_sprites = npc_sprites.duplicate()
	
	for point in generate_points():
		await get_tree().create_timer(get_physics_process_delta_time()).timeout
		
		if available_sprites.is_empty():
			available_sprites = npc_sprites.duplicate()
			available_sprites.shuffle()
		
		var npc := npc_scene.instantiate() as Character
		
		npc.position = Vector3(point.x - 0.5 * region_size.x, 0, point.y - 0.5 * region_size.y)
		npc.sprite = available_sprites.pop_back()
		
		add_child(npc)

func generate_points() -> Array[Vector2]:
	_cell_size = min_distance / sqrt(2)
	_cols = ceili(region_size.x / _cell_size)
	_rows = ceili(region_size.y / _cell_size)
	
	var grid: Array[int] = []
	
	grid.resize(_cols * _rows)
	grid.fill(0)
	
	var points: Array[Vector2] = []
	var active: Array[Vector2] = []

	var first := Vector2(randf_range(0, region_size.x), randf_range(0, region_size.y))
	var first_cell := Vector2i(int(first.x / _cell_size), int(first.y / _cell_size))
	
	grid[first_cell.y * _cols + first_cell.x] = 1
	
	points.append(first)
	active.append(first)
	
	while active.size() > 0:
		var rand_idx := randi_range(0, active.size() - 1)
		var spawn_center := active[rand_idx]
		var accepted := false
		
		for i in NUM_SAMPLES_BEFORE_REJECTION:
			var angle := randf() * TAU
			var radius := randf_range(min_distance, 2 * min_distance)
			var candidate := spawn_center + Vector2(cos(angle), sin(angle)) * radius
			
			if _is_valid(candidate, grid, points):
				var c_cell := Vector2i(int(candidate.x / _cell_size), int(candidate.y / _cell_size))
				
				grid[c_cell.y * _cols + c_cell.x] = points.size() + 1
				
				points.append(candidate)
				active.append(candidate)
				
				accepted = true
				
				break
		
		if not accepted:
			active.remove_at(rand_idx)
	
	return points

func _is_valid(candidate: Vector2, grid: Array[int], points: Array[Vector2]) -> bool:
	if candidate.x < 0 or candidate.x >= region_size.x \
	or candidate.y < 0 or candidate.y >= region_size.y:
		return false
		
	var cell := Vector2i(int(candidate.x / _cell_size), int(candidate.y / _cell_size))
	
	for dx in range(-2, 3): for dy in range(-2, 3):
		var nx := cell.x + dx
		var ny := cell.y + dy
		
		if nx < 0 or nx >= _cols or ny < 0 or ny >= _rows:
			continue
		
		var idx: int = grid[ny * _cols + nx]
		
		if idx > 0:
			var other := points[idx - 1]
			
			if candidate.distance_squared_to(other) < min_distance * min_distance:
				return false
	
	return true
