extends ColorRect

var extended = false

var carefree = preload("res://ui/accessibility/carefree.mp3")

@onready
var animator : AnimationPlayer = get_node("Tab Animator")
@onready
var audio_player : AudioStreamPlayer = $"../../../World/AudioStreamPlayer"

enum BUTTON_STATE {
	SCENE,
	SETTINGS
}

var state = BUTTON_STATE.SCENE

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

func _on_scene_pressed():
	if(state != BUTTON_STATE.SCENE):
		state = BUTTON_STATE.SCENE
		
		animator.play_backwards("selector_bounce")

func _on_settings_pressed():
	if(state != BUTTON_STATE.SETTINGS):
		state = BUTTON_STATE.SETTINGS
		
		animator.play("selector_bounce")

func _on_line_edit_text_changed(new_text):
	var scale = float(new_text)
	
	for child in $"../../../World/Agents".get_children():
		child.scale = (Vector3.ONE * scale)
