extends Control

var selected = Color.WHITE
var hover = Color(1,1,1,0.7)
var unselected = Color(1,1,1,0.4)
var disabled = Color(1,1,1,0.1)

enum STATE {
	SELECTED,
	UNSELECTED,
	DISABLED
}

var DEFAULT_MODULATE = {
	STATE.SELECTED: selected,
	STATE.UNSELECTED: unselected,
	STATE.DISABLED: disabled
}

@onready
var button = $Button
@onready
var view_options = $".."
@onready
var camera = $"../../../../Camera"

@export
var camera_mode : CalChart.CAMERA_MODE = CalChart.CAMERA_MODE.FREE
@export
var state : STATE = STATE.UNSELECTED

# Called when the node enters the scene tree for the first time.
func _ready():
	self.modulate = DEFAULT_MODULATE[self.state]
	
	button.mouse_entered.connect(_on_button_mouse_entered)
	button.mouse_exited.connect(_on_button_mouse_exited)
	button.pressed.connect(_on_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_mouse_entered():
	if(state == STATE.UNSELECTED):
		self.modulate = hover

func _on_button_mouse_exited():
	if(state == STATE.UNSELECTED):
		self.modulate = unselected
	
func _on_button_pressed():
	if(state == STATE.UNSELECTED):
		clear_buttons()
		self.state = STATE.SELECTED
		self.modulate = selected
		
		camera.change_mode(self.camera_mode)
	
func clear_buttons():
	for child in view_options.get_children():
		if(!child.name.contains("Divider")):
			if(child.state != STATE.DISABLED):
				child.state = STATE.UNSELECTED
				child.modulate = unselected
