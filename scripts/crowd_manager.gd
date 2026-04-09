extends Node

const NUM_SAMPLES_BEFORE_REJECTION := 30

@export var region_size: Vector2 = Vector2(100, 100)
@export var min_distance: float = 5
@export var max_characters: int = 100

@export var character_scene: PackedScene
@export var character_sprites: Array[Texture2D]
@export var character_archetypes: Array[NPCArchetype]
@export var navigation_region: NavigationRegion3D

@export var influence_radius: float = 4

@onready var _nav_map: RID

var _player_archetype: NPCArchetype = preload("res://resources/archetypes/player.tres")

var _characters: Array[Character] = []
var _spatial_grid: Dictionary[Vector2i, Array] = {}

func _ready() -> void:
	await NavigationServer3D.map_changed # idk
	
	_nav_map = navigation_region.get_navigation_map()
	
	var available_sprites = character_sprites.duplicate()
	
	await NavigationServer3D.map_changed # idk 2
	
	var spawn_points = _generate_points()
	
	for point in spawn_points:
		await get_tree().process_frame
		
		if available_sprites.is_empty():
			available_sprites = character_sprites.duplicate()
			available_sprites.shuffle()
		
		var character: Character = character_scene.instantiate()
		
		add_child(character)
		
		var nav_pos := NavigationServer3D.map_get_closest_point(
			_nav_map,
			Vector3(point.x, 10.0, point.y)
		)

		character.position = nav_pos
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
	var points: Array[Vector2] = []
	
	var attempts := 0
	var max_attempts := 10000
	
	while attempts < max_attempts and points.size() < max_characters:
		attempts += 1
		
		var p3: Vector3 = NavigationServer3D.map_get_random_point(
			_nav_map,
			1,      # navigation layers
			true    # uniform sampling
		)
		
		#print(p3)
		
		var candidate := Vector2(p3.x, p3.z)
		
		if _is_far_enough(candidate, points):
			points.append(candidate)
	
	return points

func _is_far_enough(candidate: Vector2, points: Array[Vector2]) -> bool:
	var min_dist_sq := min_distance * min_distance
	
	for p in points:
		if candidate.distance_squared_to(p) < min_dist_sq:
			return false
	
	return true
