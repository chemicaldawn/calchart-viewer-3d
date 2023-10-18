extends Control

@onready
var field = get_parent().get_node("Field")
@onready
var slider = get_node("Navbar/Scrubber/Slider")

var input = false
var restore_active_playback = false

func _on_slider_drag_started():
	
	restore_active_playback = field.active_playback
	field.stop_active_playback()
	
	load_slider_timestamp()
	input = true
	
func _on_slider_drag_ended(value_changed):
	input = false
	
	if(restore_active_playback):
		field.start_active_playback()

func _on_slider_value_changed(value):
	if(input):
		load_slider_timestamp()

func load_slider_timestamp():
	field.current_timestamp.beat = int(slider.value)
	field.load_timestamp(field.current_timestamp)
