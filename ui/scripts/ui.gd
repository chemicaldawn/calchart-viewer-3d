extends Control

@onready
var agent_director = $"../Director/Agent Director"
@onready
var slider = $"Viewer Controls/Navbar/Scrubber/Slider"
@onready
var audio : AudioStreamPlayer = $"../World/AudioStreamPlayer"
@onready
var volume_slider = $"Viewer Controls/Navbar/Volume/Volume Slider"

var input = false
var restore_active_playback = false

func _process(delta):
	# logarithmically accurate volume slider wow so sexy
	audio.volume_db = (43*(log(volume_slider.value + 1)/log(10)) - 80)

func _on_slider_drag_started():
	
	restore_active_playback = agent_director.active_playback
	agent_director.stop_active_playback()
	
	load_slider_timestamp()
	input = true
	
func _on_slider_drag_ended(value_changed):
	input = false
	
	if(restore_active_playback):
		agent_director.start_active_playback()

func _on_slider_value_changed(value):
	if(input):
		load_slider_timestamp()

func load_slider_timestamp():
	agent_director.current_timestamp.beat = int(slider.value)
	agent_director.load_timestamp(agent_director.current_timestamp)
