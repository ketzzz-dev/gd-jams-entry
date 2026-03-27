extends Node3D

var mouse_sensitivity := 0.001
var twist_input := 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Hold right click to move camera
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	rotate_y(twist_input)
	twist_input = 0.0

func _input(event):
	# Double click to return to original position
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.double_click:
			get_tree().call_group("tweens", "stop_all")
			
			var tween = get_tree().create_tween()
			tween.set_trans(Tween.TRANS_QUAD)
			tween.set_ease(Tween.EASE_OUT)
			
			tween.tween_property(self, "rotation_degrees", Vector3.ZERO, 0.5)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
