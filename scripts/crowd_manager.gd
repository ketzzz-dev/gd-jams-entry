extends Node

const NUM_SAMPLES_BEFORE_REJECTION := 30

@export var region_size: Vector2 = Vector2(100, 100)
@export var min_distance: float = 5

@export var character_scene: PackedScene
@export var character_sprites: Array[Texture2D]
@export var character_archetypes: Array[NPCArchetype]

@export var influence_radius: float = 4

var _player_archetype: NPCArchetype = preload("res://resources/archetypes/player.tres")

var _cols: int
var _rows: int
var _cell_size: float

var _characters: Array[Character] = []
var _spatial_grid: Dictionary[Vector2i, Array] = {}

func _ready() -> void:
	var available_sprites = character_sprites.duplicate()
	
	for point in _generate_points():
		await get_tree().process_frame
		
		if available_sprites.is_empty():
			available_sprites = character_sprites.duplicate()
			available_sprites.shuffle()
		
		var character: Character = character_scene.instantiate()
		
		add_child(character)
		
		character.position = Vector3(point.x - 0.5 * region_size.x, 0, point.y - 0.5 * region_size.y)
		character.sprite.texture = available_sprites.pop_back()
		character.brain.archetype = _pick_archetype()
		
		_characters.append(character)
	
	var random_index = randi_range(0, _characters.size() - 1)
	
	_characters[random_index].brain.archetype = _player_archetype
	
	for character in _characters:
		character.active = true

func _physics_process(_delta: float) -> void:
	_rebuild_spatial_grid()
	
	for character in _characters:
		if not character.brain:
			continue
		
		var pos := Vector2(character.position.x, character.position.z)
		
		var repulsion := Vector2.ZERO
		var velocity_sum := Vector2.ZERO
		var neighbour_count := 0
		var nearest := INF
		
		for other in _get_neighbours(character):
			if other == character:
				continue
			
			var other_pos := Vector2(other.position.x, other.position.z)
			var offset := pos - other_pos
			var dist := offset.length()
			
			if dist < nearest:
				nearest = dist
			
			if dist > influence_radius or is_zero_approx(dist):
				continue
			
			neighbour_count += 1
			
			var push_strength := 1.0 / (dist * dist)
			
			repulsion += offset.normalized() * push_strength
			velocity_sum += Vector2(other.velocity.x, other.velocity.z)
		
		var avg_direction := Vector2.ZERO
		
		if neighbour_count > 0:
			avg_direction = (velocity_sum / neighbour_count).normalized()
		
		character.brain.crowd_average = avg_direction
		character.brain.crowd_repulsion = repulsion
		character.brain.nearest_distance = nearest

func _pick_archetype() -> NPCArchetype:
	var total_weight := 0.0
	
	for archetype in character_archetypes:
		total_weight += archetype.spawn_weight
	
	var roll := randf() * total_weight

	for archetype in character_archetypes:
		roll -= archetype.spawn_weight
		
		if roll <= 0.0:
			return archetype
	
	return character_archetypes.back()

func _rebuild_spatial_grid() -> void:
	_spatial_grid.clear()
	
	for character in _characters:
		var cell := Vector2i(
			floori(character.position.x / influence_radius),
			floori(character.position.z / influence_radius)
		)
		
		if not _spatial_grid.has(cell):
			_spatial_grid[cell] = []
		
		_spatial_grid[cell].append(character)

func _get_neighbours(character: Character) -> Array:
	var cell := Vector2i(
		floori(character.position.x / influence_radius),
		floori(character.position.z / influence_radius)
	)
	
	var neighbours := []
	
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			var neighbour_cell := cell + Vector2i(dx, dy)
			
			if _spatial_grid.has(neighbour_cell):
				neighbours.append_array(_spatial_grid[neighbour_cell])
	
	return neighbours

func _generate_points() -> Array[Vector2]:
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
	
	for dx in range(-2, 3):
		for dy in range(-2, 3):
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
