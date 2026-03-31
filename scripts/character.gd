class_name Character
extends CharacterBody3D

@export var sprite: Texture2D

@export var speed: float = 3
@export var acceleration: float = 2
@export var deceleration: float = 9

@onready var brain := $NPCBrain

var _input_vector := Vector2.ZERO:
	set(value):
		_input_vector = value.normalized()

func _ready() -> void:
	if sprite:
		$Sprite3D.texture = sprite

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if brain:
		_input_vector = brain.get_intent(delta)
	
	var target_velocity = _input_vector * speed
	var acceleration_factor = deceleration if _input_vector.is_zero_approx() else acceleration
	var alpha = 1 - exp(-acceleration_factor * delta)
	
	velocity.x = lerpf(velocity.x, target_velocity.x, alpha)
	velocity.z = lerpf(velocity.z, target_velocity.y, alpha)
	
	move_and_slide()
