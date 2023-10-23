extends Node

@onready
var loader = $"../Loader"

@onready
var list_request = $"List Request"
@onready
var show_request = $"Show Request"
@onready
var audio_request = $"Audio Request"

@onready
var show_list: ItemList = $"../../UI/Main Menu/Content/Show List"
@onready
var audio_player = $"../../World/AudioStreamPlayer"
@onready
var info : Label = $"../../UI/Main Menu/Content/Info"

var shows = {}
var audio_url = ""

func _ready():
	Logger.info("NETWORK","Requesting shows list...")
	list_request.request("https://calchart-server.herokuapp.com/list/")

func _on_show_list_item_selected(index):
	
	var selected_show = shows[index]["slug"]
	show_list.mouse_filter = show_list.MOUSE_FILTER_IGNORE
	
	Logger.info("NETWORK","Requesting " + shows[index]["name"] + "...")
	show_request.request("https://calchart-server.herokuapp.com/get/" + selected_show + "/")
	
	info.text = "Downloading " + shows[index]["name"] + "..."


func _on_list_request_request_completed(result, response_code, headers, body):
	
	Logger.info("NETWORK","Shows list recieved.")
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	shows = json["shows"]
	
	for show in shows:
		show_list.add_item(show["name"])
			
	info.text = "Select a show from the list below."
	$"../../UI/Main Menu/Main Menu Animator".play("show_fade")

func _on_show_request_request_completed(result, response_code, headers, body):
	
	Logger.info("NETWORK","Show recieved.")
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	info.text = "Populating field..."
				
	audio_url = json["audio"]
	
	Logger.info("NETWORK","Requesting show audio file...")
	audio_request.set_download_file("user://audio.mp3")
	audio_request.request(audio_url)
	
	loader.load_show(json)
	$"../../UI/Main Menu/Main Menu Animator".play("transition")


func _on_audio_request_request_completed(result, response_code, headers, body):
	
	Logger.info("NETWORK","Audio recieved.")
	
	var audio_file = FileAccess.open("user://audio.mp3", FileAccess.READ)
	var sound = AudioStreamMP3.new()
	sound.data = audio_file.get_buffer(audio_file.get_length())
	
	audio_player.stream = sound
