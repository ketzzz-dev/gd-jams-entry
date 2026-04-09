class_name Character
extends CharacterBody3D

@export var speed: float = 3
@export var acceleration: float = 2
@export var deceleration: float = 9

@onready var sprite: Sprite3D = $Sprite3D
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var brain: NPCBrain = $NPCBrain

var cluster_id: int = -1
var cluster_center: Vector3 = Vector3.ZERO

var _input_vector := Vector2.ZERO
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
	
	move_and_slide()

func set_selected(value) -> void:
	selected = value

func set_frozen(value: bool) -> void:
	frozen = value
	if frozen:
		velocity = Vector3.ZERO
