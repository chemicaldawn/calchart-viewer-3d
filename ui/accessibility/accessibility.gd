extends Control

var carefree = preload("res://ui/accessibility/carefree.mp3")

@onready
var audio_player : AudioStreamPlayer = $"../../../../../World/AudioStreamPlayer"

func _on_check_box_toggled(button_pressed):
	
	if(button_pressed):
		audio_player.stream = carefree
	else:
		var audio_file = FileAccess.open("user://audio.mp3", FileAccess.READ)
		var sound = AudioStreamMP3.new()
		sound.data = audio_file.get_buffer(audio_file.get_length())
			
		audio_player.stream = sound
