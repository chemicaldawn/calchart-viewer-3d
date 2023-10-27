extends Node

@onready
var camera : Camera3D = $"../../World/Camera"
@onready
var agent_director = $"../Agent Director"

var speed_scalar = 20
var angular_scalar = 0.001
var camera_floor = 5

var camera_mode : CalChart.CAMERA_MODE = CalChart.CAMERA_MODE.FREE
var mouse_locked = false

@onready
var free_view_position : Vector3 = camera.position
@onready
var free_view_rotation : Vector3 = camera.rotation

@onready
var focus_indicator_animator = $"../../UI/Focus Detector/Focus Indicator Animator"

func _process(delta):
	
	# focus fix for chromium-based browsers
	if(mouse_locked && (Input.get_mouse_mode() == 0)):
		break_focus()
	
	# free camera movement processing
	if (camera_mode == CalChart.CAMERA_MODE.FREE) and (mouse_locked == true):
		var planar_vector = Vector2.ZERO
		var vertical_scalar = 0
		
		if(Input.is_action_pressed("Move Camera Forward")):
			planar_vector += Vector2(0,-1)
		if(Input.is_action_pressed("Move Camera Backward")):
			planar_vector += Vector2(0,1)
		if(Input.is_action_pressed("Move Camera Left")):
			planar_vector += Vector2(-1,0)
		if(Input.is_action_pressed("Move Camera Right")):
			planar_vector += Vector2(1,0)
			
		if(Input.is_action_pressed("Move Camera Up")):
			vertical_scalar += 1
		if(Input.is_action_pressed("Move Camera Down")):
			vertical_scalar -= 1
			
		planar_vector = planar_vector.normalized()
		planar_vector = planar_vector.rotated(-camera.rotation.y)

		camera.position.x += planar_vector.x * speed_scalar * delta
		camera.position.z += planar_vector.y * speed_scalar * delta
		
		camera.position.y += vertical_scalar * speed_scalar * delta
		
		if(camera.position.y < camera_floor):
			camera.position.y = camera_floor
		
	if (camera_mode == CalChart.CAMERA_MODE.FIRSTPERSON):
		camera.position = agent_director.highlighted_agent.position + Vector3(0,1.5,0)
		#camera.rotation = agent_director.highlighted_agent.rotation
	
	if (camera_mode == CalChart.CAMERA_MODE.THIRDPERSON):
		camera.position = agent_director.highlighted_agent.position + Vector3(0,3,0)
		camera.position -= Vector3(0,0,-2).rotated(Vector3(0,1,0),camera.rotation.y)
	
func _input(event):
	if(mouse_locked):
		if((camera_mode == CalChart.CAMERA_MODE.FREE) || (camera_mode == CalChart.CAMERA_MODE.SPECTATOR) || (camera_mode == CalChart.CAMERA_MODE.FIRSTPERSON) || (camera_mode == CalChart.CAMERA_MODE.THIRDPERSON)):
			if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				camera.rotation.x -= event.relative.y * angular_scalar
				camera.rotation.y -= event.relative.x * angular_scalar
			
		if(Input.is_action_just_pressed("Break Cursor")):
			break_focus()
			
	
# when main window is clicked
func _on_focus_detector_pressed():
	focus()
	
func focus():
	mouse_locked = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	focus_indicator_animator.play("focus")
	
func break_focus():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_locked = false
	
	focus_indicator_animator.play_backwards("focus")

func change_mode(mode : CalChart.CAMERA_MODE):
	
	if(agent_director.highlighted_agent):
		agent_director.highlighted_agent.visible = true
	
	if(camera_mode == CalChart.CAMERA_MODE.FREE):
		free_view_position = camera.position
		free_view_rotation = camera.rotation
	
	match mode:
		
		CalChart.CAMERA_MODE.FREE:
			camera.position = free_view_position
			camera.rotation = free_view_rotation
			
		CalChart.CAMERA_MODE.SPECTATOR:
			camera.position = Vector3(80,40,100)
			camera.rotation = Vector3(-2*PI/9,0,0)
			
		CalChart.CAMERA_MODE.TOPDOWN:
			camera.position = Vector3(80,80,42.5)
			camera.rotation = Vector3(-PI/2,0,0)
			
		CalChart.CAMERA_MODE.FIRSTPERSON:
			agent_director.highlighted_agent.visible = false
	
	camera_mode = mode


