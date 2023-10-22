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
		print(len(rendered_beatsheet))
		return rendered_beatsheet[timestamp.beat] + (float(beatsheet[timestamp.beat + 1])/1000.0) * timestamp.subbeat
		
	func get_seconds_elapsed_from_int(beat : int):
		return rendered_beatsheet[beat]

class StuntSheet:
	var name = "SS1"
	var beats = 0
