extends Control

@onready
var title_bar_animator = $"Title Bar Animator"
@onready
var main_menu_animator = $"../../../Main Menu/Main Menu Animator"

func _on_back_button_mouse_entered():
	title_bar_animator.play("back_button_slide")

func _on_back_button_mouse_exited():
	title_bar_animator.play_backwards("back_button_slide")

func _on_back_button_pressed():
	main_menu_animator.current_animation = "transition"
	main_menu_animator.seek(0.5)
	main_menu_animator.play_backwards()
	
	$"../../../../Director/Agent Director".stop_active_playback()
	
	$"../../../Tab Menu/Background/Scene Options/Highlight/OptionButton".select(0)
	
	$"../../../Main Menu".reset()
