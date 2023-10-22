extends Control

func _on_highstepper_button_pressed():
	$"Content/Highstepper Container/Highstepper Viewport/Highstepper/Animator".play("spin")


func _on_show_list_item_selected(index):
	$"Content/Highstepper Container/Highstepper Viewport/Highstepper/Animator".play("spin_loop")
