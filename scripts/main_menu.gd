extends Control

@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var options_button: Button = $CenterContainer/VBoxContainer/HowToPlayButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var background: TextureRect = $Background
@onready var center_container: CenterContainer = $CenterContainer
@onready var how_to_panel: Control = $HowToPanel
@onready var back_button: Button = $HowToPanel/VBoxContainer/BackButton

var game: PackedScene = preload("res://scenes/mainmap.tscn")

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _process(delta: float) -> void:
	background.rotation_degrees += TAU * delta * 2.0

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(game)

func _on_options_pressed() -> void:
	how_to_panel.visible = true
	center_container.visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed() -> void:
	how_to_panel.visible = false
	center_container.visible = true
