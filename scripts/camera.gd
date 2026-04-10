extends Node3D

@onready var crowd_manager: Node = $"../CrowdManager"
@onready var gm: Node = $"../GameManager"

var mouse_sensitivity := 0.001
var twist_input := 0.0
var zoom_speed := 45.0
var rotation_speed := 0.005
var zooming := false
var moving := false
var selection_mode := false
var original_basis : Basis

@onready var camera := $Camera3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Hold right click to move camera
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and !zooming and !selection_mode:
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
			if event.button_index == MOUSE_BUTTON_LEFT and event.double_click and !zooming and !selection_mode:
				get_tree().call_group("tweens", "stop_all")
				
				var tween = get_tree().create_tween()
				tween.set_trans(Tween.TRANS_QUAD)
				tween.set_ease(Tween.EASE_OUT)
				
				tween.tween_property(self, "rotation_degrees", Vector3.ZERO, 0.5)
			
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and selection_mode:
				_try_select_npc(event.position)
				return
			
			if moving:
				return
				
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				zooming = true
				original_basis = camera.global_transform.basis
				
				var tween = get_tree().create_tween()
				tween.set_trans(Tween.TRANS_QUAD)
				tween.set_ease(Tween.EASE_OUT)
				tween.tween_property(camera, "fov", clamp(camera.fov - zoom_speed, 30, 90), 0.5)
			elif event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed and zooming:
				zooming = false
				var tween = get_tree().create_tween()
				tween.set_trans(Tween.TRANS_QUAD)
				tween.set_ease(Tween.EASE_OUT)
				tween.tween_property(camera, "fov", 75, 0.5)
				camera.global_transform.basis = original_basis

func _try_select_npc(mouse_pos: Vector2) -> void:
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + camera.project_ray_normal(mouse_pos) * 1000.0
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := space_state.intersect_ray(query)
	
	for npc in crowd_manager.get_characters():
		npc.set_selected(false)
	
	if result and result.has("collider") and result.collider is Character:
		var npc: Character = result.collider
		npc.selected = true
		gm.register_guess(npc, crowd_manager)
		
		if crowd_manager.is_player(npc):
			print("You selected the PLAYER!")
		else:
			print ("Selected NPC: ", npc.name)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_mode") and !zooming:
		selection_mode = !selection_mode
		crowd_manager.set_frozen(selection_mode)
		print("Selection mode: ", selection_mode)
	
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
