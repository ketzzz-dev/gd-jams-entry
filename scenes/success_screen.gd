extends Panel

signal next_stage_pressed

@onready var next_btn: Button = $NextStage
@onready var stage_stats: VBoxContainer = $StageStats

func _ready():
	next_btn.pressed.connect(_on_next_pressed)

func show_stats(time_taken: float, guesses_used: int) -> void:
	stage_stats.clear()
	var t = Label.new()
	t.text = "Time: %0.2f s" % [time_taken]
	stage_stats.add_child(t)
	var g = Label.new()
	g.text = "Guesses used: " + str(guesses_used)
	stage_stats.add_child(g)
	visible = true

func _on_next_pressed():
	visible = false
	emit_signal("next_stage_pressed")
