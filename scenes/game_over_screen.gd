extends Panel

signal restart_pressed

@onready var restart_btn: Button = $RestartStage
@onready var stats_box: VBoxContainer = $Stats

func _ready() -> void:
	restart_btn.connect("pressed", Callable(self, "_on_restart_pressed"))

func show_stats(completed: int, fails: int, total_time: float) -> void:
	for child in stats_box.get_children():
		child.queue_free()

	var c = Label.new()
	c.text = "Completed Stages: %d" % [completed]
	stats_box.add_child(c)

	var f = Label.new()
	f.text = "Fails: %d" % [fails]
	stats_box.add_child(f)

	var t = Label.new()
	t.text = "Total Time: %0.2f s" % [total_time]
	stats_box.add_child(t)

	visible = true

func _on_restart_pressed() -> void:
	visible = false
	emit_signal("restart_pressed")
