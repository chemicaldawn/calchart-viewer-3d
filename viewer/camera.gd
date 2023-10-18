extends Camera3D

@onready
var field = $"../Field"

var speed_scalar = 30
var angular_scalar = 0.001

var camera_mode : CalChart.CAMERA_MODE = CalChart.CAMERA_MODE.FREE
var mouse_locked = false

var free_view_position : Vector3 = self.position
var free_view_rotation : Vector3 = self.rotation

func _process(delta):
	
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
		planar_vector = planar_vector.rotated(-self.rotation.y)

		self.position.x += planar_vector.x * speed_scalar * delta
		self.position.z += planar_vector.y * speed_scalar * delta
		
		self.position.y += vertical_scalar * speed_scalar * delta
		
	if (camera_mode == CalChart.CAMERA_MODE.FIRSTPERSON):
		self.position = field.highlighted_agent.position + Vector3(0,1.7,0)
		#self.rotation = field.highlighted_agent.rotation
	
func _input(event):
	if(mouse_locked):
		if((camera_mode == CalChart.CAMERA_MODE.FREE) || (camera_mode == CalChart.CAMERA_MODE.SPECTATOR) || (camera_mode == CalChart.CAMERA_MODE.FIRSTPERSON)):
			if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				self.rotation.x -= event.relative.y * angular_scalar
				self.rotation.y -= event.relative.x * angular_scalar
			
		if(Input.is_action_just_pressed("Break Cursor")):
			
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_locked = false
	
# when main window is clicked
func _on_focus_detector_pressed():
	mouse_locked = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func change_mode(mode : CalChart.CAMERA_MODE):
	
	if(field.highlighted_agent):
		field.highlighted_agent.visible = true
	
	if(camera_mode == CalChart.CAMERA_MODE.FREE):
		free_view_position = self.position
		free_view_rotation = self.rotation
		
		print(free_view_position)
		print(free_view_rotation)
	
	match mode:
		
		CalChart.CAMERA_MODE.FREE:
			self.position = free_view_position
			self.rotation = free_view_rotation
			
		CalChart.CAMERA_MODE.SPECTATOR:
			self.position = Vector3(80,40,100)
			self.rotation = Vector3(-2*PI/9,0,0)
			
		CalChart.CAMERA_MODE.TOPDOWN:
			self.position = Vector3(80,80,42.5)
			self.rotation = Vector3(-PI/2,0,0)
			
		CalChart.CAMERA_MODE.FIRSTPERSON:
			field.highlighted_agent.visible = false
	
	camera_mode = mode
