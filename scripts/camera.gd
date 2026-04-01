extends Node3D

var mouse_sensitivity := 0.001
var twist_input := 0.0
var zoom_speed := 45.0
var rotation_speed := 0.005
var zooming := false
var moving := false
var original_basis : Basis

@onready var camera := $Camera3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Hold right click to move camera
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and !zooming:
		moving = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		moving = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	rotate_y(twist_input)
	twist_input = 0.0
	
	if zooming:
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_dir = camera.project_ray_normal(mouse_pos)
		
		var target_point = ray_origin + ray_dir * 10.0
		
		var target_basis = Transform3D().looking_at(target_point - camera.global_transform.origin, Vector3.UP).basis
		camera.global_transform.basis = camera.global_transform.basis.slerp(target_basis, 5 * delta)

func _input(event):
	# Double click to return to original position
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.double_click and !zooming:
			get_tree().call_group("tweens", "stop_all")
			
			var tween = get_tree().create_tween()
			tween.set_trans(Tween.TRANS_QUAD)
			tween.set_ease(Tween.EASE_OUT)
			
			tween.tween_property(self, "rotation_degrees", Vector3.ZERO, 0.5)
		
		if moving:
			return
			
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			zooming = true
			original_basis = camera.global_transform.basis
			
			var tween = get_tree().create_tween()
			tween.set_trans(Tween.TRANS_QUAD)
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(camera, "fov", clamp(camera.fov - zoom_speed, 30, 90), 0.5)
		elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and zooming:
			zooming = false
			camera.fov = 75
			camera.global_transform.basis = original_basis

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
