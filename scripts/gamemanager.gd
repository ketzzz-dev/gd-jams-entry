extends Node

@export var hud_path: NodePath
@export var stage_time: float = 30.0
@export var max_guesses: int = 3

var guesses_left: int
var completed_stages: int = 0
var fails: int = 0
var total_elapsed: float = 0.0
var stage_start_time: float = 0.0

@onready var timer: Timer = Timer.new()
@onready var ui: Node = get_node_or_null("../UI")
@onready var hud: Node = get_node_or_null(hud_path)
@onready var success_screen: Node = ui.get_node("SuccessScreen")
@onready var game_over_screen: Node = ui.get_node("GameOverScreen")
@onready var crowd_manager = get_node("../CrowdManager")

func _ready():
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_stage_timeout)
	success_screen.connect("next_stage_pressed", Callable(self, "_on_next_stage"))
	game_over_screen.connect("restart_pressed", Callable(self, "_on_restart"))
	start_stage(stage_time)

func start_stage(time: float):
	guesses_left = max_guesses
	if hud:
		hud.set_guesses(guesses_left)
		hud.set_timer(time)
	timer.wait_time = time
	timer.start()
	stage_start_time = Time.get_ticks_msec() / 1000.0

func _process(delta: float) -> void:
	if timer.is_stopped():
		return
	var time_left = timer.time_left
	hud.set_timer(time_left)

func register_guess(character: Character, crowd_manager_node: Node):
	if crowd_manager_node.is_player(character):
		var time_taken = (Time.get_ticks_msec() / 1000.0) - stage_start_time
		_on_success(time_taken)
	else:
		guesses_left -= 1
		hud.set_guesses(guesses_left)
		hud.show_notification("Wrong! " + str(guesses_left) + " left")
		if guesses_left <= 0:
			_on_fail()

func _on_success(time_taken: float):
	completed_stages += 1
	total_elapsed += time_taken
	timer.stop()
	success_screen.show_stats(time_taken, max_guesses - guesses_left)
	success_screen.visible = true

func _on_fail():
	fails += 1
	total_elapsed += timer.wait_time - timer.time_left
	timer.stop()
	if fails >= 3:
		game_over_screen.show_stats(completed_stages, fails, total_elapsed)
		game_over_screen.visible = true
	else:
		hud.show_notification("Stage failed. Restarting...")
		var t = get_tree().create_timer(1.0)
		t.timeout.connect(Callable(self, "_restart_stage"))

func _restart_stage() -> void:
	start_stage(stage_time)

func _on_stage_timeout():
	_on_fail()

func _on_next_stage() -> void:
	start_stage(stage_time)

func _on_restart() -> void:
	completed_stages = 0
	fails = 0
	total_elapsed = 0.0
	start_stage(stage_time)
