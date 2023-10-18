extends HBoxContainer

@onready
var select_dependent_mode_buttons = [
	$"First-Person View"
	#$"Third-Person View",
	#$"Cal Band Simulator"
]

func agent_selected():
	
	for button in select_dependent_mode_buttons:
		button.state = button.STATE.UNSELECTED
		button.modulate = button.unselected

func _on_option_button_item_selected(index):
	agent_selected()
