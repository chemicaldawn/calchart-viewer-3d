extends Node

func get_header(level : String, source : String):
	
	var time = Time.get_time_dict_from_system()
	return "[" + "%02d:%02d:%02d" % [time.hour, time.minute, time.second] + "] " + "[" + source.to_upper() + "/" + level.to_upper() + "]: "

func info(source : String, message : String):
	print(get_header("INFO",source) + message)

func warn(source : String, message : String):
	print(get_header("WARN",source) + message)
