extends Node

var Agent = preload("res://world/scenes/agent.tscn")

@onready
var agent_director = $"../Agent Director"
@onready
var agent_container = $"../../World/Agents"
@onready
var view_options = $"../../UI/Viewer Controls/Toolbar/View Options"
@onready
var show_label = $"../../UI/Viewer Controls/Toolbar/Title Bar/Show Name"
@onready
var year_label = $"../../UI/Viewer Controls/Toolbar/Title Bar/Year"
@onready
var slider : Slider = $"../../UI/Viewer Controls/Navbar/Scrubber/Slider"
@onready
var highlight_dropdown : OptionButton = $"../../UI/Tab Menu/Background/Scene Options/Highlight/OptionButton"

func load_show(data_recieved):
	
	Logger.info("LOADER","Loading show...")
	
	create_show_objects(data_recieved["viewer"]["show"],data_recieved["beats"])
	populate_agents(data_recieved["viewer"]["show"])
	
	agent_director.load_timestamp(CalChart.MusicTimestamp.new())
	agent_director.stop()

func create_show_objects(data: Dictionary, beat_data : String):
	
	Logger.info("LOADER","Loading show objects into memory...")
	
	var show = CalChart.Show.new()
	show.show_name = data["title"]
	show.year = data["year"]
	
	show_label.text = show.show_name
	year_label.text = show.year
	
	var stuntsheet_index = 0
	var total_stuntsheet_beats = 0
	
	for stuntsheet in data["sheets"]:
		
		var sheet_object = CalChart.StuntSheet.new()
		sheet_object.name = "SS" + str(stuntsheet_index)
		sheet_object.beats = int(stuntsheet["beats"])
		
		show.sheets.append(sheet_object)
		
		stuntsheet_index += 1
		total_stuntsheet_beats += stuntsheet["beats"]
		
	show.beatsheet = load_beatsheet(beat_data)
	show.rendered_beatsheet = render_beatsheet(show.beatsheet)
	
	var total_beatsheet_beats = len(show.rendered_beatsheet) - 2
	var total_beats = 0
	
	if(total_beatsheet_beats <= total_stuntsheet_beats):
		total_beats = total_beatsheet_beats
		
	if(total_stuntsheet_beats < total_beatsheet_beats):
		total_beats = total_stuntsheet_beats
	
	show.total_beats = total_beats
	slider.max_value = total_beats
	agent_director.current_show = show

func populate_agents(data):
	
	Logger.info("LOADER","Populating field...")
	var show = agent_director.current_show
	
	# initial population - populate field with named agents
	for label in data["labels"]:
		
		Logger.info("LOADER","Setting up agent " + label)
		
		var agent = Agent.instantiate()
		var animation : Animation  = Animation.new()
		animation.add_track(Animation.TYPE_POSITION_3D)
		animation.add_track(Animation.TYPE_ROTATION_3D)
		animation.set_length(1000)
		animation.track_set_path(0,".")
		animation.track_set_path(1,".")
		
		var animator : AnimationPlayer = agent.get_node("Animator")
		
		# iterate through all stuntsheets and insert animation keyframes
		var stuntsheet_beat_index = 1
		
		for stuntsheet in data["sheets"]:
			
			# protects against crashes caused by empty stuntsheets at the end of shows
			if((len(show.rendered_beatsheet)) > (stuntsheet_beat_index + stuntsheet["beats"])):
				
				# fill in stuntsheet movements
				var movement_beat_index = 0
				
				for movement in stuntsheet["movements"][label]:
					
					var start_pos = Vector2.ZERO
					var end_pos = Vector2.ZERO
					var start_rotation = PI
					var end_rotation = PI
					
					# sets start and end pos to same if mark. if even, uses actual start and end pos.
					if(movement["type"] == "mark"):
						start_pos = Vector2(movement["x"],movement["y"])
						end_pos = start_pos
						
						start_rotation = PI + deg_to_rad(movement["facing"])
						end_rotation = PI + deg_to_rad(movement["facing"])
					
					elif(movement["type"] == "even"):
						start_pos = Vector2(movement["x1"],movement["y1"])
						end_pos = Vector2(movement["x2"],movement["y2"])
						
						start_rotation = PI + deg_to_rad(movement["facing"])
						end_rotation = PI + deg_to_rad(movement["facing"])
						
					elif(movement["type"] == "arc"):
						start_pos = Vector2(movement["start_x"],movement["start_y"])
						end_pos = Vector2(movement["center_x"],movement["center_y"])
					
					# add keyframe
					var start_time = show.get_seconds_elapsed_from_int(stuntsheet_beat_index + movement_beat_index)
					var end_time = show.get_seconds_elapsed_from_int(stuntsheet_beat_index + movement_beat_index + int(movement["beats"]))
					
					animation.track_insert_key(0,start_time,Vector3(start_pos.x,0,start_pos.y))
					animation.track_insert_key(0,end_time,Vector3(start_pos.x,0,start_pos.y))
					
					animation.track_insert_key(1,end_time - 0.1,Quaternion.from_euler(Vector3(0,start_rotation,0)))
					animation.track_insert_key(1,end_time,Quaternion.from_euler(Vector3(0,end_rotation,0)))
					
					movement_beat_index += int(movement["beats"])
					
				stuntsheet_beat_index += int(stuntsheet["beats"])
		
		agent.set_name(label)
		highlight_dropdown.add_item(label)
		
		var library = AnimationLibrary.new()
		library.add_animation("movements",animation)
		
		animator.add_animation_library("rendered_show",library)
		animator.set_current_animation("rendered_show/movements")
		
		agent_container.add_child(agent)
	
func load_beatsheet(data):
	
	Logger.info("LOADER","Loading beatsheet into memory...")
	
	var json = JSON.new()
	var error = json.parse(data)
	
	if(error == OK):
		var beat_data = json.data["beats"]
		
		if(beat_data[0] != 0):
			beat_data.push_front(0)

		return beat_data
		
func render_beatsheet(beatsheet : Array):
	
	var rendered_beatsheet = []
	
	for i in range(0,beatsheet.size()):
		
		rendered_beatsheet.append(0)
		
		for j in range(0,i+1):
			
			rendered_beatsheet[i] += float(beatsheet[j])/1000.0

	return rendered_beatsheet
	
func reset():
	for child in agent_container.get_children():
		child.reparent(null)
		child.queue_free()
		
	slider.value = 1
		
	agent_director.highlighted_agent = null
	view_options.agent_deselected()
