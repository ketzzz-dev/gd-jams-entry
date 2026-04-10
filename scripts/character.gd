class_name Character
extends CharacterBody3D

@export var speed: float = 3
@export var acceleration: float = 2
@export var deceleration: float = 9

@onready var sprite: Sprite3D = $Sprite3D
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var brain: NPCBrain = $NPCBrain

var cluster_id: int = -1
var cluster_center: Vector3 = Vector3.ZERO

var _input_vector := Vector2.ZERO
var _last_direction := Vector2.ZERO
var active := false
var selected := false
var frozen := false

func _physics_process(delta: float) -> void:
	if frozen:
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if brain and active:
		var intent = brain.get_intent(delta)
		
		_input_vector = intent.normalized() if intent.length_squared() > 1 else intent
	else:
		_input_vector = Vector2.ZERO
	
	var target_velocity = _input_vector * speed
	var acceleration_factor = deceleration if _input_vector.is_zero_approx() else acceleration
	var alpha = 1 - exp(-acceleration_factor * delta)
	
	velocity.x = lerpf(velocity.x, target_velocity.x, alpha)
	velocity.z = lerpf(velocity.z, target_velocity.y, alpha)
	
	var is_idle = velocity.is_zero_approx()
	
	if not is_idle:
		var cam = get_viewport().get_camera_3d()

		var forward = cam.global_transform.basis.z
		var right = cam.global_transform.basis.x

		# Flatten to XZ plane
		forward.y = 0
		right.y = 0

		forward = forward.normalized()
		right = right.normalized()

		var move_dir = velocity.normalized()

		var x = move_dir.dot(right)
		var y = move_dir.dot(forward)

		_last_direction = Vector2(x, y)
	
	animation_tree.set("parameters/conditions/idle", is_idle)
	animation_tree.set("parameters/conditions/walk", not is_idle)
	
	animation_tree.set("parameters/Idle/blend_position", _last_direction)
	animation_tree.set("parameters/Walk/blend_position", _last_direction)
	
	move_and_slide()

func set_selected(value) -> void:
	selected = value

func set_frozen(value: bool) -> void:
	frozen = value
	if frozen:
		velocity = Vector3.ZERO
