extends Node

var current_show = CalChart.Show.new()
var current_timestamp = CalChart.MusicTimestamp.new()

func multiplier_from_beat(beat : int): return (1/(current_show.beatsheet[beat]/1000))

var active_playback = false
var is_audio_loaded = false

var highlighted_agent : Node3D = null

@onready
var agent_container = $"../../World/Agents"
@onready
var movement_controller = $"../Movement Controller"

@onready
var play_icon : TextureRect = $"../../UI/Viewer Controls/Navbar/Controls/Play/Play Icon"
@onready
var pause_icon : TextureRect = $"../../UI/Viewer Controls/Navbar/Controls/Play/Pause Icon"

@onready
var sheet_label : Label = $"../../UI/Viewer Controls/Navbar/Stunt Sheet"
@onready
var beat_label : Label = $"../../UI/Viewer Controls/Navbar/Beat"
@onready
var slider : Slider = $"../../UI/Viewer Controls/Navbar/Scrubber/Slider"
@onready
var audio_player = $"../../World/AudioStreamPlayer"
@onready
var dot_highlight_dropdown : OptionButton = $"../../UI/Tab Menu/Background/Scene Options/Highlight/OptionButton"

func play():
	
	load_timestamp(current_timestamp)
	var time = current_show.get_seconds_elapsed(current_timestamp)
	
	for agent in agent_container.get_children():
		
		agent.get_node("Animator").seek(time)
		agent.get_node("Animator").play()
		
	audio_player.play(float(time))
	
	active_playback = true
		
func stop():
	
	load_timestamp(current_timestamp)
	var time = current_show.get_seconds_elapsed(current_timestamp)
	
	for agent in agent_container.get_children():
		
		agent.get_node("Animator").pause()
		
	audio_player.stop()
		
	active_playback = false

func load_timestamp(timestamp : CalChart.MusicTimestamp, sync = false, update_slider = false):
	
	current_timestamp = timestamp.normalize(current_show)
	var time = current_show.get_seconds_elapsed(current_timestamp)
	
	for agent in agent_container.get_children():
		
		var animator : AnimationPlayer = agent.get_node("Animator")
		animator.seek(time,true)
		
	update_navbar(timestamp)
	
	if(sync && active_playback):
		audio_player.play(time)

func update_navbar(timestamp : CalChart.MusicTimestamp):
	
	var sheet_dict = current_show.get_sheet(current_timestamp)
	
	sheet_label.text = "Stunt Sheet " + str(sheet_dict["sheet_number"])
	
	var beat = sheet_dict["relative_beat"] - 1
	
	if(beat == 0):
		beat = "Hup"
	else:
		beat = str(beat)
	
	beat_label.text = "Beat " + beat

func update_slider():
	slider.value = current_timestamp.beat + current_timestamp.subbeat

func _process(delta):
	
	if(Input.is_action_just_pressed("Skip Left")):
		
		if(Input.is_action_pressed("Control")):
			_on_skip_backward_pressed()
		else:
			_on_step_backward_pressed()
			
	if(Input.is_action_just_pressed("Skip Right")):
		
		if(Input.is_action_pressed("Control")):
			_on_skip_forward_pressed()
		else:
			_on_step_forward_pressed()
		
	if(!movement_controller.mouse_locked):
		
		if(Input.is_action_just_pressed("Move Camera Up")):
			toggle_active_playback()

	# active playback 
	if(active_playback):
		current_timestamp.subbeat += (delta) * multiplier_from_beat(current_timestamp.beat)
		
		if(current_timestamp.subbeat >= 1):
			current_timestamp.beat += 1
			current_timestamp.subbeat -= 1
			
		load_timestamp(current_timestamp)
		update_slider()
		

func start_active_playback():
	play()
	play_icon.visible = false
	pause_icon.visible = true

func stop_active_playback():
	stop()
	play_icon.visible = true
	pause_icon.visible = false
	
func toggle_active_playback():
	if(active_playback):
		stop_active_playback()
	else:
		start_active_playback()

# controls
func _on_step_forward_pressed():
	current_timestamp.advance_beat(1)
	
	load_timestamp(current_timestamp, true)
	update_slider()

func _on_step_backward_pressed():
	current_timestamp.advance_beat(-1)
	
	load_timestamp(current_timestamp, true)
	update_slider()

func _on_skip_forward_pressed():
	current_timestamp.advance_sheet(current_show,1)
	
	load_timestamp(current_timestamp, true)
	update_slider()

func _on_skip_backward_pressed():
	current_timestamp.rewind_sheet(current_show,1)
	
	load_timestamp(current_timestamp, true)
	update_slider()
	
func deselect_all_agents():
	for child in agent_container.get_children():
		child.deselect()

func _on_option_button_item_selected(index):
	var dot = dot_highlight_dropdown.get_item_text(index)
	
	deselect_all_agents()
	highlighted_agent = agent_container.get_node(dot)
	highlighted_agent.select()


func _on_play_button_pressed():
	toggle_active_playback()
