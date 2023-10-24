extends Node

# this singleton holds classes so they can be accessed from anywhere 
enum CAMERA_MODE {
	FREE,
	SPECTATOR,
	TOPDOWN,
	FIRSTPERSON,
	THIRDPERSON,
	SIMULATOR
}

class MusicTimestamp:
	var beat : int = 1
	var subbeat : float = 0
	
	func normalize(show : CalChart.Show):
		
		if(beat > show.total_beats):
			beat = show.total_beats
		if(beat < 1):
			beat = 1
			
		return self
	
	func advance_beat(beats : int):
		subbeat = 0
		beat += beats
	
	func advance_sheet(show : CalChart.Show, sheets : int):
		
		var sheet_dict = show.get_sheet(self)
		beat += (sheet_dict["sheet"].beats - sheet_dict["relative_beat"] + 1)
		
		subbeat = 0
		
	func rewind_sheet(show : CalChart.Show, sheets : int):
		
		var sheet_dict = show.get_sheet(self)
		var alt_sheet_dict = show.get_sheet(self,-1)
		
		beat -= sheet_dict["relative_beat"]
		beat -= alt_sheet_dict["sheet"].beats
		beat += 1
		
		subbeat = 0

class Show:
	var show_name = "Show Name"
	var year = "2000"
	
	var sheets = []
	
	# contains the length in milliseconds of each beat
	var beatsheet = []
	
	# contains the total elapsed length at each beat
	var rendered_beatsheet = []
	
	var total_beats = 0
	
	func get_sheet(timestamp: MusicTimestamp, offset : int = 0):
		
		var beat = timestamp.beat
		var sheet_index = 0
		
		while beat >= 0:
			
			if(beat - sheets[sheet_index].beats <= 0):
				return {
					"sheet" : sheets[sheet_index + offset],
					"sheet_number" : sheet_index + 1,
					"relative_beat" : beat
					}
			else:
				beat -= sheets[sheet_index].beats
			
			sheet_index += 1
			
	func get_seconds_elapsed(timestamp: MusicTimestamp):
		return rendered_beatsheet[timestamp.beat] + (float(beatsheet[timestamp.beat + 1])/1000.0) * timestamp.subbeat
		
	func get_seconds_elapsed_from_int(beat : int):
		return rendered_beatsheet[beat]

class StuntSheet:
	var name = "SS1"
	var beats = 0
	
enum CONFIGURATION_TYPE {
	DECIMAL,
	INTEGER,
	MULTI_SELECT
}

class Configuration:
	
	func _init(new_id : String, new_options : Array):
		
		id = new_id
		
		for option in new_options:
			options[option.id] = option
	
	var id = "configuration"
	var options = {}
	
	func set_option(option_id : String, value):
		options[option_id].value = value
	
	func serialize():
		
		var serial = {}
		
		for option in options.values():
			serial[option.id] = option.get_iterable()
			
		return JSON.stringify(serial)
		
	func deserialize(json_string : String):
		
		var serial = JSON.parse_string(json_string)
		
		for option in serial.values():
			
			if(option.id in options.keys()):
				options[option["id"]] = ConfigurationOption.new(option["id"],option["type"],option["value"])
	
	func save():
		var config_file = FileAccess.open("user://" + id + ".json", FileAccess.WRITE)
		config_file.store_string(serialize())
		
	func load():
		var config_file = FileAccess.open("user://" + id + ".json", FileAccess.READ)
		deserialize(config_file.get_as_text())
	
class ConfigurationOption:
	
	func _init(option_id : String, option_type : CONFIGURATION_TYPE, option_value):
		id = option_id
		type = option_type
		value = option_value
	
	var id = "configuration_option"
	var type = CONFIGURATION_TYPE.DECIMAL
	var value = 0
	
	var linked_node = null
	var linked_function = null
	
	func get_iterable():
		return {
			"id": id,
			"type": type,
			"value": value
		}
		
	func create_linked_node():
		var node_path = "res://configuration/nodes/"
		
		match type:
			CONFIGURATION_TYPE.DECIMAL:
				node_path += "decimal"
				
		node_path += ".tscn"
	
	func serialize():
		return JSON.stringify(get_iterable())
