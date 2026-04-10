extends Control

@onready var timer_label: Label = $TimerLabel
@onready var guesses_label: Label = $GuessesLabel
@onready var notification: Label = $Notification

func set_timer(seconds: float) -> void:
	var s = int(ceil(seconds))
	var mm = int(s / 60)
	var ss = s % 60
	timer_label.text = "%02d:%02d" % [mm, ss]

func set_guesses(left: int) -> void:
	guesses_label.text = "Guesses: " + str(left)

func show_notification(text: String, duration: float = 1.2) -> void:
	notification.text = text
	notification.visible = true
	notification.modulate = Color(1,1,1,1)
	var tween = create_tween()
	tween.tween_property(notification, "modulate:a", 0.0, duration).set_delay(0.6)
	tween.connect("finished", Callable(self, "_on_notification_fade"))

func _on_notification_fade() -> void:
	notification.visible = false
