extends Control

func _ready():
	$VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")

func _on_options_button_pressed():
	var options_scene = load("res://scenes/Menu/options.tscn").instantiate()
	get_tree().current_scene.add_child(options_scene)
	

func _on_quit_button_pressed():
	get_tree().quit()

