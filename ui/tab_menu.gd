extends ColorRect

var extended = false

@onready
var animator : AnimationPlayer = get_node("Tab Animator")

func _process(delta):
	
	if(Input.is_action_just_pressed("Toggle Menu")):
		toggle()
		
func toggle():
	extended = !extended
	animate()

func animate():
	
	if(extended):
		animator.play("slide_out")
	
	else:
		animator.play_backwards("slide_out")


func _on_texture_button_pressed():
		toggle()
