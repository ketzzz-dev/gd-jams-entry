extends Control

@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var options_button: Button = $CenterContainer/VBoxContainer/HowToPlayButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var background: TextureRect = $Background

var game: PackedScene = preload("res://scenes/mainmap.tscn")

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _process(delta: float) -> void:
	background.rotation_degrees += TAU * delta * 2.0

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(game)

func _on_options_pressed() -> void:
	print("How to Play?")

func _on_quit_pressed() -> void:
	get_tree().quit()
