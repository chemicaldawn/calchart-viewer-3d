extends Node

func _ready():
	
	Logger.info("CONFIGURATION","Creating configuration objects...")
	
	var settings = CalChart.Configuration.new(
		"settings",
		[
			CalChart.ConfigurationOption.new(
				"marcher_scale", CalChart.CONFIGURATION_TYPE.DECIMAL, 1.0
			)
		]
	)
	
	Logger.info("CONFIGURATION","Loading configuration...")
	
	settings.load()
	
