extends CharacterBody3D

@export var sprites: Array[Texture2D]

@onready var sprite := $Sprite3D as Sprite3D

func _ready() -> void:
	var rand_idx := randi_range(0, sprites.size() - 1)
	
	sprite.texture = sprites[rand_idx]
