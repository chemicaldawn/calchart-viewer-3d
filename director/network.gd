extends HTTPRequest

@onready
var show_list = $"../../Viewer/UI/Main Menu/Anchor/Show List"
@onready
var audio_player = $"../../Viewer/AudioStreamPlayer"
@onready
var info : Label = $"../../Viewer/UI/Main Menu/Anchor/Info"

var shows = {}
var audio_url = ""

func _ready():
	request_completed.connect(_on_request_completed)
	request("https://calchart-server.herokuapp.com/list/")
	
func _on_request_completed(result, response_code, headers, body):
	
	var content_type = "unknown"
	
	for header in headers:
		if("Content-Type" in header):
			content_type = header.split(" ")[1] 
	
	print(content_type)
	
	match content_type:
		
		"application/json":
			var json = JSON.parse_string(body.get_string_from_utf8())

			# assume shows list
			if(json.has("shows")):
				
				shows = json["shows"]
				for show in shows:
					
					show_list.add_item(show["name"])
					
				info.text = "Select a show from the list below."
			
			# assume show
			elif(json.has("viewer")):
				info.text = "Populating field..."
				
				audio_url = json["audio"]
				
				set_download_file("user://audio.mp3")
				request(audio_url)
				
				$"../Loader".load_show(json)
				$"../../Viewer/UI/Main Menu/AnimationPlayer".play("transition")
				
		"audio/mpeg":
			
			var audio_file = FileAccess.open("user://audio.mp3", FileAccess.READ)
			var sound = AudioStreamMP3.new()
			sound.data = audio_file.get_buffer(audio_file.get_length())
			
			audio_player.stream = sound

func _on_show_list_item_selected(index):
	
	var selected_show = shows[index]["slug"]
	show_list.mouse_filter = show_list.MOUSE_FILTER_IGNORE
	request("https://calchart-server.herokuapp.com/get/" + selected_show + "/")
	
	info.text = "Downloading " + shows[index]["name"] + "..."
