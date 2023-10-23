extends Control

@onready
var loader = $"../../Director/Loader"

@onready
var show_list = $"Content/Show List"
@onready
var info_label = $Content/Info

func _on_highstepper_button_pressed():
	$"Content/Highstepper Container/Highstepper Viewport/Highstepper/Animator".play("spin")


func _on_show_list_item_selected(index):
	$"Content/Highstepper Container/Highstepper Viewport/Highstepper/Animator".play("spin_loop")

func reset():
	$"Content/Highstepper Container/Highstepper Viewport/Highstepper/Animator".stop()
	show_list.deselect_all()
	info_label.text = "Select a show from the list below."
	loader.reset()
